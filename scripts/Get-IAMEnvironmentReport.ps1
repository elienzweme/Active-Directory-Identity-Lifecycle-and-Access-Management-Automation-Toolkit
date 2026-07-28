#requires -Version 5.1
#requires -Modules ActiveDirectory

[CmdletBinding()]
param(
    [string]$ToolkitRoot = (Split-Path $PSScriptRoot -Parent),
    [switch]$Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module ActiveDirectory -ErrorAction Stop
Import-Module (Join-Path $ToolkitRoot 'modules\IAM-Common.psm1') -Force

$config = Import-IAMToolkitConfig -Path (
    Join-Path $ToolkitRoot 'config\IAM-Toolkit-Config.psd1'
)

$mappingPath = Join-Path $ToolkitRoot 'input\RBAC-Mapping.csv'
$reportDir   = Join-Path $ToolkitRoot 'Reports'

New-Item -Path $reportDir -ItemType Directory -Force | Out-Null

$mappings  = @(Get-IAMRbacMappings -Path $mappingPath)
$timestamp = (Get-Date).ToString('o')

$users = @(
    Get-ADUser -Filter * -Properties `
        DisplayName,
        SamAccountName,
        UserPrincipalName,
        EmployeeID,
        Department,
        Title,
        Manager,
        Enabled,
        LockedOut,
        PasswordLastSet,
        LastLogonDate,
        DistinguishedName,
        HomeDirectory,
        HomeDrive,
        MemberOf
)

$inventory    = New-Object System.Collections.Generic.List[object]
$entitlements = New-Object System.Collections.Generic.List[object]
$readiness    = New-Object System.Collections.Generic.List[object]

foreach ($user in $users) {
    $managerName = if ($user.Manager) {
        try {
            (Get-ADUser -Identity $user.Manager -ErrorAction Stop).Name
        }
        catch {
            ''
        }
    }
    else {
        ''
    }

    $groupNames = @(Get-IAMGroupNames -User $user)

    # Mappings granted by actual group membership.
    $mappedAccess = @(
        $mappings |
        Where-Object {
            $_.PSObject.Properties.Name -contains 'DepartmentGroup' -and
            -not [string]::IsNullOrWhiteSpace([string]$_.DepartmentGroup) -and
            $_.DepartmentGroup -in $groupNames
        }
    )

    # Expected mapping based on the AD Department attribute.
    $expectedMappings = @(
        $mappings |
        Where-Object {
            $_.PSObject.Properties.Name -contains 'Department' -and
            $_.Department -eq $user.Department
        }
    )

    $expectedGroup = if (
        $expectedMappings.Count -eq 1 -and
        $expectedMappings[0].PSObject.Properties.Name -contains 'DepartmentGroup'
    ) {
        [string]$expectedMappings[0].DepartmentGroup
    }
    else {
        ''
    }

    $groupCompliant = if ([string]::IsNullOrWhiteSpace([string]$user.Department)) {
        'NotApplicable'
    }
    elseif ($expectedMappings.Count -ne 1) {
        'NoUniqueMapping'
    }
    elseif ($expectedGroup -in $groupNames) {
        'Yes'
    }
    else {
        'No'
    }

    # Safely extract mapped-access values. These remain blank after a Leaver
    # when the user has no department-group memberships.
    $departmentGroups = @(
        $mappedAccess |
        Where-Object {
            $_.PSObject.Properties.Name -contains 'DepartmentGroup' -and
            -not [string]::IsNullOrWhiteSpace([string]$_.DepartmentGroup)
        } |
        Select-Object -ExpandProperty DepartmentGroup -Unique
    ) -join '; '

    $mappedDriveRoots = @(
        $mappedAccess |
        Where-Object {
            $_.PSObject.Properties.Name -contains 'MappedDriveRoot' -and
            -not [string]::IsNullOrWhiteSpace([string]$_.MappedDriveRoot)
        } |
        Select-Object -ExpandProperty MappedDriveRoot -Unique
    ) -join '; '

    $entitledFolders = @(
        $mappedAccess |
        Where-Object {
            $_.PSObject.Properties.Name -contains 'EntitledFolder' -and
            -not [string]::IsNullOrWhiteSpace([string]$_.EntitledFolder)
        } |
        Select-Object -ExpandProperty EntitledFolder -Unique
    ) -join '; '

    $driveLetters = @(
        $mappedAccess |
        Where-Object {
            $_.PSObject.Properties.Name -contains 'DepartmentDriveLetter' -and
            -not [string]::IsNullOrWhiteSpace([string]$_.DepartmentDriveLetter)
        } |
        Select-Object -ExpandProperty DepartmentDriveLetter -Unique
    ) -join '; '

    $accessLevels = @(
        $mappedAccess |
        Where-Object {
            $_.PSObject.Properties.Name -contains 'AccessLevel' -and
            -not [string]::IsNullOrWhiteSpace([string]$_.AccessLevel)
        } |
        Select-Object -ExpandProperty AccessLevel -Unique
    ) -join '; '

    $accessTypes = @(
        $mappedAccess |
        Where-Object {
            $_.PSObject.Properties.Name -contains 'AccessType' -and
            -not [string]::IsNullOrWhiteSpace([string]$_.AccessType)
        } |
        Select-Object -ExpandProperty AccessType -Unique
    ) -join '; '

    $dataOwners = @(
        $mappedAccess |
        Where-Object {
            $_.PSObject.Properties.Name -contains 'DataOwner' -and
            -not [string]::IsNullOrWhiteSpace([string]$_.DataOwner)
        } |
        Select-Object -ExpandProperty DataOwner -Unique
    ) -join '; '

    $sharePathChecks = @(
        foreach ($mapping in $mappedAccess) {
            if (
                $mapping.PSObject.Properties.Name -contains 'EntitledFolder' -and
                -not [string]::IsNullOrWhiteSpace([string]$mapping.EntitledFolder)
            ) {
                Test-Path -LiteralPath $mapping.EntitledFolder
            }
        }
    )

    $shareExists = if ($mappedAccess.Count -eq 0) {
        $false
    }
    else {
        $sharePathChecks.Count -gt 0 -and
        $sharePathChecks -notcontains $false
    }

    $privilegedGroups = @(
        $groupNames |
        Where-Object {
            $_ -in $config.PrivilegedGroups
        }
    )

    $missing = New-Object System.Collections.Generic.List[string]

    foreach ($pair in @(
        @('EmployeeID',        $user.EmployeeID),
        @('Department',        $user.Department),
        @('Title',             $user.Title),
        @('Manager',           $managerName),
        @('UserPrincipalName', $user.UserPrincipalName)
    )) {
        if ([string]::IsNullOrWhiteSpace([string]$pair[1])) {
            $missing.Add([string]$pair[0])
        }
    }

    $managed = (
        $user.DistinguishedName -like '*OU=Departments,*' -or
        -not [string]::IsNullOrWhiteSpace([string]$user.EmployeeID)
    )

    $jmlReady = if ($managed -and $missing.Count -eq 0) {
        'Yes'
    }
    elseif ($managed) {
        'No'
    }
    else {
        'NotManaged'
    }

    $inventory.Add(
        [pscustomobject][ordered]@{
            ReportTimestamp             = $timestamp
            DisplayName                 = $user.DisplayName
            SamAccountName              = $user.SamAccountName
            UserPrincipalName           = $user.UserPrincipalName
            EmployeeID                  = $user.EmployeeID
            Department                  = $user.Department
            Title                       = $user.Title
            Manager                     = $managerName
            Enabled                     = $user.Enabled
            LockedOut                   = $user.LockedOut
            PasswordLastSet             = $user.PasswordLastSet
            LastLogonDate               = $user.LastLogonDate
            HomeDirectory               = $user.HomeDirectory
            HomeDrive                   = $user.HomeDrive
            DepartmentGroup             = $departmentGroups
            DepartmentMappedDriveRoot   = $mappedDriveRoots
            DepartmentSharedDrive       = $entitledFolders
            DepartmentEntitledFolder    = $entitledFolders
            DepartmentDriveLetter       = $driveLetters
            SharedDriveAccess            = $accessLevels
            AccessType                  = $accessTypes
            DataOwner                   = $dataOwners
            OU                          = Get-IAMParentDN $user.DistinguishedName
            SecurityGroups              = $groupNames -join '; '
            PrivilegedGroups            = $privilegedGroups -join '; '
            DepartmentGroupCompliant    = $groupCompliant
            SharePathExists             = $shareExists
            JMLReady                    = $jmlReady
            MissingJMLAttributes        = $missing -join '; '
        }
    )

    foreach ($mapping in $mappings) {
        $mappingGroup = if (
            $mapping.PSObject.Properties.Name -contains 'DepartmentGroup'
        ) {
            [string]$mapping.DepartmentGroup
        }
        else {
            ''
        }

        $mappingDepartment = if (
            $mapping.PSObject.Properties.Name -contains 'Department'
        ) {
            [string]$mapping.Department
        }
        else {
            ''
        }

        $isMember = (
            -not [string]::IsNullOrWhiteSpace($mappingGroup) -and
            $mappingGroup -in $groupNames
        )

        $departmentMatches = (
            -not [string]::IsNullOrWhiteSpace($mappingDepartment) -and
            $user.Department -eq $mappingDepartment
        )

        if ($isMember -or $departmentMatches) {
            $isCompliant = $isMember -and $departmentMatches

            $reason = if ($isCompliant) {
                'Department and group membership match'
            }
            elseif ($departmentMatches -and -not $isMember) {
                'Expected department group is missing'
            }
            elseif ($isMember -and -not $departmentMatches) {
                'Group membership does not match AD Department'
            }
            else {
                'Not applicable'
            }

            $mappingFolder = if (
                $mapping.PSObject.Properties.Name -contains 'EntitledFolder'
            ) {
                [string]$mapping.EntitledFolder
            }
            else {
                ''
            }

            $entitlements.Add(
                [pscustomobject][ordered]@{
                    ReportTimestamp          = $timestamp
                    DisplayName              = $user.DisplayName
                    SamAccountName           = $user.SamAccountName
                    EmployeeID               = $user.EmployeeID
                    ADDepartment             = $user.Department
                    MappedDepartment         = $mappingDepartment
                    DepartmentGroup          = $mappingGroup
                    IsGroupMember            = $isMember
                    MappedDriveRoot          = $mapping.MappedDriveRoot
                    EntitledFolder           = $mappingFolder
                    DepartmentDriveLetter    = $mapping.DepartmentDriveLetter
                    ExpectedAccessLevel      = $mapping.AccessLevel
                    AccessType               = $mapping.AccessType
                    DataOwner                = $mapping.DataOwner
                    SharePathExists          = if ($mappingFolder) {
                        Test-Path -LiteralPath $mappingFolder
                    }
                    else {
                        $false
                    }
                    DepartmentMatchesMapping = $departmentMatches
                    EntitlementCompliant     = $isCompliant
                    ComplianceReason         = $reason
                }
            )
        }
    }

    if ($managed) {
        $readiness.Add(
            [pscustomobject][ordered]@{
                ReportTimestamp      = $timestamp
                DisplayName          = $user.DisplayName
                SamAccountName       = $user.SamAccountName
                EmployeeID           = $user.EmployeeID
                Department           = $user.Department
                Title                = $user.Title
                Manager              = $managerName
                UserPrincipalName    = $user.UserPrincipalName
                Enabled              = $user.Enabled
                OU                   = Get-IAMParentDN $user.DistinguishedName
                DepartmentGroup      = $departmentGroups
                EntitledFolder       = $entitledFolders
                JMLReady             = $jmlReady
                MissingAttributes    = $missing -join '; '
                RecommendedIdentifier = if ($user.EmployeeID) {
                    'EmployeeID'
                }
                else {
                    'SamAccountName'
                }
                RecommendedAction    = if ($jmlReady -eq 'Yes') {
                    'Ready for Mover/Leaver automation'
                }
                else {
                    "Populate: $($missing -join ', ')"
                }
            }
        )
    }
}

$inventory |
    Sort-Object Department, DisplayName |
    Export-Csv (
        Join-Path $reportDir 'AD-User-Inventory.csv'
    ) -NoTypeInformation -Encoding UTF8

$entitlements |
    Sort-Object MappedDepartment, DisplayName |
    Export-Csv (
        Join-Path $reportDir 'RBAC-Entitlement-Report.csv'
    ) -NoTypeInformation -Encoding UTF8

$readiness |
    Sort-Object Department, DisplayName |
    Export-Csv (
        Join-Path $reportDir 'JML-Readiness-Report.csv'
    ) -NoTypeInformation -Encoding UTF8

$shareReport = foreach ($mapping in $mappings) {
    $mappedRoot = if (
        $mapping.PSObject.Properties.Name -contains 'MappedDriveRoot'
    ) {
        [string]$mapping.MappedDriveRoot
    }
    else {
        ''
    }

    $entitledFolder = if (
        $mapping.PSObject.Properties.Name -contains 'EntitledFolder'
    ) {
        [string]$mapping.EntitledFolder
    }
    else {
        ''
    }

    $departmentGroup = if (
        $mapping.PSObject.Properties.Name -contains 'DepartmentGroup'
    ) {
        [string]$mapping.DepartmentGroup
    }
    else {
        ''
    }

    $shareExists  = $mappedRoot -and (Test-Path -LiteralPath $mappedRoot)
    $folderExists = $entitledFolder -and (
        Test-Path -LiteralPath $entitledFolder
    )

    $groupFound = $false
    $rights     = ''
    $accessType = ''
    $inherited  = ''
    $note       = ''

    if ($folderExists -and $departmentGroup) {
        try {
            $escapedGroup = [regex]::Escape($departmentGroup)

            $matchingRules = @(
                (Get-Acl -LiteralPath $entitledFolder).Access |
                Where-Object {
                    $_.IdentityReference.Value -match "\\$escapedGroup$"
                }
            )

            $groupFound = $matchingRules.Count -gt 0

            $rights = @(
                $matchingRules |
                Select-Object -ExpandProperty FileSystemRights -Unique
            ) -join '; '

            $accessType = @(
                $matchingRules |
                Select-Object -ExpandProperty AccessControlType -Unique
            ) -join '; '

            $inherited = @(
                $matchingRules |
                Select-Object -ExpandProperty IsInherited -Unique
            ) -join '; '
        }
        catch {
            $note = $_.Exception.Message
        }
    }

    $expectedAccess = if (
        $mapping.PSObject.Properties.Name -contains 'AccessLevel'
    ) {
        [string]$mapping.AccessLevel
    }
    else {
        ''
    }

    $permissionCompliant = (
        $folderExists -and
        $groupFound -and
        (
            [string]::IsNullOrWhiteSpace($expectedAccess) -or
            $rights -match [regex]::Escape($expectedAccess)
        )
    )

    [pscustomobject][ordered]@{
        ReportTimestamp         = $timestamp
        Department              = $mapping.Department
        DepartmentGroup         = $departmentGroup
        ShareName               = $mapping.ShareName
        MappedDriveRoot         = $mappedRoot
        EntitledFolder          = $entitledFolder
        PhysicalPath            = $mapping.PhysicalPath
        AccessLevelExpected     = $expectedAccess
        ABEExpected             = $mapping.ABEExpected
        ShareExists             = [bool]$shareExists
        FolderExists            = [bool]$folderExists
        GroupFoundInACL         = $groupFound
        ActualFileSystemRights  = $rights
        AccessControlType       = $accessType
        IsInherited             = $inherited
        PermissionCompliant     = $permissionCompliant
        ValidationComputer      = $env:COMPUTERNAME
        ValidationNote          = $note
    }
}

$shareReport |
    Export-Csv (
        Join-Path $reportDir 'FileShare-Permissions-Report.csv'
    ) -NoTypeInformation -Encoding UTF8

$groupReport = foreach (
    $group in Get-ADGroup -Filter * -Properties Description, Members
) {
    $members = @(
        Get-ADGroupMember -Identity $group -Recursive `
            -ErrorAction SilentlyContinue
    )

    [pscustomobject][ordered]@{
        ReportTimestamp = $timestamp
        GroupName       = $group.Name
        GroupCategory   = $group.GroupCategory
        GroupScope      = $group.GroupScope
        Description     = $group.Description
        MemberCount     = $members.Count
        UserMembers     = @(
            $members |
            Where-Object {
                $_.ObjectClass -eq 'user'
            } |
            Select-Object -ExpandProperty SamAccountName
        ) -join '; '
        DistinguishedName = $group.DistinguishedName
    }
}

$groupReport |
    Sort-Object GroupName |
    Export-Csv (
        Join-Path $reportDir 'AD-Group-Inventory.csv'
    ) -NoTypeInformation -Encoding UTF8

if (-not $Quiet) {
    Write-Host "IAM reports refreshed in $reportDir" -ForegroundColor Green

    Get-ChildItem -Path $reportDir -Filter '*.csv' |
        Select-Object Name, Length, LastWriteTime
}

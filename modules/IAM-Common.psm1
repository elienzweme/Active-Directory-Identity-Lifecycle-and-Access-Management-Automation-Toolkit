#requires -Version 5.1
#requires -Modules ActiveDirectory

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-IAMToolkitRoot {
    [CmdletBinding()]
    param()

    return (Split-Path -Path $PSScriptRoot -Parent)
}

function Import-IAMToolkitConfig {
    [CmdletBinding()]
    param(
        [string]$Path = (
            Join-Path (Get-IAMToolkitRoot) 'config\IAM-Toolkit-Config.psd1'
        )
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Configuration file not found: $Path"
    }

    return Import-PowerShellDataFile -LiteralPath $Path
}

function Get-IAMOperator {
    [CmdletBinding()]
    param()

    if ($env:USERDOMAIN) {
        return "$env:USERDOMAIN\$env:USERNAME"
    }

    return $env:USERNAME
}

function Get-IAMPropertyValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        $InputObject,

        [Parameter(Mandatory)]
        [string]$PropertyName,

        [AllowNull()]
        $DefaultValue = ''
    )

    if ($null -eq $InputObject) {
        return $DefaultValue
    }

    if ($InputObject.PSObject.Properties.Name -contains $PropertyName) {
        $value = $InputObject.$PropertyName

        if ($null -ne $value) {
            return $value
        }
    }

    return $DefaultValue
}

function Initialize-IAMCsv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string[]]$Headers
    )

    $parent = Split-Path -Path $Path -Parent

    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -Path $parent -ItemType Directory -Force | Out-Null
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        ($Headers -join ',') |
            Set-Content -LiteralPath $Path -Encoding UTF8
    }
}

function Write-IAMCsvRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string[]]$Headers,

        [Parameter(Mandatory)]
        [hashtable]$Data
    )

    Initialize-IAMCsv -Path $Path -Headers $Headers

    $row = [ordered]@{}

    foreach ($header in $Headers) {
        $row[$header] = if (
            $Data.ContainsKey($header) -and
            $null -ne $Data[$header]
        ) {
            [string]$Data[$header]
        }
        else {
            ''
        }
    }

    [pscustomobject]$row |
        Export-Csv `
            -LiteralPath $Path `
            -Append `
            -NoTypeInformation `
            -Encoding UTF8
}

function Get-IAMLogSchemas {
    [CmdletBinding()]
    param()

    return @{
        'JML-Audit.csv' = @(
            'Timestamp',
            'ExecutionID',
            'RequestID',
            'TicketID',
            'EmployeeID',
            'SamAccountName',
            'UserPrincipalName',
            'Action',
            'ApprovalStatus',
            'PreviousDepartment',
            'Department',
            'PreviousJobTitle',
            'JobTitle',
            'PreviousManager',
            'Manager',
            'PreviousOU',
            'TargetOU',
            'AssignedGroups',
            'RemovedGroups',
            'DepartmentMappedDriveRoot',
            'PreviousEntitledFolders',
            'EntitledFolders',
            'SharedDriveAccess',
            'HomeFolder',
            'HomeDrive',
            'Status',
            'Technician',
            'ComputerName',
            'InventoryRefreshed',
            'ErrorMessage'
        )

        'Joiner-Report.csv' = @(
            'Timestamp',
            'ExecutionID',
            'RequestID',
            'TicketID',
            'EmployeeID',
            'SamAccountName',
            'UserPrincipalName',
            'DisplayName',
            'Department',
            'JobTitle',
            'Manager',
            'TargetOU',
            'DepartmentGroup',
            'DepartmentMappedDriveRoot',
            'EntitledFolder',
            'DepartmentDriveLetter',
            'SharedDriveAccess',
            'HomeDirectory',
            'HomeDrive',
            'FolderCreated',
            'AclApplied',
            'AccountEnabled',
            'ChangePasswordAtLogon',
            'ApprovedBy',
            'Technician',
            'ComputerName',
            'InventoryRefreshed',
            'Status',
            'ErrorMessage'
        )

        'Mover-Report.csv' = @(
            'Timestamp',
            'ExecutionID',
            'RequestID',
            'TicketID',
            'EmployeeID',
            'SamAccountName',
            'PreviousDepartment',
            'Department',
            'PreviousJobTitle',
            'JobTitle',
            'PreviousManager',
            'Manager',
            'PreviousOU',
            'TargetOU',
            'RemovedGroups',
            'AssignedGroups',
            'PreviousEntitledFolders',
            'EntitledFolders',
            'DepartmentMappedDriveRoot',
            'DepartmentDriveLetter',
            'SharedDriveAccess',
            'HomeDirectory',
            'HomeDrive',
            'ApprovedBy',
            'Technician',
            'ComputerName',
            'InventoryRefreshed',
            'Status',
            'ErrorMessage'
        )

        'Leaver-Report.csv' = @(
            'Timestamp',
            'ExecutionID',
            'RequestID',
            'TicketID',
            'EmployeeID',
            'SamAccountName',
            'PreviousDepartment',
            'PreviousJobTitle',
            'PreviousManager',
            'PreviousOU',
            'DisabledUsersOU',
            'AccountDisabled',
            'PasswordReset',
            'RemovedGroups',
            'RevokedEntitledFolders',
            'HomeFolder',
            'HomeFolderRetained',
            'ManagerCleared',
            'HomeDriveCleared',
            'ApprovedBy',
            'Technician',
            'ComputerName',
            'InventoryRefreshed',
            'Status',
            'ErrorMessage'
        )

        'RBAC-Changes.csv' = @(
            'Timestamp',
            'ExecutionID',
            'RequestID',
            'TicketID',
            'EmployeeID',
            'SamAccountName',
            'Action',
            'GroupName',
            'ChangeType',
            'PreviousDepartment',
            'Department',
            'MappedDriveRoot',
            'EntitledFolder',
            'AccessLevel',
            'AccessType',
            'ApprovedBy',
            'Technician',
            'ComputerName',
            'Status',
            'ErrorMessage'
        )

        'HomeFolder-Report.csv' = @(
            'Timestamp',
            'ExecutionID',
            'RequestID',
            'TicketID',
            'EmployeeID',
            'SamAccountName',
            'Action',
            'HomeFolder',
            'HomeDrive',
            'FolderCreated',
            'AclApplied',
            'FolderRetained',
            'FolderArchived',
            'Technician',
            'ComputerName',
            'Status',
            'ErrorMessage'
        )

        'Script-Errors.csv' = @(
            'Timestamp',
            'ExecutionID',
            'RequestID',
            'TicketID',
            'EmployeeID',
            'SamAccountName',
            'ScriptName',
            'Action',
            'ErrorType',
            'ErrorMessage',
            'FailedStep',
            'ComputerName',
            'Technician'
        )

        'Execution-History.csv' = @(
            'ExecutionID',
            'ScriptName',
            'StartTime',
            'EndTime',
            'DurationSeconds',
            'ComputerName',
            'Technician',
            'WhatIfMode',
            'RequestsFound',
            'RequestsProcessed',
            'SuccessCount',
            'FailureCount',
            'SkippedCount',
            'ReportRefreshResult',
            'Result'
        )
    }
}

function Initialize-IAMLogFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$LogDirectory
    )

    $schemas = Get-IAMLogSchemas

    foreach ($name in $schemas.Keys) {
        Initialize-IAMCsv `
            -Path (Join-Path $LogDirectory $name) `
            -Headers $schemas[$name]
    }
}

function Write-IAMLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$LogDirectory,

        [Parameter(Mandatory)]
        [string]$FileName,

        [Parameter(Mandatory)]
        [hashtable]$Data
    )

    $schemas = Get-IAMLogSchemas

    if (-not $schemas.ContainsKey($FileName)) {
        throw "Unknown log file: $FileName"
    }

    Write-IAMCsvRecord `
        -Path (Join-Path $LogDirectory $FileName) `
        -Headers $schemas[$FileName] `
        -Data $Data
}

function Get-IAMNormalizedMapping {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Mapping
    )

    $sharedDrive = [string](
        Get-IAMPropertyValue `
            -InputObject $Mapping `
            -PropertyName 'SharedDrive'
    )

    $mappedDriveRoot = [string](
        Get-IAMPropertyValue `
            -InputObject $Mapping `
            -PropertyName 'MappedDriveRoot'
    )

    if (
        [string]::IsNullOrWhiteSpace($mappedDriveRoot) -and
        -not [string]::IsNullOrWhiteSpace($sharedDrive)
    ) {
        $mappedDriveRoot = Split-Path -Path $sharedDrive -Parent
    }

    $entitledFolder = [string](
        Get-IAMPropertyValue `
            -InputObject $Mapping `
            -PropertyName 'EntitledFolder'
    )

    if (
        [string]::IsNullOrWhiteSpace($entitledFolder) -and
        -not [string]::IsNullOrWhiteSpace($sharedDrive)
    ) {
        $entitledFolder = $sharedDrive
    }

    $shareName = [string](
        Get-IAMPropertyValue `
            -InputObject $Mapping `
            -PropertyName 'ShareName' `
            -DefaultValue 'Departments'
    )

    $departmentDriveLetter = [string](
        Get-IAMPropertyValue `
            -InputObject $Mapping `
            -PropertyName 'DepartmentDriveLetter' `
            -DefaultValue 'S:'
    )

    $homeDrive = [string](
        Get-IAMPropertyValue `
            -InputObject $Mapping `
            -PropertyName 'HomeDrive' `
            -DefaultValue 'H:'
    )

    return [pscustomobject][ordered]@{
        Department           = Get-IAMPropertyValue $Mapping 'Department'
        OU                   = Get-IAMPropertyValue $Mapping 'OU'
        DepartmentGroup      = Get-IAMPropertyValue $Mapping 'DepartmentGroup'
        ShareName            = $shareName
        MappedDriveRoot      = $mappedDriveRoot
        EntitledFolder       = $entitledFolder
        PhysicalPath         = Get-IAMPropertyValue $Mapping 'PhysicalPath'
        DepartmentDriveLetter = $departmentDriveLetter
        HomeDrive            = $homeDrive
        AccessLevel          = Get-IAMPropertyValue $Mapping 'AccessLevel'
        AccessType           = Get-IAMPropertyValue $Mapping 'AccessType'
        DataOwner            = Get-IAMPropertyValue $Mapping 'DataOwner'
        ApprovalRequired     = Get-IAMPropertyValue $Mapping 'ApprovalRequired'
        ABEExpected          = Get-IAMPropertyValue $Mapping 'ABEExpected'
        Description          = Get-IAMPropertyValue $Mapping 'Description'
    }
}

function Get-IAMRbacMappings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "RBAC mapping file not found: $Path"
    }

    return @(
        Import-Csv -LiteralPath $Path |
        ForEach-Object {
            Get-IAMNormalizedMapping -Mapping $_
        }
    )
}

function Get-IAMRbacMapping {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Department,

        [Parameter(Mandatory)]
        [array]$Mappings
    )

    $matches = @(
        $Mappings |
        Where-Object {
            $_.Department -eq $Department
        }
    )

    if ($matches.Count -ne 1) {
        throw (
            "Expected one RBAC mapping for '$Department'; " +
            "found $($matches.Count)."
        )
    }

    Get-ADOrganizationalUnit `
        -Identity $matches[0].OU `
        -ErrorAction Stop |
    Out-Null

    Get-ADGroup `
        -Identity $matches[0].DepartmentGroup `
        -ErrorAction Stop |
    Out-Null

    return $matches[0]
}

function Resolve-IAMManager {
    [CmdletBinding()]
    param(
        [string]$Manager
    )

    if ([string]::IsNullOrWhiteSpace($Manager)) {
        return $null
    }

    $escaped = $Manager.Replace("'", "''")

    $matches = @(
        Get-ADUser `
            -Filter (
                "DisplayName -eq '$escaped' -or " +
                "SamAccountName -eq '$escaped' -or " +
                "UserPrincipalName -eq '$escaped'"
            ) `
            -Properties DistinguishedName `
            -ErrorAction Stop
    )

    if ($matches.Count -eq 0) {
        throw "Manager '$Manager' was not found."
    }

    if ($matches.Count -gt 1) {
        throw (
            "Manager '$Manager' matched multiple accounts. " +
            "Use sAMAccountName or UPN."
        )
    }

    return $matches[0]
}

function Resolve-IAMUser {
    [CmdletBinding()]
    param(
        [string]$EmployeeID,
        [string]$SamAccountName,
        [string[]]$Properties = @()
    )

    $baseProperties = @(
        'Department',
        'Title',
        'Manager',
        'MemberOf',
        'PrimaryGroupID',
        'HomeDirectory',
        'HomeDrive',
        'UserPrincipalName',
        'EmployeeID',
        'Enabled',
        'DistinguishedName'
    )

    $allProperties = @(
        $baseProperties + $Properties |
        Select-Object -Unique
    )

    $byEmployee = @()
    $bySam      = @()

    if (-not [string]::IsNullOrWhiteSpace($EmployeeID)) {
        $escapedEmployeeID = $EmployeeID.Replace('\', '\5c').
            Replace('*', '\2a').
            Replace('(', '\28').
            Replace(')', '\29').
            Replace([char]0, '\00')

        $byEmployee = @(
            Get-ADUser `
                -LDAPFilter "(employeeID=$escapedEmployeeID)" `
                -Properties $allProperties `
                -ErrorAction Stop
        )
    }

    if (-not [string]::IsNullOrWhiteSpace($SamAccountName)) {
        $bySam = @(
            Get-ADUser `
                -Identity $SamAccountName `
                -Properties $allProperties `
                -ErrorAction SilentlyContinue
        )
    }

    if ($byEmployee.Count -gt 1) {
        throw "EmployeeID '$EmployeeID' matches multiple users."
    }

    if ($bySam.Count -gt 1) {
        throw "SamAccountName '$SamAccountName' matches multiple users."
    }

    if (
        $byEmployee.Count -eq 1 -and
        $bySam.Count -eq 1 -and
        $byEmployee[0].DistinguishedName -ne
            $bySam[0].DistinguishedName
    ) {
        throw 'EmployeeID and SamAccountName identify different users.'
    }

    if ($byEmployee.Count -eq 1) {
        return $byEmployee[0]
    }

    if ($bySam.Count -eq 1) {
        return $bySam[0]
    }

    throw (
        "User not found. EmployeeID='$EmployeeID'; " +
        "SamAccountName='$SamAccountName'."
    )
}

function Get-IAMGroupNames {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Microsoft.ActiveDirectory.Management.ADUser]$User
    )

    $resolvedUser = Get-ADUser `
        -Identity $User.DistinguishedName `
        -Properties MemberOf, PrimaryGroupID `
        -ErrorAction Stop

    $groupNames = New-Object System.Collections.Generic.List[string]

    # Direct memberships stored in the MemberOf attribute.
    foreach ($groupDN in @($resolvedUser.MemberOf)) {
        if ([string]::IsNullOrWhiteSpace([string]$groupDN)) {
            continue
        }

        try {
            $group = Get-ADGroup `
                -Identity $groupDN `
                -ErrorAction Stop

            if (-not $groupNames.Contains($group.Name)) {
                $groupNames.Add($group.Name)
            }
        }
        catch {
            Write-Verbose (
                "Unable to resolve direct group '$groupDN': " +
                $_.Exception.Message
            )
        }
    }

    # The primary group is not present in MemberOf. For normal users this is
    # usually Domain Users (RID 513).
    if ($null -ne $resolvedUser.PrimaryGroupID) {
        try {
            $domainSID = (Get-ADDomain -ErrorAction Stop).DomainSID.Value
            $primaryGroupSID = (
                "$domainSID-$($resolvedUser.PrimaryGroupID)"
            )

            $primaryGroup = Get-ADGroup `
                -Identity $primaryGroupSID `
                -ErrorAction Stop

            if (-not $groupNames.Contains($primaryGroup.Name)) {
                $groupNames.Add($primaryGroup.Name)
            }
        }
        catch {
            Write-Verbose (
                "Unable to resolve the primary group for " +
                "'$($resolvedUser.SamAccountName)': " +
                $_.Exception.Message
            )
        }
    }

    return @(
        $groupNames |
        Sort-Object -Unique
    )
}

function Get-IAMMappedAccess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Microsoft.ActiveDirectory.Management.ADUser]$User,

        [Parameter(Mandatory)]
        [array]$Mappings
    )

    $groupNames = @(Get-IAMGroupNames -User $User)

    return @(
        $Mappings |
        Where-Object {
            $_.PSObject.Properties.Name -contains 'DepartmentGroup' -and
            -not [string]::IsNullOrWhiteSpace(
                [string]$_.DepartmentGroup
            ) -and
            $_.DepartmentGroup -in $groupNames
        }
    )
}

function Test-IAMRequestAlreadyCompleted {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RequestID,

        [Parameter(Mandatory)]
        [string]$AuditPath
    )

    if (-not (Test-Path -LiteralPath $AuditPath)) {
        return $false
    }

    return [bool](
        Import-Csv -LiteralPath $AuditPath |
        Where-Object {
            $_.RequestID -eq $RequestID -and
            $_.Status -eq 'Success'
        } |
        Select-Object -First 1
    )
}

function New-IAMRandomPassword {
    [CmdletBinding()]
    param(
        [ValidateRange(14, 128)]
        [int]$Length = 20
    )

    $upper   = 'ABCDEFGHJKLMNPQRSTUVWXYZ'
    $lower   = 'abcdefghijkmnopqrstuvwxyz'
    $digits  = '23456789'
    $special = '!@#$%*-_=+?'
    $all     = $upper + $lower + $digits + $special

    $characters = New-Object System.Collections.Generic.List[char]

    foreach ($set in @($upper, $lower, $digits, $special)) {
        $characters.Add(
            $set[(Get-Random -Maximum $set.Length)]
        )
    }

    while ($characters.Count -lt $Length) {
        $characters.Add(
            $all[(Get-Random -Maximum $all.Length)]
        )
    }

    return -join(
        $characters |
        Sort-Object {
            Get-Random
        }
    )
}

function ConvertTo-IAMUserNamePart {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Value
    )

    $normalized = $Value.Normalize(
        [Text.NormalizationForm]::FormD
    )

    $builder = New-Object Text.StringBuilder

    foreach ($character in $normalized.ToCharArray()) {
        if (
            [Globalization.CharUnicodeInfo]::GetUnicodeCategory(
                $character
            ) -ne
            [Globalization.UnicodeCategory]::NonSpacingMark
        ) {
            [void]$builder.Append($character)
        }
    }

    return (
        (
            $builder.ToString() -replace
            '[^a-zA-Z0-9._-]',
            ''
        ).ToLowerInvariant()
    )
}

function Get-IAMUniqueSamAccountName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FirstName,

        [Parameter(Mandatory)]
        [string]$LastName,

        [string]$RequestedSamAccountName
    )

    $baseName = if ($RequestedSamAccountName) {
        ConvertTo-IAMUserNamePart -Value $RequestedSamAccountName
    }
    else {
        ConvertTo-IAMUserNamePart -Value "$FirstName.$LastName"
    }

    if ([string]::IsNullOrWhiteSpace($baseName)) {
        throw 'Unable to generate a username.'
    }

    $baseName = $baseName.Substring(
        0,
        [Math]::Min(20, $baseName.Length)
    )

    $candidate = $baseName
    $number    = 2

    while (
        Get-ADUser `
            -Filter "SamAccountName -eq '$candidate'" `
            -ErrorAction SilentlyContinue
    ) {
        $suffix = [string]$number

        $candidate = (
            $baseName.Substring(
                0,
                [Math]::Min(
                    20 - $suffix.Length,
                    $baseName.Length
                )
            ) +
            $suffix
        )

        $number++
    }

    return $candidate
}

function Set-IAMHomeFolderAcl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$DomainUser
    )

    $acl = Get-Acl -LiteralPath $Path

    $acl.SetAccessRuleProtection(
        $true,
        $false
    )

    foreach ($rule in @($acl.Access)) {
        [void]$acl.RemoveAccessRuleAll($rule)
    }

    $inheritance = (
        [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor
        [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
    )

    $propagation = (
        [System.Security.AccessControl.PropagationFlags]::None
    )

    $allow = (
        [System.Security.AccessControl.AccessControlType]::Allow
    )

    $accessRules = @(
        @($DomainUser, 'Modify, Synchronize'),
        @('BUILTIN\Administrators', 'FullControl'),
        @('NT AUTHORITY\SYSTEM', 'FullControl')
    )

    foreach ($accessRule in $accessRules) {
        $rule = New-Object `
            -TypeName Security.AccessControl.FileSystemAccessRule `
            -ArgumentList @(
                $accessRule[0],
                $accessRule[1],
                $inheritance,
                $propagation,
                $allow
            )

        [void]$acl.AddAccessRule($rule)
    }

    Set-Acl -LiteralPath $Path -AclObject $acl
}

function Get-IAMParentDN {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$DistinguishedName
    )

    $parts = $DistinguishedName -split ',', 2

    if ($parts.Count -lt 2) {
        return ''
    }

    return $parts[1]
}

function Invoke-IAMReportRefresh {
    [CmdletBinding()]
    param(
        [string]$ToolkitRoot = (Get-IAMToolkitRoot)
    )

    $reportScript = Join-Path `
        $ToolkitRoot `
        'scripts\Get-IAMEnvironmentReport.ps1'

    if (-not (Test-Path -LiteralPath $reportScript)) {
        return 'ReportScriptMissing'
    }

    try {
        & $reportScript -Quiet -ErrorAction Stop | Out-Null
        return 'Success'
    }
    catch {
        return "Failed: $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function *

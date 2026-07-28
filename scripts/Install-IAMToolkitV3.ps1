[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$CurrentToolkit = 'C:\IAM-Toolkit',
    [Parameter(Mandatory)]
    [string]$PackageRoot,
    [string]$DepartmentDriveLetter = 'S:'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $PackageRoot)) {
    throw "PackageRoot not found: $PackageRoot"
}
if ($DepartmentDriveLetter -notmatch '^[A-Z]:$') {
    throw "DepartmentDriveLetter must use a value such as S:."
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "$CurrentToolkit-Backup-$stamp"

if (Test-Path -LiteralPath $CurrentToolkit) {
    Copy-Item -LiteralPath $CurrentToolkit -Destination $backup -Recurse -Force
}

if ($PSCmdlet.ShouldProcess($CurrentToolkit, 'Install IAM Toolkit v3 and align the department drive letter')) {
    foreach ($directory in @('config','modules','scripts','docs')) {
        $destination = Join-Path $CurrentToolkit $directory
        New-Item -Path $destination -ItemType Directory -Force | Out-Null
        Copy-Item -Path (Join-Path $PackageRoot "$directory\*") -Destination $destination -Recurse -Force
    }

    foreach ($directory in @('input','logs','Reports','backups')) {
        New-Item -Path (Join-Path $CurrentToolkit $directory) -ItemType Directory -Force | Out-Null
    }

    foreach ($directory in @('logs','Reports')) {
        foreach ($file in Get-ChildItem -Path (Join-Path $PackageRoot $directory) -File) {
            $destinationFile = Join-Path $CurrentToolkit "$directory\$($file.Name)"
            if (-not (Test-Path -LiteralPath $destinationFile)) {
                Copy-Item -LiteralPath $file.FullName -Destination $destinationFile
            }
        }
    }

    foreach ($file in Get-ChildItem -Path (Join-Path $PackageRoot 'input') -File) {
        $destinationFile = Join-Path $CurrentToolkit "input\$($file.Name)"
        if ($file.Name -like '*-Template.csv' -or -not (Test-Path -LiteralPath $destinationFile)) {
            Copy-Item -LiteralPath $file.FullName -Destination $destinationFile -Force
        }
    }

    Copy-Item -LiteralPath (Join-Path $PackageRoot 'README.md') -Destination $CurrentToolkit -Force

    $configPath = Join-Path $CurrentToolkit 'config\IAM-Toolkit-Config.psd1'
    $configText = Get-Content -LiteralPath $configPath -Raw
    $configText = $configText -replace "DepartmentDriveLetter\s*=\s*'[A-Z]:'",
        "DepartmentDriveLetter     = '$DepartmentDriveLetter'"
    Set-Content -LiteralPath $configPath -Value $configText -Encoding UTF8

    foreach ($mappingPath in @(
        (Join-Path $CurrentToolkit 'input\RBAC-Mapping.csv'),
        (Join-Path $CurrentToolkit 'input\RBAC-Mapping-Template.csv')
    )) {
        if (Test-Path -LiteralPath $mappingPath) {
            $mappings = @(Import-Csv -LiteralPath $mappingPath)
            foreach ($mapping in $mappings) {
                if ($mapping.PSObject.Properties.Name -contains 'DepartmentDriveLetter') {
                    $mapping.DepartmentDriveLetter = $DepartmentDriveLetter
                }
            }
            $mappings | Export-Csv -LiteralPath $mappingPath -NoTypeInformation -Encoding UTF8
        }
    }

    Get-ChildItem "$CurrentToolkit\scripts\*.ps1" | Unblock-File
    Unblock-File "$CurrentToolkit\modules\IAM-Common.psm1"
}

Write-Host "Backup: $backup" -ForegroundColor Cyan
Write-Host "Installed: $CurrentToolkit" -ForegroundColor Green
Write-Host "Department drive: $DepartmentDriveLetter -> \\FILE01\Departments" -ForegroundColor Green

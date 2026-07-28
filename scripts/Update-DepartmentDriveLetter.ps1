[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$ToolkitRoot = 'C:\IAM-Toolkit',
    [string]$DepartmentDriveLetter = 'S:'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($DepartmentDriveLetter -notmatch '^[A-Z]:$') {
    throw "DepartmentDriveLetter must use a value such as S:."
}

$configPath = Join-Path $ToolkitRoot 'config\IAM-Toolkit-Config.psd1'
$mappingPaths = @(
    (Join-Path $ToolkitRoot 'input\RBAC-Mapping.csv'),
    (Join-Path $ToolkitRoot 'input\RBAC-Mapping-Template.csv')
)

if ($PSCmdlet.ShouldProcess($ToolkitRoot, "Set department mapped drive to $DepartmentDriveLetter")) {
    if (Test-Path -LiteralPath $configPath) {
        $configText = Get-Content -LiteralPath $configPath -Raw
        $configText = $configText -replace "DepartmentDriveLetter\s*=\s*'[A-Z]:'",
            "DepartmentDriveLetter     = '$DepartmentDriveLetter'"
        Set-Content -LiteralPath $configPath -Value $configText -Encoding UTF8
    }

    foreach ($mappingPath in $mappingPaths) {
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
}

Write-Host "Updated department mapping: $DepartmentDriveLetter -> \\FILE01\Departments" -ForegroundColor Green
Write-Host "Regenerate reports with: C:\IAM-Toolkit\scripts\Get-IAMEnvironmentReport.ps1" -ForegroundColor Cyan

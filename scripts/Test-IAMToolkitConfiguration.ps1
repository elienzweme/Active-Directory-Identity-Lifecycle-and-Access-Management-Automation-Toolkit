#requires -Version 5.1
#requires -Modules ActiveDirectory
[CmdletBinding()]param([string]$ToolkitRoot=(Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference='Continue';Import-Module ActiveDirectory;Import-Module (Join-Path $ToolkitRoot 'modules\IAM-Common.psm1') -Force
$config=Import-IAMToolkitConfig -Path (Join-Path $ToolkitRoot 'config\IAM-Toolkit-Config.psd1');$maps=Get-IAMRbacMappings (Join-Path $ToolkitRoot 'input\RBAC-Mapping.csv')
$results=@();$results+=[pscustomobject]@{Test='Domain';Target=$config.DomainDNSName;Result=try{(Get-ADDomain).DNSRoot}catch{'Failed'}};$results+=[pscustomobject]@{Test='HomeFolderRoot';Target=$config.HomeFolderUncRoot;Result=Test-Path $config.HomeFolderUncRoot};$results+=[pscustomobject]@{Test='DepartmentShareRoot';Target=$config.DepartmentMappedDriveRoot;Result=Test-Path $config.DepartmentMappedDriveRoot}
foreach($m in $maps){$results+=[pscustomobject]@{Test='OU';Target=$m.OU;Result=[bool](Get-ADOrganizationalUnit $m.OU -ErrorAction SilentlyContinue)};$results+=[pscustomobject]@{Test='Group';Target=$m.DepartmentGroup;Result=[bool](Get-ADGroup $m.DepartmentGroup -ErrorAction SilentlyContinue)};$results+=[pscustomobject]@{Test='EntitledFolder';Target=$m.EntitledFolder;Result=Test-Path $m.EntitledFolder}}
$results|Format-Table -AutoSize

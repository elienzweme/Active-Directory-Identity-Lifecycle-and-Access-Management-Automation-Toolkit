# IAM Toolkit — JML Integrated Reporting v3

This version connects lifecycle automation to a live Active Directory and file-share reporting layer.

## Key corrections

- Department shared-folder access is derived from AD group membership and `RBAC-Mapping.csv`, not from `HomeDirectory`.
- `\\FILE01\Departments` is reported as the mapped-drive root, while `\\FILE01\Departments\<Department>` is the user’s entitled ABE-visible folder.
- Mover and Leaver can identify existing users by EmployeeID or SamAccountName.
- Successful lifecycle changes automatically refresh current-state reports.
- The uploaded AD inventory is included as `Reports\AD-User-Inventory-Current-Snapshot.csv` for comparison.

## First run

```powershell
Get-ChildItem C:\IAM-Toolkit\scripts\*.ps1 | Unblock-File
Unblock-File C:\IAM-Toolkit\modules\IAM-Common.psm1
C:\IAM-Toolkit\scripts\Test-IAMToolkitConfiguration.ps1
C:\IAM-Toolkit\scripts\Get-IAMEnvironmentReport.ps1
```

## Lifecycle tests

```powershell
C:\IAM-Toolkit\scripts\New-Joiner.ps1 -WhatIf
C:\IAM-Toolkit\scripts\Invoke-Mover.ps1 -WhatIf
C:\IAM-Toolkit\scripts\Invoke-Leaver.ps1 -WhatIf
```


## Confirmed department drive design

```text
S: -> \\FILE01\Departments
```

Access-Based Enumeration and NTFS permissions determine which subfolders appear:

```text
HR user       -> S:\HR
Finance user  -> S:\Finance
Security user -> S:\Security
```

The JML scripts assign and remove department security groups. Group Policy maps the common `S:` drive. The scripts and reports record both the mapped root and each user's entitled department subfolder.

## Upgrade an existing installation

```powershell
C:\IAM-Toolkit\scripts\Update-DepartmentDriveLetter.ps1
C:\IAM-Toolkit\scripts\Get-IAMEnvironmentReport.ps1
```

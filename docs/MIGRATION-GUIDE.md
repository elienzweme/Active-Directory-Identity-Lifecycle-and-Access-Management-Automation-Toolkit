# Migration Guide

1. Back up `C:\IAM-Toolkit`.
2. Copy the v2 package to a temporary folder.
3. Run the installer from the package:

```powershell
C:\Temp\IAM-Toolkit-JML-Integrated-Reporting-v2\scripts\Install-IAMToolkitV3.ps1 `
  -PackageRoot C:\Temp\IAM-Toolkit-JML-Integrated-Reporting-v2
```

The installer preserves existing input, log, and report files and replaces scripts, modules, configuration, and documentation. Because schemas changed, compare your current `JML-Requests.csv` and `RBAC-Mapping.csv` with the v2 templates. At minimum add `SamAccountName` to JML requests and the mapped-root/entitled-folder fields to RBAC mapping.

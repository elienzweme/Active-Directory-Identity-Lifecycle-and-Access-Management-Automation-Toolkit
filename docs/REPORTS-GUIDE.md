# Reports Guide

- **AD-User-Inventory.csv:** Current AD identity attributes, home folders, group-derived department shares, privileged groups, compliance, and JML readiness.
- **RBAC-Entitlement-Report.csv:** One row for each expected or actual department entitlement. This highlights department/group mismatches.
- **FileShare-Permissions-Report.csv:** Validates mapped roots, entitled folders, and NTFS group ACLs.
- **JML-Readiness-Report.csv:** Shows whether an existing account can be safely targeted by Mover/Leaver automation and what attributes are missing.
- **AD-Group-Inventory.csv:** Group scope, category, membership counts, and user members.

Run manually:

```powershell
C:\IAM-Toolkit\scripts\Get-IAMEnvironmentReport.ps1
```

Joiner, Mover, and Leaver automatically refresh these reports after successful changes unless `-SkipReportRefresh` is used.

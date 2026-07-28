# JML Workflow with Integrated Current-State Reporting

```text
JML-Requests.csv + RBAC-Mapping.csv
                 ↓
      Joiner / Mover / Leaver
                 ↓
       Active Directory + FILE01
                 ↓
       Transaction and audit logs
                 ↓
 Automatic current-state report refresh
 ├── AD-User-Inventory.csv
 ├── RBAC-Entitlement-Report.csv
 ├── FileShare-Permissions-Report.csv
 ├── JML-Readiness-Report.csv
 └── AD-Group-Inventory.csv
```

The lifecycle scripts never use `AD-User-Inventory.csv` as their source of truth. They query Active Directory live. The inventory report is operational context and post-change evidence. `RBAC-Mapping.csv` is the authoritative mapping between department, group, OU, mapped-drive root, entitled subfolder, access level, and data owner.

## Identifier handling

Mover and Leaver requests can identify an account using `EmployeeID`, `SamAccountName`, or both. When both are present, the scripts confirm that they identify the same account. This allows existing lab users without EmployeeID values to be automated while the readiness report identifies which records should be remediated.

## Shared-folder model

- Physical path: `D:\Shares\Departments\<Department>`
- SMB mapped-drive root: `\\FILE01\Departments`
- User drive letter: `S:`
- ABE-visible entitled folder: `\\FILE01\Departments\<Department>`
- Authorization: department AD group + NTFS ACL

The report distinguishes the mapped-drive root from the entitled subfolder.

# CSV Schema Reference

## Logs

### JML-Audit.csv

```text
Timestamp
ExecutionID
RequestID
TicketID
EmployeeID
SamAccountName
UserPrincipalName
Action
ApprovalStatus
PreviousDepartment
Department
PreviousJobTitle
JobTitle
PreviousManager
Manager
PreviousOU
TargetOU
AssignedGroups
RemovedGroups
DepartmentMappedDriveRoot
PreviousEntitledFolders
EntitledFolders
SharedDriveAccess
HomeFolder
HomeDrive
Status
Technician
ComputerName
InventoryRefreshed
ErrorMessage
```

### Joiner-Report.csv

```text
Timestamp
ExecutionID
RequestID
TicketID
EmployeeID
SamAccountName
UserPrincipalName
DisplayName
Department
JobTitle
Manager
TargetOU
DepartmentGroup
DepartmentMappedDriveRoot
EntitledFolder
DepartmentDriveLetter
SharedDriveAccess
HomeDirectory
HomeDrive
FolderCreated
AclApplied
AccountEnabled
ChangePasswordAtLogon
ApprovedBy
Technician
ComputerName
InventoryRefreshed
Status
ErrorMessage
```

### Mover-Report.csv

```text
Timestamp
ExecutionID
RequestID
TicketID
EmployeeID
SamAccountName
PreviousDepartment
Department
PreviousJobTitle
JobTitle
PreviousManager
Manager
PreviousOU
TargetOU
RemovedGroups
AssignedGroups
PreviousEntitledFolders
EntitledFolders
DepartmentMappedDriveRoot
DepartmentDriveLetter
SharedDriveAccess
HomeDirectory
HomeDrive
ApprovedBy
Technician
ComputerName
InventoryRefreshed
Status
ErrorMessage
```

### Leaver-Report.csv

```text
Timestamp
ExecutionID
RequestID
TicketID
EmployeeID
SamAccountName
PreviousDepartment
PreviousJobTitle
PreviousManager
PreviousOU
DisabledUsersOU
AccountDisabled
PasswordReset
RemovedGroups
RevokedEntitledFolders
HomeFolder
HomeFolderRetained
ManagerCleared
HomeDriveCleared
ApprovedBy
Technician
ComputerName
InventoryRefreshed
Status
ErrorMessage
```

### RBAC-Changes.csv

```text
Timestamp
ExecutionID
RequestID
TicketID
EmployeeID
SamAccountName
Action
GroupName
ChangeType
PreviousDepartment
Department
MappedDriveRoot
EntitledFolder
AccessLevel
AccessType
ApprovedBy
Technician
ComputerName
Status
ErrorMessage
```

### HomeFolder-Report.csv

```text
Timestamp
ExecutionID
RequestID
TicketID
EmployeeID
SamAccountName
Action
HomeFolder
HomeDrive
FolderCreated
AclApplied
FolderRetained
FolderArchived
Technician
ComputerName
Status
ErrorMessage
```

### Script-Errors.csv

```text
Timestamp
ExecutionID
RequestID
TicketID
EmployeeID
SamAccountName
ScriptName
Action
ErrorType
ErrorMessage
FailedStep
ComputerName
Technician
```

### Execution-History.csv

```text
ExecutionID
ScriptName
StartTime
EndTime
DurationSeconds
ComputerName
Technician
WhatIfMode
RequestsFound
RequestsProcessed
SuccessCount
FailureCount
SkippedCount
ReportRefreshResult
Result
```

## Reports

### AD-User-Inventory.csv

```text
ReportTimestamp
DisplayName
SamAccountName
UserPrincipalName
EmployeeID
Department
Title
Manager
Enabled
LockedOut
PasswordLastSet
LastLogonDate
HomeDirectory
HomeDrive
DepartmentGroup
DepartmentMappedDriveRoot
DepartmentSharedDrive
DepartmentDriveLetter
SharedDriveAccess
AccessType
DataOwner
OU
SecurityGroups
PrivilegedGroups
DepartmentGroupCompliant
SharePathExists
JMLReady
MissingJMLAttributes
```

### RBAC-Entitlement-Report.csv

```text
ReportTimestamp
DisplayName
SamAccountName
EmployeeID
ADDepartment
MappedDepartment
DepartmentGroup
IsGroupMember
MappedDriveRoot
EntitledFolder
DepartmentDriveLetter
ExpectedAccessLevel
AccessType
DataOwner
SharePathExists
DepartmentMatchesMapping
EntitlementCompliant
ComplianceReason
```

### FileShare-Permissions-Report.csv

```text
ReportTimestamp
Department
DepartmentGroup
ShareName
MappedDriveRoot
EntitledFolder
PhysicalPath
AccessLevelExpected
ABEExpected
ShareExists
FolderExists
GroupFoundInACL
ActualFileSystemRights
AccessControlType
IsInherited
PermissionCompliant
ValidationComputer
ValidationNote
```

### JML-Readiness-Report.csv

```text
ReportTimestamp
DisplayName
SamAccountName
EmployeeID
Department
Title
Manager
UserPrincipalName
Enabled
OU
DepartmentGroup
EntitledFolder
JMLReady
MissingAttributes
RecommendedIdentifier
RecommendedAction
```

### AD-Group-Inventory.csv

```text
ReportTimestamp
GroupName
GroupCategory
GroupScope
Description
MemberCount
UserMembers
DistinguishedName
```

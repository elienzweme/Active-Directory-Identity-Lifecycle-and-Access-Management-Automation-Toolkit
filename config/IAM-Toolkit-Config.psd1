@{
    DomainDN                  = 'DC=Corp,DC=local'
    DomainDNSName             = 'Corp.local'
    FileServer                = 'FILE01'

    HomeFolderAdminRoot       = '\\FILE01\HomeFolders'
    HomeFolderUncRoot         = '\\FILE01\HomeFolders'
    DefaultHomeDrive          = 'H:'

    DepartmentShareName       = 'Departments'
    DepartmentMappedDriveRoot = '\\FILE01\Departments'
    DepartmentPhysicalRoot    = 'D:\Shares\Departments'
    DepartmentDriveLetter     = 'S:'

    DisabledUsersOU           = 'OU=Disabled Users,DC=Corp,DC=local'

    PrivilegedGroups = @(
        'Domain Admins',
        'Enterprise Admins',
        'Schema Admins',
        'Administrators',
        'IAM Admins',
        'Privileged Security Admins'
    )

    BuiltInAccounts = @(
        'Administrator',
        'Guest',
        'krbtgt'
    )
}

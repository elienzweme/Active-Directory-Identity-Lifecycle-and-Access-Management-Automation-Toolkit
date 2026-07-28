# Department Drive Mapping

## Confirmed lab mapping

| Item | Value |
|---|---|
| File server | FILE01 |
| SMB share | Departments |
| UNC mapped root | `\\FILE01\Departments` |
| Client drive letter | `S:` |
| Physical root on FILE01 | `D:\Shares\Departments` |
| Access model | Department security groups + NTFS permissions + ABE |
| Home drive | `H:` |
| Home folder root | `\\FILE01\HomeFolders` |

Group Policy maps the common `S:` drive. The JML scripts manage department group membership. ABE and NTFS permissions determine which department subfolder is visible to each user.

permissionset 8857 "SBSI - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'SimplifiedBankStatementImport - Edit';

    IncludedPermissionSets = "SBSI - Read";

    Permissions = tabledata "Bank Statement Import Preview" = IMD;
}
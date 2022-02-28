permissionset 8860 "SBSI - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'SimplifiedBankStatementImport - Read';

    IncludedPermissionSets = "SBSI - Objects";

    Permissions = tabledata "Bank Statement Import Preview" = R;
}

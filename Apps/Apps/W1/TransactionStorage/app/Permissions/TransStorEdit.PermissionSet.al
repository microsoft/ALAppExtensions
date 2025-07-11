namespace System.DataAdministration;

permissionset 6202 "Trans. Stor. - Edit"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Trans. Stor. - Read";

    Permissions = tabledata "Transaction Storage Setup" = IM;
}
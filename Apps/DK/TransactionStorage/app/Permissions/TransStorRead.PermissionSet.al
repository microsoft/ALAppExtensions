namespace System.DataAdministration;

permissionset 6200 "Trans. Stor. - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Transact. Storage Objects";

    Permissions = tabledata "Transaction Storage Setup" = R;
}
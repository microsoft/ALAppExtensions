permissionset 89 "Permissions & Licenses - Edit"
{
    Assignable = False;

    IncludedPermissionSets = "Permissions & Licenses - Read";

    Permissions = tabledata "Access Control" = IMD,
                  tabledata "Tenant Permission" = IMD,
                  tabledata "Tenant Permission Set" = IMD;
}

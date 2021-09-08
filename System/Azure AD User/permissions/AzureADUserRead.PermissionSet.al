permissionset 9011 "Azure AD User - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Language - Read";

    Permissions = tabledata User = r,
                  tabledata "User Property" = r;
}
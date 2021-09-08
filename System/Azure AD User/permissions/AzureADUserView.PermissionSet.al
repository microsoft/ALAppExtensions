permissionset 9024 "Azure AD User - View"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Azure AD User - Read";

    Permissions = tabledata User = m;
}
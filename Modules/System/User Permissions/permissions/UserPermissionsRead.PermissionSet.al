permissionset 152 "User Permissions - Read"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata "Access Control" = r,
                  tabledata User = r;
}
permissionset 8700 "Table Information - Read"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata "Table Information" = r,
                  tabledata "Table Information Cache" = r,
                  tabledata "Company Size Cache" = r;
}
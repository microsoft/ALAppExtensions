permissionset 95 "Session - Read"
{
    Access = Public;
    Assignable = False;

    Permissions = tabledata "Active Session" = R,
                  tabledata "Database Locks" = R,
                  tabledata "Server Instance" = R,
                  tabledata Session = R,
                  tabledata "Session Event" = R;
}
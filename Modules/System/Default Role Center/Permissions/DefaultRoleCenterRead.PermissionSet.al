permissionset 9171 "Default Role Center - Read"
{
    Access = internal;
    Assignable = false;

    Permissions = tabledata "All Profile" = r,
                  tabledata AllObjWithCaption = r;
}
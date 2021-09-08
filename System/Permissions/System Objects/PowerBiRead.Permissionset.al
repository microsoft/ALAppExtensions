permissionset 111 "Power BI - Read"
{
    Access = Public;
    Assignable = false;

    Permissions = tabledata "Power BI Blob" = R,
                  tabledata "Power BI Default Selection" = R;
}
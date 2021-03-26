permissionset 2715 "Page Summary Provider - Read"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata "Page Metadata" = r,
                  tabledata "Tenant Media Thumbnails" = r,
                  tabledata "Tenant Media Set" = r;
}
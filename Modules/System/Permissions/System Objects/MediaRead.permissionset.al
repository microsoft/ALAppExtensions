permissionset 101 "Media - Read"
{
    Assignable = False;

    Permissions = tabledata Media = R,
                  tabledata "Media Set" = R,
                  tabledata "Media Resources" = R,
                  tabledata "Tenant Media" = R,
                  tabledata "Tenant Media Set" = R,
                  tabledata "Tenant Media Thumbnails" = R;
}
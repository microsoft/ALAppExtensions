permissionset 102 "Media - View"
{
    Access = Public;
    Assignable = False;

    IncludedPermissionSets = "Media - Read";

    Permissions = tabledata "Tenant Media" = imd,
                  tabledata "Tenant Media Set" = imd,
                  tabledata "Tenant Media Thumbnails" = imd;
}
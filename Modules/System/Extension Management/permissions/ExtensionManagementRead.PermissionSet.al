permissionset 2500 "Extension Management - Read"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Language - Read";

    Permissions = tabledata "Application Object Metadata" = r,
                  tabledata "Extension Deployment Status" = R,
                  tabledata "NAV App Installed App" = r,
                  tabledata "NAV App Tenant Operation" = r,
                  tabledata "Published Application" = r,
                  tabledata "NAV App Setting" = r,
                  tabledata "Windows Language" = r;
}
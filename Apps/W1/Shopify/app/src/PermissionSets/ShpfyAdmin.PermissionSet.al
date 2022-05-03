/// <summary>
/// Shpfy - Admin Permissions (ID 30103).
/// </summary>
permissionset 30103 "Shpfy - Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Shopify - Admin', MaxLength = 30;

    IncludedPermissionSets = "Shpfy - Edit";

    Permissions =
        tabledata "Shpfy Registered Store" = IMD;
}
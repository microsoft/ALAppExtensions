/// <summary>
/// Shpfy - Admin Permissions (ID 30103).
/// </summary>
permissionset 30103 "Shpfy - Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Shopify - Admin', MaxLength = 30;

    IncludedPermissionSets = "Shpfy - Edit";

#if not CLEAN21
#pragma warning disable AL0432
    Permissions =
        tabledata "Shpfy Registered Store" = IMD,
        tabledata "Shpfy Registered Store New" = IMD;
#pragma warning restore AL0432
#else
    Permissions =
        tabledata "Shpfy Registered Store New" = IMD;
#endif
}
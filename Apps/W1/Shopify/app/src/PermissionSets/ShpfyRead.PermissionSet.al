namespace Microsoft.Integration.Shopify;

/// <summary>
/// Shpfy - Read Permissions (ID 30100).
/// </summary>
#pragma warning disable AS0090, AS0049
permissionset 30100 "Shpfy - Read"
{
    Access = Internal;
    Assignable = false;
    Caption = 'Shopify - Read', MaxLength = 30;

    IncludedPermissionSets = "Shpfy - Objects";

    Permissions =
        tabledata "Shpfy Bulk Operation" = R,
        tabledata "Shpfy Credit Card Company" = R,
        tabledata "Shpfy Cue" = R,
        tabledata "Shpfy Customer" = R,
        tabledata "Shpfy Customer Address" = R,
        tabledata "Shpfy Customer Template" = R,
        tabledata "Shpfy Data Capture" = R,
        tabledata "Shpfy Doc. Link To Doc." = R,
        tabledata "Shpfy Fulfillment Line" = R,
        tabledata "Shpfy FulFillment Order Header" = R,
        tabledata "Shpfy FulFillment Order Line" = R,
        tabledata "Shpfy Gift Card" = R,
        tabledata "Shpfy Initial Import Line" = r,
        tabledata "Shpfy Inventory Item" = R,
        tabledata "Shpfy Log Entry" = R,
        tabledata "Shpfy Metafield" = R,
        tabledata "Shpfy Order Attribute" = R,
        tabledata "Shpfy Order Disc.Appl." = R,
        tabledata "Shpfy Order Fulfillment" = R,
        tabledata "Shpfy Order Header" = R,
        tabledata "Shpfy Order Line" = R,
        tabledata "Shpfy Order Line Attribute" = R,
        tabledata "Shpfy Order Payment Gateway" = R,
        tabledata "Shpfy Order Risk" = R,
        tabledata "Shpfy Order Shipping Charges" = R,
        tabledata "Shpfy Orders To Import" = R,
        tabledata "Shpfy Order Tax Line" = R,
        tabledata "Shpfy Order Transaction" = R,
        tabledata "Shpfy Payment Method Mapping" = R,
        tabledata "Shpfy Payment Transaction" = R,
        tabledata "Shpfy Payout" = R,
        tabledata "Shpfy Product" = R,
#if not CLEAN22
        tabledata "Shpfy Province" = R,
#endif
#if not CLEAN21
#pragma warning disable AL0432
        tabledata "Shpfy Registered Store" = R,
#pragma warning restore AL0432
#endif
        tabledata "Shpfy Registered Store New" = R,
        tabledata "Shpfy Refund Header" = R,
        tabledata "Shpfy Refund Line" = R,
        tabledata "Shpfy Return Header" = R,
        tabledata "Shpfy Return Line" = R,
        tabledata "Shpfy Shipment Method Mapping" = R,
        tabledata "Shpfy Shop" = R,
        tabledata "Shpfy Shop Collection Map" = R,
        tabledata "Shpfy Shop Inventory" = R,
        tabledata "Shpfy Shop Location" = R,
        tabledata "Shpfy Synchronization Info" = R,
        tabledata "Shpfy Tag" = R,
        tabledata "Shpfy Tax Area" = R,
#if not CLEAN22
        tabledata "Shpfy Templates Warnings" = R,
#endif
        tabledata "Shpfy Transaction Gateway" = R,
        tabledata "Shpfy Variant" = R;
}
#pragma warning restore AS0090, AS0049
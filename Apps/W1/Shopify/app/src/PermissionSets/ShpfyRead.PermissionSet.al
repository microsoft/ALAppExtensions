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
        tabledata "Shpfy Credit Card Company" = R,
        tabledata "Shpfy Cue" = R,
        tabledata "Shpfy Customer" = R,
        tabledata "Shpfy Customer Address" = R,
        tabledata "Shpfy Customer Template" = R,
        tabledata "Shpfy Data Capture" = R,
        tabledata "Shpfy Gift Card" = R,
        tabledata "Shpfy Inventory Item" = R,
        tabledata "Shpfy Log Entry" = R,
        tabledata "Shpfy Metafield" = R,
        tabledata "Shpfy Order Attribute" = R,
        tabledata "Shpfy Order Disc.Appl." = R,
        tabledata "Shpfy Order Fulfillment" = R,
        tabledata "Shpfy Order Header" = R,
        tabledata "Shpfy Order Line" = R,
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
        tabledata "Shpfy Province" = R,
        tabledata "Shpfy Registered Store" = R,
        tabledata "Shpfy Shipment Method Mapping" = R,
        tabledata "Shpfy Shop" = R,
        tabledata "Shpfy Shop Collection Map" = R,
        tabledata "Shpfy Shop Inventory" = R,
        tabledata "Shpfy Shop Location" = R,
        tabledata "Shpfy Synchronization Info" = R,
        tabledata "Shpfy Tag" = R,
        tabledata "Shpfy Tax Area" = R,
        tabledata "Shpfy Transaction Gateway" = R,
        tabledata "Shpfy Variant" = R;
}
#pragma warning restore AS0090, AS0049
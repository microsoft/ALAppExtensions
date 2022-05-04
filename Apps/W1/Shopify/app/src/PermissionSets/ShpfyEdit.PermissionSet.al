/// <summary>
/// Shpfy - Edit Permissions (ID 30102).
/// </summary>
permissionset 30102 "Shpfy - Edit"
{
    Access = Internal;
    Assignable = false;
    Caption = 'Shopify - Edit', MaxLength = 30;

    IncludedPermissionSets = "Shpfy - Read",
        "Shpfy Indirect Perm";

    Permissions =
        tabledata "Shpfy Credit Card Company" = IMD,
        tabledata "Shpfy Cue" = IMD,
        tabledata "Shpfy Customer" = IMD,
        tabledata "Shpfy Customer Address" = IMD,
        tabledata "Shpfy Customer Template" = IMD,
        tabledata "Shpfy Data Capture" = IMD,
        tabledata "Shpfy Gift Card" = IMD,
        tabledata "Shpfy Inventory Item" = IMD,
        tabledata "Shpfy Log Entry" = IMD,
        tabledata "Shpfy Metafield" = IMD,
        tabledata "Shpfy Order Attribute" = IMD,
        tabledata "Shpfy Order Disc.Appl." = IMD,
        tabledata "Shpfy Order Fulfillment" = IMD,
        tabledata "Shpfy Order Header" = IMD,
        tabledata "Shpfy Order Line" = IMD,
        tabledata "Shpfy Order Payment Gateway" = IMD,
        tabledata "Shpfy Order Risk" = IMD,
        tabledata "Shpfy Order Shipping Charges" = IMD,
        tabledata "Shpfy Orders To Import" = IMD,
        tabledata "Shpfy Order Tax Line" = IMD,
        tabledata "Shpfy Order Transaction" = IMD,
        tabledata "Shpfy Payment Method Mapping" = IMD,
        tabledata "Shpfy Payment Transaction" = IMD,
        tabledata "Shpfy Payout" = IMD,
        tabledata "Shpfy Product" = IMD,
        tabledata "Shpfy Province" = IMD,
        tabledata "Shpfy Registered Store" = imd,
        tabledata "Shpfy Shipment Method Mapping" = IMD,
        tabledata "Shpfy Shop" = IMD,
        tabledata "Shpfy Shop Collection Map" = IMD,
        tabledata "Shpfy Shop Inventory" = IMD,
        tabledata "Shpfy Shop Location" = IMD,
        tabledata "Shpfy Synchronization Info" = IMD,
        tabledata "Shpfy Tag" = IMD,
        tabledata "Shpfy Tax Area" = IMD,
        tabledata "Shpfy Transaction Gateway" = IMD,
        tabledata "Shpfy Variant" = IMD;
}
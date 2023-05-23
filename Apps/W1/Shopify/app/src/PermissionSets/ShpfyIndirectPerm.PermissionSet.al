permissionset 30101 "Shpfy Indirect Perm"
{
    Assignable = false;
    Caption = 'Shopify Indirect Permissions', MaxLength = 30;

    Permissions =
        tabledata "Config. Template Header" = r,
        tabledata "Config. Template Line" = r,
        tabledata "Country/Region" = r,
        tabledata Customer = rimd,
        tabledata "Dimensions Template" = r,
        tabledata "Extended Text Header" = r,
        tabledata "Extended Text Line" = r,
        tabledata "General Ledger Setup" = r,
        tabledata Item = rim,
        tabledata "Item Attr. Value Translation" = r,
        tabledata "Item Attribute" = r,
        tabledata "Item Attribute Translation" = r,
        tabledata "Item Attribute Value" = r,
        tabledata "Item Attribute Value Mapping" = r,
        tabledata "Item Category" = rim,
        tabledata "Item Reference" = rim,
        tabledata "Item Unit of Measure" = rim,
        tabledata "Item Variant" = rim,
        tabledata "Item Vendor" = rim,
        tabledata "Sales Header" = rimd,
        tabledata "Sales Line" = rimd,
        tabledata "Sales Shipment Header" = rm,
        tabledata "Sales Shipment Line" = r,
        tabledata "Shipping Agent" = r,
        tabledata "Unit of Measure" = rim,
        tabledata "VAT Posting Setup" = r,
        tabledata Vendor = rim;
}

/// <summary>
/// Enum Shpfy Inventory Management (ID 30124).
/// </summary>
enum 30124 "Shpfy Inventory Management"
{
    Access = Internal;
    Caption = 'Shopify Inventory Management';
    Extensible = true;

    value(0; SHOPIFY)
    {
        Caption = 'Shopify';
    }
    value(1; NOT_MANAGED)
    {
        Caption = 'Not Managed';
    }
    value(2; FULFILLMENT_SERVICE)
    {
        Caption = 'Fulfillment Service';
    }

}

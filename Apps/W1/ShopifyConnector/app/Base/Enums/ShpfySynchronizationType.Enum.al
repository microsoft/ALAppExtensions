/// <summary>
/// Enum Shopify Synchronization Type (ID 30103).
/// </summary>
enum 30103 "Shpfy Synchronization Type"
{
    Access = Internal;
    Caption = 'Shopify Synchronization Type';

    value(0; Undefined)
    {
        Caption = ' ';
    }
    value(1; Products)
    {
        Caption = 'Products';
    }
    value(2; Orders)
    {
        Caption = 'Orders';
    }
    value(3; Customers)
    {
        Caption = 'Customers';
    }

}

/// <summary>
/// Enum Shpfy Customer Import Range (ID 30105).
/// </summary>
enum 30105 "Shpfy Customer Import Range"
{
    Access = Internal;
    Caption = 'Shopify Customer Import Range';
    Extensible = true;

    value(0; None)
    {
        Caption = 'None';
    }
    value(1; WithOrderImport)
    {
        Caption = 'With Order Import';
    }
    value(2; AllCustomers)
    {
        Caption = 'All Customers';
    }
}

/// <summary>
/// Enum Shpfy Cancel Reason (ID 30116).
/// </summary>
enum 30116 "Shpfy Cancel Reason"
{
    Access = Internal;
    Caption = 'Shopify Cancel Reason';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Customer)
    {
        Caption = 'Customer';
    }
    value(2; Fraud)
    {
        Caption = 'Fraud';
    }
    value(3; Inventory)
    {
        Caption = 'Inventory';
    }
    value(4; Other)
    {
        Caption = 'Other';
    }
    value(99; Unknown)
    {
        Caption = 'Unknown';
    }
}

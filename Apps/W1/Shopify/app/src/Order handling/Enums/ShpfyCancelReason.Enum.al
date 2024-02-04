namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Cancel Reason (ID 30116).
/// </summary>
enum 30116 "Shpfy Cancel Reason"
{
    Caption = 'Shopify Cancel Reason';
    Extensible = false;

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
    value(5; Staff)
    {
        Caption = 'Staff';
    }
    value(6; Declined)
    {
        Caption = 'Declined';
    }
    value(99; Unknown)
    {
        Caption = 'Unknown';
    }
}

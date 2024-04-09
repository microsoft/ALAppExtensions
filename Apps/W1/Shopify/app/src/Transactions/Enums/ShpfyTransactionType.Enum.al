namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Transaction Type (ID 30134).
/// </summary>
enum 30134 "Shpfy Transaction Type"
{
    Caption = 'Shopify Transaction Type';
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Authorization)
    {
        Caption = 'Authorization';
    }
    value(2; Capture)
    {
        Caption = 'Capture';
    }
    value(3; Sale)
    {
        Caption = 'Sale';
    }
    value(4; Void)
    {
        Caption = 'Void';
    }
    value(5; Refund)
    {
        Caption = 'Refund';
    }

}

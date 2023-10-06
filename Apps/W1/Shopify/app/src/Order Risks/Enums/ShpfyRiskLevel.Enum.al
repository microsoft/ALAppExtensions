namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Risk Level (ID 30126).
/// </summary>
enum 30126 "Shpfy Risk Level"
{
    Caption = 'Shopify Risk Level';
    Extensible = false;
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Low)
    {
        Caption = 'Low';
    }
    value(2; Medium)
    {
        Caption = 'Medium';
    }
    value(3; High)
    {
        Caption = 'High';
    }

}

/// <summary>
/// Enum Shpfy Processing Method (ID 30118).
/// </summary>
enum 30118 "Shpfy Processing Method"
{
    Access = Internal;
    Caption = 'Shopify Processing Method';
    Extensible = true;

    value(0; Checkout)
    {
        Caption = 'Checkout';
    }
    value(1; Direct)
    {
        Caption = 'Direct';
    }
    value(2; Manual)
    {
        Caption = 'Manual';
    }
    value(3; Offsite)
    {
        Caption = 'Offsite';
    }
    value(4; Express)
    {
        Caption = 'Express';
    }
    value(5; Free)
    {
        Caption = 'Free';
    }
    value(99; Unknown)
    {
        Caption = 'Unknown';
    }
}

/// <summary>
/// Enum Shpfy Allocation Method (ID 30115).
/// </summary>
enum 30115 "Shpfy Allocation Method"
{
    Access = Internal;
    Caption = 'Shopify Allocation Method';

    value(0; across)
    {
        Caption = 'Across';
    }
    value(1; each)
    {
        Caption = 'Each';
    }
    value(2; one)
    {
        Caption = 'One';
    }
    value(99; Unknown)
    {
        Caption = 'Unknown';
    }
}

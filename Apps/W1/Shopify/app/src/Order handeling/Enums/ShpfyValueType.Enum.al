/// <summary>
/// Enum Shpfy Value Type (ID 30123).
/// </summary>
enum 30123 "Shpfy Value Type"
{
    Access = Internal;
    Caption = 'Shopify Value Type';
    Extensible = true;

    value(3; "Fixed Amount")
    {
        Caption = 'Fixed Amount';
    }
    value(4; "Percentage")
    {
        Caption = 'Percentage';
    }
    value(99; Unknown)
    {
        Caption = 'Unknown';
    }
}

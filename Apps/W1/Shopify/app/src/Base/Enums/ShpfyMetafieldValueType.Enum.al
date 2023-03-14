/// <summary>
/// Enum Shpfy Metafield Value Type (ID 30102).
/// </summary>
enum 30102 "Shpfy Metafield Value Type"
{
    Access = Internal;
    Caption = 'Shopify  Metafield Value Type';
    Extensible = false;

    value(0; String)
    {
        Caption = 'String';
    }

    value(1; Integer)
    {
        Caption = 'Integer';
    }

    value(2; Json)
    {
        Caption = 'Json';
    }
}
/// <summary>
/// Enum Shpfy Import Action (ID 30100).
/// </summary>
enum 30100 "Shpfy Import Action"
{
    Access = Internal;
    Caption = 'Shopify Import Action';
    Extensible = true;

    value(0; New)
    {
        Caption = 'New';
    }
    value(1; Update)
    {
        Caption = 'Update';
    }
}

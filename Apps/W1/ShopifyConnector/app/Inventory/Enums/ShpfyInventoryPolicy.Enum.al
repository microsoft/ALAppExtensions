/// <summary>
/// Enum Shpfy Inventory Policy (ID 30125).
/// </summary>
enum 30125 "Shpfy Inventory Policy"
{
    Access = Internal;
    Caption = 'Shopify Inventory Policy';
    Extensible = true;

    value(0; DENY)
    {
        Caption = 'Deny';
    }
    value(1; CONTINUE)
    {
        Caption = 'Continue';
    }

}

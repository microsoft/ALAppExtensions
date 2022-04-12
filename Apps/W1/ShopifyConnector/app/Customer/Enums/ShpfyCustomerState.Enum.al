/// <summary>
/// Enum Shpfy Customer State (ID 30107).
/// </summary>
enum 30107 "Shpfy Customer State"
{
    Access = Internal;
    Caption = 'Shopify Customer State';
    Extensible = true;

    value(0; Disabled)
    {
        Caption = 'Disabled';
    }

    value(1; Invited)
    {
        Caption = 'Invited';
    }

    value(2; Enabled)
    {
        Caption = 'Enabled';
    }

    value(3; Declined)
    {
        Caption = 'Declined';
    }
}
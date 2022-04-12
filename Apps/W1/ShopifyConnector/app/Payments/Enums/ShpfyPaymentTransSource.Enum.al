/// <summary>
/// Enum Shpfy Payment Transaction Source (ID 30114).
/// </summary>
enum 30114 "Shpfy Payment Trans. Source"
{
    Access = Internal;
    Caption = 'Shopify Payment Trans. Source';
    Extensible = true;

    value(0; Unknown)
    {
        Caption = ' ';
    }
    value(1; Charge)
    {
        Caption = 'Charge';
    }
    value(2; Refund)
    {
        Caption = 'Refund';
    }
    value(3; Dispute)
    {
        Caption = 'Dispute';
    }
    value(4; Reserve)
    {
        Caption = 'Reserve';
    }
    value(5; Adjustment)
    {
        Caption = 'Adjustment';
    }
    value(6; Payout)
    {
        Caption = 'Payout';
    }

}

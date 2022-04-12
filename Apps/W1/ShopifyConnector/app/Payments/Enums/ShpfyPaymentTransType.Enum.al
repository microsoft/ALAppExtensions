/// <summary>
/// Enum Shpfy Payment Transcation Type (ID 30127).
/// </summary>
enum 30127 "Shpfy Payment Trans. Type"
{
    Access = Internal;
    Caption = 'Shopify Payment Transcation Type';
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
    value(6; Credit)
    {
        Caption = 'Credit';
    }
    value(7; Debit)
    {
        Caption = 'Debit';
    }
    value(8; Payout)
    {
        Caption = 'Payout';
    }
    value(9; "Payout Failure")
    {
        Caption = 'Payout Failure';
    }
    value(10; "Payout Cancellation")
    {
        Caption = 'Payout Cancellation';
    }
    value(11; "Payment Refund")
    {
        Caption = 'Payment Refund';
    }

}

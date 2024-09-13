namespace Microsoft.SubscriptionBilling;

enum 8008 "Usage Based Billing Doc. Type"
{
    Extensible = false;
    value(0; None)
    {
        Caption = ' ', Locked = true;
    }
    value(1; Invoice)
    {
        Caption = 'Invoice';
    }
    value(2; "Credit Memo")
    {
        Caption = 'Credit Memo';
    }
    value(3; "Posted Invoice")
    {
        Caption = 'Posted Invoice';
    }
    value(4; "Posted Credit Memo")
    {
        Caption = 'Posted Credit Memo';
    }
}

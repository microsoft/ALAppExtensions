namespace Microsoft.SubscriptionBilling;

enum 8054 "Rec. Billing Document Type"
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
}
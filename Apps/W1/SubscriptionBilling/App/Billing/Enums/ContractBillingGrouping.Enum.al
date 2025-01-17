namespace Microsoft.SubscriptionBilling;

enum 8059 "Contract Billing Grouping"
{
    Extensible = false;

    value(0; None)
    {
        Caption = ' ', Locked = true;
    }
    value(1; Contract)
    {
        Caption = 'Contract';
    }
    value(2; "Contract Partner")
    {
        Caption = 'Contract Partner';
    }
}
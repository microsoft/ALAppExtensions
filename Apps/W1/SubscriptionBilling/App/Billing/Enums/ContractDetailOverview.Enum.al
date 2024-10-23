namespace Microsoft.SubscriptionBilling;

enum 8060 "Contract Detail Overview"
{
    Extensible = false;
    value(0; None)
    {
        Caption = ' ', Locked = true;
    }
    value(1; "Without prices")
    {
        Caption = 'Without prices';
    }
    value(2; "Complete")
    {
        Caption = 'Complete';
    }
}
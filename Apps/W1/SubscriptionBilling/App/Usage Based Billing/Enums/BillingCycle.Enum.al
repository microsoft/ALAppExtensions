namespace Microsoft.SubscriptionBilling;

enum 8011 "Billing Cycle"
{
    Extensible = false;
    value(0; None)
    {
        Caption = ' ', Locked = true;
    }
    value(1; Month)
    {
        Caption = 'Month';
    }
    value(2; Year)
    {
        Caption = 'Year';
    }
}

namespace Microsoft.SubscriptionBilling;

enum 8005 "Period Calculation"
{
    Extensible = false;

    value(0; "Align to Start of Month")
    {
        Caption = 'Align to Start of Month';
    }
    value(1; "Align to End of Month")
    {
        Caption = 'Align to End of Month';
    }
}

namespace Microsoft.SubscriptionBilling;

enum 8051 "Invoicing Via"
{
    Extensible = false;

    value(0; "Sales")
    {
        Caption = 'Sales';
    }
    value(1; "Contract")
    {
        Caption = 'Contract';
    }
}

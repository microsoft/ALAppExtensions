namespace Microsoft.SubscriptionBilling;

enum 8056 "Item Service Commitment Type"
{
    Extensible = false;

    value(0; "Sales without Service Commitment")
    {
        Caption = 'Sales without Service Commitment';
    }
    value(1; "Sales with Service Commitment")
    {
        Caption = 'Sales with Service Commitment';
    }
    value(2; "Service Commitment Item")
    {
        Caption = 'Service Commitment Item';
    }
    value(3; "Invoicing Item")
    {
        Caption = 'Invoicing Item';
    }

}

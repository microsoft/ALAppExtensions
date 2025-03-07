namespace Microsoft.SubscriptionBilling;

enum 8056 "Item Service Commitment Type"
{
    Extensible = false;

    value(0; "Sales without Service Commitment")
    {
        Caption = 'No Subscription';
    }
    value(1; "Sales with Service Commitment")
    {
        Caption = 'Sales with Subscription';
    }
    value(2; "Service Commitment Item")
    {
        Caption = 'Subscription Item';
    }
    value(3; "Invoicing Item")
    {
        Caption = 'Invoicing Item';
    }

}

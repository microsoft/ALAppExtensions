namespace Microsoft.SubscriptionBilling;

enum 8013 "Usage Data Reference Type"
{
    Extensible = false;
    value(0; Product)
    {
        Caption = 'Product';
    }
    value(1; Subscription)
    {
        Caption = 'Subscription';
    }
    value(2; Customer)
    {
        Caption = 'Customer';
    }
}

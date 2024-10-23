namespace Microsoft.SubscriptionBilling;

enum 8053 "Service Partner"
{
    Extensible = false;

    value(0; Customer)
    {
        Caption = 'Customer';
    }
    value(1; "Vendor")
    {
        Caption = 'Vendor';
    }
}

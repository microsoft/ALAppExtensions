namespace Microsoft.SubscriptionBilling;

enum 8019 "Service Object Type"
{
    Extensible = false;

    value(0; Item)
    {
        Caption = 'Item';
    }
    value(1; "G/L Account")
    {
        Caption = 'G/L Account';
    }
}

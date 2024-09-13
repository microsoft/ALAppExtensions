namespace Microsoft.SubscriptionBilling;

enum 8002 "Contract Origin Name Type"
{
    Extensible = false;

    value(0; None)
    {
        Caption = ' ', Locked = true;
    }
    value(1; "Sell-to Customer")
    {
        Caption = 'Sell-to Customer';
    }
    value(2; "Ship-to Address")
    {
        Caption = 'Ship-to Address';
    }
    value(3; Both)
    {
        Caption = 'Both';
    }
}
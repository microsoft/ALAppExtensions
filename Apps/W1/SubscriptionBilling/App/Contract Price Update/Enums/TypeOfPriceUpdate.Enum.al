namespace Microsoft.SubscriptionBilling;

enum 8004 "Type Of Price Update"
{
    Extensible = false;

    value(0; None)
    {
        Caption = ' ', Locked = true;
    }
    value(1; "Contract Renewal")
    {
        Caption = 'Contract Renewal';
    }
    value(2; "Price Update")
    {
        Caption = 'Price Update';
    }
}

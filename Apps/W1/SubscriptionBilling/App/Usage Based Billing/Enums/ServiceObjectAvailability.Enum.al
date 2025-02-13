namespace Microsoft.SubscriptionBilling;

enum 8018 "Service Object Availability"
{
    Extensible = false;

    value(0; None)
    {
        Caption = ' ', Locked = true;
    }
    value(1; Connected)
    {
        Caption = 'Connected';
    }
    value(2; Available)
    {
        Caption = 'Available';
    }
    value(3; "Not Available")
    {
        Caption = 'Not Available';
    }
}

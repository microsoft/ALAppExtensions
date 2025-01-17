namespace Microsoft.SubscriptionBilling;

enum 8014 "Usage Data Subscription Status"
{
    Extensible = false;
    value(0; None)
    {
        Caption = ' ', Locked = true;
    }
    value(1; Active)
    {
        Caption = 'Active';
    }
    value(2; Suspended)
    {
        Caption = 'Suspended';
    }
    value(3; Deleted)
    {
        Caption = 'Deleted';
    }
    value(4; Inactive)
    {
        Caption = 'Inactive';
    }
    value(5; "Waiting for cancellation")
    {
        Caption = 'Waiting for cancellation';
    }
}

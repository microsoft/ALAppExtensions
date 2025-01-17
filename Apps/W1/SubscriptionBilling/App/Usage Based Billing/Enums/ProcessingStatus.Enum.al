namespace Microsoft.SubscriptionBilling;

enum 8012 "Processing Status"
{
    Extensible = false;
    value(0; None)
    {
        Caption = ' ', Locked = true;
    }
    value(1; Ok)
    {
        Caption = 'Ok';
    }
    value(2; Error)
    {
        Caption = 'Error';
    }
    value(3; Closed)
    {
        Caption = 'Closed';
    }
}

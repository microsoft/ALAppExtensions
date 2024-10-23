namespace Microsoft.SubscriptionBilling;

enum 8017 Process
{
    Extensible = true;

    value(0; "No Contract Assigned")
    {
        Caption = 'No Contract Assigned';
    }
    value(1; "Contract Assigned")
    {
        Caption = 'Contract Assigned';
    }
    value(2; "Contract Renewal")
    {
        Caption = 'Contract Renewal';
    }
}

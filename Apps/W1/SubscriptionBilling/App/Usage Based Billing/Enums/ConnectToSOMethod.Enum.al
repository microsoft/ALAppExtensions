namespace Microsoft.SubscriptionBilling;

enum 8009 "Connect To SO Method"
{
    Extensible = false;

    value(0; "None")
    {
        Caption = 'None';
    }
    value(1; "Existing Service Commitments")
    {
        Caption = 'Existing Service Commitments';
    }
    value(2; "New Service Commitments")
    {
        Caption = 'New Service Commitments';
    }
}

namespace Microsoft.SubscriptionBilling;

enum 8055 "Contract Line Type"
{
    Extensible = false;
    value(0; "Comment")
    {
        Caption = 'Comment';
    }
    value(1; "Service Commitment")
    {
        Caption = 'Service Commitment';
    }
}
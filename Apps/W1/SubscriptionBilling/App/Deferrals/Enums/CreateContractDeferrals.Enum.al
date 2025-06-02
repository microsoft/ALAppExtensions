namespace Microsoft.SubscriptionBilling;

enum 8020 "Create Contract Deferrals"
{
    value(0; "Contract-dependent")
    {
        Caption = 'Contract-dependent';
    }
    value(1; Yes)
    {
        Caption = 'Yes';
    }
    value(2; No)
    {
        Caption = 'No';
    }
}

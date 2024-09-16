namespace Microsoft.SubscriptionBilling;

enum 8058 "Vendor Rec. Billing Grouping"
{
    Extensible = false;
    Access = Internal;

    value(0; "Contract")
    {
        Caption = 'Contract';
    }
    value(1; "Buy-from Vendor No.")
    {
        Caption = 'Contract Partner (Buy-from Vendor)';
    }
    value(2; "Pay-to Vendor No.")
    {
        Caption = 'Invoice recipient (Pay-To Vendor)';
    }
}
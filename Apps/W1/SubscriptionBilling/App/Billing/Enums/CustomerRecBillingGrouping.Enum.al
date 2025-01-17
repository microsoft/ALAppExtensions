namespace Microsoft.SubscriptionBilling;

enum 8057 "Customer Rec. Billing Grouping"
{
    Extensible = false;

    value(0; "Contract")
    {
        Caption = 'Contract';
    }
    value(1; "Sell-to Customer No.")
    {
        Caption = 'Contract Partner (Sell-to Customer)';
    }
    value(2; "Bill-to Customer No.")
    {
        Caption = 'Invoice recipient (Bill-To Customer)';
    }
}
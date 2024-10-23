namespace Microsoft.SubscriptionBilling;

enum 8007 "Usage Based Pricing"
{
    Extensible = false;

    value(0; None)
    {
        Caption = ' ', Locked = true;
    }
    value(1; "Usage Quantity")
    {
        Caption = 'Usage Quantity';
    }
    value(2; "Fixed Quantity")
    {
        Caption = 'Fixed Quantity';
    }
    value(3; "Unit Cost Surcharge")
    {
        Caption = 'Unit Cost Surcharge';
    }
}

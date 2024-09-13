namespace Microsoft.SubscriptionBilling;

enum 8003 "Price Update Method" implements "Contract Price Update"
{
    Extensible = false;

    value(0; "Calculation Base by %")
    {
        Caption = 'Calculation Base by %';
        Implementation = "Contract Price Update" = "Calculation Base By Perc";
    }
    value(1; "Price by %")
    {
        Caption = 'Price by %';
        Implementation = "Contract Price Update" = "Price By Percent";
    }
    value(2; "Recent Item Prices")
    {
        Caption = 'Recent Item Prices';
        Implementation = "Contract Price Update" = "Recent Item Price";
    }
}

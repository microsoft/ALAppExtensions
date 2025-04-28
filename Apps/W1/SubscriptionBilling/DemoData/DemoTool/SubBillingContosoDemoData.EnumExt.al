namespace Microsoft.SubscriptionBilling;

using Microsoft.DemoTool;

enumextension 8101 "Sub. Billing Contoso Demo Data" extends "Contoso Demo Data Module"
{
    value(8101; "Subscription Billing")
    {
        Implementation = "Contoso Demo Data Module" = "Sub. Billing Contoso Module";
    }
}
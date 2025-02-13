namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.RoleCenters;

pageextension 8082 "Order Processor RC" extends "Order Processor Role Center"
{
    layout
    {
        addafter(Control14)
        {
            part(SubBillingActivities; "Sub. Billing Activities")
            {
                ApplicationArea = Jobs;
                Caption = 'Subscription & Recurring Billing';
            }
        }
    }
}

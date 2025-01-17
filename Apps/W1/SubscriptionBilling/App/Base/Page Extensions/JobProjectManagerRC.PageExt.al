namespace Microsoft.SubscriptionBilling;

using Microsoft.Projects.RoleCenters;

pageextension 8083 "Job Project Manager RC" extends "Job Project Manager RC"
{
    layout
    {
        addafter(Control77)
        {
            part(SubBillingActivities; "Sub. Billing Activities")
            {
                ApplicationArea = Jobs;
                Caption = 'Subscription & Recurring Billing';
            }
        }
    }
}

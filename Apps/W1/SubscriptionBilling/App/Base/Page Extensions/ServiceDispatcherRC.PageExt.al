namespace Microsoft.SubscriptionBilling;

using Microsoft.Service.RoleCenters;

pageextension 8081 "Service Dispatcher RC" extends "Service Dispatcher Role Center"
{
    layout
    {
        addafter(Control32)
        {
            part(SubBillingActivities; "Sub. Billing Activities")
            {
                ApplicationArea = Jobs;
                Caption = 'Subscription & Recurring Billing';
            }
        }
    }
}

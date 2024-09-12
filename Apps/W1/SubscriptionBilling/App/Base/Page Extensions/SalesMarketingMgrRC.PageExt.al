namespace Microsoft.SubscriptionBilling;

using Microsoft.CRM.RoleCenters;

pageextension 8084 "Sales Marketing Mgr. RC" extends "Sales & Relationship Mgr. RC"
{
    layout
    {
        addafter(Control16)
        {
            part(SubBillingActivities; "Sub. Billing Activities")
            {
                ApplicationArea = Jobs;
                Caption = 'Subscription & Recurring Billing';
            }
        }
    }
}

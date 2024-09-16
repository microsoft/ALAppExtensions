namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.RoleCenters;

pageextension 8080 "Business Manager RC" extends "Business Manager Role Center"
{
    layout
    {
        addafter(Control46)
        {
            part(SubBillingActivities; "Sub. Billing Activities")
            {
                ApplicationArea = Jobs;
                Caption = 'Subscription & Recurring Billing';
            }
        }
    }
}

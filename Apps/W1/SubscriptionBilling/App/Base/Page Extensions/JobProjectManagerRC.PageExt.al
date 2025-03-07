#if not CLEAN26
namespace Microsoft.SubscriptionBilling;

using Microsoft.Projects.RoleCenters;

pageextension 8083 "Job Project Manager RC" extends "Job Project Manager RC"
{
    ObsoleteReason = 'Removed as Subscription Billing is not relevant in context of projects.';
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';
    layout
    {
        addafter(Control77)
        {
            part(SubBillingActivities; "Sub. Billing Activities")
            {
                ObsoleteReason = 'Removed as Subscription Billing is not relevant in context of projects.';
                ObsoleteState = Pending;
                ObsoleteTag = '26.0';
                Visible = false;
                ApplicationArea = All;
                Caption = 'Subscription Billing';
            }
        }
    }
}
#endif

#if not CLEAN26
namespace Microsoft.SubscriptionBilling;

using Microsoft.CRM.RoleCenters;

pageextension 8084 "Sales Marketing Mgr. RC" extends "Sales & Relationship Mgr. RC"
{
    ObsoleteReason = 'Removed as Subscription Billing is not relevant in context of sales & marketing.';
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';
    layout
    {
        addafter(Control16)
        {
            part(SubBillingActivities; "Sub. Billing Activities")
            {
                ObsoleteReason = 'Removed as Subscription Billing is not relevant in context of sales & marketing.';
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

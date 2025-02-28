#if not CLEAN26
namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.RoleCenters;

pageextension 8080 "Business Manager RC" extends "Business Manager Role Center"
{
    ObsoleteReason = 'Removed as Subscription Billing is not relevant in context of Business Manager.';
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';
    layout
    {
        addafter(Control46)
        {
            part(SubBillingActivities; "Sub. Billing Activities")
            {
                ObsoleteReason = 'Removed as Subscription Billing is not relevant in context of Business Manager.';
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

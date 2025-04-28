#if not CLEAN26
namespace Microsoft.SubscriptionBilling;

using Microsoft.Service.RoleCenters;

pageextension 8081 "Service Dispatcher RC" extends "Service Dispatcher Role Center"
{
    ObsoleteReason = 'Removed as Subscription Billing is not relevant in context of service module.';
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';
    layout
    {
        addafter(Control32)
        {
            part(SubBillingActivities; "Sub. Billing Activities")
            {
                ObsoleteReason = 'Removed as Subscription Billing is not relevant in context of service module.';
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

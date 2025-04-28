#if not CLEAN26
namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.RoleCenters;

pageextension 8082 "Order Processor RC" extends "Order Processor Role Center"
{
    ObsoleteReason = 'Removed as Subscription Billing is not relevant in context of order processor.';
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';
    layout
    {
        addafter(Control14)
        {
            part(SubBillingActivities; "Sub. Billing Activities")
            {
                ObsoleteReason = 'Removed as Subscription Billing is not relevant in context of order processor.';
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

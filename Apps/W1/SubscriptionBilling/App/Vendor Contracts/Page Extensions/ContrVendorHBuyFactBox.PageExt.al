namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Payables;

pageextension 8001 "Contr. Vendor H. Buy FactBox" extends "Vendor Hist. Buy-from FactBox"
{
    layout
    {
        addlast(Control1)
        {
            field("Vendor Contracts"; Rec."Vendor Contracts")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Vendor Subscription Contracts';
                DrillDownPageId = "Vendor Contracts";
                ToolTip = 'Specifies the number of Vendor Subscription Contracts that have been registered for the vendor.';
            }
        }
    }
}
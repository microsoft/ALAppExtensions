namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Payables;

pageextension 8008 "Vendor Ledger Entries" extends "Vendor Ledger Entries"
{
    layout
    {
        addlast(control1)
        {
            field("Recurring Billing"; Rec."Recurring Billing")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether the entry was created via recurring billing.';
            }
        }
    }
}

namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Receivables;

pageextension 8007 "Customer Ledger Entries" extends "Customer Ledger Entries"
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

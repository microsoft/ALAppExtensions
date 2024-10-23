namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

pageextension 8066 "Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        addlast("Invoice Details")
        {
            field("Contract Detail Overview"; Rec."Contract Detail Overview")
            {
                ApplicationArea = Basic, Suite;
                Enabled = Rec."Recurring Billing";
                ToolTip = 'Specifies whether the billing details for this document are automatically output.';
            }
        }
    }
}
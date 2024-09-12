namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;

pageextension 8068 "Posted Sales Invoice" extends "Posted Sales Invoice"
{
    layout
    {
        addlast("Invoice Details")
        {
            field("Contract Detail Overview"; Rec."Contract Detail Overview")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies whether the billing details for this document are automatically output.';
            }
        }
    }
}
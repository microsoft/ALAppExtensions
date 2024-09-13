namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;

pageextension 8069 "Posted Sales Credit Memo" extends "Posted Sales Credit Memo"
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
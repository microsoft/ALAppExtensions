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
                ToolTip = 'Specifies whether to automatically print the billing details for this document. This is only relevant if you are using Subscription Billing functionalities.';
            }
        }
    }
}
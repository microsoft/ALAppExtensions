namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

pageextension 8067 "Sales Credit Memo" extends "Sales Credit Memo"
{
    layout
    {
        addlast("Credit Memo Details")
        {
            field("Contract Detail Overview"; Rec."Contract Detail Overview")
            {
                ApplicationArea = Basic, Suite;
                Enabled = Rec."Recurring Billing";
                ToolTip = 'Specifies whether to automatically print the billing details for this document. This is only relevant if you are using Subscription Billing functionalities.';
            }
        }
    }
}
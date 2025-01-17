namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

pageextension 8077 "Sales Line FactBox" extends "Sales Line FactBox"
{
    layout
    {
        addafter("Required Quantity")
        {
            field("Service Commitments"; Rec."Service Commitments")
            {
                ApplicationArea = All;
                ToolTip = 'Shows the number of service commitments (Subscription Billing) for the sales line.';
            }
        }
    }
}
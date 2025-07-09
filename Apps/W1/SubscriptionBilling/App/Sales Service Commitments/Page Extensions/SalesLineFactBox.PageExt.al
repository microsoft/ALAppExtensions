namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

pageextension 8077 "Sales Line FactBox" extends "Sales Line FactBox"
{
    layout
    {
        addafter("Required Quantity")
        {
            field("Service Commitments"; Rec."Subscription Lines")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the number of Subscription Lines for the sales line.';
            }
        }
    }
}
namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

pageextension 8009 "Blanket Sales Order Subform" extends "Blanket Sales Order Subform"
{
    layout
    {
        addafter("Line Amount")
        {
            field("Service Commitments"; Rec."Subscription Lines")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the number of Subscription Lines for the sales line.';
            }
        }
    }
    actions
    {
        addlast("&Line")
        {
            action(ShowSalesServiceCommitments)
            {
                ApplicationArea = All;
                Caption = 'Subscription Lines';
                Image = AllLines;
                RunObject = page "Sales Service Commitments";
                RunPageLink = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Document Line No." = field("Line No.");
                ToolTip = 'Shows the Subscription Lines for the sales line.';
            }
        }
        addlast("F&unctions")
        {
            action(AddSalesServiceCommitment)
            {
                ApplicationArea = All;
                Caption = 'Add Subscription Lines';
                Image = ExpandDepositLine;
                ToolTip = 'Shows all Subscription Lines for the item. Subscription Lines can be added, changed or removed.';

                trigger OnAction()
                var
                    SalesServiceCommitmentMgmt: Codeunit "Sales Subscription Line Mgmt.";
                begin
                    SalesServiceCommitmentMgmt.AddAdditionalSalesServiceCommitmentsForSalesLine(Rec);
                end;
            }
        }
    }
}
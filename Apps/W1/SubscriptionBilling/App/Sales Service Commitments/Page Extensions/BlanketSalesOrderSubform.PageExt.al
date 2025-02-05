namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

pageextension 8009 "Blanket Sales Order Subform" extends "Blanket Sales Order Subform"
{
    layout
    {
        addafter("Line Amount")
        {
            field("Service Commitments"; Rec."Service Commitments")
            {
                ApplicationArea = All;
                ToolTip = 'Shows the number of service commitments (Subscription Billing) for the sales line.';
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
                Caption = 'Service Commitments';
                Image = AllLines;
                RunObject = page "Sales Service Commitments";
                RunPageLink = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Document Line No." = field("Line No.");
                ToolTip = 'Shows the service commitments for the sales line.';
            }
        }
        addlast("F&unctions")
        {
            action(AddSalesServiceCommitment)
            {
                ApplicationArea = All;
                Caption = 'Add Service Commitments';
                Image = ExpandDepositLine;
                ToolTip = 'Shows all service commitments for the item. Service commitments can be added, changed or removed.';

                trigger OnAction()
                var
                    SalesServiceCommitmentMgmt: Codeunit "Sales Service Commitment Mgmt.";
                begin
                    SalesServiceCommitmentMgmt.AddAdditionalSalesServiceCommitmentsForSalesLine(Rec);
                end;
            }
        }
    }
}
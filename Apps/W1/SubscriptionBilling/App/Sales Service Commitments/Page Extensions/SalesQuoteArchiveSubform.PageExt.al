namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Archive;

pageextension 8078 "Sales Quote Archive Subform" extends "Sales Quote Archive Subform"
{
    layout
    {
        addafter("Line Amount")
        {
            field("Service Commitments"; Rec."Service Commitments")
            {
                ApplicationArea = All;
                ToolTip = 'Shows the number of service commitments for the sales line.';
            }
        }
    }
    actions
    {
        addfirst(processing)
        {
            action(ShowSalesServiceCommitmentArchive)
            {
                ApplicationArea = All;
                Caption = 'Service Commitments';
                Image = AllLines;
                RunObject = Page "Sales Serv. Comm. Archive List";
                RunPageLink = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Document Line No." = field("Line No.");
                ToolTip = 'Shows the archived service commitments for the line.';
            }
        }
    }
}
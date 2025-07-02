namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Archive;

pageextension 8078 "Sales Quote Archive Subform" extends "Sales Quote Archive Subform"
{
    layout
    {
        addafter("Line Amount")
        {
            field("Service Commitments"; Rec."Subscription Lines")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the number of Subscription Lines for the archived sales line.';
            }
        }
    }
    actions
    {
        addlast("&Line")
        {
            action(ShowSalesServiceCommitmentArchive)
            {
                ApplicationArea = All;
                Caption = 'Subscription Lines';
                Image = AllLines;
                RunObject = page "Sales Serv. Comm. Archive List";
                RunPageLink = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Document Line No." = field("Line No.");
                ToolTip = 'Shows the archived Subscription Lines for the line.';
            }
        }
    }
}
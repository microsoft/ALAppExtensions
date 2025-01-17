namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Archive;

pageextension 8010 "Blanket Sales Order Arch. Sub." extends "Blanket Sales Order Arch. Sub."
{
    layout
    {
        addafter("Line Amount")
        {
            field("Service Commitments"; Rec."Service Commitments")
            {
                ApplicationArea = All;
                ToolTip = 'Shows the number of service commitments (Subscription Billing) for the archived sales line.';
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
                Caption = 'Service Commitments';
                Image = AllLines;
                RunObject = page "Sales Serv. Comm. Archive List";
                RunPageLink = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Document Line No." = field("Line No.");
                ToolTip = 'Shows the archived service commitments for the line.';
            }
        }
    }
}
namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Document;
using Microsoft.Sustainability.Ledger;

pageextension 6270 "Sust. Finished Prod. Order" extends "Finished Production Order"
{

    actions
    {
        addafter("&Warehouse Entries")
        {
            action("Sustainability Ledger Entries")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Sustainability Ledger Entries';
                Image = Ledger;
                RunObject = Page "Sustainability Ledger Entries";
                RunPageLink = "Document No." = field("No.");
                ToolTip = 'View the sustainability ledger entries on the document or journal line.';
            }
            action("Sustainability Value Entries")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Sustainability Value Entries';
                Image = Ledger;
                RunObject = Page "Sustainability Value Entries";
                RunPageLink = "Document No." = field("No.");
                ToolTip = 'View the sustainability Value entries on the document or journal line.';
            }
        }
    }
}
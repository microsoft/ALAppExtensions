namespace Microsoft.Finance.GeneralLedger.Review;

using Microsoft.Finance.GeneralLedger.Ledger;

pageextension 22204 "General Ledger Entries Review" extends "General Ledger Entries"
{
    actions
    {
        addfirst("Ent&ry")
        {
            action("Review Entries")
            {
                ApplicationArea = Dimensions;
                Caption = 'Review Entries';
                Image = CheckList;
                ToolTip = 'Opens a page where you can manually review G/L entries';
                RunObject = Page "Review G/L Entries";
                RunPageLink = "G/L Account No." = field("G/L Account No.");
                AboutTitle = 'Review Entries';
                AboutText = 'Opens a new page where you can manually mark entries as reviewed and open the page in Excel';
                AccessByPermission = table "G/L Entry" = X;
            }
        }

        addlast(Promoted)
        {
            actionref(ReviewEntries_Promoted; "Review Entries")
            {
            }
        }
    }
}
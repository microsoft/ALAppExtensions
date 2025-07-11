namespace Microsoft.Finance.GeneralLedger.Review;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;

pageextension 22220 "Chart of Accounts Review" extends "Chart of Accounts"
{
    actions
    {
        addfirst("A&ccount")
        {
            action("Review Entries")
            {
                AboutTitle = 'Review Entries';
                AboutText = 'Opens a new page where you can manually mark entries as reviewed and open the page in Excel';
                ApplicationArea = Dimensions;
                Caption = 'Review Entries';
                Image = CheckList;
                AccessByPermission = table "G/L Entry" = X;
                ToolTip = 'Opens a page where you can manually review G/L entries';
                RunObject = Page "Review G/L Entries";
                RunPageLink = "G/L Account No." = field("No.");
            }
        }

        addlast(Category_Process)
        {
            actionref(ReviewEntries_Promoted; "Review Entries")
            {
            }
        }
    }
}
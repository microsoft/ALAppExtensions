namespace Microsoft.Finance.CashDesk;

using Microsoft.Foundation.ExtendedText;

pageextension 31275 "Extended Text CZP" extends "Extended Text"
{
    layout
    {
        addlast(Sales)
        {
            field("Cash Desk CZP"; Rec."Cash Desk CZP")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}

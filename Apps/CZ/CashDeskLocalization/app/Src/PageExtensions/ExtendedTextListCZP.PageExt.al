namespace Microsoft.Finance.CashDesk;

using Microsoft.Foundation.ExtendedText;

pageextension 31276 "Extended Text List CZP" extends "Extended Text List"
{
    layout
    {
        addlast(Control1)
        {
            field("Cash Desk CZP"; Rec."Cash Desk CZP")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
        }
    }
}

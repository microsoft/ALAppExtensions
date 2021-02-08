pageextension 11747 "Posted Purch. Credit Memos CZL" extends "Posted Purchase Credit Memos"
{
    layout
    {
        addafter("Posting Date")
        {
            field("VAT Date CZL"; Rec."VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies date by which the accounting transaction will enter VAT statement.';
                Visible = false;
            }
        }
    }
}

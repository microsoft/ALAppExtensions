pageextension 11736 "Posted Sales Credit Memos CZL" extends "Posted Sales Credit Memos"
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
        addlast(Control1)
        {
            field("Credit Memo Type CZL"; Rec."Credit Memo Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of credit memo (corrective tax document, internal correction, insolvency tax document).';
                Visible = false;
            }
        }
    }
}

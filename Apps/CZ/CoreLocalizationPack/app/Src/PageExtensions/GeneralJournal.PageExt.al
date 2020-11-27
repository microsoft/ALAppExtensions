pageextension 11722 "General Journal CZL" extends "General Journal"
{
    layout
    {
        addafter("Posting Date")
        {
            field("VAT Date CZL"; Rec."VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies date by which the accounting transaction will enter VAT statement.';
            }
            field("Original Doc. VAT Date CZL"; Rec."Original Doc. VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT date of the original document.';
                Visible = false;
            }
        }
        addafter(Correction)
        {
            field("Original Doc. Partner Type CZL"; Rec."Original Doc. Partner Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of partner (customer or vendor). It''s possible for VAT Control Report.';
            }
            field("Original Doc. Partner No. CZL"; Rec."Original Doc. Partner No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of partner (customer or vendor). It''s possible for VAT Control Report.';
            }
        }
    }
}

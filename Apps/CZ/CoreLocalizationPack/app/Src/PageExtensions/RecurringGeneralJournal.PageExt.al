pageextension 11725 "Recurring General Journal CZL" extends "Recurring General Journal"
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
        addafter("Account No.")
        {
            field("Posting Group CZL"; Rec."Posting Group")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies the posting group that will be used in posting the journal line.The field is used only if the account type is either customer or vendor.';
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

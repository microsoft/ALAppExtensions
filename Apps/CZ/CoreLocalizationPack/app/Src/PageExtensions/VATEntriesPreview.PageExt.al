pageextension 11759 "VAT Entries Preview CZL" extends "VAT Entries Preview"
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
                ToolTip = 'Specifies the VAT entry''s Original Document VAT Date.';
            }
        }
        addafter("EU Service")
        {
            field("VAT Settlement No. CZL"; Rec."VAT Settlement No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the document number which the VAT entries were closed.';
            }
            field("VAT Ctrl. Report Line No. CZL"; Rec."VAT Ctrl. Report Line No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT control report line number of the VAT control line that the entry is linked to.';
            }
        }
        addafter("EU 3-Party Trade")
        {
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the entry was part of a 3-party intermediate role.';
            }
        }
    }
}

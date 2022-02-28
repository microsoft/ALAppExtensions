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
        addafter("Document No.")
        {
            field("External Document No. CZL"; Rec."External Document No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number that the vendor uses on the invoice they sent to you or number of receipt.';
            }
        }
        addbefore("VAT Calculation Type")
        {
            field("Unrealized Amount CZL"; Rec."Unrealized Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the unrealized amount of the VAT entry.';
                Visible = false;
            }
            field("Unrealized Base CZL"; Rec."Unrealized Base")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the unrealized base of the VAT entry.';
                Visible = false;
            }
            field("Remaining Unrealized Amount CZL"; Rec."Remaining Unrealized Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the remaining unrealized amount of the VAT entry.';
                Visible = false;
            }
            field("Remaining Unrealized Base CZL"; Rec."Remaining Unrealized Base")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the remaining unrealized base of the VAT entry.';
                Visible = false;
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

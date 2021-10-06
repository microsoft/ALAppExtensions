pageextension 11760 "G/L Entries Preview CZL" extends "G/L Entries Preview"
{
    layout
    {
        addafter("Posting Date")
        {
            field("VAT Date CZL"; Rec."VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the entry''s VAT Date.';
            }
        }
#if CLEAN19
        modify("Debit Amount")
        {
            Visible = true;
        }
        modify("Credit Amount")
        {
            Visible = true;
        }
#endif
        addafter("FA Entry No.")
        {

            field("External Document No. CZL"; Rec."External Document No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the external document number on the entry.';
                Visible = false;
            }
        }
    }
}

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
    }
}

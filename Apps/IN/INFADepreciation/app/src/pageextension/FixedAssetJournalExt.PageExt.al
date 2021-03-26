pageextension 18635 "Fixed Asset Journal Ext" extends "Fixed Asset Journal"
{
    layout
    {
        addafter("FA Reclassification Entry")
        {
            field("FA Shift Line No."; Rec."FA Shift Line No.")
            {
                Visible = false;
                ToolTip = 'Specifies the line number of FA shift being used in journal entry.';
                ApplicationArea = FixedAssets;
            }
        }
    }
}
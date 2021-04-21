pageextension 18634 "Fixed Asset GL Journal Ext" extends "Fixed Asset G/L Journal"
{
    layout
    {
        addafter("Budgeted FA No.")
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
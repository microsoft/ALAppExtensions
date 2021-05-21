pageextension 18812 "Source Code Setup" extends "Source Code Setup"
{
    layout
    {
        addlast(General)
        {
            field("TDS Adjustment Journal"; Rec."TCS Adjustment Journal")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for TCS Adjustment Journal.';
            }
        }
    }
}
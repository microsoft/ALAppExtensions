pageextension 18811 "Location Card TCS" extends "Location Card"
{
    layout
    {
        addafter("State Code")
        {
            field("T.C.A.N No."; Rec."T.C.A.N. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the T.C.A.N No of Location';
            }
        }
    }
}
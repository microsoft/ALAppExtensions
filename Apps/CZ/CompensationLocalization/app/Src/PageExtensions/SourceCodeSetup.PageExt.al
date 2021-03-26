pageextension 31271 "Source Code Setup CZC" extends "Source Code Setup"
{
    layout
    {
        addlast(Sales)
        {
            field("Compensation CZC"; Rec."Compensation CZC")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the source code for posted entries from compensation.';
            }
        }
    }
}

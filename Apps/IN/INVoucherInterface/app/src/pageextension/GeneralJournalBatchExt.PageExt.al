pageextension 18931 "General Journal Batch Ext." extends "General Journal Batches"
{
    layout
    {
        addafter("Bal. Account No.")
        {
            field("Location Code"; "Location Code")
            {
                Caption = 'Location Code';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specify the Location code';
            }
        }
    }
}
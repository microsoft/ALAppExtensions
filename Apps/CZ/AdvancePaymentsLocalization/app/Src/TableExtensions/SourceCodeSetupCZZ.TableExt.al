tableextension 31076 "Source Code Setup CZZ" extends "Source Code Setup"
{
    fields
    {
        field(11760; "Close Advance Letter CZZ"; Code[10])
        {
            Caption = 'Close Advance Letter';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
            ToolTip = 'Specifies the source code for closing sales and purchase advance letters.';
        }
    }
}
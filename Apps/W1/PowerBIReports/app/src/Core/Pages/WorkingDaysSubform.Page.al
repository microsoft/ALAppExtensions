namespace Microsoft.PowerBIReports;

page 36953 "Working Days Subform"
{
    PageType = ListPart;
    SourceTable = "Working Day";
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Working Days';
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(WorkingDayRepeater)
            {
                field(DayNumber; Rec."Day Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the day number ranging from 0 to 6.';
                }
                field(DayName; Rec."Day Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the day name (e.g. Monday).';
                }
                field(Working; Rec.Working)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this is a working day.';
                }
            }
        }
    }
}
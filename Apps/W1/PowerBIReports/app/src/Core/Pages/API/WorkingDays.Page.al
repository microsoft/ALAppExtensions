namespace Microsoft.PowerBIReports;

page 36960 "Working Days"
{
    PageType = API;
    Caption = 'Power BI Working Days';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'workingDay';
    EntitySetName = 'workingDays';
    EntityCaption = 'Working Day';
    EntitySetCaption = 'Working Days';
    SourceTable = "Working Day";
    SourceTableView = where(Working = const(true));
    DelayedInsert = true;
    DataAccessIntent = ReadOnly;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                }
                field(dayNumber; Rec."Day Number")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
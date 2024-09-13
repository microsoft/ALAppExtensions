namespace Microsoft.PowerBIReports;

using System.DateTime;

page 36955 "Date Setup"
{
    PageType = API;
    Caption = 'Power BI Date Setup';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'dateSetup';
    EntitySetName = 'dateSetups';
    EntityCaption = 'Date Setup';
    EntitySetCaption = 'Date Setups';
    SourceTable = "PowerBI Reports Setup";
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
                field(fiscalCalendarFirstMonth; Rec."First Month of Fiscal Calendar")
                {
                }
                field(firstDayOfWeek; Rec."First Day Of Week")
                {
                }
                field(isoCountryHolidays; Rec."ISO Country Holidays")
                {
                }
                field(weeklyType; Rec."Weekly Type")
                {
                }
                field(quarterWeekType; Rec."Quarter Week Type")
                {
                }
                field(calendarRange; Rec."Calendar Range")
                {
                }
                field(calendarPrefix; Rec."Calendar Gregorian Prefix")
                {
                }
                field(fiscalGregorianPrefix; Rec."Fiscal Gregorian Prefix")
                {
                }
                field(fiscalWeeklyPrefix; Rec."Fiscal Weekly Prefix")
                {
                }
                field(useCustomFisclPeriods; Rec."Use Custom Fiscal Periods")
                {
                }
                field(ignoreWeeklyPeriods; Rec."Ignore Weekly Fiscal Periods")
                {
                }
                field(timeZone; Rec."Time Zone")
                {
                }
                field(timeZoneDisplayName; TimeZoneDisplayName)
                {
                }
                field(dateTblStart; Rec."Date Table Starting Date")
                {
                }
                field(dateTblEnd; Rec."Date Table Ending Date")
                {
                }
            }
        }
    }

    var
        TimeZoneDisplayName: Text[250];

    trigger OnAfterGetCurrRecord()
    var
        TimeZoneRec: Record "Time Zone";
    begin
        Clear(TimeZoneDisplayName);
        TimeZoneRec.SetCurrentKey(ID);
        TimeZoneRec.SetRange(ID, Rec."Time Zone");
        if TimeZoneRec.FindFirst() then
            TimeZoneDisplayName := TimeZoneRec."Display Name";
    end;
}
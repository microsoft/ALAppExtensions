namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Manufacturing.Capacity;

query 36983 "Calendar Entries"
{
    Access = Internal;
    Caption = 'Power BI Calendar Entries';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'calendarEntry';
    EntitySetName = 'calendarEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(CalendarEntry; "Calendar Entry")
        {
            column(capacityType; "Capacity Type")
            {
            }
            column(no; "No.")
            {
            }
            column(workCenterGroupCode; "Work Center Group Code")
            {
            }
            column(date; Date)
            {
            }
            column(capacityEffective; "Capacity (Effective)")
            {
                Method = Sum;
            }
        }
    }

    trigger OnBeforeOpen()
    var
        PBIMgt: Codeunit "Manuf. Filter Helper";
        DateFilterText: Text;
    begin
        DateFilterText := PBIMgt.GenerateManufacturingReportDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(date, DateFilterText);
    end;
}
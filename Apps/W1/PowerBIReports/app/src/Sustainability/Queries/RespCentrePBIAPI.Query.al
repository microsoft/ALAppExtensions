namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.Inventory.Location;

query 37066 "Resp Centre - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Responsibility Centre';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'pbiResponsibilityCentre';
    EntitySetName = 'pbiResponsibilityCentres';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(ResponsibilityCenter; "Responsibility Center")
        {
            column(code; Code) { }
            column(name; Name) { }
            column(waterCapactiybyMonth; "Water Capacity Quantity(Month)") { }
        }
    }
}
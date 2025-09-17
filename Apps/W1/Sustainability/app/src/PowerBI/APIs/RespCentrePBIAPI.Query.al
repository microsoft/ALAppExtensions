namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.Inventory.Location;

query 6216 "Resp Centre - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Responsibility Centre';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
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
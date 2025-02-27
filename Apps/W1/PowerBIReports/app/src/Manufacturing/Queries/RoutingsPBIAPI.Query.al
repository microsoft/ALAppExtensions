namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Manufacturing.Routing;

query 37010 "Routings - PBI API"
{
    Access = Internal;
    Caption = 'Power BI Routings';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'routing';
    EntitySetName = 'routings';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(routing; "Routing Header")
        {
            column(no; "No.") { }
            column(type; Type) { }
            column(status; Status) { }
            column(description; Description) { }
        }
    }
}
namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Manufacturing.Routing;

query 37009 "Routing Links - PBI API"
{
    Access = Internal;
    Caption = 'Power BI Routing Links';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'routingLink';
    EntitySetName = 'routingLinks';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(routingLink; "Routing Link")
        {
            column(code; Code) { }
            column(description; Description) { }
        }
    }
}
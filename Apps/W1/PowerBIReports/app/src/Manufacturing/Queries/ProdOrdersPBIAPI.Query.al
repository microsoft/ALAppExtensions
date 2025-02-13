namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Manufacturing.Document;

query 37008 "Prod. Orders - PBI API"
{
    Access = Internal;
    Caption = 'Power BI Production Orders';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'manufacturingProductionOrder';
    EntitySetName = 'manufacturingProductionOrders';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(productionOrder; "Production Order")
        {
            column(status; Status)
            {
            }
            column(no; "No.")
            {
            }
        }
    }
}
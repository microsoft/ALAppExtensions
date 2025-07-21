namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Manufacturing.Setup;

query 37007 "Manufacturing Setup - PBI API"
{
    Access = Internal;
    Caption = 'Power BI Manufacturing Setup';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'manufacturingSetup';
    EntitySetName = 'manufacturingSetup';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(manufacturingSetup; "Manufacturing Setup")
        {
            column(showCapacityIn; "Show Capacity In") { }
        }
    }
}
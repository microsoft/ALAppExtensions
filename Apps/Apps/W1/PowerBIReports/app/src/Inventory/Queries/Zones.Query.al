namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Warehouse.Structure;

query 36982 Zones
{
    Access = Internal;
    Caption = 'Power BI Zones';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'zone';
    EntitySetName = 'zones';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(zone; Zone)
        {
            column(zoneCode; "Code")
            {
            }
            column(zoneDescription; Description)
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(binTypeCode; "Bin Type Code")
            {
            }
        }
    }
}
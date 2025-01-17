namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Warehouse.Structure;

query 36966 Bins
{
    Access = Internal;
    Caption = 'Power BI Bins';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'bin';
    EntitySetName = 'bins';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(bin; Bin)
        {
            column(binCode; "Code")
            {
            }
            column(description; Description)
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(binType; "Bin Type Code")
            {
            }
            column(zoneCode; "Zone Code")
            {
            }
        }
    }
}
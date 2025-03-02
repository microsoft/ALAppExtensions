namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.Foundation.Address;

query 37062 "Country Region - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Country Region';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'pbiCountryRegion';
    EntitySetName = 'pbiCountryRegions';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(CountryRegion; "Country/Region")
        {
            column(code; Code) { }
            column(name; Name) { }

        }
    }
}
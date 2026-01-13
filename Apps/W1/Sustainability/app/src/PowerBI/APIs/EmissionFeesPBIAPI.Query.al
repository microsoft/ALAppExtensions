namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.Sustainability.Emission;

query 6211 "Emission Fees - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Emission Fees';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'pbiEmissionFee';
    EntitySetName = 'pbiEmissionFees';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(EmissionFee; "Emission Fee")
        {
            column(emissionType; "Emission Type") { }
            column(scopeType; "Scope Type") { }
            column(startingDate; "Starting Date") { }
            column(endingDate; "Ending Date") { }
            column(countryRegionCode; "Country/Region Code") { }
            column(responsibilityCentre; "Responsibility Center") { }
            column(carbonFee; "Carbon Fee") { }
            column(carbonEquivalentFactor; "Carbon Equivalent Factor") { }
        }
    }
}
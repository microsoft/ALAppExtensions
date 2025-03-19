namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.Sustainability.Ledger;

query 37022 "Sust Ledger Entries - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sustainability Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'pbiSustainabilityLedgerEntry';
    EntitySetName = 'pbiSustainabilityLedgerEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(SustainabilityLedgerEntry; "Sustainability Ledger Entry")
        {
            column(sustainAccountNo; "Account No.") { }
            column(entryNo; "Entry No.") { }
            column(postingDate; "Posting Date") { }
            column(documentType; "Document Type") { }
            column(emissionco2; "Emission Co2") { }
            column(emissionch4; "Emission CH4") { }
            column(emissionN2O; "Emission N2O") { }
            column(emissionCo2e; "CO2e Emission") { }
            column(carbonFee; "Carbon Fee") { }
            column(waterIntensity; "Water Intensity") { }
            column(dischargedIntoWater; "Discharged Into Water") { }
            column(wasteIntensity; "Waste Intensity") { }
            column(dimensionSetID; "Dimension Set ID") { }
            column(responsibilityCenter; "Responsibility Center") { }
            column(countryRegionCode; "Country/Region Code") { }
            column(description; Description) { }
            column(waterType; "Water Type") { }
            column(waterWasteIntensityType; "Water/Waste Intensity Type") { }
        }
    }

    trigger OnBeforeOpen()
    var
        PBIMgt: Codeunit "PBI Sustain. Filter Helper";
        DateFilterText: Text;
    begin
        DateFilterText := PBIMgt.GenerateSustainabilityReportDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(postingDate, DateFilterText);
    end;
}
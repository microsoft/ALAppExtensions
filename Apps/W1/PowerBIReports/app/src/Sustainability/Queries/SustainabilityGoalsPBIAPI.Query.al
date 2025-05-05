namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.Sustainability.Scorecard;

query 37021 "Sustainability Goals - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sustainability Goals';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'pbiSustainabilityGoal';
    EntitySetName = 'pbiSustainabilityGoals';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(SustainabilityGoals; "Sustainability Goal")
        {
            column(scoreCardNo; "Scorecard No.") { }
            column(no; "No.") { }
            column(lineNo; "Line No.") { }
            column(name; Name) { }
            column(owner; Owner) { }
            column(countryRegion; "Country/Region Code") { }
            column(responsibilityCentre; "Responsibility Center") { }
            column(targetValueForCo2; "Target Value for CO2") { }
            column(targetValueForCh4; "Target Value for CH4") { }
            column(targetValueForN2O; "Target Value for N2O") { }
            column(targetValueForWaterIntensity; "Target Value for Water Int.") { }
            column(targetValueForWasteIntensity; "Target Value for Waste Int.") { }
            column(mainGoal; "Main Goal") { }
            column(startDate; "Start Date") { }
            column(endDate; "End Date") { }
            column(baselineStartDate; "Baseline Start Date") { }
            column(baselineEndDate; "Baseline End Date") { }
        }
    }
}
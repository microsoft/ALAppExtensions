namespace Microsoft.Sustainability.Reports;

using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Setup;
using Microsoft.Inventory.Location;

report 6211 "Emission Per Facility"
{
    DefaultRenderingLayout = EmissionPerFacilityExcel;
    ApplicationArea = Basic, Suite;
    Caption = 'Emission Per Facility';
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Sustainability Ledger Entry"; "Sustainability Ledger Entry")
        {
            DataItemTableView = sorting("Entry No.");
            RequestFilterFields = "Posting Date", "Responsibility Center", "Account No.";
            column(PeriodFilter; StrSubstNo(PeriodLbl, SustLedgDateFilter))
            {
            }
            column(SustLedgDateFilter; SustLedgDateFilter)
            {
            }
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(ShowDetails; ShowDetails)
            {
            }
            column(Responsibility_Center; "Responsibility Center")
            {
                IncludeCaption = true;
            }
            column(Responsibility_Center_Name; ResponsibilityCenter.Name)
            {
                IncludeCaption = true;
            }
            column(Account_No_; "Account No.")
            {
                IncludeCaption = true;
            }
            column(Account_Name; "Account Name")
            {
                IncludeCaption = true;
            }
            column(Description; Description)
            {
                IncludeCaption = true;
            }
            column(Unit_of_Measure; ReportingUOMCode)
            {
            }
            column(UnitOfMeasureCaption; FieldCaption("Unit of Measure"))
            {
            }
            column(Emission_Scope; "Emission Scope")
            {
                IncludeCaption = true;
            }
            column(Country_Region_Code; "Country/Region Code")
            {
                IncludeCaption = true;
            }
            column(Emission_CO2; "Emission CO2")
            {
                IncludeCaption = true;
            }
            column(Emission_CH4; "Emission CH4")
            {
                IncludeCaption = true;
            }
            column(Emission_N2O; "Emission N2O")
            {
                IncludeCaption = true;
            }
            trigger OnAfterGetRecord()
            begin
                if not ResponsibilityCenter.Get("Responsibility Center") then
                    Clear(ResponsibilityCenter);

                if UseReportingUOMFactor then begin
                    "Emission CO2" := Round("Emission CO2" * ReportingUOMFactor, RoundingPrecision, RoundingDirection);
                    "Emission CH4" := Round("Emission CH4" * ReportingUOMFactor, RoundingPrecision, RoundingDirection);
                    "Emission N2O" := Round("Emission N2O" * ReportingUOMFactor, RoundingPrecision, RoundingDirection);
                end;
            end;
        }
    }
    requestpage
    {
        AboutText = 'This report encompasses greenhouse gas (GHG) emission data documented across various facilities - Responsibility Centers.';
        AboutTitle = 'About Emission Per Facility';
    }
    rendering
    {
        layout(EmissionPerFacilityExcel)
        {
            Type = Excel;
            Caption = 'Emission Per Facility Excel Layout';
            LayoutFile = './src/Reports/EmissionPerFacility.xlsx';
            Summary = 'Built in layout for the Emission Per Facility excel report. This report encompasses greenhouse gas (GHG) emission data documented across various facilities - Responsibility Centers.';
        }
        layout(EmissionPerFacilityRDLC)
        {
            Type = RDLC;
            Caption = 'Emission Per Facility RDLC Layout';
            LayoutFile = './src/Reports/EmissionPerFacility.rdlc';
            Summary = 'Built in layout for the Emission Per Facility RDLC report. This report encompasses greenhouse gas (GHG) emission data documented across various facilities - Responsibility Centers.';
        }
    }
    labels
    {
        EmissionPerFacility = 'Emission Per Facility';
        EmissionPerFacilityPrint = 'Emission Per Facility (Print)', MaxLength = 31, Comment = 'Excel worksheet name.';
        PageCaption = 'Page';
        EmissionsByRespCenter = 'Emissions by R. C.', MaxLength = 31, Comment = 'Excel worksheet name.';
        AverageByScopeAndRC = 'Average by Scope and R. C.', MaxLength = 31, Comment = 'Excel worksheet name.';
        AverageByAccountAndRC = 'Average by Account and R. C.', MaxLength = 31, Comment = 'Excel worksheet name.';
        CompName = 'Company Name';
        CountryRegionCode = 'Country/Region Code';
        EmissionByRespCenter = 'Emissions by Responsibility Center';
        EmissionScope = 'Emission Scope';
        ResponsibilityCenter = 'Responsibility Center';
        SumOfEmission_CO2 = 'Sum of Emission CO2';
        SumOfEmission_CH4 = 'Sum of Emission CH4';
        SumOfEmission_N2O = 'Sum of Emission N2O';
        AverageOfEmission_CO2 = 'Average of Emission CO2';
        AverageOfEmission_CH4 = 'Average of Emission CH4';
        AverageOfEmission_N2O = 'Average of Emission N2O';
        AccountName = 'Account Name';
        DataRetrieved = 'Data retrieved:';
        // About the report labels
        AboutTheReportLabel = 'About the report', MaxLength = 31, Comment = 'Excel worksheet name.';
        EnvironmentLabel = 'Environment';
        CompanyLabel = 'Company';
        UserLabel = 'User';
        RunOnLabel = 'Run on';
        ReportNameLabel = 'Report name';
        DocumentationLabel = 'Documentation';
    }

    trigger OnPreReport()
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustLedgDateFilter := "Sustainability Ledger Entry".GetFilter("Posting Date");
        SustainabilitySetup.GetReportingParameters(ReportingUOMCode, UseReportingUOMFactor, ReportingUOMFactor, RoundingDirection, RoundingPrecision);
    end;

    var
        ResponsibilityCenter: Record "Responsibility Center";
        ReportingUOMCode: Code[10];
        SustainabilityAccountName, SustLedgDateFilter, RoundingDirection : Text;
        ReportingUOMFactor, RoundingPrecision : Decimal;
        ShowDetails, UseReportingUOMFactor : Boolean;
        PeriodLbl: Label 'Period: %1', Comment = '%1 - period filter';
}
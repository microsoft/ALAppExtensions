namespace Microsoft.Sustainability.Reports;

using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Setup;

report 6212 "Total Emissions"
{
    DefaultRenderingLayout = TotalEmissionsExcel;
    ApplicationArea = Basic, Suite;
    Caption = 'Total Emissions';
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Sustainability Ledger Entry"; "Sustainability Ledger Entry")
        {
            DataItemTableView = sorting("Entry No.");
            RequestFilterFields = "Posting Date", "Emission Scope", "Account No.";
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
            column(Emission_Scope; "Emission Scope")
            {
                IncludeCaption = true;
            }
            column(Account_No_; "Account No.")
            {
                IncludeCaption = true;
            }
            column(Account_Name; "Account Name")
            {
            }
            column(Posting_Date; "Posting Date")
            {
                IncludeCaption = true;
            }
            column(Document_Type; "Document Type")
            {
                IncludeCaption = true;
            }
            column(Document_No_; "Document No.")
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
        AboutText = 'This report provides information on the cumulative greenhouse gas (GHG) emissions across the chosen Sustainability Accounts and periods.';
        AboutTitle = 'About Total Emissions';
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(Show_Details; ShowDetails)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Details';
                        ToolTip = 'Specifies if the report includes all sustainability entries. By default, the report does not show such entries.';
                    }
                }
            }
        }
    }
    rendering
    {
        layout(TotalEmissionsExcel)
        {
            Type = Excel;
            Caption = 'Total Emissions Excel Layout';
            LayoutFile = './src/Reports/TotalEmissions.xlsx';
            Summary = 'Built in layout for the Total Emissions excel report. This report provides information on the cumulative greenhouse gas (GHG) emissions across the chosen Sustainability Accounts and periods.';
        }
        layout(TotalEmissionsRDLC)
        {
            Type = RDLC;
            Caption = 'Total Emissions RDLC Layout';
            LayoutFile = './src/Reports/TotalEmissions.rdlc';
            Summary = 'Built in layout for the Total Emissions RDLC report. This report provides information on the cumulative greenhouse gas (GHG) emissions across the chosen Sustainability Accounts and periods.';
        }
    }
    labels
    {
        TotalEmissionsCaption = 'Total Emissions';
        TotalEmissionsPrint = 'Total Emissions (Print)', MaxLength = 31, Comment = 'Excel worksheet name.';
        PageCaption = 'Page';
        CompName = 'Company Name';
        PostingDate = 'Posting Date';
        EmissionsPerScopes = 'Emissions Per Scopes', MaxLength = 31, Comment = 'Excel worksheet name.';
        EmissionsThroughPeriod = 'Emissions Through Period', MaxLength = 31, Comment = 'Excel worksheet name.';
        EmissionsSplit = 'Emissions Split', MaxLength = 31, Comment = 'Excel worksheet name.';
        SumOfEmission_CO2 = 'Sum of Emission CO2';
        SumOfEmission_CH4 = 'Sum of Emission CH4';
        SumOfEmission_N2O = 'Sum of Emission N2O';
        EmissionScope = 'Emission Scope';
        AccountName = 'Account Name';
        DocumentType = 'Document Type';
        TotalEmissionOfCO2 = 'Total Emission of CO2';
        TotalEmissionOfCH4 = 'Total Emission of CH4';
        TotalEmissionOfN2O = 'Total Emission of N2O';
        TotalEmissionsLabel = 'Total Emissions';
        UnitofMeasureLabel = 'Unit of Measure';
        DataRetrieved = 'Data retrieved:';
        // About the report labels
        AboutTheReportLabel = 'About the report', MaxLength = 31, Comment = 'Excel worksheet name.';
        EnvironmentLabel = 'Environment';
        CompanyLabel = 'Company';
        CompanyNameLabel = 'Company Name';
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
        ReportingUOMCode: Code[10];
        SustainabilityAccountName, SustLedgDateFilter, RoundingDirection : Text;
        ShowDetails, UseReportingUOMFactor : Boolean;
        ReportingUOMFactor, RoundingPrecision : Decimal;
        PeriodLbl: Label 'Period: %1', Comment = '%1 - period filter';
}
namespace Microsoft.Sustainability.Reports;

using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Setup;
using Microsoft.Sustainability.Account;

report 6210 "Emission By Category"
{
    DefaultRenderingLayout = EmissionByCategoryExcel;
    ApplicationArea = Basic, Suite;
    Caption = 'Emission By Category';
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Sustainability Ledger Entry"; "Sustainability Ledger Entry")
        {
            DataItemTableView = sorting("Entry No.");
            RequestFilterFields = "Posting Date", "Account Category", "Account No.";
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
            column(Account_Category; "Account Category")
            {
                IncludeCaption = true;
            }
            column(Account_Category_Description; SustainAccountCategory.Description)
            {
                IncludeCaption = true;
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
            column(Emission_Scope; "Emission Scope")
            {
                IncludeCaption = true;
            }
            column(Country_Region_Code; "Country/Region Code")
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
                if not SustainAccountCategory.Get("Account Category") then
                    Clear(SustainAccountCategory);

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
        AboutText = 'This report presents information on greenhouse gas (GHG) emissions categorized by Sustainability Categories.';
        AboutTitle = 'About Emission By Category';
    }
    rendering
    {
        layout(EmissionByCategoryExcel)
        {
            Type = Excel;
            Caption = 'Emission By Category Excel Layout';
            LayoutFile = './src/Reports/EmissionByCategory.xlsx';
            Summary = 'Built in layout for the Emission By Category excel report. This report presents information on greenhouse gas (GHG) emissions categorized by Sustainability Categories.';
        }
        layout(EmissionByCategoryRDLC)
        {
            Type = RDLC;
            Caption = 'Emission By Category RDLC Layout';
            LayoutFile = './src/Reports/EmissionByCategory.rdlc';
            Summary = 'Built in layout for the Emission By Category RDLC report. This report presents information on greenhouse gas (GHG) emissions categorized by Sustainability Categories.';
        }
    }
    labels
    {
        EmissionByCategory = 'Emission By Category';
        EmissionByCategoryPrint = 'Emission By Category (Print)', MaxLength = 31, Comment = 'Excel worksheet name.';
        EmissionByCategoryAnalysis = 'Emission By Category (Analysis)', MaxLength = 31, Comment = 'Excel worksheet name.';
        PageCaption = 'Page';
        CompName = 'Company Name';
        PostingDate = 'Posting Date';
        TotalEmissionsperCategory = 'Total Emissions per Category';
        SumOfEmission_CO2 = 'Sum of Emission CO2';
        SumOfEmission_CH4 = 'Sum of Emission CH4';
        SumOfEmission_N2O = 'Sum of Emission N2O';
        AccountCategoryDescription = 'Account Category Description';
        CategoryDetails = 'Category Details', MaxLength = 31, Comment = 'Excel worksheet name.';
        AccountName = 'Account Name';
        DocumentType = 'Document Type';
        CountryRegionCode = 'Country/Region Code';
        EmissionScope = 'Emission Scope';
        AccountCategory = 'Account Category';
        AccountNo = 'Account No.';
        AverageEmissions = 'Average Emissions', MaxLength = 31, Comment = 'Excel worksheet name.';
        AverageEmissionsperCategory = 'Average Emissions per Category';
        AverageOfEmission_CO2 = 'Average of Emission CO2';
        AverageOfEmission_CH4 = 'Average of Emission CH4';
        AverageOfEmission_N2O = 'Average of Emission N2O';
        EmissionsPerDocument = 'Emissions Per Document', MaxLength = 31, Comment = 'Excel worksheet name.';
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
        SustainAccountCategory: Record "Sustain. Account Category";
        ReportingUOMCode: Code[10];
        SustainabilityAccountName, SustLedgDateFilter, RoundingDirection : Text;
        ShowDetails, UseReportingUOMFactor : Boolean;
        ReportingUOMFactor, RoundingPrecision : Decimal;
        PeriodLbl: Label 'Period: %1', Comment = '%1 - period filter';
}
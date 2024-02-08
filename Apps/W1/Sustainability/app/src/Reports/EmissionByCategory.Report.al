namespace Microsoft.Sustainability.Reports;

using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Setup;
using Microsoft.Sustainability.Account;

report 6210 "Emission By Category"
{
    DefaultLayout = Excel;
    ExcelLayout = './src/Reports/EmissionByCategory.xlsx';
    RDLCLayout = './src/Reports/EmissionByCategory.rdlc';
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
            column(Posting_Date; Format("Posting Date"))
            {
            }
            column(Posting_Date_Caption; FieldCaption("Posting Date"))
            {
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
                    "Emission CO2" := Round("Emission CO2" * ReportingUOMFactor, RoundingPrecission, RoundingDirection);
                    "Emission CH4" := Round("Emission CH4" * ReportingUOMFactor, RoundingPrecission, RoundingDirection);
                    "Emission N2O" := Round("Emission N2O" * ReportingUOMFactor, RoundingPrecission, RoundingDirection);
                end;
            end;
        }
    }
    labels
    {
        EmissionByCategory = 'Emission By Category';
        PageCaption = 'Page';
    }
    trigger OnPreReport()
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustLedgDateFilter := "Sustainability Ledger Entry".GetFilter("Posting Date");
        SustainabilitySetup.GetReportingParameters(ReportingUOMCode, UseReportingUOMFactor, ReportingUOMFactor, RoundingDirection, RoundingPrecission);
    end;

    var
        SustainAccountCategory: Record "Sustain. Account Category";
        ReportingUOMCode: Code[10];
        SustainabilityAccountName, SustLedgDateFilter, RoundingDirection : Text;
        ShowDetails, UseReportingUOMFactor : Boolean;
        ReportingUOMFactor, RoundingPrecission : Decimal;
        PeriodLbl: Label 'Period: %1', Comment = '%1 - period filter';
}
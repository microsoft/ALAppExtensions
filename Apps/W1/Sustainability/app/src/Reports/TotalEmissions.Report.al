namespace Microsoft.Sustainability.Reports;

using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Setup;

report 6212 "Total Emissions"
{
    DefaultLayout = Excel;
    ExcelLayout = './src/Reports/TotalEmissions.xlsx';
    RDLCLayout = './src/Reports/TotalEmissions.rdlc';
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
                    "Emission CO2" := Round("Emission CO2" * ReportingUOMFactor, RoundingPrecission, RoundingDirection);
                    "Emission CH4" := Round("Emission CH4" * ReportingUOMFactor, RoundingPrecission, RoundingDirection);
                    "Emission N2O" := Round("Emission N2O" * ReportingUOMFactor, RoundingPrecission, RoundingDirection);
                end;
            end;
        }
    }

    requestpage
    {
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
    labels
    {
        TotalEmissionsCaption = 'Total Emissions';
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
        ReportingUOMCode: Code[10];
        SustainabilityAccountName, SustLedgDateFilter, RoundingDirection : Text;
        ShowDetails, UseReportingUOMFactor : Boolean;
        ReportingUOMFactor, RoundingPrecission : Decimal;
        PeriodLbl: Label 'Period: %1', Comment = '%1 - period filter';
}
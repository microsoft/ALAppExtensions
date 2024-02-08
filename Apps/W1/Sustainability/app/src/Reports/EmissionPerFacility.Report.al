namespace Microsoft.Sustainability.Reports;

using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Setup;
using Microsoft.Inventory.Location;

report 6211 "Emission Per Facility"
{
    DefaultLayout = Excel;
    ExcelLayout = './src/Reports/EmissionPerFacility.xlsx';
    RDLCLayout = './src/Reports/EmissionPerFacility.rdlc';
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
                    "Emission CO2" := Round("Emission CO2" * ReportingUOMFactor, RoundingPrecission, RoundingDirection);
                    "Emission CH4" := Round("Emission CH4" * ReportingUOMFactor, RoundingPrecission, RoundingDirection);
                    "Emission N2O" := Round("Emission N2O" * ReportingUOMFactor, RoundingPrecission, RoundingDirection);
                end;
            end;
        }
    }
    labels
    {
        EmissionPerFacility = 'Emission Per Facility';
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
        ResponsibilityCenter: Record "Responsibility Center";
        ReportingUOMCode: Code[10];
        SustainabilityAccountName, SustLedgDateFilter, RoundingDirection : Text;
        ReportingUOMFactor, RoundingPrecission : Decimal;
        ShowDetails, UseReportingUOMFactor : Boolean;
        PeriodLbl: Label 'Period: %1', Comment = '%1 - period filter';
}
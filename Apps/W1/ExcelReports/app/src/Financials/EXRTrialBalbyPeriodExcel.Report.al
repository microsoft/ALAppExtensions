// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Company;
using Microsoft.ExcelReports;

report 4408 "EXR Trial Bal by Period Excel"
{
    ApplicationArea = All;
    Caption = 'Trial Balance by Period (Excel)';
    DataAccessIntent = ReadOnly;
    DefaultRenderingLayout = TrialBalancebyPeriodExcelLayout;
    ExcelLayoutMultipleDataSheets = true;
    UsageCategory = ReportsAndAnalysis;
    MaximumDatasetSize = 1000000;

    dataset
    {
        dataitem(TrialBalanceByPeriod; "G/L Account")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Account Type", "Date Filter";
            column(AccountNumber; "No.") { IncludeCaption = true; }
            column(AccountName; Name) { IncludeCaption = true; }
            column(IncomeBalance; "Income/Balance") { IncludeCaption = true; }
            column(AccountCategory; "Account Category") { IncludeCaption = true; }
            column(AccountSubcategory; "Account Subcategory Descript.") { IncludeCaption = true; }
            column(AccountType; "Account Type") { IncludeCaption = true; }
            column(Indentation; Indentation) { IncludeCaption = true; }
            column(IndentedAccountName; IndentedAccountName) { }

            dataitem(EXRTrialBalanceBuffer; "EXR Trial Balance Buffer")
            {
                DataItemTableView = sorting("G/L Account No.");
                DataItemLink = "G/L Account No." = field("No.");
                column(Account; "G/L Account No.") { IncludeCaption = true; }
                column(Dimension1Code; "Dimension 1 Code") { IncludeCaption = true; }
                column(Dimension2Code; "Dimension 2 Code") { IncludeCaption = true; }
                column(NetChange; "Net Change") { IncludeCaption = true; }
                column(PeriodStart; "Period Start") { IncludeCaption = true; }
                column(PeriodEnd; "Period End") { IncludeCaption = true; }
            }

            trigger OnAfterGetRecord()
            begin
                Clear(EXRTrialBalanceBuffer);
                EXRTrialBalanceBuffer.DeleteAll();
                IndentedAccountName := PadStr('', TrialBalanceByPeriod.Indentation * 2, ' ') + TrialBalanceByPeriod.Name;

                BuildDataset(TrialBalanceByPeriod);
            end;
        }
        dataitem(Dimension1; "Dimension Value")
        {
            DataItemTableView = sorting("Code") where("Global Dimension No." = const(1));

            column(Dim1Code; Dimension1."Code") { IncludeCaption = true; }
            column(Dim1Name; Dimension1.Name) { IncludeCaption = true; }
        }
        dataitem(Dimension2; "Dimension Value")
        {
            DataItemTableView = sorting("Code") where("Global Dimension No." = const(2));

            column(Dim2Code; Dimension2."Code") { IncludeCaption = true; }
            column(Dim2Name; Dimension2.Name) { IncludeCaption = true; }
        }
    }

    requestpage
    {
        SaveValues = true;
        AboutTitle = 'About Trial Balance by Period (Excel)';
        AboutText = 'View a trial balance with debit/credit columns for net change and balance for a period you specify. You get the report directly in Excel. See amounts in both local currency (LCY) and additional reporting currency (ACY), the latter only showing data if Additional Reporting Currency is in use. In addition to debit/credit for net change and balance the report shows the net debit/credit amount for both net change and balance for comparison. Data is summarized for the period specified in the report''s request page''s Date Filter parameter and grouped by the 2 global dimensions per G/L account category.';

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PeriodLengthField; PeriodLength)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Period Length';
                        ToolTip = 'Specifies the period for which data is shown in the report. For example, enter "1M" for one month, "30D" for thirty days, "3Q" for three quarters, or "5Y" for five years.';
                    }
                    // Used to set the date filter on the report header across multiple languages
                    field(RequestDateFilter; DateFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Date Filter';
                        ToolTip = 'Specifies the Date Filter applied to the EXR Trial Bal. by Period Report.';
                        Visible = false;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            Evaluate(PeriodLength, '<1M>');
        end;

        trigger OnClosePage()
        begin
            DateFilter := TrialBalanceByPeriod.GetFilter("Date Filter");
        end;
    }

    rendering
    {
        layout(TrialBalancebyPeriodExcelLayout)
        {
            Type = Excel;
            LayoutFile = './ReportLayouts/Excel/GeneralLedger/TrialBalancebyPeriodExcel.xlsx';
            Caption = 'Trial Balance by Period Excel';
            Summary = 'Built in layout for the Trial Balance by Period report. This report contains aggregated general ledger data per accounting period for the trial balance with a net debit/credit net change column for each period. Report uses Query connections.';
        }
    }
    labels
    {
        DataRetrieved = 'Data retrieved:';
        TrialBalanceByPeriod = 'Trial Balance by Period';
        TrialBalanceByPeriodPrint = 'Trial Bal. by Period (Print)', MaxLength = 31, Comment = 'Excel worksheet name.';
        TrialBalanceByPeriodAnalysis = 'Trial Bal. by Period (Analysis)', MaxLength = 31, Comment = 'Excel worksheet name.';
        YearPeriodStart = 'Year';
        DateFilterLabel = 'Date Filter:';
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
        ThisReportingStartDate: Date;
    begin
        TrialBalanceByPeriod.SecurityFiltering(SecurityFilter::Filtered);
        CompanyInformation.Get();
        ExcelReportsTelemetry.LogReportUsage(Report::"EXR Trial Bal by Period Excel");

        ReportingPeriodStartDate.Add(TrialBalanceByPeriod.GetRangeMin("Date Filter"));
        ThisReportingStartDate := TrialBalanceByPeriod.GetRangeMin("Date Filter");
        repeat
            ThisReportingStartDate := CalcDate(PeriodLength, ThisReportingStartDate);
            ReportingPeriodEndDate.Add(CalcDate('<-1D>', ThisReportingStartDate));
            ReportingPeriodStartDate.Add(ThisReportingStartDate);
        until ThisReportingStartDate >= TrialBalanceByPeriod.GetRangeMax("Date Filter");
        ReportingPeriodEndDate.Add(CalcDate('<-1D>', ThisReportingStartDate));
    end;

    var
        ExcelReportsTelemetry: Codeunit "Excel Reports Telemetry";
        DateFilter: Text;

    protected var
        CompanyInformation: Record "Company Information";
        PeriodLength: DateFormula;
        IndentedAccountName: Text;
        ReportingPeriodEndDate: List of [Date];
        ReportingPeriodStartDate: List of [Date];

    local procedure BuildDataset(var GLAccount: Record "G/L Account")
    var
        DimensionValue1: Record "Dimension Value";
        DimensionValue2: Record "Dimension Value";
        ThisReportingEndDate: Date;
        ThisReportingStartDate: Date;
        i: Integer;
    begin
        DimensionValue1.SetRange("Global Dimension No.", 1);
        DimensionValue2.SetRange("Global Dimension No.", 2);

        for i := 1 to ReportingPeriodStartDate.Count() do begin
            ThisReportingStartDate := ReportingPeriodStartDate.Get(i);
            ThisReportingEndDate := ReportingPeriodEndDate.Get(i);
            GLAccount.SetRange("Date Filter", ThisReportingStartDate, ThisReportingEndDate);

            AddGLToDataset(GLAccount, ThisReportingStartDate, ThisReportingEndDate, '', '');
            if DimensionValue1.FindSet() then
                repeat
                    AddGLToDataset(GLAccount, ThisReportingStartDate, ThisReportingEndDate, DimensionValue1."Code", '');
                    if DimensionValue2.FindSet() then
                        repeat
                            AddGLToDataset(GLAccount, ThisReportingStartDate, ThisReportingEndDate, DimensionValue1."Code", DimensionValue2."Code");
                        until DimensionValue2.Next() = 0;
                until DimensionValue1.Next() = 0;

            if DimensionValue2.FindSet() then
                repeat
                    AddGLToDataset(GLAccount, ThisReportingStartDate, ThisReportingEndDate, '', DimensionValue2."Code");
                until DimensionValue2.Next() = 0;
        end;
    end;

    local procedure AddGLToDataset(var GLAccount: Record "G/L Account"; PeriodStartDate: Date; PeriodEndDate: Date; Dimension1Code: Code[20]; Dimension2Code: Code[20])
    var
        LocalGLAccount: Record "G/L Account";
    begin
        LocalGLAccount.Copy(GLAccount);
        LocalGLAccount.SetFilter("Global Dimension 1 Filter", Dimension1Code);
        LocalGLAccount.SetFilter("Global Dimension 2 Filter", Dimension2Code);

        LocalGLAccount.CalcFields("Net Change", "Balance at Date");
        Clear(EXRTrialBalanceBuffer);
        EXRTrialBalanceBuffer."G/L Account No." := LocalGLAccount."No.";
        EXRTrialBalanceBuffer."Period Start" := PeriodStartDate;
        EXRTrialBalanceBuffer."Period End" := PeriodEndDate;
        EXRTrialBalanceBuffer."Dimension 1 Code" := Dimension1Code;
        EXRTrialBalanceBuffer."Dimension 2 Code" := Dimension2Code;
        EXRTrialBalanceBuffer.Validate("Net Change", LocalGLAccount."Net Change");
        EXRTrialBalanceBuffer.Validate("Balance", LocalGLAccount."Balance at Date");
        EXRTrialBalanceBuffer.Insert(true);
    end;
}
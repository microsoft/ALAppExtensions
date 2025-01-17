// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Company;
using Microsoft.ExcelReports;

report 4406 "EXR Trial BalanceBudgetExcel"
{
    ApplicationArea = All;
    Caption = 'Trial Balance/Budget Excel (Preview)';
    DataAccessIntent = ReadOnly;
    DefaultRenderingLayout = TrialBalanceBudgetExcelLayout;
    ExcelLayoutMultipleDataSheets = true;
    UsageCategory = ReportsAndAnalysis;
    MaximumDatasetSize = 1000000;

    dataset
    {
        dataitem(GLAccounts; "G/L Account")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Account Type", "Date Filter", "Budget Filter";
            column(AccountNumber; "No.") { IncludeCaption = true; }
            column(AccountName; Name) { IncludeCaption = true; }
            column(IncomeBalance; "Income/Balance") { IncludeCaption = true; }
            column(AccountCategory; "Account Category") { IncludeCaption = true; }
            column(AccountSubcategory; "Account Subcategory Descript.") { IncludeCaption = true; }
            column(AccountType; "Account Type") { IncludeCaption = true; }
            column(Indentation; Indentation) { IncludeCaption = true; }
            column(IndentedAccountName; IndentedAccountName) { }

            trigger OnAfterGetRecord()
            begin
                IndentedAccountName := PadStr('', GLAccounts.Indentation * 2, ' ') + GLAccounts.Name;
            end;
        }
        dataitem(Dimension1; "Dimension Value")
        {
            DataItemTableView = sorting("Code");
            UseTemporary = true;

            column(Dim1Code; Dimension1."Code") { IncludeCaption = true; }
            column(Dim1Name; Dimension1.Name) { IncludeCaption = true; }
        }
        dataitem(Dimension2; "Dimension Value")
        {
            DataItemTableView = sorting("Code");
            UseTemporary = true;

            column(Dim2Code; Dimension2."Code") { IncludeCaption = true; }
            column(Dim2Name; Dimension2.Name) { IncludeCaption = true; }
        }
        dataitem(TrialBalanceBudgetData; "EXR Trial Balance Buffer")
        {
            RequestFilterFields = Balance, "Net Change";
            column(Account; "G/L Account No.") { IncludeCaption = true; }
            column(Dimension1Code; "Dimension 1 Code") { IncludeCaption = true; }
            column(Dimension2Code; "Dimension 2 Code") { IncludeCaption = true; }
            column(NetChange; "Net Change") { IncludeCaption = true; }
            column(Balance; Balance) { IncludeCaption = true; }
            column(NetBudget; "Budget (Net)") { IncludeCaption = true; }
            column(BalanceBudget; "Budget (Bal. at Date)") { IncludeCaption = true; }
            column(BudgetNetPct; "% of Budget Net") { IncludeCaption = true; }
            column(BudgetBalPct; "% of Budget Bal.") { IncludeCaption = true; }
        }
    }
    requestpage
    {
        SaveValues = true;
        AboutTitle = 'Trial Balance/Budget Excel';
        AboutText = 'This report contains aggregated general ledger data for the trial balance with debit/credit columns for net change and balance. A report is shown for both local currency (LCY) and additional reporting currency (ACY, the latter only showing data if Additional Reporting Currency is in use. In addition to debit/credit for net change and balance the report shows the net debit/credit amount for both net change and balance for comparison. The aggregation is for the period specified in the report''s request page''s Datefilter parameter and summarized per the 2 global dimensions per g/l account category.';
    }
    rendering
    {
        layout(TrialBalanceBudgetExcelLayout)
        {
            Type = Excel;
            LayoutFile = './ReportLayouts/Excel/GeneralLedger/TrialBalanceBudgetExcel.xlsx';
            Caption = 'Trial Balance/Budget Excel';
            Summary = 'Built in layout for Trial Balance/Budget Excel. Customer facing sheet contains a pivot table that shows the account balance in local currency and additional reporting currencies. Report uses Query connections.';
        }
    }

    labels
    {
        DataRetrieved = 'Data retrieved:';
        NetBudgetLabel = 'Net Budget';
        BalanceBudgetLabel = 'Budget Balance';
        TrialBalancevsBudget = 'Trial Balance vs. Budget';
    }
    trigger OnPreReport()
    var
        TrialBalance: Codeunit "Trial Balance";
    begin
        TrialBalanceBudgetData.SecurityFiltering(SecurityFilter::Filtered);
        CompanyInformation.Get();
        ExcelReportsTelemetry.LogReportUsage(Report::"EXR Trial BalanceBudgetExcel");
        TrialBalance.ConfigureTrialBalance(true, false);
        TrialBalance.InsertTrialBalanceReportData(GLAccounts, Dimension1, Dimension2, TrialBalanceBudgetData);
    end;

    var
        ExcelReportsTelemetry: Codeunit "Excel Reports Telemetry";

    protected var
        CompanyInformation: Record "Company Information";
        IndentedAccountName: Text;

}
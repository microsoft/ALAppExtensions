// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Company;

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
        dataitem(TrialBalanceBudgetData; "G/L Account")
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

            dataitem(EXRTrialBalanceBuffer; "EXR Trial Balance Buffer")
            {
                DataItemLink = "G/L Account No." = field("No.");
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
            trigger OnAfterGetRecord()
            var
                TrialBalance: Codeunit "Trial Balance";
            begin
                IndentedAccountName := PadStr('', TrialBalanceBudgetData.Indentation * 2, ' ') + TrialBalanceBudgetData.Name;
                TrialBalance.InsertBreakdownForGLAccount(TrialBalanceBudgetData, Dimension1Values, Dimension2Values, EXRTrialBalanceBuffer);
            end;

            trigger OnPreDataItem()
            var
                DimensionValue: Record "Dimension Value";
            begin
                DimensionValue.SetRange("Global Dimension No.", 1);
                if DimensionValue.FindSet() then
                    repeat
                        Dimension1Values.Add(DimensionValue.Code);
                    until DimensionValue.Next() = 0;
                Dimension1Values.Add('');
                DimensionValue.SetRange("Global Dimension No.", 2);
                if DimensionValue.FindSet() then
                    repeat
                        Dimension2Values.Add(DimensionValue.Code);
                    until DimensionValue.Next() = 0;
                Dimension2Values.Add('');
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
    begin
        TrialBalanceBudgetData.SecurityFiltering(SecurityFilter::Filtered);
        CompanyInformation.Get();
    end;

    var
        Dimension1Values: List of [Code[20]];
        Dimension2Values: List of [Code[20]];

    protected var
        CompanyInformation: Record "Company Information";
        IndentedAccountName: Text;

}
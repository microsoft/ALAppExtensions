// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Company;

report 4405 "EXR Trial Balance Excel"
{
    AdditionalSearchTerms = 'year closing,close accounting period,close fiscal year';
    ApplicationArea = All;
    Caption = 'Trial Balance Excel (Preview)';
    DataAccessIntent = ReadOnly;
    DefaultRenderingLayout = TrialBalanceExcelLayout;
    ExcelLayoutMultipleDataSheets = true;
    UsageCategory = ReportsAndAnalysis;
    MaximumDatasetSize = 1000000;

    dataset
    {
        dataitem(TrialBalanceData; "G/L Account")
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
                column(NetChangeDebit; "Net Change (Debit)") { IncludeCaption = true; }
                column(NetChangeCredit; "Net Change (Credit)") { IncludeCaption = true; }
                column(Balance; Balance) { IncludeCaption = true; }
                column(BalanceDebit; "Balance (Debit)") { IncludeCaption = true; }
                column(BalanceCredit; "Balance (Credit)") { IncludeCaption = true; }
                column(NetChangeACY; "Net Change (ACY)") { IncludeCaption = true; }
                column(NetChangeDebitACY; "Net Change (Debit) (ACY)") { IncludeCaption = true; }
                column(NetChangeCreditACY; "Net Change (Credit) (ACY)") { IncludeCaption = true; }
                column(BalanceACY; "Balance (ACY)") { IncludeCaption = true; }
                column(BalanceDebitACY; "Balance (Debit) (ACY)") { IncludeCaption = true; }
                column(BalanceCreditACY; "Balance (Credit) (ACY)") { IncludeCaption = true; }
            }

            trigger OnAfterGetRecord()
            var
                TrialBalance: Codeunit "Trial Balance";
            begin
                IndentedAccountName := PadStr('', TrialBalanceData.Indentation * 2, ' ') + TrialBalanceData.Name;
                TrialBalance.InsertBreakdownForGLAccount(TrialBalanceData, Dimension1Values, Dimension2Values, EXRTrialBalanceBuffer);
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
        AboutTitle = 'Trial Balance Excel';
        AboutText = 'This report contains aggregated general ledger data for the trial balance with debit/credit columns for net change and balance. A report is shown for both local currency (LCY) and additional reporting currency (ACY), the latter only showing data if Additional Reporting Currency is in use. The aggregation is for the period specified in the report''s request page''s Datefilter parameter and summarized per the 2 global dimensions per g/l account category.';
    }
    rendering
    {
        layout(TrialBalanceExcelLayout)
        {
            Type = Excel;
            LayoutFile = './ReportLayouts/Excel/GeneralLedger/TrialBalanceExcel.xlsx';
            Caption = 'Trial Balance Excel';
            Summary = 'Built in layout for Trial Balance Excel. This report contains aggregated general ledger data for the trial balance with debit/credit columns for net change and balance. Report uses Query connections.';
        }
    }
    labels
    {
        TrialBalanceLCY = 'Trial Balance (LCY)';
        TrialBalanceACYSheet = 'Trial Balance (ACY)';
        TrialBalanceACY = 'Trial Balance (Additional Reporting Currency)';
        DataRetrieved = 'Data retrieved:';
    }

    trigger OnPreReport()
    begin
        TrialBalanceData.SecurityFiltering(SecurityFilter::Filtered);
        CompanyInformation.Get();
    end;

    var
        Dimension1Values: List of [Code[20]];
        Dimension2Values: List of [Code[20]];

    protected var
        CompanyInformation: Record "Company Information";
        IndentedAccountName: Text;

}


// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Company;

report 4407 "EXR Trial Bal. Prev Year Excel"
{
    ApplicationArea = All;
    Caption = 'Trial Balance/Previous Year Excel (Preview)';
    DataAccessIntent = ReadOnly;
    DefaultRenderingLayout = TrialBalancePrevYearExcelLayout;
    ExcelLayoutMultipleDataSheets = true;
    UsageCategory = ReportsAndAnalysis;
    MaximumDatasetSize = 1000000;

    dataset
    {
        dataitem(TrialBalancePreviousYearData; "G/L Account")
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
                DataItemLink = "G/L Account No." = field("No.");
                RequestFilterFields = Balance, "Net Change";
                column(Account; "G/L Account No.") { IncludeCaption = true; }
                column(Dimension1Code; "Dimension 1 Code") { IncludeCaption = true; }
                column(Dimension2Code; "Dimension 2 Code") { IncludeCaption = true; }
                column(NetChangeDebit; "Net Change (Debit)") { IncludeCaption = true; }
                column(NetChangeCredit; "Net Change (Credit)") { IncludeCaption = true; }
                column(BalanceDebit; "Balance (Debit)") { IncludeCaption = true; }
                column(BalanceCredit; "Balance (Credit)") { IncludeCaption = true; }
                column(LastPeriodNet; "Last Period Net") { IncludeCaption = true; }
                column(LastPeriodBalance; "Last Period Bal.") { IncludeCaption = true; }
                column(NetVariance; "Net Variance") { IncludeCaption = true; }
                column(NetPercentVariance; "% of Net Variance") { IncludeCaption = true; }
                column(BalanceVariance; "Bal. Variance") { IncludeCaption = true; }
                column(BalancePercentVariance; "% of Bal. Variance") { IncludeCaption = true; }
                column(NetChangeDebitACY; "Net Change (Debit) (ACY)") { IncludeCaption = true; }
                column(NetChangeCreditACY; "Net Change (Credit) (ACY)") { IncludeCaption = true; }
                column(BalanceDebitACY; "Balance (Debit) (ACY)") { IncludeCaption = true; }
                column(BalanceCreditACY; "Balance (Credit) (ACY)") { IncludeCaption = true; }
                column(LastPeriodNetACY; "Last Period Net (ACY)") { IncludeCaption = true; }
                column(LastPeriodBalanceACY; "Last Period Bal. (ACY)") { IncludeCaption = true; }
                column(NetVarianceACY; "Net Variance (ACY)") { IncludeCaption = true; }
                column(NetPercentVarianceACY; "% of Net Variance (ACY)") { IncludeCaption = true; }
                column(BalanceVarianceACY; "Bal. Variance (ACY)") { IncludeCaption = true; }
                column(BalancePercentVarianceACY; "% of Bal. Variance (ACY)") { IncludeCaption = true; }
            }

            trigger OnAfterGetRecord()
            begin
                Clear(EXRTrialBalanceBuffer);
                EXRTrialBalanceBuffer.DeleteAll();
                IndentedAccountName := PadStr('', TrialBalancePreviousYearData.Indentation * 2, ' ') + TrialBalancePreviousYearData.Name;

                BuildDataset(TrialBalancePreviousYearData);
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
        AboutTitle = 'Trial Balance/Previous Year Excel';
        AboutText = 'This report contains aggregated general ledger data for the trial balance with debit/credit columns for net change and balance. A report is shown for both local currency (LCY) and additional reporting currency (ACY, the latter only showing data if Additional Reporting Currency is in use. In addition to debit/credit for net change and balance the report shows the net debit/credit amount for both net change and balance for comparison. The aggregation is for the period specified in the report''s request page''s Datefilter parameter and summarized per the 2 global dimensions per g/l account category.';
    }
    rendering
    {
        layout(TrialBalancePrevYearExcelLayout)
        {
            Type = Excel;
            LayoutFile = './ReportLayouts/Excel/GeneralLedger/TrialBalancePrevYearExcel.xlsx';
            Caption = 'Trial Balance/Previous Year Excel';
            Summary = 'Built in layout for the Trial Balance/Previous Year Excel report.This report contains aggregated general ledger data for the trial balance with debit/credit columns for net change and balance. Report uses Query connections.';
        }
    }
    labels
    {
        DataRetrieved = 'Data retrieved:';
        TrialBalanceLCY = 'Trial Balance (LCY)';
        TrialBalanceACY = 'Trial Balance (ACY)';
        TrialBalancevsLastPeriodACY = 'Trial Balance vs. Last Period (Additional Reporting Currency)';
        TrialBalancevsLastPeriod = 'Trial Balance vs. Last Period';
    }
    trigger OnPreReport()
    begin
        TrialBalancePreviousYearData.SecurityFiltering(SecurityFilter::Filtered);
        CompanyInformation.Get();

        FromDate := TrialBalancePreviousYearData.GetRangeMin("Date Filter");
        ToDate := TrialBalancePreviousYearData.GetRangeMax("Date Filter");
        PriorFromDate := CalcDate('<-1Y>', FromDate + 1) - 1;
        PriorToDate := CalcDate('<-1Y>', ToDate + 1) - 1;
    end;

    protected var
        CompanyInformation: Record "Company Information";
        FromDate: Date;
        PriorFromDate: Date;
        PriorToDate: Date;
        ToDate: Date;
        IndentedAccountName: Text;

    local procedure BuildDataset(var GLAccount: Record "G/L Account")
    var
        DimensionValue1: Record "Dimension Value";
        DimensionValue2: Record "Dimension Value";
    begin
        DimensionValue1.SetRange("Global Dimension No.", 1);
        DimensionValue2.SetRange("Global Dimension No.", 2);

        InsertGLAccountData(GLAccount, DimensionValue1, DimensionValue2);
    end;

    local procedure InsertGLAccountData(var GLAccount: Record "G/L Account"; var DimensionValue1: Record "Dimension Value"; var DimensionValue2: Record "Dimension Value")
    begin
        AddGLToDataset(GLAccount, '', '');

        if DimensionValue1.FindSet() then
            repeat
                AddGLToDataset(GLAccount, DimensionValue1."Code", '');
                if DimensionValue2.FindSet() then
                    repeat
                        AddGLToDataset(GLAccount, DimensionValue1."Code", DimensionValue2."Code");
                    until DimensionValue2.Next() = 0;
            until DimensionValue1.Next() = 0;

        if DimensionValue2.FindSet() then
            repeat
                AddGLToDataset(GLAccount, '', DimensionValue2."Code");
            until DimensionValue2.Next() = 0;
    end;

    local procedure AddGLToDataset(var GLAccount: Record "G/L Account"; Dimension1Code: Code[20]; Dimension2Code: Code[20])
    var
        LocalGLAccount: Record "G/L Account";
        LocalGLAccountLastPeriod: Record "G/L Account";
    begin
        LocalGLAccount.Copy(GLAccount);
        LocalGLAccount.SetRange("Global Dimension 1 Filter", Dimension1Code);
        LocalGLAccount.SetRange("Global Dimension 2 Filter", Dimension2Code);

        LocalGLAccount.CalcFields("Net Change", "Balance at Date", "Additional-Currency Net Change", "Add.-Currency Balance at Date");
        LocalGLAccountLastPeriod.Copy(LocalGLAccount);
        LocalGLAccountLastPeriod.SetRange("Date Filter", PriorFromDate, PriorToDate);
        LocalGLAccountLastPeriod.CalcFields("Net Change", "Balance at Date", "Additional-Currency Net Change", "Add.-Currency Balance at Date");

        Clear(EXRTrialBalanceBuffer);
        EXRTrialBalanceBuffer."G/L Account No." := LocalGLAccount."No.";
        EXRTrialBalanceBuffer."Dimension 1 Code" := Dimension1Code;
        EXRTrialBalanceBuffer."Dimension 2 Code" := Dimension2Code;

        EXRTrialBalanceBuffer.Validate("Net Change", LocalGLAccount."Net Change");
        EXRTrialBalanceBuffer.Validate("Balance", LocalGLAccount."Balance at Date");
        EXRTrialBalanceBuffer.Validate("Last Period Net", LocalGLAccountLastPeriod."Net Change");
        EXRTrialBalanceBuffer.Validate("Last Period Bal.", LocalGLAccountLastPeriod."Balance at Date");

        EXRTrialBalanceBuffer.Validate("Net Change (ACY)", LocalGLAccount."Additional-Currency Net Change");
        EXRTrialBalanceBuffer.Validate("Balance (ACY)", LocalGLAccount."Add.-Currency Balance at Date");
        EXRTrialBalanceBuffer.Validate("Last Period Net (ACY)", LocalGLAccountLastPeriod."Additional-Currency Net Change");
        EXRTrialBalanceBuffer.Validate("Last Period Bal. (ACY)", LocalGLAccountLastPeriod."Add.-Currency Balance at Date");
        EXRTrialBalanceBuffer.CalculateVariances();
        EXRTrialBalanceBuffer.Insert(true);
    end;
}


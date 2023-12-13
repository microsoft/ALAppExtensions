// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Reports;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Period;
using System.Utilities;

report 11720 "Turnover Rpt. by Gl. Dim. CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/TurnoverRptbyGlDim.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Turnover Report by Global Dimensions';
    TransactionType = Update;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = sorting("No.") where("Account Type" = filter(Posting));
            RequestFilterFields = "No.", "Date Filter", "Global Dimension 1 Filter", "Global Dimension 2 Filter";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(tcText002___gtePeriodText; PeriodLbl + PeriodText)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(USERID; UserId)
            {
            }
            column(Filters; Filters)
            {
            }
            column(gdaDateFrom; DateFrom)
            {
            }
            column(gdaDateStartFisk; DateStartFisk)
            {
            }
            column(gdaDateTo; DateTo)
            {
            }
            column(gteDimCaption; DimCaption)
            {
            }
            column(AccountNo; "No.")
            {
            }
            column(AccDescription; Name)
            {
            }
            column(Synthesis; Synthesis)
            {
            }
            column(Group; Group)
            {
            }
            column(Class; Class)
            {
            }
            column(PrintSynthesisTotals; PrintSynthesis)
            {
            }
            column(PrintDimensions; PrintDim)
            {
            }
            column(SynthesisTotalText; StrSubstNo(TotalForLbl, Synthesis))
            {
            }
            column(GroupTotalText; StrSubstNo(TotalForLbl, Group))
            {
            }
            column(ClassTotalText; StrSubstNo(TotalForLbl, Class))
            {
            }
            column(Col1TotalInitialAmt; Initial2Debit - Initial2Credit)
            {
            }
            column(Col2InitialAmt; InitialDebit - InitialCredit)
            {
            }
            column(Col3Debit; Debit)
            {
            }
            column(Col4Credit; Credit)
            {
            }
            column(Col5DebitTotal; Debit2)
            {
            }
            column(Col6CreditTotal; Credit2)
            {
            }
            column(Col7EndAmt; FinishedDebit - FinishedCredit)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(ReportCaption; General_Ledger_by_Global_DimensionCaptionLbl)
            {
            }
            column(AccNoCaption; AccountCaptionLbl)
            {
            }
            column(Col1TotalInitialAmtCaption; Initial2Debit_gdeInitial2CreditCaptionLbl)
            {
            }
            column(Col2InitialAmtCaption; InitialDebit_gdeInitialCreditCaptionLbl)
            {
            }
            column(Col3DebitCaption; DebitCaptionLbl)
            {
            }
            column(Col4CreditCaption; CreditCaptionLbl)
            {
            }
            column(Col5DebitTotalCaption; Debit2CaptionLbl)
            {
            }
            column(Col6CreditTotalCaption; Credit2CaptionLbl)
            {
            }
            column(Col7EndAmtCaption; FinishedDebit_gdeFinishedCreditCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            dataitem(Dimensions; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(DimCodeText; DimCodeText)
                {
                }
                column(DimCol1TotalInitialAmt; Initial2Debit - Initial2Credit)
                {
                }
                column(DimCol2InitialAmt; InitialDebit - InitialCredit)
                {
                }
                column(DimCol3Debit; Debit)
                {
                }
                column(DimCol4Credit; Credit)
                {
                }
                column(DimCol5DebitTotal; Debit2)
                {
                }
                column(DimCol6CreditTotal; Credit2)
                {
                }
                column(DimCol7EndAmt; FinishedDebit - FinishedCredit)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        DimensionValue.FindSet()
                    else
                        DimensionValue.Next();

                    if (Number < DimCount) or (not PrintEmptyDim) then begin
                        if Detail = Detail::GlDim1 then
                            "G/L Account".SetFilter("Global Dimension 1 Filter", DimensionValue.Code);
                        if Detail = Detail::GlDim2 then
                            "G/L Account".SetFilter("Global Dimension 2 Filter", DimensionValue.Code);
                        DimCodeText := DimensionValue.Code;
                    end else begin
                        if Detail = Detail::GlDim1 then
                            "G/L Account".SetFilter("Global Dimension 1 Filter", '''''');
                        if Detail = Detail::GlDim2 then
                            "G/L Account".SetFilter("Global Dimension 2 Filter", '''''');
                        DimCodeText := OthersCaptionLbl;
                    end;

                    CalculateValues();

                    if (InitialDebit = 0) and (InitialCredit = 0) and
                       (Initial2Debit = 0) and (Initial2Credit = 0) and
                       (Debit = 0) and (Credit = 0) and
                       (Debit2 = 0) and (Credit2 = 0) and
                       (FinishedDebit = 0) and (FinishedCredit = 0)
                    then
                        CurrReport.Skip();
                end;

                trigger OnPreDataItem()
                begin
                    if not PrintDim then
                        CurrReport.Break();

                    case Detail of
                        Detail::GlDim1:
                            begin
                                DimensionValue.SetRange("Dimension Code", GeneralLedgerSetup."Global Dimension 1 Code");
                                if Dim1Filter <> '' then
                                    DimensionValue.SetFilter(Code, Dim1Filter);
                            end;
                        Detail::GlDim2:
                            begin
                                DimensionValue.SetRange("Dimension Code", GeneralLedgerSetup."Global Dimension 2 Code");
                                if Dim2Filter <> '' then
                                    DimensionValue.SetFilter(Code, Dim2Filter);
                            end;
                    end;

                    PrintEmptyDim := not (((Dim1Filter <> '') and (Detail = Detail::GlDim1)) or
                                          ((Dim2Filter <> '') and (Detail = Detail::GlDim2)));

                    DimCount := DimensionValue.Count();
                    if PrintEmptyDim then
                        DimCount += 1;

                    SetRange(Number, 1, DimCount);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                Synthesis := CopyStr("No.", 1, 3);
                Group := CopyStr("No.", 1, 2);
                Class := CopyStr("No.", 1, 1);

                if not PrintDim then begin
                    CalculateValues();

                    if (InitialDebit = 0) and (InitialCredit = 0) and
                       (Initial2Debit = 0) and (Initial2Credit = 0) and
                       (Debit = 0) and (Credit = 0) and
                       (Debit2 = 0) and (Credit2 = 0) and
                       (FinishedDebit = 0) and (FinishedCredit = 0)
                    then
                        CurrReport.Skip();
                end;
            end;

            trigger OnPreDataItem()
            var
                Dim: Record Dimension;
                DimTransln: Record "Dimension Translation";
            begin
                PeriodText := Format(DateFrom) + '..' + Format(DateTo);
                if DateFrom > DateTo then
                    Error(WrongDateIntervalLbl);

                if GLEntry.RecordLevelLocking then begin
                    GLEntry.LockTable();
                    GLEntry.FindLast();
                end;

                GeneralLedgerSetup.Get();
                case Detail of
                    Detail::GlDim1:
                        begin
                            Dim.Get(GeneralLedgerSetup."Global Dimension 1 Code");
                            if DimTransln.Get(GeneralLedgerSetup."Global Dimension 1 Code", CurrReport.Language) then
                                DimCaption := DimTransln."Code Caption"
                            else
                                DimCaption := Dim."Code Caption";
                        end;
                    Detail::GlDim2:
                        begin
                            Dim.Get(GeneralLedgerSetup."Global Dimension 2 Code");
                            if DimTransln.Get(GeneralLedgerSetup."Global Dimension 2 Code", CurrReport.Language) then
                                DimCaption := DimTransln."Code Caption"
                            else
                                DimCaption := Dim."Code Caption";
                        end;
                    Detail::Empty:
                        Clear(DimCaption);
                end;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        SourceTable = "Country/Region";

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DetailField; Detail)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Detail';
                        OptionCaption = 'Empty,Shortcut Dimension 1 Code,Shortcut Dimension 2 Code';
                        ToolTip = 'Specifies detail of report';
                    }
                    field(PrintSynthesisField; PrintSynthesis)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Synthesis';
                        ToolTip = 'Specifies if the synthesis accounts have to be printed.';
                    }
                    field(IncomeInFYField; IncomeInFY)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Income Only In Current Year';
                        ToolTip = 'Specifies if the income only has to be printed only in current year.';
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        PrintDim := Detail <> Detail::Empty;

        DateFrom := "G/L Account".GetRangeMin("Date Filter");
        DateTo := "G/L Account".GetRangeMax("Date Filter");

        // Fiscal Year Start
        DateStartFisk := AccountingPeriodMgt.FindFiscalYear(DateFrom);

        Dim1Filter := "G/L Account".GetFilter("Global Dimension 1 Filter");
        Dim2Filter := "G/L Account".GetFilter("Global Dimension 2 Filter");
        Filters := "G/L Account".GetFilters;
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GLEntry: Record "G/L Entry";
        DimensionValue: Record "Dimension Value";
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
        Synthesis: Code[3];
        Group: Code[2];
        Class: Code[1];
        PeriodText: Text[30];
        DimCaption: Text[80];
        Dim1Filter: Text;
        Dim2Filter: Text;
        Filters: Text;
        InitialDebit: Decimal;
        InitialCredit: Decimal;
        Initial2Debit: Decimal;
        Initial2Credit: Decimal;
        Debit: Decimal;
        Credit: Decimal;
        Debit2: Decimal;
        Credit2: Decimal;
        FinishedDebit: Decimal;
        FinishedCredit: Decimal;
        DateFrom: Date;
        DateTo: Date;
        DateStartFisk: Date;
        Detail: Option Empty,GlDim1,GlDim2;
        PrintSynthesis: Boolean;
        IncomeInFY: Boolean;
        PrintDim: Boolean;
        PrintEmptyDim: Boolean;
        DimCount: Integer;
        DimCodeText: Text[30];
        TotalForLbl: Label 'Total for %1', Comment = '%1 = type of total';
        PeriodLbl: Label 'Period :';
        WrongDateIntervalLbl: Label 'Wrong Date Interval!';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        General_Ledger_by_Global_DimensionCaptionLbl: Label 'Turnover report by Global Dimension';
        AccountCaptionLbl: Label 'Account No.';
        DebitCaptionLbl: Label 'Debit for period';
        CreditCaptionLbl: Label 'Credit for period';
        Debit2CaptionLbl: Label 'Total debit for all period';
        Credit2CaptionLbl: Label 'Total credit for all period';
        InitialDebit_gdeInitialCreditCaptionLbl: Label 'Initial state for period';
        Initial2Debit_gdeInitial2CreditCaptionLbl: Label 'Initial state for period';
        FinishedDebit_gdeFinishedCreditCaptionLbl: Label 'Closing balance';
        OthersCaptionLbl: Label 'Others';
        TotalCaptionLbl: Label 'Total';

    procedure CalculateValues()
    begin
        // Fiscal Year First Period
        // Start Balance
        if IncomeInFY and ("G/L Account"."Income/Balance" = "G/L Account"."Income/Balance"::"Income Statement") then begin
            if DateFrom = DateStartFisk then
                "G/L Account".SetFilter("Date Filter", '%1..%2', DateStartFisk, ClosingDate(DateFrom - 1))
            else
                "G/L Account".SetFilter("Date Filter", '%1..%2', DateStartFisk, DateFrom - 1);
        end else
            if DateFrom = DateStartFisk then
                "G/L Account".SetFilter("Date Filter", '..%1', ClosingDate(DateFrom - 1))
            else
                "G/L Account".SetFilter("Date Filter", '..%1', DateFrom - 1);
        "G/L Account".CalcFields("Debit Amount", "Credit Amount");
        InitialDebit := "G/L Account"."Debit Amount";
        InitialCredit := "G/L Account"."Credit Amount";

        // Start Balance 2
        if not (IncomeInFY and ("G/L Account"."Income/Balance" = "G/L Account"."Income/Balance"::"Income Statement")) then begin
            "G/L Account".SetFilter("Date Filter", '..%1', ClosingDate(DateStartFisk - 1));
            "G/L Account".CalcFields("Debit Amount", "Credit Amount");
            Initial2Debit := "G/L Account"."Debit Amount";
            Initial2Credit := "G/L Account"."Credit Amount";
        end else begin
            Initial2Debit := 0;
            Initial2Credit := 0;
        end;

        // Balance by period
        "G/L Account".SetFilter("Date Filter", '%1..%2', DateFrom, DateTo);
        "G/L Account".CalcFields("Debit Amount", "Credit Amount");
        Debit := "G/L Account"."Debit Amount";
        Credit := "G/L Account"."Credit Amount";

        // Balance by period 2
        "G/L Account".SetFilter("Date Filter", '%1..%2', DateStartFisk, DateTo);
        "G/L Account".CalcFields("Debit Amount", "Credit Amount");
        Debit2 := "G/L Account"."Debit Amount";
        Credit2 := "G/L Account"."Credit Amount";

        // End balance
        if IncomeInFY and ("G/L Account"."Income/Balance" = "G/L Account"."Income/Balance"::"Income Statement") then
            "G/L Account".SetFilter("Date Filter", '%1..%2', DateStartFisk, DateTo)
        else
            "G/L Account".SetFilter("Date Filter", '..%1', DateTo);
        "G/L Account".CalcFields("Debit Amount", "Credit Amount");
        FinishedDebit := "G/L Account"."Debit Amount";
        FinishedCredit := "G/L Account"."Credit Amount";
    end;
}

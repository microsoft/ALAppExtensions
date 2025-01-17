#if not CLEAN24
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;

report 11769 "VAT Statement CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/VATStatement.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'VAT Statement CZ';
    UsageCategory = ReportsAndAnalysis;
    ObsoleteState = Pending;
    ObsoleteTag = '24.0';
    ObsoleteReason = 'This report is replaced by the extension of VAT Statement report (11703).';

    dataset
    {
        dataitem("VAT Statement Name"; "VAT Statement Name")
        {
            DataItemTableView = sorting("Statement Template Name", Name);
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Statement Template Name", Name;
            column(StmtName1_VatStmtName; "Statement Template Name")
            {
            }
            column(Name1_VatStmtName; Name)
            {
            }
            dataitem("VAT Statement Line"; "VAT Statement Line")
            {
                DataItemLink = "Statement Template Name" = field("Statement Template Name"), "Statement Name" = field(Name);
                DataItemTableView = sorting("Statement Template Name", "Statement Name") where(Print = const(true));
                RequestFilterFields = "Row No.";
                column(Heading; Heading)
                {
                }
                column(CompanyName; COMPANYPROPERTY.DisplayName())
                {
                }
                column(StmtName_VatStmtName; "VAT Statement Name"."Statement Template Name")
                {
                }
                column(Name_VatStmtName; "VAT Statement Name".Name)
                {
                }
                column(Heading2; Heading2)
                {
                }
                column(HeaderText; HeaderText)
                {
                }
                column(GlSetupLCYCode; GeneralLedgerSetup."LCY Code")
                {
                }
                column(Allamountsarein; AllamountsareinLbl)
                {
                }
                column(TxtGLSetupAddnalReportCur; StrSubstNo(AmountsCurrencyLbl, GeneralLedgerSetup."Additional Reporting Currency"))
                {
                }
                column(GLSetupAddRepCurrency; GeneralLedgerSetup."Additional Reporting Currency")
                {
                }
                column(VatStmLineTableCaptFilter; TableCaption() + ': ' + VATStmtLineFilter)
                {
                }
                column(VatStmtLineFilter; VATStmtLineFilter)
                {
                }
                column(VatStmtLineRowNo; "Row No.")
                {
                    IncludeCaption = true;
                }
                column(Description_VatStmtLine; Description)
                {
                    IncludeCaption = true;
                }
                column(TotalAmount; TotalAmount)
                {
                    AutoFormatExpression = GetCurrency();
                    AutoFormatType = 1;
                }
                column(UseAmtsInAddCurr; UseAmtsInAddCurr)
                {
                }
                column(Selection; VATStatementReportSelection)
                {
                }
                column(PeriodSelection; VATStatementReportPeriodSelection)
                {
                }
                column(PrintInIntegers; PrintInIntegers)
                {
                }
                column(PageGroupNo; PageGroupNo)
                {
                }
                column(VATStmtCaption; VATStmtCaptionLbl)
                {
                }
                column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
                {
                }
                column(VATStmtTemplateCaption; VATStmtTemplateCaptionLbl)
                {
                }
                column(VATStmtNameCaption; VATStmtNameCaptionLbl)
                {
                }
                column(AmtsareinwholeLCYsCaption; AmtsareinwholeLCYsCaptionLbl)
                {
                }
                column(ReportinclallVATentriesCaption; ReportinclallVATentriesCaptionLbl)
                {
                }
                column(RepinclonlyclosedVATentCaption; RepinclonlyclosedVATentCaptionLbl)
                {
                }
                column(TotalAmountCaption; TotalAmountCaptionLbl)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    CalcLineTotal("VAT Statement Line", TotalAmount, 0);
                    if PrintInIntegers then
                        TotalAmount := RoundAmount(TotalAmount);
                    case "Show CZL" of
                        "Show CZL"::"Zero If Negative":
                            if TotalAmount < 0 then
                                TotalAmount := 0;
                        "Show CZL"::"Zero If Positive":
                            if TotalAmount > 0 then
                                TotalAmount := 0;
                    end;
                    if "Print with" = "Print with"::"Opposite Sign" then
                        TotalAmount := -TotalAmount;
                    PageGroupNo := NextPageGroupNo;
                    if "New Page" then
                        NextPageGroupNo := PageGroupNo + 1;
                end;

                trigger OnPreDataItem()
                begin
                    PageGroupNo := 1;
                    NextPageGroupNo := 1;
                end;
            }
            trigger OnPreDataItem()
            begin
                GeneralLedgerSetup.Get();
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
                    group("Statement Period")
                    {
                        Caption = 'Statement Period';
                        field(StartingDate; StartDate)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Starting Date';
                            ToolTip = 'Specifies the start date for the time interval for VAT statement lines in the report.';
                        }
                        field(EndingDate; EndDateReq)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Ending Date';
                            ToolTip = 'Specifies the end date for the time interval for VAT statement lines in the report.';
                        }
                    }
                    field(Selection; VATStatementReportSelection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include VAT Entries';
                        Importance = Additional;
                        ToolTip = 'Specifies if you want to include open VAT entries in the report.';
                    }
                    field(PeriodSelection; VATStatementReportPeriodSelection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include VAT Entries';
                        Importance = Additional;
                        ToolTip = 'Specifies if you want to include VAT entries from before the specified time period in the report.';
                    }
                    field(RoundToWholeNumbers; PrintInIntegers)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Round to Whole Numbers';
                        Importance = Additional;
                        ToolTip = 'Specifies if you want the amounts in the report to be rounded to whole numbers.';

                        trigger OnValidate()
                        begin
                            RoundingDirectionCtrlVisible := PrintInIntegers;
                        end;
                    }
                    group(RoundingDirectionCtrl)
                    {
                        ShowCaption = false;
                        Visible = RoundingDirectionCtrlVisible;
                        field(RoundingDirectionField; RoundingDirection)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Rounding Direction';
                            OptionCaption = 'Nearest,Down,Up';
                            ToolTip = 'Specifies rounding direction of the vat statement';
                        }
                    }
                    field(ShowAmtInAddCurrency; UseAmtsInAddCurr)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Amounts in Add. Reporting Currency';
                        Importance = Additional;
                        MultiLine = true;
                        ToolTip = 'Specifies if you want report amounts to be shown in the additional reporting currency.';
                    }
                    field(SettlementNoFilterField; SettlementNoFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Filter VAT Settlement No.';
                        ToolTip = 'Specifies the filter setup of document number which the VAT entries were closed.';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            RoundingDirectionCtrlVisible := PrintInIntegers;
        end;
    }
    trigger OnPreReport()
    begin
        if EndDateReq = 0D then
            EndDate := DMY2Date(31, 12, 9999)
        else
            EndDate := EndDateReq;
        VATStatementLine.SetRange("Date Filter", StartDate, EndDateReq);
        if VATStatementReportPeriodSelection = VATStatementReportPeriodSelection::"Before and Within Period" then
            Heading := BeforeAndWithinPeriodLbl
        else
            Heading := EntriesWithinPeriodLbl;
        Heading2 := StrSubstNo(PeriodRangeLbl, StartDate, EndDateReq);
        VATStmtLineFilter := VATStatementLine.GetFilters();
        if SettlementNoFilter <> '' then
            Heading2 := Heading2 + ',' + VATEntry.FieldCaption("VAT Settlement No. CZL") + ':' + SettlementNoFilter;
    end;

    var
        GLAccount: Record "G/L Account";
        VATEntry: Record "VAT Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        SecondVATEntry: Record "VAT Entry";
        VATStatementLine: Record "VAT Statement Line";
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        VATStatementReportSelection: Enum "VAT Statement Report Selection";
        VATStatementReportPeriodSelection: Enum "VAT Statement Report Period Selection";
        PrintInIntegers: Boolean;
        VATStmtLineFilter: Text;
        Heading: Text[50];
        Amount: Decimal;
        TotalAmount: Decimal;
        RowNo: array[6] of Code[10];
        ErrorText: Text[80];
        index: Integer;
        PageGroupNo: Integer;
        NextPageGroupNo: Integer;
        UseAmtsInAddCurr: Boolean;
        HeaderText: Text[50];
        EndDate: Date;
        StartDate: Date;
        EndDateReq: Date;
        Heading2: Text;
        RoundingDirection: Option Nearest,Down,Up;
        SettlementNoFilter: Text[50];
        CallLevel: Integer;
        DivisionError: Boolean;
        BeforeAndWithinPeriodLbl: Label 'VAT entries before and within the period';
        EntriesWithinPeriodLbl: Label 'VAT entries within the period';
        AmountsCurrencyLbl: Label 'Amounts are in %1, rounded without decimals.', Comment = '%1=additional reporting currency';
        PeriodRangeLbl: Label 'Period: %1..%2', Comment = '%1=start date, %2=end date';
        AllamountsareinLbl: Label 'All amounts are in';
        VATStmtCaptionLbl: Label 'VAT Statement';
        CurrReportPageNoCaptionLbl: Label 'Page';
        VATStmtTemplateCaptionLbl: Label 'VAT Statement Template';
        VATStmtNameCaptionLbl: Label 'VAT Statement Name';
        AmtsareinwholeLCYsCaptionLbl: Label 'Amounts are in whole LCYs.';
        ReportinclallVATentriesCaptionLbl: Label 'The report includes all VAT entries.';
        RepinclonlyclosedVATentCaptionLbl: Label 'The report includes only closed VAT entries.';
        TotalAmountCaptionLbl: Label 'Amount';
        CircularRefErr: Label 'Formula cannot be calculated due to circular references.';
        DivideByZeroErr: Label 'Dividing by zero is not possible.';
        InvalidValueErr: Label 'You have entered an invalid value or a nonexistent row number.';

        RoundingDirectionCtrlVisible: Boolean;

    procedure CalcLineTotal(VATStatementLine: Record "VAT Statement Line"; var TotalAmount: Decimal; Level: Integer): Boolean
    var
        IsHandled: Boolean;
    begin
        if Level = 0 then
            TotalAmount := 0;
        case VATStatementLine.Type of
            VATStatementLine.Type::"Account Totaling":
                begin
                    GLAccount.SetFilter("No.", VATStatementLine."Account Totaling");
                    if EndDateReq = 0D then
                        EndDate := DMY2Date(31, 12, 9999)
                    else
                        EndDate := EndDateReq;
                    GLAccount.SetRange("Date Filter", StartDate, EndDate);
                    Amount := 0;
                    if GLAccount.FindSet() and (VATStatementLine."Account Totaling" <> '') then
                        repeat
                            case VATStatementLine."G/L Amount Type CZL" of
                                VATStatementLine."G/L Amount Type CZL"::"Net Change":
                                    begin
                                        GLAccount.CalcFields("Net Change (VAT Date) CZL", "Net Change ACY (VAT Date) CZL");
                                        Amount := ConditionalAdd(Amount, GLAccount."Net Change (VAT Date) CZL", GLAccount."Net Change ACY (VAT Date) CZL");
                                    end;
                                VATStatementLine."G/L Amount Type CZL"::Debit:
                                    begin
                                        GLAccount.CalcFields("Debit Amount (VAT Date) CZL", "Debit Amt. ACY (VAT Date) CZL");
                                        Amount := ConditionalAdd(Amount, GLAccount."Debit Amount (VAT Date) CZL", GLAccount."Debit Amt. ACY (VAT Date) CZL");
                                    end;
                                VATStatementLine."G/L Amount Type CZL"::Credit:
                                    begin
                                        GLAccount.CalcFields("Credit Amount (VAT Date) CZL", "Credit Amt. ACY (VAT Date) CZL");
                                        Amount := ConditionalAdd(Amount, GLAccount."Credit Amount (VAT Date) CZL", GLAccount."Credit Amt. ACY (VAT Date) CZL");
                                    end;
                            end;
                        until GLAccount.Next() = 0;
                    CalcTotalAmount(VATStatementLine, TotalAmount);
                end;
            VATStatementLine.Type::"VAT Entry Totaling":
                begin
                    VATEntry.Reset();

                    if not VATEntry.SetCurrentKey(
                         Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group",
                         "Gen. Bus. Posting Group", "Gen. Prod. Posting Group",
                         "EU 3-Party Trade")
                    then
                        VATEntry.SetCurrentKey(
                          Type, Closed, "Tax Jurisdiction Code", "Use Tax", "Posting Date");

                    VATEntry.SetVATStatementLineFiltersCZL(VATStatementLine);
                    GeneralLedgerSetup.Get();
                    VATEntry.SetPeriodFilterCZL(VATStatementReportPeriodSelection, StartDate, EndDate, VATReportingDateMgt.IsVATDateEnabled());
                    if SettlementNoFilter <> '' then
                        VATEntry.SetFilter("VAT Settlement No. CZL", SettlementNoFilter);
                    VATEntry.SetClosedFilterCZL(VATStatementReportSelection);

                    SecondVATEntry.Reset();
                    SecondVATEntry.CopyFilters(VATEntry);
                    Amount := 0;
                    case VATStatementLine."Amount Type" of
                        VATStatementLine."Amount Type"::Amount:
                            begin
                                VATEntry.CalcSums(Amount, "Additional-Currency Amount");
                                Amount := ConditionalAdd(0, VATEntry.Amount, VATEntry."Additional-Currency Amount");
                            end;
                        VATStatementLine."Amount Type"::Base:
                            begin
                                VATEntry.CalcSums(Base, "Additional-Currency Base");
                                Amount := ConditionalAdd(0, VATEntry.Base, VATEntry."Additional-Currency Base");
                            end;
                        VATStatementLine."Amount Type"::"Unrealized Amount":
                            begin
                                VATEntry.CalcSums("Remaining Unrealized Amount", "Add.-Curr. Rem. Unreal. Amount");
                                Amount := ConditionalAdd(0, VATEntry."Remaining Unrealized Amount", VATEntry."Add.-Curr. Rem. Unreal. Amount");
                            end;
                        VATStatementLine."Amount Type"::"Unrealized Base":
                            begin
                                VATEntry.CalcSums("Remaining Unrealized Base", "Add.-Curr. Rem. Unreal. Base");
                                Amount := ConditionalAdd(0, VATEntry."Remaining Unrealized Base", VATEntry."Add.-Curr. Rem. Unreal. Base");
                            end;
                    end;
                    OnCalcLineTotalOnBeforeCalcTotalAmountVATEntryTotaling(VATStatementLine, VATEntry, Amount, UseAmtsInAddCurr);
                    CalcTotalAmount(VATStatementLine, TotalAmount);
                end;
            VATStatementLine.Type::"Row Totaling":
                begin
                    if Level >= ArrayLen(RowNo) then
                        exit(false);
                    Level := Level + 1;
                    RowNo[Level] := VATStatementLine."Row No.";

                    if VATStatementLine."Row Totaling" = '' then
                        exit(true);
                    VATStatementLine.SetRange("Statement Template Name", VATStatementLine."Statement Template Name");
                    VATStatementLine.SetRange("Statement Name", VATStatementLine."Statement Name");
                    VATStatementLine.SetFilter("Row No.", VATStatementLine."Row Totaling");
                    if VATStatementLine.FindSet() then
                        repeat
                            if not CalcLineTotal(VATStatementLine, TotalAmount, Level) then begin
                                if Level > 1 then
                                    exit(false);
                                for index := 1 to ArrayLen(RowNo) do
                                    ErrorText := ErrorText + RowNo[index] + ' => ';
                                ErrorText := CopyStr((ErrorText + '...'), 1, MaxStrLen(ErrorText));
                                VATStatementLine.FieldError("Row No.", ErrorText);
                            end;
                        until VATStatementLine.Next() = 0;
                end;
            VATStatementLine.Type::"Formula CZL":
                begin
                    Amount := EvaluateExpression(true, VATStatementLine."Row Totaling", VATStatementLine, true);
                    CalcTotalAmount(VATStatementLine, TotalAmount);
                end;
            else begin
                IsHandled := false;
                Amount := 0;
                OnCalcLineTotalVATStatementLineTypeCase(VATStatementLine, Amount, IsHandled);
            end;
        end;

        exit(true);
    end;

    local procedure CalcTotalAmount(VATStatementLine: Record "VAT Statement Line"; var TotalAmount: Decimal)
    begin
        if VATStatementLine."Calculate with" = VATStatementLine."Calculate with"::"Opposite Sign" then
            Amount := -Amount;
        if PrintInIntegers and VATStatementLine.Print then
            Amount := RoundAmount(Amount);
        TotalAmount := TotalAmount + Amount;
    end;

    procedure InitializeRequest(var NewVATStatementName: Record "VAT Statement Name"; var NewVATStatementLine: Record "VAT Statement Line"; NewSelection: Enum "VAT Statement Report Selection"; NewPeriodSelection: Enum "VAT Statement Report Period Selection"; NewPrintInIntegers: Boolean; NewUseAmtsInAddCurr: Boolean; SettlementNoFilter2: Text[50])
    begin
        "VAT Statement Name".Copy(NewVATStatementName);
        "VAT Statement Line".Copy(NewVATStatementLine);
        VATStatementReportSelection := NewSelection;
        VATStatementReportPeriodSelection := NewPeriodSelection;
        PrintInIntegers := NewPrintInIntegers;
        UseAmtsInAddCurr := NewUseAmtsInAddCurr;
        if NewVATStatementLine.GetFilter("Date Filter") <> '' then begin
            StartDate := NewVATStatementLine.GetRangeMin("Date Filter");
            EndDateReq := NewVATStatementLine.GetRangeMax("Date Filter");
            EndDate := EndDateReq;
        end else begin
            StartDate := 0D;
            EndDateReq := 0D;
            EndDate := DMY2Date(31, 12, 9999);
        end;
        SettlementNoFilter := SettlementNoFilter2;
    end;

    local procedure ConditionalAdd(Amount: Decimal; AmountToAdd: Decimal; AddCurrAmountToAdd: Decimal): Decimal
    begin
        if UseAmtsInAddCurr then
            exit(Amount + AddCurrAmountToAdd);

        exit(Amount + AmountToAdd);
    end;

    local procedure GetCurrency(): Code[10]
    begin
        if UseAmtsInAddCurr then
            exit(GeneralLedgerSetup."Additional Reporting Currency");

        exit('');
    end;

    procedure SetRoundingDirection(NewRoundingDirection: Option)
    begin
        RoundingDirection := NewRoundingDirection;
    end;

    procedure RoundAmount(Amount3: Decimal): Decimal
    var
        RoundDirParameter: Text[1];
    begin
        case RoundingDirection of
            RoundingDirection::Nearest:
                RoundDirParameter := '=';
            RoundingDirection::Up:
                RoundDirParameter := '>';
            RoundingDirection::Down:
                RoundDirParameter := '<';
        end;
        exit(Round(Amount3, 1, RoundDirParameter));
    end;


    local procedure EvaluateExpression(IsVATStmtLineExpression: Boolean; Expression: Text; VATStatementLine: Record "VAT Statement Line"; CalcAddCurr: Boolean): Decimal
    var
        Result: Decimal;
        Parantheses: Integer;
        Operator: Char;
        LeftOperand: Text;
        RightOperand: Text;
        LeftResult: Decimal;
        RightResult: Decimal;
        i: Integer;
        IsExpression: Boolean;
        IsFilter: Boolean;
        Operators: Text[8];
        OperatorNo: Integer;
        VATStmtLineID: Integer;
        LineTotalAmount: Decimal;
    begin
        Result := 0;

        CallLevel := CallLevel + 1;
        if CallLevel > 25 then
            Error(CircularRefErr);

        Expression := DelChr(Expression, '<>', '');
        if StrLen(Expression) > 0 then begin
            Parantheses := 0;
            IsExpression := false;
            Operators := '+-*/^';
            OperatorNo := 1;
            repeat
                i := StrLen(Expression);
                repeat
                    if Expression[i] = '(' then
                        Parantheses := Parantheses + 1
                    else
                        if Expression[i] = ')' then
                            Parantheses := Parantheses - 1;
                    if (Parantheses = 0) and (Expression[i] = Operators[OperatorNo]) then
                        IsExpression := true
                    else
                        i := i - 1;
                until IsExpression or (i <= 0);
                if not IsExpression then
                    OperatorNo := OperatorNo + 1;
            until (OperatorNo > StrLen(Operators)) or IsExpression;
            if IsExpression then begin
                if i > 1 then
                    LeftOperand := CopyStr(Expression, 1, i - 1)
                else
                    LeftOperand := '';
                if i < StrLen(Expression) then
                    RightOperand := CopyStr(Expression, i + 1)
                else
                    RightOperand := '';
                Operator := Expression[i];
                LeftResult :=
                  EvaluateExpression(
                    IsVATStmtLineExpression, LeftOperand, VATStatementLine, CalcAddCurr);
                RightResult :=
                  EvaluateExpression(
                    IsVATStmtLineExpression, RightOperand, VATStatementLine, CalcAddCurr);
                case Operator of
                    '^':
                        Result := Power(LeftResult, RightResult);
                    '*':
                        Result := LeftResult * RightResult;
                    '/':
                        if RightResult = 0 then begin
                            Result := 0;
                            DivisionError := true;
                            if DivisionError then
                                Error(DivideByZeroErr);
                        end else
                            Result := LeftResult / RightResult;
                    '+':
                        Result := LeftResult + RightResult;
                    '-':
                        Result := LeftResult - RightResult;
                end;
            end else
                if (Expression[1] = '(') and (Expression[StrLen(Expression)] = ')') then
                    Result :=
                      EvaluateExpression(
                        IsVATStmtLineExpression, CopyStr(Expression, 2, StrLen(Expression) - 2),
                        VATStatementLine, CalcAddCurr)
                else begin
                    IsFilter :=
                      (StrPos(Expression, '..') +
                       StrPos(Expression, '|') +
                       StrPos(Expression, '<') +
                       StrPos(Expression, '>') +
                       StrPos(Expression, '&') +
                       StrPos(Expression, '=') > 0);
                    if (StrLen(Expression) > 10) and (not IsFilter) then
                        Evaluate(Result, Expression)
                    else
                        if IsVATStmtLineExpression then begin
                            VATStatementLine.SetRange("Statement Template Name", VATStatementLine."Statement Template Name");
                            VATStatementLine.SetRange("Statement Name", VATStatementLine."Statement Name");
                            VATStatementLine.SetFilter("Row No.", Expression);

                            VATStmtLineID := VATStatementLine."Line No.";
                            if VATStatementLine.Find('-') then
                                repeat
                                    if VATStatementLine."Line No." <> VATStmtLineID then begin
                                        CalcLineTotal(VATStatementLine, LineTotalAmount, 0);
                                        Result := Result + LineTotalAmount;
                                    end
                                until VATStatementLine.Next() = 0
                            else
                                if IsFilter or (not Evaluate(Result, Expression)) then
                                    Error(InvalidValueErr);
                        end
                end;
        end;
        CallLevel := CallLevel - 1;
        exit(Result);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcLineTotalOnBeforeCalcTotalAmountVATEntryTotaling(VATStatementLine: Record "VAT Statement Line"; var VATEntry: Record "VAT Entry"; var Amount: Decimal; UseAmtsInAddCurr: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcLineTotalVATStatementLineTypeCase(VATStatementLine: Record "VAT Statement Line"; var Amount: Decimal; var IsHandled: Boolean)
    begin
    end;
}
#endif
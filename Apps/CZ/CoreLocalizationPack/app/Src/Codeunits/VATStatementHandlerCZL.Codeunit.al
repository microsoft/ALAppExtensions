// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;

codeunit 31140 "VAT Statement Handler CZL"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        GlobalGLAccount: Record "G/L Account";
        VATStatement: Report "VAT Statement";
        SettlementNoFilter: Text[50];
        StartDate: Date;
        EndDate: Date;
        PeriodSelection: Enum "VAT Statement Report Period Selection";
        CircularRefErr: Label 'Formula cannot be calculated due to circular references.';
        DivideByZeroErr: Label 'Dividing by zero is not possible.';
        InvalidValueErr: Label 'You have entered an invalid value or a nonexistent row number.';

    [EventSubscriber(ObjectType::Report, Report::"VAT Statement", 'OnAfterGetAmtRoundingDirection', '', false, false)]
    local procedure GetRoundingDirectionOnAfterGetAmtRoundingDirection(Direction: Text[1])
    begin
        Direction := VATStatement.GetAmtRoundingDirectionCZL();
    end;

    [EventSubscriber(ObjectType::Report, Report::"VAT Statement", 'OnCalcLineTotalWithBaseOnCaseElse', '', false, false)]
    local procedure CalcFormulaOnCalcLineTotalWithBaseOnCaseElse(var VATStmtLine2: Record "VAT Statement Line"; var Amount: Decimal; var TotalAmount: Decimal; PrintInIntegers: Boolean)
    begin
        if VATStmtLine2.Type <> VATStmtLine2.Type::"Formula CZL" then
            exit;
        Amount := EvaluateExpression(VATStmtLine2."Row Totaling", VATStmtLine2);
        if VATStmtLine2."Calculate with" = 1 then
            Amount := -Amount;
        if PrintInIntegers and VATStmtLine2.Print then
            Amount := Round(Amount, 1, VATStatement.GetAmtRoundingDirectionCZL());
        TotalAmount := TotalAmount + Amount;
    end;

    [EventSubscriber(ObjectType::Report, Report::"VAT Statement", 'OnCalcLineTotalOnBeforeCalcTotalAmountAccountTotaling', '', false, false)]
    local procedure CalcLineTotalOnCalcLineTotalOnBeforeCalcTotalAmountAccountTotaling(VATStmtLine: Record "VAT Statement Line"; var Amount: Decimal; UseAmtsInAddCurr: Boolean)
    begin
        if VATStmtLine."G/L Amount Type CZL" = VATStmtLine."G/L Amount Type CZL"::"Net Change" then
            exit;

        Amount := 0;
        if GlobalGLAccount.FindSet() and (VATStmtLine."Account Totaling" <> '') then
            repeat
                case VATStmtLine."G/L Amount Type CZL" of
                    VATStmtLine."G/L Amount Type CZL"::Debit:
                        begin
                            GlobalGLAccount.CalcFields("Debit Amount", "Add.-Currency Debit Amount");
                            Amount := ConditionalAdd(Amount, GlobalGLAccount."Debit Amount", GlobalGLAccount."Add.-Currency Debit Amount", UseAmtsInAddCurr);
                        end;
                    VATStmtLine."G/L Amount Type CZL"::Credit:
                        begin
                            GlobalGLAccount.CalcFields("Credit Amount", "Add.-Currency Credit Amount");
                            Amount := ConditionalAdd(Amount, GlobalGLAccount."Credit Amount", GlobalGLAccount."Add.-Currency Credit Amount", UseAmtsInAddCurr);
                        end;
                end;
            until GlobalGLAccount.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Report, Report::"VAT Statement", 'OnCalcLineTotalWithBaseOnAfterGLAccSetFilters', '', false, false)]
    local procedure SetDateFilterOnCalcLineTotalWithBaseOnAfterGLAccSetFilters(var GLAccount: Record "G/L Account"; VATStatementLine2: Record "VAT Statement Line")
    begin
        GlobalGLAccount.Reset();
        GlobalGLAccount.CopyFilters(GLAccount);
    end;

    [EventSubscriber(ObjectType::Report, Report::"VAT Statement", 'OnCalcLineTotalOnVATEntryTotalingOnAfterVATEntrySetFilters', '', false, false)]
    local procedure OnCalcLineTotalOnVATEntryTotalingOnAfterVATEntrySetFilters(VATStmtLine: Record "VAT Statement Line"; var VATEntry: Record "VAT Entry"; Selection: Enum "VAT Statement Report Selection")
    var
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
    begin
        VATEntry.SetVATStatementLineFiltersCZL(VATStmtLine);
        VATEntry.SetPeriodFilterCZL(
            PeriodSelection, StartDate, EndDate, VATReportingDateMgt.IsVATDateEnabled());
        VATEntry.SetClosedFilterCZL(Selection);
        if SettlementNoFilter <> '' then
            VATEntry.SetFilter("VAT Settlement No. CZL", SettlementNoFilter);
    end;

    local procedure ConditionalAdd(Amount: Decimal; AmountToAdd: Decimal; AddCurrAmountToAdd: Decimal; UseAmtsInAddCurr: Boolean): Decimal
    begin
        if UseAmtsInAddCurr then
            exit(Amount + AddCurrAmountToAdd);
        exit(Amount + AmountToAdd);
    end;

    local procedure EvaluateExpression(Expression: Text; VATStatementLine: Record "VAT Statement Line"): Decimal
    var
        CallLevel: Integer;
    begin
        CallLevel := 0;
        exit(EvaluateExpression(Expression, VATStatementLine, CallLevel));
    end;

    local procedure EvaluateExpression(Expression: Text; VATStatementLine: Record "VAT Statement Line"; CallLevel: Integer): Decimal
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
                  EvaluateExpression(LeftOperand, VATStatementLine, CallLevel);
                RightResult :=
                  EvaluateExpression(RightOperand, VATStatementLine, CallLevel);
                case Operator of
                    '^':
                        Result := Power(LeftResult, RightResult);
                    '*':
                        Result := LeftResult * RightResult;
                    '/':
                        if RightResult = 0 then begin
                            Result := 0;
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
                        CopyStr(Expression, 2, StrLen(Expression) - 2),
                        VATStatementLine, CallLevel)
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
                    else begin
                        VATStatementLine.SetRange("Statement Template Name", VATStatementLine."Statement Template Name");
                        VATStatementLine.SetRange("Statement Name", VATStatementLine."Statement Name");
                        VATStatementLine.SetFilter("Row No.", Expression);

                        VATStmtLineID := VATStatementLine."Line No.";
                        if VATStatementLine.Find('-') then
                            repeat
                                if VATStatementLine."Line No." <> VATStmtLineID then begin
                                    VATStatement.CalcLineTotal(VATStatementLine, LineTotalAmount, 0);
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

    procedure Initialize(var NewVATStatementName: Record "VAT Statement Name"; var NewVATStatementLine: Record "VAT Statement Line"; NewSelection: Enum "VAT Statement Report Selection"; NewPeriodSelection: Enum "VAT Statement Report Period Selection"; NewPrintInIntegers: Boolean; NewUseAmtsInAddCurr: Boolean; NewStartDate: Date; NewEndDate: Date; NewSettlementNoFilter: Text[50]; NewRoundingDirection: Option)
    begin
        VATStatement.InitializeRequestCZL(NewVATStatementName, NewVATStatementLine, NewSelection, NewPeriodSelection, NewPrintInIntegers, NewUseAmtsInAddCurr, NewSettlementNoFilter, NewRoundingDirection, false);
        StartDate := NewStartDate;
        EndDate := NewEndDate;
        PeriodSelection := NewPeriodSelection;
        SettlementNoFilter := NewSettlementNoFilter;
    end;
}
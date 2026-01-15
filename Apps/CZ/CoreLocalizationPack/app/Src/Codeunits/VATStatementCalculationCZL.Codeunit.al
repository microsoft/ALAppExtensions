// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.VAT.Ledger;

codeunit 11723 "VAT Statement Calculation CZL"
{
    Permissions = tabledata "VAT Entry" = r;
    Access = Internal;

    var
        TempVATStatementLineBuffer: Record "VAT Statement Line" temporary;
        GlobalVATStatement: Report "VAT Statement";
        BufferingMode: Boolean;
        CircularRefErr: Label 'Formula cannot be calculated due to circular references.';
        DivideByZeroErr: Label 'Dividing by zero is not possible.';
        InvalidValueErr: Label 'You have entered an invalid value or a nonexistent row number.';
        DrillDownErr: Label 'DrillDown is not possible when %1 is %2.', Comment = '%1=fieldcaption, %2=VAT statement line type';

    procedure CalcLineTotal(VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL"; var TotalAmount: Decimal): Boolean
    var
        DummyTotalBase: Decimal;
    begin
        exit(CalcLineTotal(VATStatementLine, VATStmtCalcParametersCZL, TotalAmount, DummyTotalBase));
    end;

    procedure CalcLineTotal(VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL"; var TotalAmount: Decimal; var TotalBase: Decimal): Boolean
    var
        DummyVATStatementName: Record "VAT Statement Name";
        DummyVATStatementLine: Record "VAT Statement Line";
    begin
        DummyVATStatementLine.SetRange("Date Filter", VATStmtCalcParametersCZL."Start Date", VATStmtCalcParametersCZL."End Date");
        GlobalVATStatement.InitializeRequestCZL(DummyVATStatementName, DummyVATStatementLine, VATStmtCalcParametersCZL);
        exit(GlobalVATStatement.CalcLineTotalWithBase(VATStatementLine, TotalAmount, TotalBase, 0));
    end;

    procedure CalcVATEntryTotalForVATReport(VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL"; var TotalAmount: Decimal; var TotalBase: Decimal)
    var
        VATReportEntryLink: Query "VAT Report Entry Link CZL";
    begin
        TotalAmount := 0;
        TotalBase := 0;

        VATReportEntryLink.SetVATStmtCalcFilters(VATStatementLine, VATStmtCalcParametersCZL);
        VATReportEntryLink.Open();
        while VATReportEntryLink.Read() do begin
            TotalAmount += VATReportEntryLink.GetAmount(VATStatementLine."Amount Type", VATStmtCalcParametersCZL."Use Amounts in Add. Currency");
            TotalBase += VATReportEntryLink.GetBase(VATStatementLine."Amount Type", VATStmtCalcParametersCZL."Use Amounts in Add. Currency");
        end;
        ProcessCalculateAmount(VATStatementLine, VATStmtCalcParametersCZL, TotalAmount);
        ProcessCalculateAmount(VATStatementLine, VATStmtCalcParametersCZL, TotalBase);
    end;

    procedure DrillDownLineTotal(VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL")
    begin
        case VATStatementLine.Type of
            VATStatementLine.Type::"Account Totaling":
                RunGeneralLedgerEntries(VATStatementLine, VATStmtCalcParametersCZL);
            VATStatementLine.Type::"VAT Entry Totaling":
                RunVATEntries(VATStatementLine, VATStmtCalcParametersCZL);
            VATStatementLine.Type::"Formula CZL":
                RunVATStmtFormDrillDown(VATStatementLine, VATStmtCalcParametersCZL);
            else
                HandleAnotherLineType(VATStatementLine, VATStmtCalcParametersCZL);
        end;
    end;

    procedure GetLinesFromFormula(VATStatementLine: Record "VAT Statement Line"; var OutTempVATStatementLine: Record "VAT Statement Line" temporary)
    var
        DummyVATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL";
        DummyAmount, DummyBase : Decimal;
    begin
        DeleteBuffer();
        BufferingMode := true;
        EvaluateExpression(VATStatementLine."Row Totaling", VATStatementLine, DummyVATStmtCalcParametersCZL, 0, DummyAmount, DummyBase);
        BufferingMode := false;
        OutTempVATStatementLine.Copy(TempVATStatementLineBuffer, true);
    end;

    procedure GetVATEntries(VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL"; var OutTempVATEntry: Record "VAT Entry" temporary)
    var
        TempVATStatementLine: Record "VAT Statement Line" temporary;
        VATEntry: Record "VAT Entry";
    begin
        if not OutTempVATEntry.IsTemporary then
            exit;
        GetLinesOfVATEntryTotalingType(VATStatementLine, TempVATStatementLine);
        if TempVATStatementLine.FindSet() then
            repeat
                VATEntry.Reset();
                if not VATEntry.SetCurrentKey(
                     Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group",
                     "Gen. Bus. Posting Group", "Gen. Prod. Posting Group",
                     "EU 3-Party Trade")
                then
                    VATEntry.SetCurrentKey(
                      Type, Closed, "Tax Jurisdiction Code", "Use Tax", "Posting Date");
                VATEntry.SetVATStmtCalcFilters(TempVATStatementLine, VATStmtCalcParametersCZL);
                if VATEntry.FindSet() then
                    repeat
                        if not OutTempVATEntry.Get(VATEntry."Entry No.") then begin
                            OutTempVATEntry.Init();
                            OutTempVATEntry := VATEntry;
                            OutTempVATEntry.Insert();
                        end;
                    until VATEntry.Next() = 0;
            until TempVATStatementLine.Next() = 0;
    end;

    procedure CalcFormulaLineTotal(VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL"; var TotalAmount: Decimal; var TotalBase: Decimal)
    begin
        EvaluateExpression(VATStatementLine."Row Totaling", VATStatementLine, VATStmtCalcParametersCZL, 0, TotalAmount, TotalBase);
        ProcessCalculateAmount(VATStatementLine, VATStmtCalcParametersCZL, TotalAmount);
        ProcessCalculateAmount(VATStatementLine, VATStmtCalcParametersCZL, TotalBase);
    end;

    local procedure GetLinesOfVATEntryTotalingType(VATStatementLine: Record "VAT Statement Line"; var OutTempVATStatementLine: Record "VAT Statement Line" temporary)
    var
        TempVATStatementLine: Record "VAT Statement Line" temporary;
        LocalVATStatementLine: Record "VAT Statement Line";
    begin
        case VATStatementLine.Type of
            VATStatementLine.Type::"Account Totaling":
                exit;
            VATStatementLine.Type::"VAT Entry Totaling":
                if not OutTempVATStatementLine.Get(VATStatementLine."Statement Template Name", VATStatementLine."Statement Name", VATStatementLine."Line No.") then begin
                    OutTempVATStatementLine.Init();
                    OutTempVATStatementLine := VATStatementLine;
                    OutTempVATStatementLine.Insert();
                end;
            VATStatementLine.Type::"Formula CZL":
                begin
                    GetLinesFromFormula(VATStatementLine, TempVATStatementLine);
                    if TempVATStatementLine.FindSet() then
                        repeat
                            GetLinesOfVATEntryTotalingType(TempVATStatementLine, OutTempVATStatementLine);
                        until TempVATStatementLine.Next() = 0;
                end;
            VATStatementLine.Type::"Row Totaling":
                begin
                    LocalVATStatementLine.SetRange("Statement Template Name", VATStatementLine."Statement Template Name");
                    LocalVATStatementLine.SetRange("Statement Name", VATStatementLine."Statement Name");
                    LocalVATStatementLine.SetFilter("Row No.", VATStatementLine."Row Totaling");
                    if LocalVATStatementLine.FindSet() then
                        repeat
                            GetLinesOfVATEntryTotalingType(LocalVATStatementLine, OutTempVATStatementLine);
                        until LocalVATStatementLine.Next() = 0;
                end;
            else
                exit;
        end;
    end;

    local procedure RunGeneralLedgerEntries(VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL")
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetFilter("G/L Account No.", VATStatementLine."Account Totaling");
        GLEntry.SetRange("VAT Bus. Posting Group");
        GLEntry.SetRange("VAT Prod. Posting Group");
        if VATStatementLine."VAT Bus. Posting Group" <> '' then
            GLEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
        if VATStatementLine."VAT Prod. Posting Group" <> '' then
            GLEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
        GLEntry.SetRange("VAT Reporting Date", VATStmtCalcParametersCZL."Start Date", VATStmtCalcParametersCZL."End Date");
        OnRunGeneralLedgerEntriesOnAfterSetGLEntryFilters(GLEntry, VATStatementLine, VATStmtCalcParametersCZL);
        Page.Run(Page::"General Ledger Entries", GLEntry);
    end;

    local procedure RunVATEntries(VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL")
    var
        VATEntry: Record "VAT Entry";
        TempVATEntry: Record "VAT Entry" temporary;
#if not CLEAN28
        VATStatementPreviewLineCZL: Page "VAT Statement Preview Line CZL";
#endif
        VATReportEntryLink: Query "VAT Report Entry Link CZL";
    begin
        if VATStmtCalcParametersCZL."VAT Report No. Filter" = '' then begin
            VATEntry.Reset();
            if not VATEntry.SetCurrentKey(
                 Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group",
                 "Gen. Bus. Posting Group", "Gen. Prod. Posting Group",
                 "EU 3-Party Trade")
            then
                VATEntry.SetCurrentKey(
                  Type, Closed, "Tax Jurisdiction Code", "Use Tax", "Posting Date");
            VATEntry.SetVATStmtCalcFilters(VATStatementLine, VATStmtCalcParametersCZL);
            OnRunVATEntriesOnAfterSetVATEntryFilters(VATEntry, VATStatementLine, VATStmtCalcParametersCZL);
#if not CLEAN28
            VATStatementPreviewLineCZL.RaiseOnBeforeOpenPageVATEntryTotaling(VATEntry, VATStatementLine);
#endif
            Page.Run(Page::"VAT Entries", VATEntry);
            exit;
        end;

        VATReportEntryLink.SetVATStmtCalcFilters(VATStatementLine, VATStmtCalcParametersCZL);
        VATReportEntryLink.GetVATEntries(TempVATEntry);
        Page.Run(Page::"VAT Entries", TempVATEntry);
    end;

    local procedure RunVATStmtFormDrillDown(VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL")
    var
        VATStmtFormDrillDown: Page "VAT Stmt. Form. Drill-Down CZL";
    begin
        VATStmtFormDrillDown.Initialize(VATStatementLine, VATStmtCalcParametersCZL);
        VATStmtFormDrillDown.Run();
    end;

    local procedure HandleAnotherLineType(VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL")
    var
#if not CLEAN28
        VATStatementPreviewLineCZL: Page "VAT Statement Preview Line CZL";
#endif
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnHandleAnotherLineType(VATStatementLine, VATStmtCalcParametersCZL, IsHandled);
#if not CLEAN28
        VATStatementPreviewLineCZL.RaiseOnColumnValueDrillDownVATStatementLineTypeCase(VATStatementLine, IsHandled);
#endif
        if not IsHandled then
            Error(DrillDownErr, VATStatementLine.FieldCaption(Type), VATStatementLine.Type);
    end;

    local procedure EvaluateExpression(Expression: Text; VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL"; CallLevel: Integer; var Amount: Decimal; var Base: Decimal)
    var
        Parantheses, i, OperatorNo, VATStmtLineID, QuotationMarks : Integer;
        Operator: Char;
        LeftOperand, RightOperand : Text;
        LineTotalAmount, LineTotalBase : Decimal;
        LeftAmount, RightAmount : Decimal;
        LeftBase, RightBase : Decimal;
        ResultAmount, ResultBase : Decimal;
        IsExpression: Boolean;
        IsFilter: Boolean;
        Operators: Text[8];
    begin
        ResultAmount := 0;
        ResultBase := 0;

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
                    if Expression[i] = '"' then
                        QuotationMarks := QuotationMarks = 0 ? QuotationMarks + 1 : QuotationMarks - 1;
                    if (Parantheses = 0) and (QuotationMarks = 0) and (Expression[i] = Operators[OperatorNo]) then
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
                EvaluateExpression(LeftOperand, VATStatementLine, VATStmtCalcParametersCZL, CallLevel, LeftAmount, LeftBase);
                EvaluateExpression(RightOperand, VATStatementLine, VATStmtCalcParametersCZL, CallLevel, RightAmount, RightBase);
                case Operator of
                    '^':
                        begin
                            ResultAmount := Power(LeftAmount, RightAmount);
                            ResultBase := Power(LeftBase, RightBase);
                        end;
                    '*':
                        begin
                            ResultAmount := LeftAmount * RightAmount;
                            ResultBase := LeftBase * RightBase;
                        end;
                    '/':
                        begin
                            if RightAmount = 0 then begin
                                ResultAmount := 0;
                                if LeftAmount <> 0 then
                                    Error(DivideByZeroErr);
                            end else
                                ResultAmount := LeftAmount / RightAmount;
                            if RightBase = 0 then begin
                                ResultBase := 0;
                                if LeftBase <> 0 then
                                    Error(DivideByZeroErr);
                            end else
                                ResultBase := LeftBase / RightBase;
                        end;
                    '+':
                        begin
                            ResultAmount := LeftAmount + RightAmount;
                            ResultBase := LeftBase + RightBase;
                        end;
                    '-':
                        begin
                            ResultAmount := LeftAmount - RightAmount;
                            ResultBase := LeftBase - RightBase;
                        end;
                end;
            end else
                if (Expression[1] = '(') and (Expression[StrLen(Expression)] = ')') then
                    EvaluateExpression(
                        CopyStr(Expression, 2, StrLen(Expression) - 2),
                        VATStatementLine, VATStmtCalcParametersCZL, CallLevel, ResultAmount, ResultBase)
                else begin
                    IsFilter :=
                      (StrPos(Expression, '..') +
                       StrPos(Expression, '|') +
                       StrPos(Expression, '<') +
                       StrPos(Expression, '>') +
                       StrPos(Expression, '&') +
                       StrPos(Expression, '=') > 0);
                    if (StrLen(Expression) > 10) and (not IsFilter) then
                        Evaluate(ResultAmount, Expression)
                    else begin
                        VATStatementLine.SetRange("Statement Template Name", VATStatementLine."Statement Template Name");
                        VATStatementLine.SetRange("Statement Name", VATStatementLine."Statement Name");
                        VATStatementLine.SetFilter("Row No.", DelChr(Expression, '<>', '"'));

                        VATStmtLineID := VATStatementLine."Line No.";
                        if VATStatementLine.Find('-') then
                            repeat
                                if VATStatementLine."Line No." <> VATStmtLineID then
                                    if not BufferingMode then begin
                                        CalcLineTotal(VATStatementLine, VATStmtCalcParametersCZL, LineTotalAmount, LineTotalBase);
                                        ResultAmount += LineTotalAmount;
                                        ResultBase += LineTotalBase;
                                    end else
                                        AddLineToBuffer(VATStatementLine);
                            until VATStatementLine.Next() = 0
                        else
                            if IsFilter or (not Evaluate(ResultAmount, Expression)) then
                                Error(InvalidValueErr);
                    end
                end;
        end;
        CallLevel := CallLevel - 1;
        Amount := ResultAmount;
        Base := ResultBase;
    end;

    local procedure AddLineToBuffer(VATStatementLine: Record "VAT Statement Line")
    begin
        TempVATStatementLineBuffer.Init();
        TempVATStatementLineBuffer := VATStatementLine;
        TempVATStatementLineBuffer.Insert();
    end;

    local procedure DeleteBuffer()
    begin
        TempVATStatementLineBuffer.Reset();
        TempVATStatementLineBuffer.DeleteAll();
    end;

    local procedure ProcessCalculateAmount(VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL"; var Amount: Decimal)
    begin
        Amount := Amount * VATStatementLine.GetCalculateSign();
        if VATStmtCalcParametersCZL."Print in Integers" and VATStatementLine.Print then
            Amount := Round(Amount, 1, VATStmtCalcParametersCZL.GetRoundingDirection());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunGeneralLedgerEntriesOnAfterSetGLEntryFilters(var GLEntry: Record "G/L Entry"; VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunVATEntriesOnAfterSetVATEntryFilters(var VATEntry: Record "VAT Entry"; VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleAnotherLineType(VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL"; var IsHandled: Boolean)
    begin
    end;
}
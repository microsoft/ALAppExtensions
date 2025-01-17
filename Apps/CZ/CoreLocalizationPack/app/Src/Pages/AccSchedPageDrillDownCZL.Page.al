// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using Microsoft.Finance.Analysis;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;

page 31204 "Acc. Sched.Page.Drill-Down CZL"
{
    Caption = 'Acc. Sched. Formula Drill-Down';
    PageType = Worksheet;
    SourceTable = "Acc. Sched. Expr. Buffer CZL";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field(Formula; Formula)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Formula';
                Editable = false;
                ToolTip = 'Specifies the formula of account schedule.';
            }
            repeater(Lines)
            {
                Editable = false;
                ShowCaption = false;
                field("Acc. Sched. Row No."; Rec."Acc. Sched. Row No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the account schedule row.';
                }
                field("Totaling Type"; Rec."Totaling Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the totaling type for the account schedule line. The type determines which accounts within the totaling interval you specify in the Totaling field will be totaled.';
                }
                field(Expression; Rec.Expression)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies expression of account schedule.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount';

                    trigger OnDrillDown()
                    var
                        GLAccount: Record "G/L Account";
                        GLAccountAnalysisView: Record "G/L Account (Analysis View)";
                        AccScheduleLine: Record "Acc. Schedule Line";
                        ChartOfAccsAnalysisView: Page "Chart of Accs. (Analysis View)";
                        AccSchedPageDrillDownCZL: Page "Acc. Sched.Page.Drill-Down CZL";
                    begin
                        AccScheduleName.Get(SourceAccScheduleLine."Schedule Name");
                        AccScheduleLine.Copy(SourceAccScheduleLine);
                        AccScheduleLine.Totaling := Rec.Expression;
                        AccScheduleLine."Totaling Type" := Rec."Totaling Type";
                        StartDate := AccScheduleLine.GetRangeMin("Date Filter");
                        EndDate := AccScheduleLine.GetRangeMax("Date Filter");

                        AccSchedManagement.SetStartDateEndDate(StartDate, EndDate);

                        if SourceColumnLayout."Column Type" = SourceColumnLayout."Column Type"::Formula then
                            Message(ColumnFormulaMsg, SourceColumnLayout.Formula)
                        else
                            case Rec."Totaling Type" of
                                Rec."Totaling Type"::"Constant CZL":
                                    Message(LineConstantMsg, Rec.Expression);
                                Rec."Totaling Type"::Formula:
                                    begin
                                        AccSchedPageDrillDownCZL.InitParameters(AccScheduleLine, SourceColumnLayout);
                                        AccSchedPageDrillDownCZL.Run();
                                    end;
                                Rec."Totaling Type"::"Custom CZL":
                                    AccSchedExtensionMgt.DrillDownAmount(
                                      AccScheduleLine,
                                      SourceColumnLayout,
                                      CopyStr(Rec.Expression, 1, 20),
                                      StartDate,
                                      EndDate);
                                Rec."Totaling Type"::"Set Base For Percent":
                                    Message(RowFormulaMsg, Rec.Expression);
                                else
                                    if Rec.Expression <> '' then begin
                                        AccScheduleLine.CopyFilter("Business Unit Filter", GLAccount."Business Unit Filter");
                                        AccScheduleLine.CopyFilter("G/L Budget Filter", GLAccount."Budget Filter");
                                        AccSchedManagement.SetGLAccRowFilters(GLAccount, AccScheduleLine);
                                        AccSchedManagement.SetGLAccColumnFilters(GLAccount, AccScheduleLine, SourceColumnLayout);
                                        if AccScheduleName."Analysis View Name" = '' then begin
                                            AccScheduleLine.CopyFilter("Dimension 1 Filter", GLAccount."Global Dimension 1 Filter");
                                            AccScheduleLine.CopyFilter("Dimension 2 Filter", GLAccount."Global Dimension 2 Filter");
                                            AccScheduleLine.CopyFilter("Business Unit Filter", GLAccount."Business Unit Filter");
                                            GLAccount.FilterGroup(2);
                                            GLAccount.SetFilter("Global Dimension 1 Filter",
                                              AccSchedManagement.GetDimTotalingFilter(1, Rec."Dimension 1 Totaling"));
                                            GLAccount.SetFilter("Global Dimension 2 Filter",
                                              AccSchedManagement.GetDimTotalingFilter(2, Rec."Dimension 2 Totaling"));
                                            GLAccount.FilterGroup(6);
                                            GLAccount.SetFilter(
                                              "Global Dimension 1 Filter",
                                              AccSchedManagement.GetDimTotalingFilter(1, SourceColumnLayout."Dimension 1 Totaling"));
                                            GLAccount.SetFilter(
                                              "Global Dimension 2 Filter",
                                              AccSchedManagement.GetDimTotalingFilter(2, SourceColumnLayout."Dimension 2 Totaling"));
                                            GLAccount.SetFilter("Business Unit Filter", SourceColumnLayout."Business Unit Totaling");
                                            GLAccount.FilterGroup(0);
                                            Page.Run(Page::"Chart of Accounts (G/L)", GLAccount)
                                        end else begin
                                            GLAccount.CopyFilter("Date Filter", GLAccountAnalysisView."Date Filter");
                                            GLAccount.CopyFilter("Budget Filter", GLAccountAnalysisView."Budget Filter");
                                            GLAccount.CopyFilter("Business Unit Filter", GLAccountAnalysisView."Business Unit Filter");
                                            GLAccountAnalysisView.SetRange("Analysis View Filter", AccScheduleName."Analysis View Name");
                                            AccScheduleLine.CopyFilter("Dimension 1 Filter", GLAccountAnalysisView."Dimension 1 Filter");
                                            AccScheduleLine.CopyFilter("Dimension 2 Filter", GLAccountAnalysisView."Dimension 2 Filter");
                                            AccScheduleLine.CopyFilter("Dimension 3 Filter", GLAccountAnalysisView."Dimension 3 Filter");
                                            AccScheduleLine.CopyFilter("Dimension 4 Filter", GLAccountAnalysisView."Dimension 4 Filter");
                                            GLAccountAnalysisView.FilterGroup(2);
                                            GLAccountAnalysisView.SetFilter(
                                              "Dimension 1 Filter",
                                              AccSchedManagement.GetDimTotalingFilter(1, Rec."Dimension 1 Totaling"));
                                            GLAccountAnalysisView.SetFilter(
                                              "Dimension 2 Filter",
                                              AccSchedManagement.GetDimTotalingFilter(2, Rec."Dimension 2 Totaling"));
                                            GLAccountAnalysisView.SetFilter(
                                              "Dimension 3 Filter",
                                              AccSchedManagement.GetDimTotalingFilter(3, Rec."Dimension 3 Totaling"));
                                            GLAccountAnalysisView.SetFilter(
                                              "Dimension 4 Filter",
                                              AccSchedManagement.GetDimTotalingFilter(4, Rec."Dimension 4 Totaling"));
                                            GLAccountAnalysisView.FilterGroup(6);
                                            GLAccountAnalysisView.SetFilter(
                                              "Dimension 1 Filter",
                                              AccSchedManagement.GetDimTotalingFilter(1, SourceColumnLayout."Dimension 1 Totaling"));
                                            GLAccountAnalysisView.SetFilter(
                                              "Dimension 2 Filter",
                                              AccSchedManagement.GetDimTotalingFilter(2, SourceColumnLayout."Dimension 2 Totaling"));
                                            GLAccountAnalysisView.SetFilter(
                                              "Dimension 3 Filter",
                                              AccSchedManagement.GetDimTotalingFilter(3, SourceColumnLayout."Dimension 3 Totaling"));
                                            GLAccountAnalysisView.SetFilter(
                                              "Dimension 4 Filter",
                                              AccSchedManagement.GetDimTotalingFilter(4, SourceColumnLayout."Dimension 4 Totaling"));
                                            GLAccountAnalysisView.SetFilter("Business Unit Filter", SourceColumnLayout."Business Unit Totaling");
                                            GLAccountAnalysisView.FilterGroup(0);
                                            Clear(ChartOfAccsAnalysisView);
                                            ChartOfAccsAnalysisView.InsertTempGLAccAnalysisViews(GLAccount);
                                            ChartOfAccsAnalysisView.SetTableView(GLAccountAnalysisView);
                                            ChartOfAccsAnalysisView.Run();
                                        end;
                                    end;
                            end;
                    end;
                }
            }
        }
    }

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        AccScheduleName: Record "Acc. Schedule Name";
        SourceAccScheduleLine: Record "Acc. Schedule Line";
        SourceColumnLayout: Record "Column Layout";
        AccSchedManagement: Codeunit AccSchedManagement;
        AccSchedExtensionMgt: Codeunit "Acc. Sched. Extension Mgt. CZL";
        Formula: Text[250];
        StartDate: Date;
        EndDate: Date;
        EntryNo: Integer;
        ColumnFormulaMsg: Label 'Column formula: %1.', Comment = '%1 = Column Layout Formula';
        RowFormulaMsg: Label 'Row formula: %1.', Comment = '%1 = Expression';
        LineConstantMsg: Label 'Row constant: %1.', Comment = '%1 = Expression';

    procedure InitParameters(var AccScheduleLine: Record "Acc. Schedule Line"; ColumnLayout: Record "Column Layout")
    begin
        SourceAccScheduleLine.Copy(AccScheduleLine);
        AccScheduleLine.TestField("Totaling Type", AccScheduleLine."Totaling Type"::Formula);
        SourceColumnLayout := ColumnLayout;
        Formula := AccScheduleLine.Totaling;

        EvaluateExpression(true, AccScheduleLine.Totaling, SourceAccScheduleLine, SourceColumnLayout);
    end;

    local procedure EvaluateExpression(IsAccSchedLineExpression: Boolean; Expression: Text; var AccScheduleLine: Record "Acc. Schedule Line"; ColumnLayout: Record "Column Layout"): Decimal
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
        AccSchedLineID: Integer;
    begin
        GeneralLedgerSetup.Get();

        Expression := DelChr(Expression, '<>', '');
        if StrLen(Expression) > 0 then begin
            Parantheses := 0;
            IsExpression := false;
            Operators := '+-*/^%';
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
                    IsAccSchedLineExpression, LeftOperand, AccScheduleLine, ColumnLayout);
                RightResult :=
                  EvaluateExpression(
                    IsAccSchedLineExpression, RightOperand, AccScheduleLine, ColumnLayout);
                case Operator of
                    '^':
                        Result := Power(LeftResult, RightResult);
                    '%':
                        if RightResult = 0 then
                            Result := 0
                        else
                            Result := 100 * LeftResult / RightResult;
                    '*':
                        Result := LeftResult * RightResult;
                    '/':
                        if RightResult = 0 then
                            Result := 0
                        else
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
                        IsAccSchedLineExpression, CopyStr(Expression, 2, StrLen(Expression) - 2),
                        AccScheduleLine, ColumnLayout)
                else begin
                    IsFilter :=
                      (StrPos(Expression, '..') +
                       StrPos(Expression, '|') +
                       StrPos(Expression, '<') +
                       StrPos(Expression, '>') +
                       StrPos(Expression, '&') +
                       StrPos(Expression, '=') > 0);
                    if (StrLen(Expression) > 20) and (not IsFilter) then
                        Evaluate(Result, Expression)
                    else
                        if IsAccSchedLineExpression then begin
                            AccScheduleLine.SetRange("Schedule Name", AccScheduleLine."Schedule Name");
                            AccScheduleLine.SetFilter("Row No.", Expression);
                            AccSchedLineID := AccScheduleLine."Line No.";
                            if AccScheduleLine.FindSet() then
                                repeat
                                    if AccScheduleLine."Line No." <> AccSchedLineID then
                                        Result := Result + CalcCellValue(AccScheduleLine, ColumnLayout);
                                until AccScheduleLine.Next() = 0
                            else begin
                                AccScheduleLine.FilterGroup(2);
                                AccScheduleLine.SetRange("Schedule Name");
                                AccScheduleLine.FilterGroup(0);
                                AccScheduleLine.SetRange("Schedule Name", GeneralLedgerSetup."Shared Account Schedule CZL");
                                if AccScheduleLine.FindSet() then
                                    repeat
                                        Result := Result + CalcCellValue(AccScheduleLine, ColumnLayout);
                                    until AccScheduleLine.Next() = 0;
                            end
                        end else begin
                            ColumnLayout.SetRange("Column Layout Name", ColumnLayout."Column Layout Name");
                            ColumnLayout.SetFilter("Column No.", Expression);
                            AccSchedLineID := ColumnLayout."Line No.";
                            if ColumnLayout.FindSet() then
                                repeat
                                    if ColumnLayout."Line No." <> AccSchedLineID then
                                        Result := Result + CalcCellValue(AccScheduleLine, ColumnLayout);
                                until ColumnLayout.Next() = 0
                        end;
                end;
        end;
        exit(Result);
    end;

    local procedure CalcCellValue(var AccScheduleLine: Record "Acc. Schedule Line"; ColumnLayout: Record "Column Layout"): Decimal
    var
        Result: Decimal;
    begin
        Result := AccSchedManagement.CalcCell(AccScheduleLine, ColumnLayout, false);
        AddFormulasExpression(AccScheduleLine, Result);
        exit(Result);
    end;

    procedure AddFormulasExpression(AccScheduleLine: Record "Acc. Schedule Line"; Result: Decimal)
    begin
        EntryNo += 1;

        Rec.Init();
        Rec."Entry No." := EntryNo;
        Rec.Expression := AccScheduleLine.Totaling;
        Rec.Amount := Result;
        Rec."Acc. Sched. Row No." := AccScheduleLine."Row No.";
        Rec."Totaling Type" := AccScheduleLine."Totaling Type";
        Rec."Dimension 1 Totaling" := AccScheduleLine."Dimension 1 Totaling";
        Rec."Dimension 2 Totaling" := AccScheduleLine."Dimension 2 Totaling";
        Rec."Dimension 3 Totaling" := AccScheduleLine."Dimension 3 Totaling";
        Rec."Dimension 4 Totaling" := AccScheduleLine."Dimension 4 Totaling";
        Rec.Insert();
    end;
}

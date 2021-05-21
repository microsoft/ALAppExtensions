// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3900 "Retention Period Impl." implements "Retention Period"
{
    Access = Internal;

    var
        MaxDateDateFormulaTxt: Label '<+CY+%1Y>', Locked = true;
        WrongInterfaceImplementationErr: Label 'This implementation of the interface does not support the enum value selected. Contact your Microsoft partner for assistance. The following information can help them address the issue: Value: %1, Interface: Interface Retention Period, Implementation: codeunit 3900 Retention Period Impl.', Comment = '%1 = a value such as 1 Week, 1 Month, 3 Months, or Custom.';
        FutureDateCalcErr: Label 'The date formula (%1) must result in a date that is at least two days before the current date. For example, to calculate a period for the past week, month, or year, use either -1W, -1M, or -1Y.', comment = '%1 = a date formula';

    local procedure RetentionPeriodDateFormula(RetentionPeriod: enum "Retention Period Enum"; Translated: Boolean): Text;
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        PeriodDateFormula: DateFormula;
    begin
        case RetentionPeriod of
            RetentionPeriod::"Never Delete":
                Evaluate(PeriodDateFormula, StrSubstNo(MaxDateDateFormulaTxt, 9999 - Date2DMY(Today(), 3)));
            RetentionPeriod::"1 Week":
                Evaluate(PeriodDateFormula, '<-1W>');
            RetentionPeriod::"28 Days":
                Evaluate(PeriodDateFormula, '<-28D>');
            RetentionPeriod::"1 Month":
                Evaluate(PeriodDateFormula, '<-1M>');
            RetentionPeriod::"3 Months":
                Evaluate(PeriodDateFormula, '<-3M>');
            RetentionPeriod::"6 Months":
                Evaluate(PeriodDateFormula, '<-6M>');
            RetentionPeriod::"1 Year":
                Evaluate(PeriodDateFormula, '<-1Y>');
            RetentionPeriod::"5 Years":
                Evaluate(PeriodDateFormula, '<-5Y>');
            else
                RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(WrongInterfaceImplementationErr, RetentionPeriod));
        end;

        if Translated then
            Exit(Format(PeriodDateFormula, 0, 1))
        else
            Exit(Format(PeriodDateFormula, 0, 2))
    end;

    procedure RetentionPeriodDateFormula(RetentionPeriod: Record "Retention Period"): Text
    begin
        exit(RetentionPeriodDateFormula(RetentionPeriod, false));
    end;

    procedure RetentionPeriodDateFormula(RetentionPeriod: Record "Retention Period"; Translated: Boolean) DateFormulaText: Text
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        DateFormulaText := RetentionPeriodDateFormula(RetentionPeriod."Retention Period", Translated);
        if DateFormulaText = '' then
            RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(WrongInterfaceImplementationErr, RetentionPeriod."Retention Period"));
    end;

    procedure CalculateExpirationDate(RetentionPeriod: Record "Retention Period"): Date
    begin
        Exit(CalcDate(RetentionPeriodDateFormula(RetentionPeriod), Today()))
    end;

    procedure CalculateExpirationDate(RetentionPeriod: Record "Retention Period"; UseDate: Date): Date
    begin
        Exit(CalcDate(RetentionPeriodDateFormula(RetentionPeriod), UseDate))
    end;

    procedure CalculateExpirationDate(RetentionPeriod: Record "Retention Period"; UseDateTime: DateTime): DateTime
    var
        UseTime: Time;
    begin
        if RetentionPeriod."Retention Period" = RetentionPeriod."Retention Period"::"Never Delete" then
            UseTime := 235959.999T
        else
            UseTime := DT2Time(UseDateTime);
        Exit(CreateDateTime(CalcDate(RetentionPeriodDateFormula(RetentionPeriod), DT2Date(UseDateTime)), UseTime))
    end;

    procedure ValidateRetentionPeriodDateFormula(DateFormula: DateFormula)
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        if Format(DateFormula) <> '' then
            if IsFutureDateFormula(DateFormula) then
                RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(FutureDateCalcErr, DateFormula));
    end;

    local procedure IsFutureDateFormula(DateFormula: DateFormula): Boolean
    begin
        Exit(CalcDate(DateFormula, Today()) >= Yesterday());
    end;

    local procedure Yesterday(): Date
    begin
        Exit(CalcDate('<-1D>', Today()))
    end;

    local procedure LogCategory(): Enum "Retention Policy Log Category"
    var
        RetentionPolicyLogCategory: Enum "Retention Policy Log Category";
    begin
        exit(RetentionPolicyLogCategory::"Retention Policy - Period");
    end;
}
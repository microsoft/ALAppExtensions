// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3901 "Retention Period Custom Impl." implements "Retention Period"
{
    Access = Internal;

    var
        WrongInterfaceImplementationErr: Label 'This implementation of the interface does not support the enum value selected. Contact your Microsoft partner for assistance. The following information can help them address the issue: Value: %1, Interface: Interface Retention Period, Implementation: codeunit 3901 Retention Period Custom Impl.', Comment = '%1 = a value such as 1 Week, 1 Month, 3 Months, or Custom.';

    local procedure RetentionPeriodDateFormula(RetentionPeriod: enum "Retention Period Enum"): Text;
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        if RetentionPeriod <> RetentionPeriod::Custom then
            RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(WrongInterfaceImplementationErr, RetentionPeriod));

        Exit('');
    end;

    procedure RetentionPeriodDateFormula(RetentionPolicy: Record "Retention Period"): Text;
    begin
        Exit(RetentionPeriodDateFormula(RetentionPolicy, false))
    end;

    procedure RetentionPeriodDateFormula(RetentionPolicy: Record "Retention Period"; Translated: Boolean) DateFormulaText: Text;
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        DateFormulaText := RetentionPeriodDateFormula(RetentionPolicy."Retention Period");
        if DateFormulaText <> '' then
            RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(WrongInterfaceImplementationErr, RetentionPolicy."Retention Period"));

        if Translated then
            Exit(Format(RetentionPolicy."Ret. Period Calculation", 0, 1))
        else
            Exit(Format(RetentionPolicy."Ret. Period Calculation", 0, 2))
    end;

    procedure CalculateExpirationDate(RetentionPolicy: Record "Retention Period"): Date
    begin
        Exit(CalcDate(RetentionPeriodDateFormula(RetentionPolicy), Today()))
    end;

    procedure CalculateExpirationDate(RetentionPolicy: Record "Retention Period"; UseDate: Date): Date
    begin
        Exit(CalcDate(RetentionPeriodDateFormula(RetentionPolicy), UseDate))
    end;

    procedure CalculateExpirationDate(RetentionPolicy: Record "Retention Period"; UseDateTime: DateTime): DateTime
    begin
        Exit(CreateDateTime(CalcDate(RetentionPeriodDateFormula(RetentionPolicy), DT2Date(UseDateTime)), DT2Time(UseDateTime)))
    end;

    local procedure LogCategory(): Enum "Retention Policy Log Category"
    var
        RetentionPolicyLogCategory: Enum "Retention Policy Log Category";
    begin
        exit(RetentionPolicyLogCategory::"Retention Policy - Period");
    end;
}
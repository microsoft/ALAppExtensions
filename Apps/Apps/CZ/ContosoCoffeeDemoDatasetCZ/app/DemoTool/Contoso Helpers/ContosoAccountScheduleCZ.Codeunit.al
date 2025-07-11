// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Finance.FinancialReports;
using Microsoft.Foundation.Enums;

codeunit 31292 "Contoso Account Schedule CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Column Layout" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertAccScheduleLine(ScheduleName: Code[10]; LineNo: Integer; RowNo: Code[10]; Description: Text[100]; Totaling: Text[250]; TotalingType: Enum "Acc. Schedule Line Totaling Type"; ShowOppositeSign: Boolean; Bold: Boolean)
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertAccScheduleLine(ScheduleName, LineNo, RowNo, Description, Totaling, TotalingType, Enum::"Acc. Schedule Line Show"::Yes, '', Bold, false, false, ShowOppositeSign, 0);
    end;

    procedure InsertColumnLayout(ColumnLayoutName: Code[10]; LineNo: Integer; ColumnNo: Code[10]; ColumnHeader: Text[30]; ColumnType: Enum "Column Layout Type"; LedgerEntryType: Enum "Column Layout Entry Type"; ComparisonPeriodFormula: Code[20]; AnalysisRoundingFactor: Enum "Analysis Rounding Factor")
    begin
        InsertColumnLayout(ColumnLayoutName, LineNo, ColumnNo, ColumnHeader, ColumnType, LedgerEntryType, Enum::"Account Schedule Amount Type"::"Net Amount", '', false, Enum::"Column Layout Show"::Always, ComparisonPeriodFormula, false, 1033, AnalysisRoundingFactor);
    end;

    procedure InsertColumnLayout(ColumnLayoutName: Code[10]; LineNo: Integer; ColumnNo: Code[10]; ColumnHeader: Text[30]; ColumnType: Enum "Column Layout Type"; LedgerEntryType: Enum "Column Layout Entry Type"; AmountType: Enum "Account Schedule Amount Type"; Formula: Code[80]; ShowOppositeSign: Boolean; Show: Enum "Column Layout Show"; ComparisonPeriodFormula: Code[20]; HideCurrencySymbol: Boolean; FormulaLCID: Integer; AnalysisRoundingFactor: Enum "Analysis Rounding Factor")
    var
        ColumnLayout: Record "Column Layout";
        Exists: Boolean;
    begin
        if ColumnLayout.Get(ColumnLayoutName, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ColumnLayout.Validate("Column Layout Name", ColumnLayoutName);
        ColumnLayout.Validate("Line No.", LineNo);
        ColumnLayout.Validate("Column No.", ColumnNo);
        ColumnLayout.Validate("Column Header", ColumnHeader);
        ColumnLayout.Validate("Column Type", ColumnType);
        ColumnLayout.Validate("Ledger Entry Type", LedgerEntryType);
        ColumnLayout.Validate("Amount Type", AmountType);
        ColumnLayout.Validate(Formula, Formula);
        ColumnLayout.Validate("Show Opposite Sign", ShowOppositeSign);
        ColumnLayout.Validate(Show, Show);
        ColumnLayout.Validate("Comparison Period Formula LCID", FormulaLCID);
        ColumnLayout."Comparison Period Formula" := ComparisonPeriodFormula;
        ColumnLayout.Validate("Hide Currency Symbol", HideCurrencySymbol);
        ColumnLayout.Validate("Rounding Factor", AnalysisRoundingFactor);


        if Exists then
            ColumnLayout.Modify(true)
        else
            ColumnLayout.Insert(true);
    end;
}

// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.IO;

using System.Reflection;

codeunit 31403 "Process Data Exch. Handler CZA"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process Data Exch.", 'OnBeforeFormatFieldValue', '', true, false)]
    local procedure DataFormulaOnBeforeFormatFieldValue(var TransformedValue: Text; DataExchField: Record "Data Exch. Field"; var DataExchFieldMapping: Record "Data Exch. Field Mapping"; FieldRef: FieldRef; DataExchColumnDef: Record "Data Exch. Column Def"; var IsHandled: Boolean)
    var
        TypeHelper: Codeunit "Type Helper";
        VarVariant: Variant;
    begin
        if IsHandled then
            exit;

        if Format(FieldRef.Type) = 'Date' then
            if Format(DataExchFieldMapping."Date Formula CZA") <> '' then begin
                VarVariant := FieldRef.Value;
                if TypeHelper.Evaluate(VarVariant, TransformedValue, DataExchColumnDef."Data Format", DataExchColumnDef."Data Formatting Culture") then begin
                    FieldRef.Value := VarVariant;
                    AdjustDataExchDateWithDateFormula(FieldRef, DataExchFieldMapping."Date Formula CZA", FieldRef.Value);
                    IsHandled := true;
                end;
            end;
    end;

    local procedure AdjustDataExchDateWithDateFormula(var FieldRef: FieldRef; DateFormula: DateFormula; DateAsVariant: Variant)
    var
        DateValue: Date;
    begin
        DateValue := DateAsVariant;
        FieldRef.Value := CalcDate(DateFormula, DateValue);
    end;
}

codeunit 20143 "Lookup Serialization"
{
    procedure LookupToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        TableFieldName: Text;
        SerializedText: Text;
    begin
        if IsNullGuid(ID) then
            exit;

        ScriptSymbolLookup.Get(CaseID, ScriptID, ID);
        case ScriptSymbolLookup."Source Type" of
            ScriptSymbolLookup."Source Type"::"Current Record":
                begin
                    TableFieldName := AppObjectHelper.GetFieldName(ScriptSymbolLookup."Source ID", ScriptSymbolLookup."Source Field ID");
                    if TableFieldName <> '' then
                        exit(VariableToString(TableFieldName));
                end;
            ScriptSymbolLookup."Source Type"::Table:
                exit(LookupTableToString(ScriptSymbolLookup));
            else begin
                    OnSerializeLookupToString(ScriptSymbolLookup, SerializedText);
                    exit(SerializedText);
                end;
        end;
    end;

    procedure ConstantOrLookupText(
        CaseID: Guid;
        ScriptID: Guid;
        ValueType: Option Constant,Lookup;
        Value: Text;
        LookupID: Guid;
        Datatype: Enum "Symbol Data Type"): Text;
    var
        ResultText: Text;
        ConstantTxt: Label '''%1''', Locked = true;
    begin
        if ValueType = ValueType::Constant then begin
            Value := ScriptDataTypeMgmt.ConvertXmlToLocalFormat(Value, Datatype);
            ResultText := StrSubstNo(ConstantTxt, Value)
        end else
            ResultText := LookupToString(CaseID, ScriptID, LookupID);

        exit(ResultText);
    end;

    procedure TableFilterToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        LookupFieldFilter: Record "Lookup Field Filter";
        TableFilters: Text;
    begin
        LookupFieldFilter.Reset();
        LookupFieldFilter.SetRange("Case ID", CaseID);
        LookupFieldFilter.SetRange("Script ID", ScriptID);
        LookupFieldFilter.SetRange("Table Filter ID", ID);
        if LookupFieldFilter.FindSet() then
            repeat
                if TableFilters <> '' then
                    TableFilters += ',';

                TableFilters += FieldFilterToString(LookupFieldFilter);
            until LookupFieldFilter.Next() = 0;

        exit(TableFilters);
    end;

    procedure LookupTableToString(ScriptSymbolLookup: Record "Script Symbol Lookup"): Text;
    var
        LookupTableName: Text;
        LookupFieldName: Text;
        TableFilters: Text;
        FieldFromTableTxt: Label '%1 from %2 %3', Comment = '%1 - Field Name, %2 - Table Name, %3 - Table Filters';
        RecordsFromTableTxt: Label 'no. of records from %1 %2', Comment = '%1 - Table Name, %2 - Table Filters';
        WhereTxt: Label '(where %1)', Comment = '%1 - Table Filters';
        AggregateValueFromTableTxt: Label '%1(%2) from %3 %4', Comment = '%1 - Method Name, %2 - Field Name, %3 - Table Name, %4 - Table Filters,';
        RecordsExistsInTableTxt: Label 'Records exists in %1 %2', Comment = '%1 - Table Name, %2 - Table Filters';
        InvalidLookupMethodErr: Label 'Lookup Table Methods %1 Not Implemented', Comment = '%1= Table Method';
    begin
        LookupTableName := AppObjectHelper.GetObjectName(ObjectType::Table, ScriptSymbolLookup."Source ID");
        LookupFieldName := AppObjectHelper.GetFieldName(ScriptSymbolLookup."Source ID", ScriptSymbolLookup."Source Field ID");

        if not IsNullGuid(ScriptSymbolLookup."Table Filter ID") then begin
            TableFilters := TableFilterToString(ScriptSymbolLookup."Case ID", ScriptSymbolLookup."Script ID", ScriptSymbolLookup."Table Filter ID");
            if TableFilters <> '' then
                TableFilters := StrSubstNo(WhereTxt, TableFilters);
        end;

        case ScriptSymbolLookup."Table Method" of
            ScriptSymbolLookup."Table Method"::" ",
            ScriptSymbolLookup."Table Method"::First,
            ScriptSymbolLookup."Table Method"::Last:
                exit(StrSubstNo(
                    FieldFromTableTxt,
                    VariableToString(LookupFieldName),
                    VariableToString(LookupTableName),
                    TableFilters));
            ScriptSymbolLookup."Table Method"::Count:
                exit(StrSubstNo(
                    RecordsFromTableTxt,
                    VariableToString(LookupTableName),
                    TableFilters));
            ScriptSymbolLookup."Table Method"::Exist:
                exit(StrSubstNo(
                    RecordsExistsInTableTxt,
                    VariableToString(LookupTableName),
                    TableFilters));
            ScriptSymbolLookup."Table Method"::Average,
            ScriptSymbolLookup."Table Method"::Sum,
            ScriptSymbolLookup."Table Method"::Min,
            ScriptSymbolLookup."Table Method"::Max:
                exit(StrSubstNo(
                    AggregateValueFromTableTxt,
                    ScriptSymbolLookup."Table Method",
                    VariableToString(LookupFieldName),
                    VariableToString(LookupTableName),
                    TableFilters));
            else
                Error(InvalidLookupMethodErr, ScriptSymbolLookup."Table Method");
        end;

    end;

    procedure FieldFilterToString(LookupFieldFilter: Record "Lookup Field Filter"): Text;
    var
        FieldDataType: Enum "Symbol Data Type";
        FilterFieldName: Text;
        FilterValue: Text;
        FieldFilterTxt: Label '%1 %2 %3', Comment = '%1 - Field Name, %2 - Filter Type, %3 - Filter Value';
    begin
        if (LookupFieldFilter."Table ID" <> 0) and (LookupFieldFilter."Field ID" <> 0) then begin
            FieldDataType := ScriptDataTypeMgmt.GetFieldDatatype(LookupFieldFilter."Table ID", LookupFieldFilter."Field ID");
            FilterFieldName := AppObjectHelper.GetFieldName(LookupFieldFilter."Table ID", LookupFieldFilter."Field ID");

            FilterValue := ConstantOrLookupText(
                LookupFieldFilter."Case ID",
                LookupFieldFilter."Script ID",
                LookupFieldFilter."Value Type",
                LookupFieldFilter.Value,
                LookupFieldFilter."Lookup ID",
                FieldDataType);
        end else begin
            FilterFieldName := '';
            FilterValue := '';
        end;
        exit(StrSubstNo(FieldFilterTxt, FilterFieldName, LookupFieldFilter."Filter Type", FilterValue));
    end;

    procedure TableSortingToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        LookupTableSorting: Record "Lookup Table Sorting";
        LookupFieldSorting: Record "Lookup Field Sorting";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        i: Integer;
        TableKeys: Text;
    begin
        LookupFieldSorting.Reset();
        LookupFieldSorting.SetRange("Case ID", CaseID);
        LookupFieldSorting.SetRange("Script ID", ScriptID);
        LookupFieldSorting.SetRange("Table Sorting ID", ID);
        if LookupFieldSorting.FindSet() then
            repeat
                if TableKeys <> '' then
                    TableKeys += ',';

                TableKeys += VariableToString(
                    AppObjectHelper.GetFieldName(
                        LookupFieldSorting."Table ID",
                        LookupFieldSorting."Field ID"));
            until LookupFieldSorting.Next() = 0;

        if TableKeys = '' then begin
            LookupTableSorting.Get(CaseID, ScriptID, ID);
            RecRef.Open(LookupTableSorting."Table ID");

            KeyRef := RecRef.KeyIndex(1);
            for i := 1 TO KeyRef.FieldCount() do begin
                Clear(FieldRef);
                FieldRef := KeyRef.FieldIndex(i);
                if TableKeys <> '' then
                    TableKeys += ',';
                TableKeys += VariableToString(
                    AppObjectHelper.GetFieldName(RecRef.Number(), FieldRef.Number()));
            end;
        end;

        exit(TableKeys);
    end;

    local procedure VariableToString(VariableName: Text): Text;
    var
        TempVariableName: Text;
        VariableFormatTxt: Label '"%1"', Comment = '%1 - Variable Name';
    begin
        TempVariableName := DelChr(VariableName, '<>=', '."\/''%][ ');
        if TempVariableName <> VariableName then
            exit(StrSubstNo(VariableFormatTxt, VariableName))
        else
            exit(VariableName);
    end;

    [IntegrationEvent(true, false)]
    procedure OnSerializeLookupToString(ScriptSymbolLookup: Record "Script Symbol Lookup"; var SerializedText: Text);
    begin
    end;

    var
        AppObjectHelper: Codeunit "App Object Helper";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
}


codeunit 20134 "Script Symbol Store"
{
    procedure InitSymbols(CaseID: Guid; ScriptID: Guid; var Symbols: Record "Script Symbol Value" Temporary);
    begin
        ScriptSymbolsMgmt.SetContext(CaseID, ScriptID);
        OnInitSymbols(CaseID, ScriptID, Symbols);
    end;

    procedure InitSymbolContext(TaxType: Code[20]; CaseID: Guid)
    var
        EmptyGuid: Guid;
    begin
        ScriptSymbolsMgmt.SetContext(TaxType, CaseID, EmptyGuid);
    end;

    procedure InsertSymbolValue(SymbolType: Enum "Symbol Type"; Datatype: Enum "Symbol Data Type"; SymbolID: Integer; Value: Variant)
    begin
        TempSymbols.Init();
        TempSymbols.Type := SymbolType;
        TempSymbols."Symbol ID" := SymbolID;
        TempSymbols.Datatype := Datatype;
        TempSymbols.Insert();
        SetSymbolValue(TempSymbols, Value);
        TempSymbols.Modify();
    end;

    procedure InsertSymbolValue(SymbolType: Enum "Symbol Type"; Datatype: Enum "Symbol Data Type"; SymbolID: Integer)
    begin
        TempSymbols.Init();
        TempSymbols.Type := SymbolType;
        TempSymbols."Symbol ID" := SymbolID;
        TempSymbols.Datatype := Datatype;
        TempSymbols.Insert();
    end;

    procedure InsertDictionaryValue(Datatype: Enum "Symbol Data Type"; SymbolID: Integer; FieldID: Integer; Value: Variant)
    begin
        TempSymbolMembers.Init();
        TempSymbolMembers."Symbol ID" := SymbolID;
        TempSymbolMembers."Member ID" := FieldID;
        TempSymbolMembers.Datatype := Datatype;
        TempSymbolMembers.Insert();
        SetSymbolMemberValue(TempSymbolMembers, Value);
        TempSymbolMembers.Modify();
    end;

    procedure InsertDictionaryValue(Datatype: Enum "Symbol Data Type"; SymbolID: Integer; FieldID: Integer)
    begin
        TempSymbolMembers.Init();
        TempSymbolMembers."Symbol ID" := SymbolID;
        TempSymbolMembers."Member ID" := FieldID;
        TempSymbolMembers.Datatype := Datatype;
        TempSymbolMembers.Insert();
    end;

    procedure CopySymbols(var ToSymbols: Record "Script Symbol Value" temporary)
    begin
        ToSymbols.Reset();
        ToSymbols.DeleteAll();
        ToSymbols.Copy(TempSymbols, true);
    end;

    procedure GetSymbolOfType(Type: enum "Symbol Type"; SymbolID: Integer; var Value: Variant);
    begin
        TempSymbols.Reset();
        TempSymbols.SetRange(Type, Type);
        TempSymbols.SetRange("Symbol ID", SymbolID);
        TempSymbols.FindFirst();
        GetSymbolValue(TempSymbols, Value);
    end;

    procedure GetSymbolMember(SymbolID: Integer; MemberID: Integer; var Value: Variant);
    begin
        TempSymbolMembers.Reset();
        TempSymbolMembers.SetRange("Symbol ID", SymbolID);
        TempSymbolMembers.SetRange("Member ID", MemberID);
        TempSymbolMembers.FindFirst();
        GetSymbolMemberValue(TempSymbolMembers, Value);
    end;

    procedure GetSymbolValue(var Symbol: Record "Script Symbol Value" Temporary; var Value: Variant);
    var
        FormulaID: Guid;
        IStream: InStream;
        IsHandled: Boolean;
        TextBuffer: Text;
        TextContent: Text;
    begin
        FormulaID := ScriptSymbolsMgmt.GetSymbolFormulaID(Symbol.Type, Symbol."Symbol ID");
        if not IsNullGuid(FormulaID) then begin
            OnEvaluateSymbolFormula(Symbol.Type, Symbol."Symbol ID", FormulaID, Symbol, Value, IsHandled);
            if not IsHandled then
                Error(UnhandledFormulaErr, ScriptSymbolsMgmt.GetSymbolName(Symbol.Type, Symbol."Symbol ID"));

            exit;
        end;

        case Symbol.Datatype of
            "Symbol Data Type"::Number:
                Value := Symbol."Number Value";
            "Symbol Data Type"::Option:
                Value := Symbol."Option Value";
            "Symbol Data Type"::Boolean:
                Value := Symbol."Boolean Value";
            "Symbol Data Type"::Date:
                Value := Symbol."Date Value";
            "Symbol Data Type"::Time:
                Value := Symbol."Time Value";
            "Symbol Data Type"::Datetime:
                Value := Symbol."DateTime Value";
            "Symbol Data Type"::Guid:
                Value := Symbol."Guid Value";
            "Symbol Data Type"::Recid:
                Value := Symbol."RecordID Value";
            "Symbol Data Type"::String:
                if Symbol."Text Value Type" = Symbol."Text Value Type"::Text then
                    Value := Symbol."Simple Text Value"
                else
                    if Symbol."Text Value".HasValue() then begin
                        Symbol.CALCFIELDS(Symbol."Text Value");
                        Symbol."Text Value".CREATEINSTREAM(IStream, TEXTENCODING::UTF8);
                        while IStream.READTEXT(TextBuffer) <> 0 do
                            TextContent += TextBuffer;

                        Value := TextContent;
                    end else
                        Value := '';
            else
                Error(DataTypeReadErr, ScriptSymbolsMgmt.GetSymbolName(Symbol.Type, Symbol."Symbol ID"));
        end;
    end;

    procedure GetSymbolMemberValue(var SymbolMembers: Record "Script Symbol Member Value" Temporary; var Value: Variant);
    var
        IStream: InStream;
        TextBuffer: Text;
        TextContent: Text;
    begin
        case SymbolMembers.Datatype of
            "Symbol Data Type"::Number:
                Value := SymbolMembers."Number Value";
            "Symbol Data Type"::Option:
                Value := SymbolMembers."Option Value";
            "Symbol Data Type"::Boolean:
                Value := SymbolMembers."Boolean Value";
            "Symbol Data Type"::Date:
                Value := SymbolMembers."Date Value";
            "Symbol Data Type"::Time:
                Value := SymbolMembers."Time Value";
            "Symbol Data Type"::Datetime:
                Value := SymbolMembers."DateTime Value";
            "Symbol Data Type"::Guid:
                Value := SymbolMembers."Guid Value";
            "Symbol Data Type"::Recid:
                Value := SymbolMembers."RecordID Value";
            "Symbol Data Type"::String:
                if SymbolMembers."String Value Type" = SymbolMembers."String Value Type"::Text then
                    Value := SymbolMembers."Simple String Value"
                else
                    if SymbolMembers."String Value".HasValue() then begin
                        SymbolMembers.CALCFIELDS(SymbolMembers."String Value");
                        SymbolMembers."String Value".CREATEINSTREAM(IStream, TEXTENCODING::UTF8);
                        while IStream.READTEXT(TextBuffer) <> 0 do
                            TextContent += TextBuffer;

                        Value := TextContent;
                    end else
                        Value := '';
            else
                Error(DataTypeReadErr, ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::"Record Variable", SymbolMembers."Symbol ID"));
        end;
    end;

    procedure SetSymbol2(SymbolType: Enum "Symbol Type"; SymbolID: Integer; Value: Variant);
    begin
        TempSymbols.Reset();
        TempSymbols.SetRange(Type, SymbolType);
        TempSymbols.SetRange("Symbol ID", SymbolID);
        TempSymbols.FindFirst();
        SetSymbolValue(TempSymbols, Value);
        TempSymbols.Modify();
    end;

    procedure SetSymbolMember(SymbolID: Integer; MemberID: Integer; Value: Variant);
    begin
        TempSymbolMembers.Reset();
        TempSymbolMembers.SetRange("Symbol ID", SymbolID);
        TempSymbolMembers.SetRange("Member ID", MemberID);
        TempSymbolMembers.FindFirst();
        SetSymbolMemberValue(TempSymbolMembers, Value);
        TempSymbolMembers.Modify();
    end;

    procedure SetSymbolValue(var Symbol: Record "Script Symbol Value" Temporary; Value: Variant);
    var
        TempRecordID: RecordID;
        TextBinaryValue: Text;
        OStream: OutStream;
    begin
        Symbol.Initialized := true;
        case Symbol.Datatype of
            "Symbol Data Type"::Number:
                Symbol."Number Value" := DataTypeMgmt.Variant2Number(Value);
            "Symbol Data Type"::Option:
                Symbol."Option Value" := DataTypeMgmt.Variant2Number(Value);
            "Symbol Data Type"::Boolean:
                Symbol."Boolean Value" := DataTypeMgmt.Variant2Boolean(Value);
            "Symbol Data Type"::Date:
                Symbol."Date Value" := DataTypeMgmt.Variant2Date(Value);
            "Symbol Data Type"::Time:
                Symbol."Time Value" := DataTypeMgmt.Variant2Time(Value);
            "Symbol Data Type"::Datetime:
                Symbol."DateTime Value" := DataTypeMgmt.Variant2DateTime(Value);
            "Symbol Data Type"::Guid:
                Symbol."Guid Value" := DataTypeMgmt.Variant2GUID(Value);
            "Symbol Data Type"::Recid:
                begin
                    DataTypeMgmt.Variant2RecordID(Value, TempRecordID);
                    Symbol."RecordID Value" := TempRecordID;
                end;
            "Symbol Data Type"::String:
                begin
                    TextBinaryValue := DataTypeMgmt.Variant2Text(Value, '');
                    if STRLEN(TextBinaryValue) > 250 then begin
                        Symbol."Text Value".CREATEOUTSTREAM(OStream, TEXTENCODING::UTF8);
                        OStream.WRITETEXT(TextBinaryValue);
                        Symbol."Text Value Type" := Symbol."Text Value Type"::BLOB;
                    end else begin
                        Symbol."Simple Text Value" := CopyStr(TextBinaryValue, 1, 250);
                        Symbol."Text Value Type" := Symbol."Text Value Type"::Text;
                    end;
                end;
            else
                Error(DataTypeWriteErr, ScriptSymbolsMgmt.GetSymbolName(Symbol.Type, Symbol."Symbol ID"));
        end;

    end;

    procedure SetSymbolMemberValue(var SymbolMembers: Record "Script Symbol Member Value" Temporary; Value: Variant);
    var
        TempRecordID: RecordID;
        TextBinaryValue: Text;
        OStream: OutStream;
    begin
        case SymbolMembers.Datatype of
            "Symbol Data Type"::Number:
                SymbolMembers."Number Value" := DataTypeMgmt.Variant2Number(Value);
            "Symbol Data Type"::Option:
                SymbolMembers."Option Value" := DataTypeMgmt.Variant2Number(Value);
            "Symbol Data Type"::Boolean:
                SymbolMembers."Boolean Value" := DataTypeMgmt.Variant2Boolean(Value);
            "Symbol Data Type"::Date:
                SymbolMembers."Date Value" := DataTypeMgmt.Variant2Date(Value);
            "Symbol Data Type"::Time:
                SymbolMembers."Time Value" := DataTypeMgmt.Variant2Time(Value);
            "Symbol Data Type"::Datetime:
                SymbolMembers."DateTime Value" := DataTypeMgmt.Variant2DateTime(Value);
            "Symbol Data Type"::Guid:
                SymbolMembers."Guid Value" := DataTypeMgmt.Variant2GUID(Value);
            "Symbol Data Type"::Recid:
                begin
                    DataTypeMgmt.Variant2RecordID(Value, TempRecordID);
                    SymbolMembers."RecordID Value" := TempRecordID;
                end;
            "Symbol Data Type"::String:
                begin
                    TextBinaryValue := DataTypeMgmt.Variant2Text(Value, '');
                    if STRLEN(TextBinaryValue) > 250 then begin
                        SymbolMembers."String Value".CREATEOUTSTREAM(OStream, TEXTENCODING::UTF8);
                        OStream.WRITETEXT(TextBinaryValue);
                        SymbolMembers."String Value Type" := SymbolMembers."String Value Type"::BLOB;
                    end else begin
                        SymbolMembers."Simple String Value" := CopyStr(TextBinaryValue, 1, 250);
                        SymbolMembers."String Value Type" := SymbolMembers."String Value Type"::Text;
                    end;
                end;
            else
                Error(DataTypeWriteErr, ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::"Record Variable", SymbolMembers."Symbol ID"));
        end;
    end;

    procedure GetLookupSourceType(CaseID: Guid; ScriptID: Guid; LookupID: Guid): Enum "Symbol Type"
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        EmptyGuid: Guid;
    begin
        if not ScriptSymbolLookup.GET(CaseID, ScriptID, LookupID) then
            ScriptSymbolLookup.GET(CaseID, EmptyGuid, LookupID);
        exit(ScriptSymbolLookup."Source Type");
    end;

    procedure TransferRecRefToSymbolMembers(var RecordRef: RecordRef; SymbolID: Integer);
    var
        FldRef: FieldRef;
    begin
        if SymbolID = 0 then
            exit;
        TempSymbolMembers.Reset();
        TempSymbolMembers.SetRange("Symbol ID", SymbolID);
        if TempSymbolMembers.FindSet() then
            repeat
                FldRef := RecordRef.Field(TempSymbolMembers."Member ID");
                SetSymbolMember(SymbolID, TempSymbolMembers."Member ID", FldRef.Value());
                TempSymbolMembers.SetRange("Member ID");
            until TempSymbolMembers.Next() = 0;
    end;

    procedure SetDefaultSymbolValue(
        var Symbols: Record "Script Symbol Value" temporary;
        Type: Enum "Symbol Type";
        SymbolID: Integer;
        Value: Variant;
        DataType: Enum "Symbol Data Type");
    begin
        Symbols.Reset();
        Symbols.SetRange(Type, Type);
        Symbols.SetRange("Symbol ID", SymbolID);
        if not Symbols.FindFirst() then begin
            Symbols.Type := Type;
            Symbols."Symbol ID" := SymbolID;
            Symbols.Datatype := DataType;
            Symbols.Insert();
        end;
        SetSymbolValue(Symbols, Value);
        Symbols.Modify();
    end;

    procedure GetLookupValue(var SourceRecordRef: RecordRef; CaseID: Guid; ScriptID: Guid; LookupID: Guid; var Value: Variant);
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        RecRefHelper: Codeunit "RecRef Handler";
        IsHandled: Boolean;
        InvalidSourceTypeErr: Label 'Source Type %1 not implemented.', Comment = '%1 = Symbol Source Type';
    begin
        ScriptSymbolLookup.GET(CaseID, ScriptID, LookupID);
        case ScriptSymbolLookup."Source Type" of
            ScriptSymbolLookup."Source Type"::"Current Record":
                RecRefHelper.GetFieldValue(SourceRecordRef, ScriptSymbolLookup."Source Field ID", Value);
            ScriptSymbolLookup."Source Type"::Database:
                GetDatabaseSymbolValue(ScriptSymbolLookup."Source Field ID", Value);
            ScriptSymbolLookup."Source Type"::System:
                GetSystemSymbolValue(ScriptSymbolLookup."Source Field ID", Value);
            ScriptSymbolLookup."Source Type"::Table:
                GetTableFieldValue(SourceRecordRef, ScriptSymbolLookup, Value);
            else begin
                    OnGetLookupValue(SourceRecordRef, ScriptSymbolLookup, IsHandled, Value);
                    if not IsHandled then
                        Error(InvalidSourceTypeErr, ScriptSymbolLookup."Source Type");
                end;
        end;
    end;

    procedure ApplyTableFilters(var SourceRecordRef: RecordRef; CaseID: Guid; ScriptID: Guid; var RecordRef: RecordRef; TableFilterID: Guid);
    var
        LookupTableFilter: Record "Lookup Table Filter";
        LookupFieldFilter: Record "Lookup Field Filter";
        RecRefHelper: Codeunit "RecRef Handler";
        FilterValue: Variant;
    begin
        if IsNullGuid(TableFilterID) then
            exit;

        LookupTableFilter.GET(CaseID, ScriptID, TableFilterID);
        LookupFieldFilter.Reset();
        LookupFieldFilter.SetRange("Case ID", CaseID);
        LookupFieldFilter.SetRange("Table Filter ID", TableFilterID);
        if LookupFieldFilter.FindSet() then
            repeat
                GetConstantOrLookupValue(
                    SourceRecordRef,
                    CaseID,
                    ScriptID,
                    LookupFieldFilter."Value Type",
                    LookupFieldFilter.Value,
                    LookupFieldFilter."Lookup ID",
                    FilterValue);
                RecRefHelper.SetFieldFilter(
                    RecordRef,
                    LookupFieldFilter."Field ID",
                    LookupFieldFilter."Filter Type",
                    FilterValue);
            until LookupFieldFilter.Next() = 0;
    end;

    procedure GetConstantOrLookupValue(var SourceRecordRef: RecordRef; CaseID: Guid; ScriptID: Guid; ValueType: Option Constant,"Lookup"; ConstantText: Text; LookupID: Guid; var Value: Variant);
    begin
        case ValueType of
            ValueType::Constant:
                Value := ConstantText;
            ValueType::Lookup:
                GetLookupValue(SourceRecordRef, CaseID, ScriptID, LookupID, Value);
        end;
    end;

    procedure GetConstantOrLookupValueOfType(
        var SourceRecordRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ValueType: Option Constant,"Lookup";
        ConstantText: Text;
        LookupID: Guid;
        ToDatatype: Enum "Symbol Data Type";
        OptionString: Text;
        var Value: Variant);
    begin
        case ValueType of
            ValueType::Constant:
                DataTypeMgmt.ConvertText2Type(ConstantText, ToDatatype, OptionString, Value);
            ValueType::Lookup:
                GetLookupValue(SourceRecordRef, CaseID, ScriptID, LookupID, Value);
        end;
    end;

    local procedure GetDatabaseSymbolValue(SymbolID: Integer; var Value: Variant);
    begin
        case SymbolID of
            "Database Symbol"::UserId.AsInteger():
                Value := UserId();
            "Database Symbol"::COMPANYNAME.AsInteger():
                Value := CompanyName();
            "Database Symbol"::SERIALNUMBER.AsInteger():
                Value := SerialNumber();
            "Database Symbol"::TENANTID.AsInteger():
                Value := TenantId();
            "Database Symbol"::SESSIONID.AsInteger():
                Value := SessionId();
            "Database Symbol"::SERVICEINSTANCEID.AsInteger():
                Value := ServiceInstanceId();
        end;
    end;

    local procedure GetSystemSymbolValue(SymbolID: Integer; var Value: Variant);
    begin
        case SymbolID of
            "System Symbol"::Today.AsInteger():
                Value := Today();
            "System Symbol"::TIME.AsInteger():
                Value := Time();
            "System Symbol"::WorkDate.AsInteger():
                Value := WorkDate();
            "System Symbol"::CURRENTDATETIME.AsInteger():
                Value := CurrentDateTime();
        end;
    end;

    local procedure GetTableFieldValue(
        var SourceRecordRef: RecordRef;
        var ScriptSymbolLookup: Record "Script Symbol Lookup";
        var Value: Variant);
    var
        AppObjectHelper: Codeunit "App Object Helper";
        LookupSerialization: Codeunit "Lookup Serialization";
        RecRef: RecordRef;
        FldRef: FieldRef;
        FieldValue: Decimal;
        ExistBool: Boolean;
        RecCount: Integer;
    begin
        Clear(Value);
        RecRef.OPEN(ScriptSymbolLookup."Source ID");

        case ScriptSymbolLookup."Table Method" of
            ScriptSymbolLookup."Table Method"::First, ScriptSymbolLookup."Table Method"::Last:
                if not IsNullGuid(ScriptSymbolLookup."Table Sorting ID") then
                    RecRef.SETVIEW(StrSubstNo(SortingTxt, LookupSerialization.TableSortingToString(ScriptSymbolLookup."Case ID", ScriptSymbolLookup."Script ID", ScriptSymbolLookup."Table Sorting ID"), 'Ascending'));
            ScriptSymbolLookup."Table Method"::Min, ScriptSymbolLookup."Table Method"::Max:
                RecRef.SETVIEW(StrSubstNo(SortingTxt, AppObjectHelper.GetFieldName(ScriptSymbolLookup."Source ID", ScriptSymbolLookup."Source Field ID"), 'Ascending'));
        end;

        ApplyTableFilters(SourceRecordRef, ScriptSymbolLookup."Case ID", ScriptSymbolLookup."Script ID", RecRef, ScriptSymbolLookup."Table Filter ID");
        case ScriptSymbolLookup."Table Method" of
            ScriptSymbolLookup."Table Method"::Count:
                Value := RecRef.Count();
            ScriptSymbolLookup."Table Method"::First:
                begin
                    FldRef := RecRef.Field(ScriptSymbolLookup."Source Field ID");
                    if RecRef.FindFirst() then begin
                        if Format(FldRef.Type()) = 'BLOB' then
                            Value := DataTypeMgmt.Variant2Text(FldRef, '')
                        else
                            Value := FldRef.Value();
                    end else
                        Value := FldRef.Value();
                end;
            ScriptSymbolLookup."Table Method"::Last:
                begin
                    FldRef := RecRef.Field(ScriptSymbolLookup."Source Field ID");
                    if RecRef.FindLast() then begin

                        if Format(FldRef.Type()) = 'BLOB' then
                            Value := DataTypeMgmt.Variant2Text(FldRef, '')
                        else
                            Value := FldRef.Value();
                    end else
                        Value := FldRef.Value();
                end;
            ScriptSymbolLookup."Table Method"::Average:
                begin
                    FldRef := RecRef.Field(ScriptSymbolLookup."Source Field ID");
                    FldRef.CalcSum();
                    FieldValue := FldRef.Value();
                    RecCount := RecRef.Count();
                    if RecCount <> 0 then
                        Value := FieldValue / RecCount;
                end;
            ScriptSymbolLookup."Table Method"::Sum:
                begin
                    FldRef := RecRef.Field(ScriptSymbolLookup."Source Field ID");
                    FldRef.CalcSum();
                    Value := FldRef.Value();
                end;
            ScriptSymbolLookup."Table Method"::Max:
                if RecRef.FindLast() then begin
                    FldRef := RecRef.Field(ScriptSymbolLookup."Source Field ID");
                    Value := FldRef.Value();
                end;
            ScriptSymbolLookup."Table Method"::Min:
                if RecRef.FindFirst() then begin
                    FldRef := RecRef.Field(ScriptSymbolLookup."Source Field ID");
                    Value := FldRef.Value();
                end;
            ScriptSymbolLookup."Table Method"::Exist:
                begin
                    ExistBool := not RecRef.IsEmpty();
                    Value := ExistBool;
                end;
        end;
        RecRef.Close();

    end;

    [IntegrationEvent(true, false)]
    procedure OnGetLookupValue(var SourceRecordRef: RecordRef; ScriptSymbolLookup: Record "Script Symbol Lookup"; var IsHandled: Boolean; var Value: Variant);
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnInitSymbols(CaseID: Guid; ScriptID: Guid; var Symbols: Record "Script Symbol Value" Temporary);
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnEvaluateSymbolFormula(SymbolType: Enum "Symbol Type"; SymbolID: Integer; FormulaID: Guid; var Symbols: Record "Script Symbol Value" Temporary; var Value: Variant; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeValidateIfUpdateIsAllowed(CaseID: Guid)
    begin
    end;

    var
        TempSymbols: Record "Script Symbol Value" Temporary;
        TempSymbolMembers: Record "Script Symbol Member Value" Temporary;
        DataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        DataTypeReadErr: Label 'Could not read the value of %1.', Comment = '%1 - Symbol Name';
        DataTypeWriteErr: Label 'Could not update the value of %1.', Comment = '%1 - Symbol Name';
        SortingTxt: Label 'VERSION(1) SORTING(%1) ORDER(%2)', Locked = true;
        UnhandledFormulaErr: Label 'Formula must be evaluated for Symbol : %1.', Comment = '%1 - Symbol Name';
}
codeunit 20142 "Lookup Mgmt."
{
    procedure GetSourceTable(CaseID: Guid): Integer;
    var
        TableID: Integer;
        IsHandled: Boolean;
        InvalidGetLookupSourceTableIDErr: Label 'GetLookupSourceTableID is Not Implemented';
        InvalidTableIDErr: Label 'TableID is not defined for Case ID %1', Comment = '%1 = Use Case ID';
    begin
        OnGetLookupSourceTableID(CaseID, TableID, IsHandled);
        if not IsHandled then
            Error(InvalidGetLookupSourceTableIDErr);

        if TableID = 0 then
            Error(InvalidTableIDErr, CaseID);

        exit(TableID);
    end;

    procedure GetLookupDatatype(CaseID: Guid; ScriptID: Guid; ID: Guid): Enum "Symbol Data Type";
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        Datatype: Enum "Symbol Data Type";
        FieldDatatype: Enum "Symbol Data Type";
        TableMethodOnlyForNumbersErr: Label 'Table Method %1 should be used only on Number type fields.', Comment = '%1 = Table Method';
    begin
        ScriptSymbolLookup.GET(CaseID, ScriptID, ID);

        case ScriptSymbolLookup."Source Type" of
            ScriptSymbolLookup."Source Type"::"Current Record":
                begin
                    if ScriptSymbolLookup."Source Field ID" = 0 then
                        exit("Symbol Data Type"::String);
                    exit(DataTypeMgmt.GetFieldDatatype(
                        ScriptSymbolLookup."Source ID",
                        ScriptSymbolLookup."Source Field ID"));
                end;
            ScriptSymbolLookup."Source Type"::Database,
            ScriptSymbolLookup."Source Type"::System,
            ScriptSymbolLookup."Source Type"::Table:
                case ScriptSymbolLookup."Table Method" of
                    ScriptSymbolLookup."Table Method"::Count,
                    ScriptSymbolLookup."Table Method"::Average:
                        exit(Datatype::Number);
                    ScriptSymbolLookup."Table Method"::Exist:
                        exit(Datatype::Boolean);
                    ScriptSymbolLookup."Table Method"::First,
                    ScriptSymbolLookup."Table Method"::Last:
                        begin
                            if ScriptSymbolLookup."Source Field ID" = 0 then
                                exit("Symbol Data Type"::String);
                            exit(DataTypeMgmt.GetFieldDatatype(
                                ScriptSymbolLookup."Source ID",
                                ScriptSymbolLookup."Source Field ID"));
                        end;
                    ScriptSymbolLookup."Table Method"::Min,
                    ScriptSymbolLookup."Table Method"::Max,
                    ScriptSymbolLookup."Table Method"::Sum:
                        begin
                            if ScriptSymbolLookup."Source Field ID" = 0 then
                                exit("Symbol Data Type"::Number);

                            FieldDatatype := DataTypeMgmt.GetFieldDatatype(
                                ScriptSymbolLookup."Source ID",
                                ScriptSymbolLookup."Source Field ID");

                            if FieldDatatype <> Datatype::Number then
                                Error(TableMethodOnlyForNumbersErr, ScriptSymbolLookup."Table Method");
                            exit(FieldDatatype);
                        end;
                end;
            else begin
                    OnGetSymbolDataType(ScriptSymbolLookup, Datatype);
                    exit(Datatype);
                end;
        end;
    end;

    procedure ConvertLookupToConstant(
        CaseID: Guid;
        ScriptID: Guid;
        var ValueType: Option Constant,"Lookup";
        var Value: Text[250];
        var LookupID: Guid;
        var FormattedValue: Text;
        Datatype: Enum "Symbol Data Type"): Boolean;
    var
        XmlValue: Text;
        Evaluated: Boolean;
        InvalidateContLbl: Label 'Constant value %1 is invalid for datatype %2', Comment = '%1= Constant value, %2 = datatype';
    begin
        if (ValueType = ValueType::Lookup) then begin
            if not Confirm('Convert to constant value ?') then
                exit(false);

            EntityMgmt.DeleteLookup(CaseID, ScriptID, LookupID);
        end;

        ValueType := ValueType::Constant;
        case Datatype of
            Datatype::Number:
                Evaluated := DataTypeMgmt.IsNumber(FormattedValue);
            Datatype::Boolean:
                Evaluated := DataTypeMgmt.IsBoolean(FormattedValue);
            Datatype::Guid:
                Evaluated := DataTypeMgmt.IsGUID(FormattedValue);
            Datatype::Date:
                Evaluated := DataTypeMgmt.IsDate(FormattedValue);
            Datatype::Datetime:
                Evaluated := DataTypeMgmt.IsDateTime(FormattedValue);
            Datatype::Time:
                Evaluated := DataTypeMgmt.IsTime(FormattedValue);
            Datatype::String, Datatype::Option:
                Evaluated := true;
            Datatype::Recid:
                Evaluated := DataTypeMgmt.IsRecID(FormattedValue);
            Datatype::Record:
                Evaluated := false;
        end;

        if not Evaluated then
            Error(InvalidateContLbl, FormattedValue, Datatype);

        XmlValue := DataTypeMgmt.ConvertLocalToXmlFormat(FormattedValue, Datatype);
        Value := CopyStr(XmlValue, 1, 250);
        exit(true);
    end;

    procedure ConvertConstantToLookup(CaseID: Guid; ScriptID: Guid; var ValueType: Option Constant,"Lookup"; var Value: Text[250]; var LookupID: Guid): Boolean;
    begin
        if (ValueType = ValueType::Constant) and (Value <> '') then begin
            if not Confirm('Convert to Lookup ?') then
                exit(false);

            Value := '';
        end;

        ValueType := ValueType::Lookup;
        if IsNullGuid(LookupID) then
            LookupID := EntityMgmt.CreateLookup(CaseID, ScriptID);
        exit(true);
    end;

    procedure OpenLookupDialogOfType(CaseID: Guid; ScriptID: Guid; ID: Guid; Datatype: Enum "Symbol Data Type");
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        ScriptSymbolLookupDialog: Page "Script Symbol Lookup Dialog";
    begin
        ScriptSymbolLookup.GET(CaseID, ScriptID, ID);
        ScriptSymbolLookupDialog.SetDatatype(Datatype);
        ScriptSymbolLookupDialog.SetCurrentRecord(ScriptSymbolLookup);
        ScriptSymbolLookupDialog.RunModal();
    end;

    procedure OpenLookupDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        RuleLookupDialog: Page "Script Symbol Lookup Dialog";
    begin
        ScriptSymbolLookup.GET(CaseID, ScriptID, ID);
        RuleLookupDialog.SetCurrentRecord(ScriptSymbolLookup);
        RuleLookupDialog.RunModal();
    end;

    [IntegrationEvent(true, false)]
    procedure OnGetLookupSourceTableID(CaseID: Guid; var TableID: Integer; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnGetSymbolDataType(
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        var Datatype: Enum "Symbol Data Type");
    begin
    end;

    var
        EntityMgmt: Codeunit "Lookup Entity Mgmt.";
        DataTypeMgmt: Codeunit "Script Data Type Mgmt.";
}
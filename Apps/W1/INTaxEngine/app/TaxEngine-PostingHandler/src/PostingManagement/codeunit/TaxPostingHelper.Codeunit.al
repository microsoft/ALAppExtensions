codeunit 20346 "Tax Posting Helper"
{
    procedure OpenInsertRecordDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        InsertRecord: Record "Tax Insert Record";
        InsertRecordDialog: Page "Tax Insert Record Dialog";
    begin
        InsertRecord.GET(CaseID, ScriptID, ID);
        InsertRecordDialog.SetCurrentRecord(InsertRecord);
        Commit();
        InsertRecordDialog.RunModal();
    end;

    procedure CreateInsertRecord(CaseID: Guid; ScriptID: Guid): Guid;
    var
        InsertRecord: Record "Tax Insert Record";
    begin
        InsertRecord.Init();
        InsertRecord."Case ID" := CaseID;
        InsertRecord."Script ID" := ScriptID;
        InsertRecord.ID := CreateGuid();
        InsertRecord.Insert();

        exit(InsertRecord.ID);
    end;

    procedure DeleteInsertRecord(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        InsertRecord: Record "Tax Insert Record";
    begin
        if IsNullGuid(ID) then
            Exit;

        InsertRecord.GET(CaseID, ScriptID, ID);
        InsertRecord.Delete(true);
    end;

    procedure InsertRecordToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        InsertRecord: Record "Tax Insert Record";
        InsertRecordField: Record "Tax Insert Record Field";
        FieldDataType: Enum "Symbol Data Type";
        TableName: Text;
        FieldName: Text;
        LookupValue: Text;
        FieldRecordText: Text;
        RecordFieldText: Text;
        ToStringFormatTxt: Label 'Insert a record in %1 (Assign %2)',
            Comment = '%1 - Table Name,%2 - Field Value Assignement';
        FieldRecordTxtLbl: Label '%1 to Field: %2', Comment = '%1 = Lookup value, %2 = variable name';
    begin
        InsertRecord.GET(CaseID, ScriptID, ID);
        TableName := AppObjectHelper.GetObjectName(ObjectType::Table, InsertRecord."Table ID");

        InsertRecordField.Reset();
        InsertRecordField.SetRange("Case ID", CaseID);
        InsertRecordField.SetRange("Insert Record ID", ID);
        if InsertRecordField.FindSet() then
            repeat
                if (InsertRecordField."Table ID" <> 0) and (InsertRecordField."Field ID" <> 0) then begin
                    FieldDataType := ScriptDatatypeMgmt.GetFieldDatatype(InsertRecordField."Table ID", InsertRecordField."Field ID");
                    FieldName := AppObjectHelper.GetFieldName(
                        InsertRecordField."Table ID",
                        InsertRecordField."Field ID");

                    LookupValue := LookupSerialization.ConstantOrLookupText(
                        InsertRecordField."Case ID",
                        InsertRecordField."Script ID",
                        InsertRecordField."Value Type",
                        InsertRecordField.Value,
                        InsertRecordField."Lookup ID",
                        FieldDataType);
                end else begin
                    FieldName := '';
                    FieldName := '';
                end;
                FieldRecordText := StrSubstNo(FieldRecordTxtLbl, LookupValue, VariableToString(FieldName));
                if RecordFieldText <> '' then
                    RecordFieldText += ', ';
                RecordFieldText += FieldRecordText;
            until InsertRecordField.Next() = 0;

        exit(StrSubstNo(ToStringFormatTxt, VariableToString(TableName), RecordFieldText));
    end;

    local procedure VariableToString(VariableName: Text): Text;
    var
        VariableName2: Text;
        VariableFormatTxt: Label '"%1"', Comment = '%1 = variable name';
    begin
        VariableName2 := DELCHR(VariableName, '<>=', '."\/''%][ ');
        if VariableName2 <> VariableName then
            exit(StrSubstNo(VariableFormatTxt, VariableName))
        else
            exit(VariableName);
    end;

    var
        AppObjectHelper: Codeunit "App Object Helper";
        LookupSerialization: Codeunit "Lookup Serialization";
        ScriptDatatypeMgmt: Codeunit "Script Data Type Mgmt.";
}
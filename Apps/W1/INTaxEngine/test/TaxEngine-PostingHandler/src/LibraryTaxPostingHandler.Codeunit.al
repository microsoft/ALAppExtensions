codeunit 137554 "Library - Tax Posting Handler"
{
    EventSubscriberInstance = Manual;

    procedure CreateInsertRecord(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    var
        TaxPostingHelper: Codeunit "Tax Posting Helper";
    begin
        Init(CaseID, ScriptID);
        ActionID := TaxPostingHelper.CreateInsertRecord(CaseID, ScriptID);
    end;

    procedure CreateInsertRecordField(CaseID: Guid; ScriptID: Guid; ActionID: Guid; TableID: Integer; FieldID: Integer; Value: Text[250])
    var
        TaxInsertRecordField: Record "Tax Insert Record Field";
    begin
        TaxInsertRecordField.Init();
        TaxInsertRecordField."Case ID" := CaseID;
        TaxInsertRecordField."Script ID" := ScriptID;
        TaxInsertRecordField."Insert Record ID" := ActionID;
        TaxInsertRecordField."Table ID" := TableID;
        TaxInsertRecordField."Field ID" := FieldID;
        TaxInsertRecordField."Value Type" := TaxInsertRecordField."Value Type"::Constant;
        TaxInsertRecordField.Value := Value;
        TaxInsertRecordField.Insert();
    end;

    procedure DeleteInsertRecord(CaseID: Guid; ScriptID: Guid; ActionID: Guid)
    var
        TaxPostingHelper: Codeunit "Tax Posting Helper";
    begin
        TaxPostingHelper.DeleteInsertRecord(CaseID, ScriptID, ActionID);
    end;

    procedure Init(var CaseID: Guid; var ScriptID: Guid)
    begin
        if not Initiated then begin
            GlobalCaseID := CreateGuid();
            GlobalScriptID := CreateGuid();
            Initiated := true;
        end;

        CaseID := GlobalCaseID;
        ScriptID := GlobalScriptID;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbols Mgmt.", 'OnGetTaxType', '', false, false)]
    local procedure OnGetTaxType(CaseID: Guid; var TaxType: Code[20]; var Handled: Boolean)
    begin
        TaxType := 'XGST';
        Handled := true;
    end;


    var
        Initiated: Boolean;
        GlobalCaseID, GlobalScriptID : Guid;
}
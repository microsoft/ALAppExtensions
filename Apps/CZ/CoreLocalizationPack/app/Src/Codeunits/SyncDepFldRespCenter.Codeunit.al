#if not CLEAN18
#pragma warning disable AL0432
codeunit 31207 "Sync.Dep.Fld-RespCenter CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Responsibility Center", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertResponsibilityCenter(var Rec: Record "Responsibility Center")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Responsibility Center", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyResponsibilityCenter(var Rec: Record "Responsibility Center")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Responsibility Center")
    var
        PreviousRecord: Record "Responsibility Center";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Bank Account Code";
        NewFieldTxt := Rec."Default Bank Account Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Bank Account Code", PreviousRecord."Default Bank Account Code CZL");
        Rec."Bank Account Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Bank Account Code"));
        Rec."Default Bank Account Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Default Bank Account Code CZL"));
    end;
}
#endif
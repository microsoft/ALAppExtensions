#if not CLEAN17
#pragma warning disable AL0432
codeunit 31129 "Sync.Dep.Fld-SrcCodeSetup CZP"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Source Code Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertSourceCodeSetup(var Rec: Record "Source Code Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Source Code Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifySourceCodeSetup(var Rec: Record "Source Code Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Source Code Setup")
    var
        PreviousRecord: Record "Source Code Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Cash Desk";
        NewFieldTxt := Rec."Cash Desk CZP";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Cash Desk", PreviousRecord."Cash Desk CZP");
        Rec."Cash Desk" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Cash Desk"));
        Rec."Cash Desk CZP" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Cash Desk CZP"));
    end;
}
#endif
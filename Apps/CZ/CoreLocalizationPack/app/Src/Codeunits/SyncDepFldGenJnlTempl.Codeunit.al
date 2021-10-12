#if not CLEAN18
#pragma warning disable AL0432, AL0603
codeunit 31306 "Sync.Dep.Fld-GenJnlTempl CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Template", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertGLAccount(var Rec: Record "Gen. Journal Template")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Template", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyGLAccount(var Rec: Record "Gen. Journal Template")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Gen. Journal Template")
    var
        PreviousRecord: Record "Gen. Journal Template";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Not Check Doc. Type", Rec."Not Check Doc. Type CZL", PreviousRecord."Not Check Doc. Type", PreviousRecord."Not Check Doc. Type CZL");
    end;
}
#endif
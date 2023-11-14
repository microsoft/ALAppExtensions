#if not CLEAN22
#pragma warning disable AL0432
codeunit 31287 "Sync.Dep.Fld-Service Header CZ"
{
    Access = Internal;
    Permissions = tabledata "Service Header" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertServiceHeader(var Rec: Record "Service Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyServiceHeader(var Rec: Record "Service Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Service Header")
    var
        PreviousRecord: Record "Service Header";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        SyncDepFldUtilities.SyncFields(Rec."Physical Transfer CZL", Rec."Physical Transfer CZ", PreviousRecord."Physical Transfer CZL", PreviousRecord."Physical Transfer CZ");
        SyncDepFldUtilities.SyncFields(Rec."Intrastat Exclude CZL", Rec."Intrastat Exclude CZ", PreviousRecord."Intrastat Exclude CZL", PreviousRecord."Intrastat Exclude CZ");
    end;
}
#endif
#if not CLEAN22
#pragma warning disable AL0432
codeunit 31491 "Sync.Dep.Fld-TransferHeader CZ"
{
    Access = Internal;
    Permissions = tabledata "Transfer Header" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertTransferHeader(var Rec: Record "Transfer Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyTransferHeader(var Rec: Record "Transfer Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Transfer Header")
    var
        PreviousRecord: Record "Transfer Header";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        SyncDepFldUtilities.SyncFields(Rec."Intrastat Exclude CZL", Rec."Intrastat Exclude CZ", PreviousRecord."Intrastat Exclude CZL", PreviousRecord."Intrastat Exclude CZ");
    end;
}
#endif
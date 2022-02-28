#if not CLEAN20
#pragma warning disable AL0432, AA0072
codeunit 31426 "Sync.Dep.Fld-ItemEntryRel. CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Item Entry Relation", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertGLEntry(var Rec: Record "Item Entry Relation")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Entry Relation", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyGLEntry(var Rec: Record "Item Entry Relation")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Item Entry Relation")
    var
        PreviousRecord: Record "Item Entry Relation";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec.Undo, Rec."Undo CZA", PreviousRecord.Undo, PreviousRecord."Undo CZA");
    end;
}
#endif

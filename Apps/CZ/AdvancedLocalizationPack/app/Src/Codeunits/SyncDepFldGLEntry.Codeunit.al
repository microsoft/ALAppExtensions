#if not CLEAN19
#pragma warning disable AL0432, AA0072
codeunit 31375 "Sync.Dep.Fld-GLEntry CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertGLEntry(var Rec: Record "G/L Entry")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyGLEntry(var Rec: Record "G/L Entry")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "G/L Entry")
    var
        PreviousRecord: Record "G/L Entry";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec.Closed, Rec."Closed CZA", PreviousRecord.Closed, PreviousRecord."Closed CZA");
        SyncDepFldUtilities.SyncFields(Rec."Closed at Date", Rec."Closed at Date CZA", PreviousRecord."Closed at Date", PreviousRecord."Closed at Date CZA");
        SyncDepFldUtilities.SyncFields(Rec."Applied Amount", Rec."Applied Amount CZA", PreviousRecord."Applied Amount", PreviousRecord."Applied Amount CZA");
    end;
}
#endif
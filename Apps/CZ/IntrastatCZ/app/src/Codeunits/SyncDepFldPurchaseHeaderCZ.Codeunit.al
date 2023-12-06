#if not CLEAN22
#pragma warning disable AL0432
codeunit 31283 "Sync.Dep.Fld-PurchaseHeader CZ"
{
    Access = Internal;
    Permissions = tabledata "Purchase Header" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertPurchaseHeader(var Rec: Record "Purchase Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyPurchaseHeader(var Rec: Record "Purchase Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Purchase Header")
    var
        PreviousRecord: Record "Purchase Header";
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
#if not CLEAN22
#pragma warning disable AL0432
codeunit 31291 "Sync.Dep.Fld-ItemCharge CZ"
{
    Access = Internal;
    Permissions = tabledata "Item Charge" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertItemCharge(var Rec: Record "Item Charge")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyItemCharge(var Rec: Record "Item Charge")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Item Charge")
    var
        PreviousRecord: Record "Item Charge";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        SyncDepFldUtilities.SyncFields(Rec."Incl. in Intrastat Amount CZL", Rec."Incl. in Intrastat Amount CZ", PreviousRecord."Incl. in Intrastat Amount CZL", PreviousRecord."Incl. in Intrastat Amount CZ");
    end;
}
#endif
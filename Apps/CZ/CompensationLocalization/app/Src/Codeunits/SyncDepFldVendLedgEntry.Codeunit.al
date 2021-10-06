#if not CLEAN18
#pragma warning disable AL0432, AA0072
codeunit 31289 "Sync.Dep.Fld-VendLedgEntry CZC"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertVendorLedgerEntry(var Rec: Record "Vendor Ledger Entry")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyVendorLedgerEntry(var Rec: Record "Vendor Ledger Entry")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Vendor Ledger Entry")
    var
        PreviousRecord: Record "Vendor Ledger Entry";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec.Compensation, Rec."Compensation CZC", PreviousRecord.Compensation, PreviousRecord."Compensation CZC");
    end;
}
#endif
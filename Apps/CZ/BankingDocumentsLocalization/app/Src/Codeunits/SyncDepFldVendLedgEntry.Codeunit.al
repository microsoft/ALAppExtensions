#if not CLEAN19
#pragma warning disable AL0432
codeunit 31338 "Sync.Dep.Fld-VendLedgEntry CZB"
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

    local procedure SyncDeprecatedFields(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        PreviousVendorLedgerEntry: Record "Vendor Ledger Entry";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(VendorLedgerEntry, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousVendorLedgerEntry);

        SyncDepFldUtilities.SyncFields(VendorLedgerEntry."Amount on Payment Order (LCY)", VendorLedgerEntry."Amount on Pmt. Order (LCY) CZB", PreviousVendorLedgerEntry."Amount on Payment Order (LCY)", PreviousVendorLedgerEntry."Amount on Pmt. Order (LCY) CZB");
    end;
}
#endif

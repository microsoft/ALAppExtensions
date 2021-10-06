#if not CLEAN19
#pragma warning disable AL0432
codeunit 31337 "Sync.Dep.Fld-CustLedgEntry CZB"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertCustLedgerEntry(var Rec: Record "Cust. Ledger Entry")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyCustLedgerEntry(var Rec: Record "Cust. Ledger Entry")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        PreviousCustLedgerEntry: Record "Cust. Ledger Entry";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(CustLedgerEntry, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousCustLedgerEntry);

        SyncDepFldUtilities.SyncFields(CustLedgerEntry."Amount on Payment Order (LCY)", CustLedgerEntry."Amount on Pmt. Order (LCY) CZB", PreviousCustLedgerEntry."Amount on Payment Order (LCY)", PreviousCustLedgerEntry."Amount on Pmt. Order (LCY) CZB");
    end;
}
#endif

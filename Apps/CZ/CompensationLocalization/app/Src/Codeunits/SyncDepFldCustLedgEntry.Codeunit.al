#if not CLEAN18
#pragma warning disable AL0432, AA0072
codeunit 31288 "Sync.Dep.Fld-CustLedgEntry CZC"
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

    local procedure SyncDeprecatedFields(var Rec: Record "Cust. Ledger Entry")
    var
        PreviousRecord: Record "Cust. Ledger Entry";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec.Compensation, Rec."Compensation CZC", PreviousRecord.Compensation, PreviousRecord."Compensation CZC");
    end;
}
#endif
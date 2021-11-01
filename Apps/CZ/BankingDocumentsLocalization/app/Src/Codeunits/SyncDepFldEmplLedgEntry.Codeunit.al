#if not CLEAN19
#pragma warning disable AL0432
codeunit 31339 "Sync.Dep.Fld-EmplLedgEntry CZB"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Employee Ledger Entry", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertEmployeeLedgerEntry(var Rec: Record "Employee Ledger Entry")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Employee Ledger Entry", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyEmployeeLedgerEntry(var Rec: Record "Employee Ledger Entry")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var EmployeeLedgerEntry: Record "Employee Ledger Entry")
    var
        PreviousEmployeeLedgerEntry: Record "Employee Ledger Entry";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(EmployeeLedgerEntry, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousEmployeeLedgerEntry);

        SyncDepFldUtilities.SyncFields(EmployeeLedgerEntry."Amount on Payment Order (LCY)", EmployeeLedgerEntry."Amount on Pmt. Order (LCY) CZB", PreviousEmployeeLedgerEntry."Amount on Payment Order (LCY)", PreviousEmployeeLedgerEntry."Amount on Pmt. Order (LCY) CZB");
    end;
}
#endif

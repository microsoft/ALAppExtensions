#if not CLEAN19
#pragma warning disable AL0432
codeunit 31387 "Sync.Dep.Fld-BankAccRecon CZB"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Bank Acc. Reconciliation", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertBankAccReconciliation(var Rec: Record "Bank Acc. Reconciliation")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Acc. Reconciliation", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyBankAccReconciliation(var Rec: Record "Bank Acc. Reconciliation")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var BankAccReconciliation: Record "Bank Acc. Reconciliation")
    var
        PreviousBankAccReconciliation: Record "Bank Acc. Reconciliation";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(BankAccReconciliation, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousBankAccReconciliation);

        SyncDepFldUtilities.SyncFields(BankAccReconciliation."Created From Iss. Bank Stat.", BankAccReconciliation."Created From Bank Stat. CZB", PreviousBankAccReconciliation."Created From Iss. Bank Stat.", PreviousBankAccReconciliation."Created From Bank Stat. CZB");
    end;
}
#endif

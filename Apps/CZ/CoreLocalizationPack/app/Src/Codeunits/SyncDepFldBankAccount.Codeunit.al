#if not CLEAN18
#pragma warning disable AL0432
codeunit 31200 "Sync.Dep.Fld-BankAccount CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertBankAccount(var Rec: Record "Bank Account")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyBankAccount(var Rec: Record "Bank Account")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Bank Account")
    var
        PreviousRecord: Record "Bank Account";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Exclude from Exch. Rate Adj.", Rec."Excl. from Exch. Rate Adj. CZL", PreviousRecord."Exclude from Exch. Rate Adj.", PreviousRecord."Excl. from Exch. Rate Adj. CZL");
    end;
}
#endif
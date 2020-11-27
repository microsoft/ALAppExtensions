#pragma warning disable AL0432,AL0603
codeunit 31123 "Sync.Dep.Fld-BankAccount CZP"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

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
        DepFieldInt, NewFieldInt : Integer;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldInt := Rec."Account Type";
        NewFieldInt := Rec."Account Type CZP".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."Account Type", PreviousRecord."Account Type CZP");
        Rec."Account Type" := DepFieldInt;
        Rec."Account Type CZP" := NewFieldInt;
    end;

}

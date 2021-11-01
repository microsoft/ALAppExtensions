#if not CLEAN17
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

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk CZP", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCashDeskCZP(var Rec: Record "Cash Desk CZP"; var xRec: Record "Cash Desk CZP")
    var
        BankAccount: Record "Bank Account";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Bank Account");
        BankAccount.ChangeCompany(Rec.CurrentCompany);
        if BankAccount.Get(xRec."No.") then
            BankAccount.Rename(Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Bank Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk CZP", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCashDeskCZP(var Rec: Record "Cash Desk CZP")
    begin
        SyncCashDeskCZP(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk CZP", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCashDeskCZP(var Rec: Record "Cash Desk CZP")
    begin
        SyncCashDeskCZP(Rec);
    end;

    local procedure SyncCashDeskCZP(var Rec: Record "Cash Desk CZP")
    var
        BankAccount: Record "Bank Account";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Bank Account");
        BankAccount.ChangeCompany(Rec.CurrentCompany);
        if not BankAccount.Get(Rec."No.") then begin
            BankAccount.Init();
            BankAccount."No." := Rec."No.";
            BankAccount.SystemId := Rec.SystemId;
            BankAccount.Insert(false, true);
        end;
        BankAccount."Account Type CZP" := BankAccount."Account Type CZP"::"Cash Desk";
        BankAccount.Name := Rec.Name;
        BankAccount."Search Name" := Rec."Search Name";
        BankAccount."Name 2" := Rec."Name 2";
        BankAccount.Address := Rec.Address;
        BankAccount."Address 2" := Rec."Address 2";
        BankAccount.City := Rec.City;
        BankAccount.Contact := Rec.Contact;
        BankAccount."Phone No." := Rec."Phone No.";
        BankAccount."Global Dimension 1 Code" := Rec."Global Dimension 1 Code";
        BankAccount."Global Dimension 2 Code" := Rec."Global Dimension 2 Code";
        BankAccount."Bank Acc. Posting Group" := Rec."Bank Acc. Posting Group";
        BankAccount."Currency Code" := Rec."Currency Code";
        BankAccount."Language Code" := Rec."Language Code";
        BankAccount."Country/Region Code" := Rec."Country/Region Code";
        BankAccount."Post Code" := Rec."Post Code";
        BankAccount.County := Rec.County;
        BankAccount."E-Mail" := Rec."E-Mail";
        BankAccount.Blocked := Rec.Blocked;
        BankAccount."No. Series" := Rec."No. Series";
        BankAccount."Min. Balance" := Rec."Min. Balance";
        BankAccount."Min. Balance Checking" := Rec."Min. Balance Checking";
        BankAccount."Max. Balance" := Rec."Max. Balance";
        BankAccount."Max. Balance Checking" := Rec."Max. Balance Checking";
        BankAccount."Allow VAT Difference" := Rec."Allow VAT Difference";
        BankAccount."Payed To/By Checking" := Rec."Payed To/By Checking";
        BankAccount."Reason Code" := Rec."Reason Code";
        BankAccount."Amounts Including VAT" := Rec."Amounts Including VAT";
        BankAccount."Confirm Inserting of Document" := Rec."Confirm Inserting of Document";
        BankAccount."Debit Rounding Account" := Rec."Debit Rounding Account";
        BankAccount."Credit Rounding Account" := Rec."Credit Rounding Account";
        BankAccount."Rounding Method Code" := Rec."Rounding Method Code";
        BankAccount."Responsibility ID (Release)" := Rec."Responsibility ID (Release)";
        BankAccount."Responsibility ID (Post)" := Rec."Responsibility ID (Post)";
        BankAccount."Responsibility Center" := Rec."Responsibility Center";
        BankAccount."Amount Rounding Precision" := Rec."Amount Rounding Precision";
        BankAccount."Cash Document Receipt Nos." := Rec."Cash Document Receipt Nos.";
        BankAccount."Cash Document Withdrawal Nos." := Rec."Cash Document Withdrawal Nos.";
        BankAccount."Cash Receipt Limit" := Rec."Cash Receipt Limit";
        BankAccount."Cash Withdrawal Limit" := Rec."Cash Withdrawal Limit";
        BankAccount."Exclude from Exch. Rate Adj." := Rec."Exclude from Exch. Rate Adj.";
        BankAccount."Cashier No." := Rec."Cashier No.";
        BankAccount.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Bank Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk CZP", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCashDeskCZP(var Rec: Record "Cash Desk CZP")
    var
        BankAccount: Record "Bank Account";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Bank Account");
        BankAccount.ChangeCompany(Rec.CurrentCompany);
        if BankAccount.Get(Rec."No.") then
            BankAccount.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Bank Account");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif
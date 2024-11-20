codeunit 14626 "Create Gen. Journal Line IS"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        UpdateGenJournalLine();
        UpdateBankAccReconciliationLine();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertGenJournalLine(var Rec: Record "Gen. Journal Line")
    var
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateBankJnlBatch: Codeunit "Create Bank Jnl. Batches";
    begin
        if (Rec."Journal Template Name" = CreateGenJournalTemplate.General()) and (Rec."Journal Batch Name" = CreateBankJnlBatch.Daily()) then
            case Rec."Line No." of
                10000:
                    Rec.Validate(Amount, -178919.2);
                20000:
                    Rec.Validate(Amount, -268378.8);
                30000:
                    Rec.Validate(Amount, -357838.4);
                40000:
                    Rec.Validate(Amount, -357838.4);
            end;
    end;

    local procedure UpdateGenJournalLine()
    var
        GenJournalLine: Record "Gen. Journal Line";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateBankJnlBatch: Codeunit "Create Bank Jnl. Batches";
    begin
        GenJournalLine.Get(CreateGenJournalTemplate.General(), CreateBankJnlBatch.Daily(), 10000);
        if GenJournalLine."Account No." = '' then begin
            GenJournalLine.Validate(Amount, 0);
            GenJournalLine.Modify(true);
        end;
    end;

    local procedure UpdateBankAccReconciliationLine()
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        BankAccount: Record "Bank Account";
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        BankAccount.Get(CreateBankAccount.Checking());

        BankAccReconciliationLine.Get(BankAccReconciliationLine."Statement Type"::"Bank Reconciliation", BankAccount."No.", BankAccount."Last Statement No.", 30000);
        BankAccReconciliationLine.Validate("Transaction Text", DepositToAccountLbl);
        BankAccReconciliationLine.Validate(Description, CopyStr(BankAccReconciliationLine."Transaction Text", 1, MaxStrLen(BankAccReconciliationLine.Description)));
        BankAccReconciliationLine.Modify(true);
    end;

    var
        DepositToAccountLbl: Label 'Deposit to Account 18.01.24', MaxLength = 100;
}
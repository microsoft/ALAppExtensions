codeunit 11529 "Create Gen. Journal Batch NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        UpdateGenJournalBatch();
    end;

    local procedure UpdateGenJournalBatch()
    var
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateGenJournalBatch: Codeunit "Create Gen. Journal Batch";
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
    begin
        ValidateRecordFields(CreateGenJournalTemplate.General(), CreateGenJournalBatch.Monthly(), CreateNLGLAccounts.PettyCash());
        ValidateRecordFields(CreateGenJournalTemplate.CashReceipts(), CreateGenJournalBatch.General(), CreateNLGLAccounts.PettyCash());
        ValidateRecordFields(CreateGenJournalTemplate.PaymentJournal(), CreateGenJournalBatch.Cash(), CreateNLGLAccounts.PettyCash());
        ValidateRecordFields(CreateGenJournalTemplate.PaymentJournal(), CreateGenJournalBatch.General(), CreateNLGLAccounts.PettyCash());
    end;

    local procedure ValidateRecordFields(JournalTemplateName: Code[10]; BatchName: Code[10]; BalAccountNo: Code[20])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.Get(JournalTemplateName, BatchName);
        GenJournalBatch.Validate("Bal. Account No.", BalAccountNo);
        GenJournalBatch.Modify(true);
    end;
}
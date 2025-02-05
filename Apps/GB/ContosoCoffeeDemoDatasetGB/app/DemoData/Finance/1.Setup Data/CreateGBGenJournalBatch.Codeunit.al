codeunit 11488 "Create GB Gen. Journal Batch"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        UpdateGenJournalBatch();
    end;

    local procedure UpdateGenJournalBatch()
    var
        CreateGBGLAccounts: Codeunit "Create GB GL Accounts";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateGenJournalBatch: Codeunit "Create Gen. Journal Batch";
    begin
        ValidateRecordFields(CreateGenJournalTemplate.General(), CreateGenJournalBatch.Monthly(), CreateGBGLAccounts.BusinessAccountOperatingDomestic());
        ValidateRecordFields(CreateGenJournalTemplate.CashReceipts(), CreateGenJournalBatch.General(), CreateGBGLAccounts.BusinessAccountOperatingDomestic());
        ValidateRecordFields(CreateGenJournalTemplate.PaymentJournal(), CreateGenJournalBatch.Cash(), CreateGBGLAccounts.BusinessAccountOperatingDomestic());
        ValidateRecordFields(CreateGenJournalTemplate.PaymentJournal(), CreateGenJournalBatch.General(), CreateGBGLAccounts.BusinessAccountOperatingDomestic());
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
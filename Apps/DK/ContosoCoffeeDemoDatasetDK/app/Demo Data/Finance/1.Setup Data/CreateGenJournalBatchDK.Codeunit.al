codeunit 13717 "Create Gen. Journal Batch DK"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure UpdateGenJournalBatch()
    var
        CreateGLAccountDK: Codeunit "Create GL Acc. DK";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateGenJournalBatch: Codeunit "Create Gen. Journal Batch";
    begin
        ValidateRecordFields(CreateGenJournalTemplate.General(), CreateGenJournalBatch.Monthly(), CreateGLAccountDK.Checkout());
        ValidateRecordFields(CreateGenJournalTemplate.CashReceipts(), CreateGenJournalBatch.General(), CreateGLAccountDK.Checkout());
        ValidateRecordFields(CreateGenJournalTemplate.PaymentJournal(), CreateGenJournalBatch.Cash(), CreateGLAccountDK.Checkout());
        ValidateRecordFields(CreateGenJournalTemplate.PaymentJournal(), CreateGenJournalBatch.General(), CreateGLAccountDK.Checkout());
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
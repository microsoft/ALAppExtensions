// codeunit 13425 "Create Gen. Journal Batch FI"
// {
//     InherentEntitlements = X;
//     InherentPermissions = X;
//     trigger OnRun()
//     begin
//         UpdateGenJournalBatch();
//     end;

//     local procedure UpdateGenJournalBatch()
//     var
//         CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
//         CreateGenJournalBatch: Codeunit "Create Gen. Journal Batch";
//         CreateGLAccount: Codeunit "Create G/L Account";
//     begin
//         ValidateRecordFields(CreateGenJournalTemplate.General(), CreateGenJournalBatch.Monthly(), CreateGLAccount.Cash());
//         ValidateRecordFields(CreateGenJournalTemplate.CashReceipts(), CreateGenJournalBatch.General(), CreateGLAccount.Cash());
//         ValidateRecordFields(CreateGenJournalTemplate.PaymentJournal(), CreateGenJournalBatch.Cash(), CreateGLAccount.Cash());
//         ValidateRecordFields(CreateGenJournalTemplate.PaymentJournal(), CreateGenJournalBatch.General(), CreateGLAccount.Cash());
//     end;

//     local procedure ValidateRecordFields(JournalTemplateName: Code[10]; BatchName: Code[10]; BalAccountNo: Code[20])
//     var
//         GenJournalBatch: Record "Gen. Journal Batch";
//     begin
//         GenJournalBatch.Get(JournalTemplateName, BatchName);
//         GenJournalBatch.Validate("Bal. Account No.", BalAccountNo);
//         GenJournalBatch.Modify(true);
//     end;
// }

codeunit 5422 "Create Payment Reg. Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoBank: Codeunit "Contoso Bank";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateBankJnlBatch: Codeunit "Create Bank Jnl. Batches";
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        ContosoBank.InsertPaymentRegistrationSetup('', CreateGenJournalTemplate.PaymentJournal(), CreateBankJnlBatch.PaymentReconciliation(), 2, CreateBankAccount.Checking(), true, true);
    end;
}
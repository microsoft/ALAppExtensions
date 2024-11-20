codeunit 5665 "Create Bank Jnl. Batches"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateNoSeries: Codeunit "Create No. Series";
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJournalTemplate.General(), Daily(), DailyLbl, Enum::"Gen. Journal Account Type"::"Bank Account", CreateBankAccount.Checking(), '', false);
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJournalTemplate.PaymentJournal(), PaymentReconciliation(), PaymentReconciliationLbl, Enum::"Gen. Journal Account Type"::"Bank Account", CreateBankAccount.Checking(), CreateNoSeries.PaymentJournal(), true);
    end;

    procedure Daily(): Code[10]
    begin
        exit(DailyTok);
    end;

    procedure PaymentReconciliation(): Code[10]
    begin
        exit(PaymentReconciliationTok);
    end;

    var
        DailyTok: Label 'DAILY', MaxLength = 10;
        PaymentReconciliationTok: Label 'PMT REG', MaxLength = 10;
        DailyLbl: Label 'Daily Journal Entries', MaxLength = 100;
        PaymentReconciliationLbl: Label 'Bank Reconciliation', MaxLength = 100;
}
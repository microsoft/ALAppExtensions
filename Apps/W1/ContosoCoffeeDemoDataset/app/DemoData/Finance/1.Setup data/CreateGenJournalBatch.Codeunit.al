codeunit 5246 "Create Gen. Journal Batch"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateNoSeries: Codeunit "Create No. Series";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJournalTemplate.General(), Monthly(), MonthlyLbl, Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash(), CreateNoSeries.GeneralJournal(), false);
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJournalTemplate.General(), Default(), DefaultLbl, Enum::"Gen. Journal Account Type"::"G/L Account", '', '', false);

        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJournalTemplate.CashReceipts(), General(), GeneralLbl, Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash(), CreateNoSeries.CashReceiptsJournal(), false);

        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJournalTemplate.InterCompanyGenJnl(), Default(), DefaultLbl, Enum::"Gen. Journal Account Type"::"G/L Account", '', CreateNoSeries.InterCompanyGenJnl(), false);

        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJournalTemplate.PaymentJournal(), General(), GeneralLbl, Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash(), CreateNoSeries.PaymentJournal(), false);
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJournalTemplate.PaymentJournal(), Cash(), CashLbl, Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash(), CreateNoSeries.PaymentJournal(), false);
    end;

    procedure Default(): Code[10]
    begin
        exit(DefaultTok);
    end;

    procedure General(): Code[10]
    begin
        exit(GeneralTok);
    end;

    procedure Monthly(): Code[10]
    begin
        exit(MonthlyTok);
    end;

    procedure Cash(): Code[10]
    begin
        exit(CashTok);
    end;

    var
        MonthlyTok: Label 'MONTHLY', MaxLength = 10;
        DefaultTok: Label 'DEFAULT', MaxLength = 10;
        GeneralTok: Label 'GENERAL', MaxLength = 10;
        CashTok: Label 'CASH', MaxLength = 10;
        GeneralLbl: Label 'GENERAL', MaxLength = 100;
        DefaultLbl: Label 'Default Journal Batch', MaxLength = 100;
        MonthlyLbl: Label 'Monthly Journal Entries', MaxLength = 100;
        CashLbl: Label 'Cash receipts and payments', MaxLength = 100;
}
codeunit 5419 "Create Gen. Journal Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        ContosoGeneralLedger.InsertGeneralJournalTemplate(CashReceipts(), CashReceiptsLbl, Enum::"Gen. Journal Template Type"::"Cash Receipts", Page::"Cash Receipt Journal", CreateNoSeries.CashReceiptsJournal(), false);
        ContosoGeneralLedger.InsertGeneralJournalTemplate(General(), GeneralLbl, Enum::"Gen. Journal Template Type"::General, Page::"General Journal", CreateNoSeries.GeneralJournal(), true);
        ContosoGeneralLedger.InsertGeneralJournalTemplate(InterCompanyGenJnl(), IntercompanyLbl, Enum::"Gen. Journal Template Type"::Intercompany, Page::"IC General Journal", CreateNoSeries.InterCompanyGenJnl(), false);
        ContosoGeneralLedger.InsertGeneralJournalTemplate(PaymentJournal(), PaymentsLbl, Enum::"Gen. Journal Template Type"::Payments, Page::"Payment Journal", CreateNoSeries.PaymentJournal(), false);
    end;

    procedure CashReceipts(): Code[10]
    begin
        exit(CashReceiptsTok);
    end;

    procedure General(): Code[10]
    begin
        exit(GeneralTok);
    end;

    procedure InterCompanyGenJnl(): Code[10]
    begin
        exit(IntercompanyTok);
    end;

    procedure PaymentJournal(): Code[10]
    begin
        exit(PaymentsTok);
    end;

    var
        CashReceiptsLbl: Label 'Cash receipts', MaxLength = 80;
        GeneralLbl: Label 'GENERAL', MaxLength = 80;
        IntercompanyLbl: Label 'Intercompany', MaxLength = 80;
        PaymentsLbl: Label 'Payments', MaxLength = 80;
        CashReceiptsTok: Label 'CASHRCPT', MaxLength = 10;
        GeneralTok: Label 'GENERAL', MaxLength = 10;
        IntercompanyTok: Label 'INTERCOMP', MaxLength = 10;
        PaymentsTok: Label 'PAYMENT', MaxLength = 10;
}
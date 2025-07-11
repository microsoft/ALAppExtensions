codeunit 18926 "TCS Journal - Library"
{
    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryTCS: Codeunit "TCS - Library";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;

    procedure CreateGenJournalTemplateBatch(
        var GenJournalTemplate: Record "Gen. Journal Template";
        var GenJournalBatch: Record "Gen. Journal Batch";
        VoucherType: Enum "Gen. Journal Template Type")
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, VoucherType);
        GenJournalTemplate.Modify(true);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    procedure CreateGenJnlLineFromCustToGLForPaymentWithFCY(
        var GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        TCSNOC: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
        Currency: Record Currency;
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, VoucherType);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"G/L Account", GLAccount."No.",
            -LibraryRandom.RandDecInRange(100000, 200000, 2));
        LibraryTCS.CreateCurrencyAndExchangeRate(Currency);
        GenJournalLine.Validate("Currency Code", Currency.Code);
        GenJournalLine.Validate("TCS Nature of Collection", TCSNOC);
        CalculateTCS(GenJournalLine);
        GenJournalLine.Modify(true);
    end;

    procedure CreateGenJnlLineFromCustToGLForPayment(
        var GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        TCSNOC: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, VoucherType);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"G/L Account", GLAccount."No.",
            -LibraryRandom.RandDecInRange(100000, 200000, 2));
        GenJournalLine.Validate("TCS Nature of Collection", TCSNOC);
        CalculateTCS(GenJournalLine);
        GenJournalLine.Modify(true);
    end;

    procedure CreateGenJnlLineFromCustToGLForInvoiceWithFCY(
        var GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        TCSNOC: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
        Currency: Record Currency;
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, VoucherType);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"G/L Account", GLAccount."No.",
            LibraryRandom.RandDecInRange(100000, 200000, 2));
        LibraryTCS.CreateCurrencyAndExchangeRate(Currency);
        GenJournalLine.Validate("Currency Code", Currency.Code);
        GenJournalLine.Validate("TCS Nature of Collection", TCSNOC);
        CalculateTCS(GenJournalLine);
        GenJournalLine.Modify(true);
    end;

    procedure CreateGenJnlLineFromCustToGLForInvoice(
        var GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        TCSNOC: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, VoucherType);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"G/L Account", GLAccount."No.",
            LibraryRandom.RandDecInRange(100000, 200000, 2));
        GenJournalLine.Validate("TCS Nature of Collection", TCSNOC);
        CalculateTCS(GenJournalLine);
        GenJournalLine.Modify(true);
    end;

    procedure CalculateTCS(GenJnlLine: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnGenJnlLine(GenJnlLine, GenJnlLine)
    end;

    procedure CreateGenJnlLineFromCustToGLForInvoiceWithoutTemplateAndBatch(
        var GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        TCSNOC: Code[10];
        JournalTemplateName: Code[10];
        JournalBtatchName: Code[10])
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, JournalTemplateName, JournalBtatchName,
            GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"G/L Account", GLAccount."No.",
            LibraryRandom.RandDecInRange(100000, 200000, 2));
        GenJournalLine.Validate("TCS Nature of Collection", TCSNOC);
        CalculateTCS(GenJournalLine);
        GenJournalLine.Modify(true);
    end;

    procedure VerifyJournalGLEntryCount(JnlBatchName: Code[10]; ExpectedCount: Integer): Code[20]
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Journal Batch Name", JnlBatchName);
        GLEntry.FindFirst();
        Assert.RecordCount(GLEntry, ExpectedCount);
        exit(GLEntry."Document No.");
    end;

    procedure FindStartDateOnAccountingPeriod(): Date
    var
        TCSSetup: Record "TCS Setup";
        TaxType: Record "Tax Type";
        AccountingPeriod: Record "Tax Accounting Period";
    begin
        TCSSetup.Get();
        TaxType.Get(TCSSetup."Tax Type");
        AccountingPeriod.SetCurrentKey("Tax Type Code");
        AccountingPeriod.SetRange("Tax Type Code", TaxType."Accounting Period");
        AccountingPeriod.SetRange(Closed, false);
        AccountingPeriod.Ascending(true);
        if AccountingPeriod.FindFirst() then
            exit(AccountingPeriod."Starting Date");
    end;
}
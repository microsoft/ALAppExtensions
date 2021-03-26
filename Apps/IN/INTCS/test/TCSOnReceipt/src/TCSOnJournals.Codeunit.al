codeunit 18928 "TCS On Journals"
{
    Subtype = Test;

    var
        LibraryTCS: Codeunit "TCS - Library";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        TCSJnlLibrary: Codeunit "TCS Journal - Library";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryRandom: Codeunit "Library - Random";
        Storage: Dictionary of [Text, Text];
        VerificationLbl: Label 'TCS not paid', Locked = true;
        EffectiveDateLbl: Label 'EffectiveDate', locked = true;
        TCSNOCTypeLbl: Label 'TCSNOCType', locked = true;
        TCSAssesseeCodeLbl: Label 'TCSAssesseeCode', locked = true;
        TCSConcessionalCodeLbl: Label 'TCSConcessionalCode', locked = true;
        TCSPercentageLbl: Label 'TCSPercentage', locked = true;
        NonPANTCSPercentageLbl: Label 'NonPANTCSPercentage', locked = true;
        SurchargePercentageLbl: Label 'SurchargePercentage', locked = true;
        ECessPercentageLbl: Label 'ECessPercentage', Locked = true;
        SHECessPercentageLbl: Label 'SHECessPercentage', locked = true;
        TCSThresholdAmountLbl: Label 'TCSThresholdAmount', locked = true;
        SurchargeThresholdAmountLbl: Label 'SurchargeThresholdAmount', locked = true;
        TCSPayErr: Label 'There are no TCS entries for Account No. %1.', Comment = '%1= G/L Account No.';
        AmountErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = TCS Amount and TCS field Caption';


    // [SCENARIO] [354362] Check if the program is calculating TCS in case an invoice is raised to the customer using General Journal
    // [SCENARIO] [354500] Check if the program is calculating TCS in case an invoice is raised to the customer using Sales Journal
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalTCS()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        TaxTransactionValue: Record "Tax Transaction Value";
        TemplateType: Enum "Gen. Journal Template Type";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create General Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForInvoice(GenJournalLine, Customer."No.", TemplateType::General, TCSPostingSetup."TCS Nature of Collection");

        // [THEN] Verify TCS Entry and Post General Journal
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetRange("Tax Record ID", GenJournalLine.RecordId);
        Assert.RecordIsNotEmpty(TaxTransactionValue);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    // [SCENARIO] [354428] -Check if the program is calculating TCS using General Journal with concessional codes.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalTCSWithConssionalCode()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        TemplateType: Enum "Gen. Journal Template Type";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create General Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForInvoice(GenJournalLine, Customer."No.", TemplateType::General, TCSPostingSetup."TCS Nature of Collection");

        // [THEN] Verify TCS Entry and Post General Journal
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        TCSJnlLibrary.VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);
    end;

    // [SCENARIO] [354376] Check if the program is calculating TCS in case an invoice is raised to the Customer using General Journal and Threshold Overlook is not selected.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalTCSWithoutThreshholdAndSurcharge()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create General Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForInvoice(GenJournalLine, Customer."No.", TemplateType::General, TCSPostingSetup."TCS Nature of Collection");

        // [THEN] Verify TCS Entry and Post General Journal
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        DocumentNo := TCSJnlLibrary.VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);
        VerifyTCSEntry(DocumentNo, LibraryTCS.RoundTCSAmount(GenJournalLine.Amount), GenJournalLine."Currency Factor", true, false, false);
    end;

    // [SCENARIO] [354377] Check if the program is calculating TCS in General Journal with no threshold and surcharge overlook for NOD lines of a particular Customer.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalTCSWithoutThreshholdAndWithSurcharge()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create General Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForInvoice(GenJournalLine, Customer."No.", TemplateType::General, TCSPostingSetup."TCS Nature of Collection");

        // [THEN] Verify TCS Entry and Post General Journal
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        DocumentNo := TCSJnlLibrary.VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);
        VerifyTCSEntry(DocumentNo, LibraryTCS.RoundTCSAmount(GenJournalLine.Amount), GenJournalLine."Currency Factor", true, true, false);
    end;

    // [SCENARIO] [354414] Check if the program is calculating TCS in case advance payment is received from the customer using General Journal
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalTCSForAdvancePayment()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        TemplateType: Enum "Gen. Journal Template Type";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create General Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForPayment(GenJournalLine, Customer."No.", TemplateType::General, TCSPostingSetup."TCS Nature of Collection");

        // [THEN] Verify TCS Entry and Post General Journal
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        TCSJnlLibrary.VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);
    end;

    // [SCENARIO] [354378] Check if the program is calculating TCS in case advance payment is received from the customer using General Journal
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalTCSForFCY()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        TaxTransactionValue: Record "Tax Transaction Value";
        TemplateType: Enum "Gen. Journal Template Type";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create General Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForPaymentWithFCY(GenJournalLine, Customer."No.", TemplateType::General, TCSPostingSetup."TCS Nature of Collection");

        // [THEN] Verify TCS Entry and Post General Journal
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetRange("Tax Record ID", GenJournalLine.RecordId);
        Assert.RecordIsNotEmpty(TaxTransactionValue);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    // [SCENARIO] [354370] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while or receiving advance from the customer using 
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromAdvanceGeneralJournalWithTCSRoundOff()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        CustLedEntry: Record "Cust. Ledger Entry";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create General Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForPayment(GenJournalLine, Customer."No.", TemplateType::General, TCSPostingSetup."TCS Nature of Collection");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify TCS Entry and Post General Journal
        DocumentNo := TCSJnlLibrary.VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);
        CustLedEntry.SetRange("Document No.", DocumentNo);
        CustLedEntry.FindFirst();
        CustLedEntry.CalcFields(Amount);
        VerifyTCSEntry(DocumentNo, LibraryTCS.RoundTCSAmount(-CustLedEntry.Amount), GenJournalLine."Currency Factor", true, false, false);
    end;


    // [SCENARIO] [354940] Calculation of TCS in case of receiving Advance from the customer while preparing Cash receipt journal/Voucher.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromCashReceiptJournalTCSAndAdvancePayment()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        TemplateType: Enum "Gen. Journal Template Type";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Cash Receipt Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForPayment(GenJournalLine, Customer."No.", TemplateType::"Cash Receipts", TCSPostingSetup."TCS Nature of Collection");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify TCS Entry and Post General Journal
        TCSJnlLibrary.VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);
    end;

    // [SCENARIO] [354941] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while preparing Cash receipt journal/Voucher.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromCashReceiptJournalWithTCS()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        TemplateType: enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Cash Receipt Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForInvoice(GenJournalLine, Customer."No.", TemplateType::"Cash Receipts", TCSPostingSetup."TCS Nature of Collection");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify TCS Entry and Post General Journal
        DocumentNo := TCSJnlLibrary.VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);
        VerifyTCSEntry(DocumentNo, LibraryTCS.RoundTCSAmount(GenJournalLine.Amount), GenJournalLine."Currency Factor", true, true, true);
    end;

    // [SCENARIO] [354942] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while receiving advance from the customer using Cash Receipt journal Journal
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromCashReceiptJournalTCSWithAdvancePaymentAndRoundingOff()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        CustLedEntry: Record "Cust. Ledger Entry";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Cash Receipt Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForPayment(GenJournalLine, Customer."No.", TemplateType::"Cash Receipts", TCSPostingSetup."TCS Nature of Collection");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify TCS Entry with Rounding off
        DocumentNo := TCSJnlLibrary.VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);
        CustLedEntry.SetRange("Document No.", DocumentNo);
        CustLedEntry.FindFirst();
        CustLedEntry.CalcFields(Amount);
        VerifyTCSEntry(DocumentNo, LibraryTCS.RoundTCSAmount(-CustLedEntry.Amount), GenJournalLine."Currency Factor", true, true, true);
    end;

    // [SCENARIO] [355107] Check if the program is calculating TCS using Cash receipt journal/Voucher in case of Foreign Currency.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromCashReceiptJournalWithTCSAndFCY()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Cash Receipt Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForInvoiceWithFCY(GenJournalLine, Customer."No.", TemplateType::"Cash Receipts", TCSPostingSetup."TCS Nature of Collection");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify TCS Entry and Post General Journal
        DocumentNo := TCSJnlLibrary.VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);
        VerifyTCSEntry(DocumentNo, LibraryTCS.RoundTCSAmount(GenJournalLine.Amount), GenJournalLine."Currency Factor", true, true, true);
    end;

    // [SCENARIO] [355106] Check if the program is calculating TCS using  Cash receipt journal/Voucher in case of different rates for same NOC with different assessee codes
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromCashReceiptJournalWithTCSAndDifferentAssesseeCode()
    var
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        TCSPostingSetup: Record "TCS Posting Setup";
        AssesseeCode: Record "Assessee Code";
        AssesseeCode2: Record "Assessee Code";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        Customer2: Record Customer;
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateAccPeriodAndFillCompInfo();
        LibraryTCS.CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);

        //Create Tax rate with First Assessee Code
        LibraryTCS.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer);
        LibraryTCS.UpdateCustomerAssesseeAndConcessionalCode(Customer, AssesseeCode, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Cash Receipt Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForInvoice(GenJournalLine, Customer."No.", TemplateType::"Cash Receipts", TCSPostingSetup."TCS Nature of Collection");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        DocumentNo := TCSJnlLibrary.VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);

        //Create Tax rate with second Assessee Code
        LibraryTCS.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer2);
        LibraryTCS.UpdateCustomerAssesseeAndConcessionalCode(Customer2, AssesseeCode2, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer2."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Cash Receipt Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForInvoice(GenJournalLine, Customer2."No.", TemplateType::"Cash Receipts", TCSPostingSetup."TCS Nature of Collection");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        DocumentNo2 := TCSJnlLibrary.VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);

        // [THEN] Verify TCS Entry with different Assessee Code
        LibraryTCS.VerifyTCSEntryForAssesseeCode(DocumentNo, AssesseeCode.Code);
        LibraryTCS.VerifyTCSEntryForAssesseeCode(DocumentNo2, AssesseeCode2.Code);
    end;

    // [SCENARIO] [354937] Check if the system is handling Additional Reporting Currency while calculating TCS from General Journal
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromTCSGeneralJournalWithAdditionalCurrency()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        TemplateType: Enum "Gen. Journal Template Type";
    begin
        // [GIVEN] Created Setup for Additional Currency, NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.UpdateGenLedSetupForAddReportingCurrency();
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create Cash Receipt Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForPayment(GenJournalLine, Customer."No.", TemplateType::"Cash Receipts", TCSPostingSetup."TCS Nature of Collection");

        // [THEN] Verify TCS Entry and Post General Journal
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        LibraryTCS.VerifyGLEntryAdditionalCurrencyAmt(GenJournalLine."Journal Batch Name", '');
    end;

    // [SCENARIO] [354938] Check if the system is handling Additional Reporting Currency while calculating TCS from Cash receipt Journal.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromCashReceiptJournalWithTCSAndAdditionalCurrency()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        TemplateType: Enum "Gen. Journal Template Type";
    begin
        // [GIVEN] Created Setup for Additional Currency, NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.UpdateGenLedSetupForAddReportingCurrency();
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Cash Receipt Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForInvoice(GenJournalLine, Customer."No.", TemplateType::"Cash Receipts", TCSPostingSetup."TCS Nature of Collection");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify Additional Currency
        LibraryTCS.VerifyGLEntryAdditionalCurrencyAmt(GenJournalLine."Journal Batch Name", '');
    end;

    // [SCENARIO] [355105] Check if the program is calculating TCS using  Cash receipt journal/Voucher in case of different rates for same NOC with different effective dates.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromCashReceiptJournalWithTCSAndDifferentEffectiveDates()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        TemplateType: Enum "Gen. Journal Template Type";
    begin
        // [GIVEN] Created Setup for Additional Currency, NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        LibraryTCS.CreateTCSPostingSetupWithDifferentEffectiveDate(TCSPostingSetup."TCS Nature of Collection", CalcDate('<-CM>', WorkDate()), TCSPostingSetup."TCS Account No.");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create cash receipt journal for different effective date
        TCSJnlLibrary.CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType::"Cash Receipts");

        //Create and Cash Receipt Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForInvoiceWithoutTemplateAndBatch(GenJournalLine, Customer."No.", TemplateType::"Cash Receipts",
            TCSPostingSetup."TCS Nature of Collection",
            GenJournalTemplate.Name, GenJournalBatch.Name);
        GenJournalLine.Validate("Posting Date", WorkDate());
        GenJournalLine.Modify(true);

        //Create cash receipt journal for different effective date
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, CalcDate('<1D>', WorkDate()));

        //Create and post Cash Receipt Journal
        TCSJnlLibrary.CreateGenJnlLineFromCustToGLForInvoiceWithoutTemplateAndBatch(GenJournalLine, Customer."No.", TemplateType::"Cash Receipts",
            TCSPostingSetup."TCS Nature of Collection",
            GenJournalTemplate.Name, GenJournalBatch.Name);
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GL Entries verified 
        TCSJnlLibrary.VerifyJournalGLEntryCount(GenJournalBatch.Name, 5);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PayTax')]
    procedure PayTCSToGovernmentFromBankPmtVoucher()
    var
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        VoucherType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354433] Check if the program is allowing to pay TCS amount to Government Authority through Bank Payment Voucher.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup,Accounting Period and Concessional code
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Bank Payment Voucher created and posted with TCS
        CreateGenJnlLineWithTCS(GenJournalLine, Customer."No.");
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] TCS Entries created and verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");

        // [THEN] TCS Pay from Bank Payment Voucher created, Posted and verified
        CreateAndPostTCSPayment(TCSPostingSetup."TCS Account No.", VoucherType::"Bank Payment Voucher");
        Assert.IsTrue(VerifyTCSPaid(DocumentNo), VerificationLbl);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PayTax')]
    procedure PayTCSToGovernmentFromSalesjournal()
    var
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        VoucherType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354508] Check if the program is allowing to pay TCS amount to Government Authority through Sales Journal.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup,Accounting Period and Concessional code
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Sales Journal created and posted with TCS
        CreateGenJnlLineWithTCS(GenJournalLine, Customer."No.");
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] TCS Entries created and verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");

        // [THEN] TCS Pay from Sales journal Created, Posted and verified
        CreateAndPostTCSPayment(TCSPostingSetup."TCS Account No.", VoucherType::Sales);
        Assert.IsTrue(VerifyTCSPaid(DocumentNo), VerificationLbl);
    end;

    [Test]
    procedure PayTCSToGovernmentFromBankPmtVoucherWithoutTCS()
    var
        VoucherType: Enum "Gen. Journal Template Type";
        GLAccountNo: Code[20];
    begin
        // [SCENARIO] [354434] Check if the program is allowing to pay TCS amount to Government Authority through Bank Payment Voucher for which no TCS entries exist.
        // [GIVEN] GL Account
        GLAccountNo := LibraryERM.CreateGLAccountNo();

        // [WHEN] TCS Pay from Bank Payment Voucher Created
        asserterror CreateAndPostTCSPayment(GLAccountNo, VoucherType::"Bank Payment Voucher");

        // [THEN] Expected Error: No TCS Entries for Given Account
        Assert.ExpectedError(StrSubstNo(TCSPayErr, GLAccountNo));
    end;

    [Test]
    procedure PayTCSToGovernmentFromSalesJournalWithoutTCS()
    var
        VoucherType: Enum "Gen. Journal Template Type";
        GLAccountNo: Code[20];
    begin
        // [SCENARIO] [354509] Check if the program is allowing to pay TCS amount to Government Authority through Sales Journal for which no TCS entries exist.
        // [GIVEN] GL Account
        GLAccountNo := LibraryERM.CreateGLAccountNo();

        // [WHEN] TCS Pay from Sales Journal Created
        asserterror CreateAndPostTCSPayment(GLAccountNo, VoucherType::Sales);

        // [THEN] Expected Error:
        Assert.ExpectedError(StrSubstNo(TCSPayErr, GLAccountNo));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PayTax')]
    procedure PostAndPayTCSToGovernmentAndVerify()
    var
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        TCSOnJournal: Codeunit "TCS On General Journal";
        DocumentNo: Code[20];
    begin
        //[Senerio [355278] [Check if system is marking TCS entries as paid which have been paid  to government using Payment Journal]
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Concessional code
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create & Post General Journal Line
        TCSOnJournal.CreateGenJnlLineWithTCS(GenJournalLine, Customer);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        LibraryTCS.VerifyTCSEntry(DocumentNo, GenJournalLine."Document Type"::Invoice, GenJournalLine.Amount);
        CreateTCSPayment(TCSPostingSetup."TCS Account No.");
        Assert.IsTrue(VerifyTCSPaid(DocumentNo), VerificationLbl);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PayTax')]
    procedure PayTCSToGovernmentdeductedUsingPaymentJournal()
    var
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        TCSOnJournal: Codeunit "TCS On General Journal";
        DocumentNo: Code[20];
    begin
        //[Senerio [355276][Check if system is allowing to pay TCS amount to government which is already deducted using Payment Journal]
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Gen. Journal Line & Pay TDS Amount to Govt.
        TCSOnJournal.CreateGenJnlLineWithTCS(GenJournalLine, Customer);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        CreateTCSPayment(TCSPostingSetup."TCS Account No.");
    end;

    local procedure CreateTCSPayment(TCSAccount: Code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        CompanyInformation: Record "Company Information";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        PayTCS: Codeunit "Pay-TCS";
    begin
        CompanyInformation.Get();
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
        GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::"G/L Account", TCSAccount,
        GenJournalLine."Bal. Account Type"::"Bank Account", LibraryERM.CreateBankAccountNo(), 0);
        GenJournalLine.Validate("Posting Date", WorkDate());
        GenJournalLine.Validate("T.C.A.N. No.", CompanyInformation."T.C.A.N. No.");
        GenJournalLine.Modify(true);
        PayTCS.PayTCS(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateAndPostTCSPayment(TCSAccount: Code[20]; VoucherType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        CompanyInformation: Record "Company Information";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        PayTCS: Codeunit "Pay-TCS";
        BalAccountType: Enum "Gen. Journal Account Type";
        BalAccountNo: Code[20];
    begin
        CompanyInformation.Get();
        if VoucherType in [VoucherType::"Bank Payment Voucher", VoucherType::"Bank Receipt Voucher"] then begin
            BalAccountType := BalAccountType::"Bank Account";
            BalAccountNo := CreateGenJournalTemplateAndDefineVoucherAccount(GenJournalTemplate, VoucherType);
        end else
            if VoucherType in [VoucherType::"Cash Payment Voucher", VoucherType::"Bank Receipt Voucher"] then begin
                BalAccountType := BalAccountType::"G/L Account";
                BalAccountNo := CreateGenJournalTemplateAndDefineVoucherAccount(GenJournalTemplate, VoucherType);
            end
            else begin
                BalAccountType := BalAccountType::"G/L Account";
                BalAccountNo := LibraryERM.CreateGLAccountNo();
                LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
            end;
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
        GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::"G/L Account", TCSAccount,
        BalAccountType, BalAccountNo, 0);
        GenJournalLine.Validate("Posting Date", WorkDate());
        GenJournalLine.Validate("T.C.A.N. No.", CompanyInformation."T.C.A.N. No.");
        GenJournalLine.Modify(true);
        PayTCS.PayTCS(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateGenJournalTemplateAndDefineVoucherAccount(var GenJournalTemplate: Record "Gen. Journal Template"; VoucherType: Enum "Gen. Journal Template Type"): Code[20]
    var
        TaxBasePublishers: Codeunit "Tax Base Test Publishers";
        TransactionDirection: Option " ",Debit,Credit,Both;
        AccountNo: Code[20];
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, VoucherType);
        GenJournalTemplate.Modify(true);

        if VoucherType < 18000 then
            exit;

        TaxBasePublishers.InsertJournalVoucherPostingSetup(VoucherType, TransactionDirection::Credit);
        TaxBasePublishers.InsertVoucherCreditAccountNo(VoucherType, AccountNo);
        exit(AccountNo);
    end;

    local procedure VerifyTCSPaid(DocumentNo: Code[20]): Boolean
    var
        TCSEntry: Record "TCS Entry";
    begin
        TCSEntry.SetRange("Document No.", DocumentNo);
        TCSEntry.SetRange("TCS Paid", true);
        if not TCSEntry.IsEmpty then
            exit(true);
    end;

    local procedure CreateGenJnlLineWithTCS(var GenJournalLine: Record "Gen. Journal Line"; CustomerNo: code[20])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
        GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Customer, CustomerNo,
        GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNoWithDirectPosting(), LibraryRandom.RandDec(10000, 2));
        TCSJnlLibrary.CalculateTCS(GenJournalLine);
        GenJournalLine.Modify();
    end;

    local procedure CreateTaxRateSetup(TCSNOC: Code[10]; AssesseeCode: Code[10]; ConcessionalCode: Code[10]; EffectiveDate: Date)
    begin
        Storage.Set(TCSNOCTypeLbl, TCSNOC);
        Storage.Set(TCSAssesseeCodeLbl, AssesseeCode);
        Storage.Set(TCSConcessionalCodeLbl, ConcessionalCode);
        Storage.Set(EffectiveDateLbl, Format(EffectiveDate, 0, 9));
        GenerateTaxComponentsPercentage();
        CreateTaxRate();
    end;

    local procedure GenerateTaxComponentsPercentage()
    begin
        Storage.Set(TCSPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(NonPANTCSPercentageLbl, Format(LibraryRandom.RandIntInRange(6, 10)));
        Storage.Set(SurchargePercentageLbl, Format(LibraryRandom.RandIntInRange(6, 10)));
        Storage.Set(ECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SHECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(TCSThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
        Storage.Set(SurchargeThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
    end;

    local procedure CreateTaxRate()
    var
        TCSSetup: Record "TCS Setup";
        PageTaxtype: TestPage "Tax Types";
    begin
        if not TCSSetup.Get() then
            exit;
        PageTaxtype.OpenEdit();
        PageTaxtype.Filter.SetFilter(Code, TCSSetup."Tax Type");
        PageTaxtype.TaxRates.Invoke();
    end;

    local procedure VerifyTCSEntry(DocumentNo: Code[20]; TCSBaseAmount: Decimal; CurrencyFactor: Decimal;
                 WithPAN: Boolean; SurchargeOverlook: Boolean; TCSThresholdOverlook: Boolean)
    var
        TCSEntry: Record "TCS Entry";
        ExpectedTCSAmount, ExpectedSurchargeAmount, ExpectedEcessAmount, ExpectedSHEcessAmount : Decimal;
        TCSPercentage, NonPANTCSPercentage, SurchargePercentage, SurchargeThresholdAmount : Decimal;
        eCessPercentage, SHECessPercentage, TCSThresholdAmount : Decimal;
    begin
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        Evaluate(TCSPercentage, Storage.Get(TCSPercentageLbl));
        Evaluate(NonPANTCSPercentage, Storage.Get(NonPANTCSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TCSThresholdAmount, Storage.Get(TCSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        if (TCSBaseAmount < TCSThresholdAmount) and (TCSThresholdOverlook = false) then
            ExpectedTCSAmount := 0
        else
            if WithPAN then
                ExpectedTCSAmount := TCSBaseAmount * TCSPercentage / 100 / CurrencyFactor
            else
                ExpectedTCSAmount := TCSBaseAmount * NonPANTCSPercentage / 100 / CurrencyFactor;

        if (TCSBaseAmount < SurchargeThresholdAmount) and (SurchargeOverlook = false) then
            ExpectedSurchargeAmount := 0
        else
            ExpectedSurchargeAmount := ExpectedTCSAmount * SurchargePercentage / 100;
        ExpectedEcessAmount := (ExpectedTCSAmount + ExpectedSurchargeAmount) * eCessPercentage / 100;
        ExpectedSHEcessAmount := (ExpectedTCSAmount + ExpectedSurchargeAmount) * SHECessPercentage / 100;
        TCSEntry.SetRange("Document No.", DocumentNo);
        TCSEntry.FindFirst();
        Assert.AreNearlyEqual(
          TCSBaseAmount / CurrencyFactor, TCSEntry."TCS Base Amount", LibraryTCS.GetTCSRoundingPrecision(),
          StrSubstNo(AmountErr, TCSEntry.FieldName("TCS Base Amount"), TCSEntry.TableCaption()));
        if WithPAN then
            Assert.AreEqual(
                TCSPercentage, TCSEntry."TCS %",
                StrSubstNo(AmountErr, TCSEntry.FieldName("TCS %"), TCSEntry.TableCaption()))
        else
            Assert.AreEqual(
                NonPANTCSPercentage, TCSEntry."TCS %",
                StrSubstNo(AmountErr, TCSEntry.FieldName("TCS %"), TCSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedTCSAmount, TCSEntry."TCS Amount", LibraryTCS.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, TCSEntry.FieldName("TCS Amount"), TCSEntry.TableCaption()));
        Assert.AreEqual(
            SurchargePercentage, TCSEntry."Surcharge %",
            StrSubstNo(AmountErr, TCSEntry.FieldName("Surcharge %"), TCSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedSurchargeAmount, TCSEntry."Surcharge Amount", LibraryTCS.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, TCSEntry.FieldName("Surcharge Amount"), TCSEntry.TableCaption()));
        Assert.AreEqual(
            eCessPercentage, TCSEntry."eCESS %",
            StrSubstNo(AmountErr, TCSEntry.FieldName("eCESS %"), TCSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedEcessAmount, TCSEntry."eCESS Amount", LibraryTCS.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, TCSEntry.FieldName("eCESS Amount"), TCSEntry.TableCaption()));
        Assert.AreEqual(
            SHECessPercentage, TCSEntry."SHE Cess %",
            StrSubstNo(AmountErr, TCSEntry.FieldName("SHE Cess %"), TCSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedSHEcessAmount, TCSEntry."SHE Cess Amount", LibraryTCS.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, TCSEntry.FieldName("SHE Cess Amount"), TCSEntry.TableCaption()));
    end;

    [PageHandler]
    procedure PayTax(var PayTCS: TestPage "Pay TCS")
    begin
        PayTCS."&Pay".Invoke();
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates");
    var
        TCSPercentage, NonPANTCSPercentage, SurchargePercentage : Decimal;
        eCessPercentage, SHECessPercentage : Decimal;
        TCSThresholdAmount, SurchargeThresholdAmount : Decimal;
        EffectiveDate: Date;
    begin
        Evaluate(EffectiveDate, Storage.Get(EffectiveDateLbl), 9);
        Evaluate(TCSPercentage, Storage.Get(TCSPercentageLbl));
        Evaluate(NonPANTCSPercentage, Storage.Get(NonPANTCSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TCSThresholdAmount, Storage.Get(TCSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(TCSNOCTypeLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(TCSAssesseeCodeLbl));
        TaxRates.AttributeValue3.SetValue(Storage.Get(TCSConcessionalCodeLbl));
        TaxRates.AttributeValue4.SetValue(EffectiveDate);
        TaxRates.AttributeValue5.SetValue(TCSPercentage);
        TaxRates.AttributeValue6.SetValue(SurchargePercentage);
        TaxRates.AttributeValue7.SetValue(NonPANTCSPercentage);
        TaxRates.AttributeValue8.SetValue(eCessPercentage);
        TaxRates.AttributeValue9.SetValue(SHECessPercentage);
        TaxRates.AttributeValue10.SetValue(TCSThresholdAmount);
        TaxRates.AttributeValue11.SetValue(SurchargeThresholdAmount);
        TaxRates.OK().Invoke();
    end;
}
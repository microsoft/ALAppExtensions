codeunit 18914 "TCS on Sales Application"
{
    Subtype = Test;

    // [SCENARIO] [354743] Check if the program is calculating TCS  in case of creating Sales Order against an advance payment with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderForAdvancePayment()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GLDocNo: Code[20];
        DocumentNo: Code[20];
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create General Journal for payment and apply payment entry on Sales Order
        CreateGenJnlLineFromCustToGLForPayment(GenJournalLine, Customer."No.", TemplateType::General, TCSPostingSetup."TCS Nature of Collection");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        GLDocNo := VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);
        DocumentNo := CreateAndPostSalesDocumentWithApplication(Customer."No.", GLDocNo, DocumentType::Order, LineType::Resource);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    // [SCENARIO] [354744] Check if the program is calculating TCS  in case of creating Sales Order against an advance payment with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceForAdvancePayment()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GLDocNo: Code[20];
        DocumentNo: Code[20];
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create General Journal for payment and apply payment entry on Sales invoice
        CreateGenJnlLineFromCustToGLForPayment(GenJournalLine, Customer."No.", TemplateType::General, TCSPostingSetup."TCS Nature of Collection");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        GLDocNo := VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);
        DocumentNo := CreateAndPostSalesDocumentWithApplication(Customer."No.", GLDocNo, DocumentType::Invoice, LineType::Resource);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    // [SCENARIO] [354745] Check if the program is calculating TCS in case of creating Sales Order against partial advance payment with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderForPartialAdvancePayment()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GLDocNo: Code[20];
        DocumentNo: Code[20];
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create General Journal for payment and apply payment entry on Sales Order
        CreateGenJnlLineFromCustToGLForPayment(GenJournalLine, Customer."No.", TemplateType::General, TCSPostingSetup."TCS Nature of Collection");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        GLDocNo := VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);
        DocumentNo := CreateAndPostSalesDocumentWithPartialApplication(Customer."No.", GLDocNo, DocumentType::Order, LineType::Resource);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    // [SCENARIO] [354746] Check if the program is calculating TCS in case of creating Sales Invoice against partial advance payment with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceForPartialAdvancePayment()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        GLDocNo: Code[20];
        DocumentNo: Code[20];
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create General Journal for payment and apply payment entry on Sales Order
        CreateGenJnlLineFromCustToGLForPayment(GenJournalLine, Customer."No.", TemplateType::General, TCSPostingSetup."TCS Nature of Collection");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        GLDocNo := VerifyJournalGLEntryCount(GenJournalLine."Journal Batch Name", 3);
        DocumentNo := CreateAndPostSalesDocumentWithPartialApplication(Customer."No.", GLDocNo, DocumentType::Invoice, LineType::Resource);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    local procedure CreateAndPostSalesDocumentWithApplication(CustomerNo: code[20];
        GLDocNo: code[20];
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type"): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            DocumentType,
            CustomerNo,
            WorkDate(), LineType,
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        SalesLine.Validate(Amount, GetGLEntryAmounttoApply(GLDocNo));
        SalesLine.Modify(true);
        SalesHeader.Validate("Applies-to Doc. Type", SalesHeader."Applies-to Doc. Type"::Payment);
        SalesHeader.Validate("Applies-to Doc. No.", GLDocNo);
        SalesHeader.Modify(true);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        exit(DocumentNo);
    end;

    local procedure CreateAndPostSalesDocumentWithPartialApplication(CustomerNo: code[20];
        GLDocNo: code[20];
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type"): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            DocumentType,
            CustomerNo,
            WorkDate(), LineType,
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        SalesLine.Validate(Amount, LibraryRandom.RandDecInRange(1000, 2000, 2));
        SalesLine.Modify(true);
        SalesHeader.Validate("Applies-to Doc. Type", SalesHeader."Applies-to Doc. Type"::Payment);
        SalesHeader.Validate("Applies-to Doc. No.", GLDocNo);
        SalesHeader.Modify(true);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        exit(DocumentNo);
    end;

    local procedure GetGLEntryAmounttoApply(DocNo: code[20]): Decimal
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document No.", DocNo);
        GLEntry.SetRange("Bal. Account Type", GLEntry."Bal. Account Type"::Customer);
        GLEntry.FindFirst();
        exit(-GLEntry.Amount);
    end;

    local procedure CreateTaxRate()
    var
        TCSSetup: Record "TCS Setup";
        PageTaxtype: TestPage "Tax Types";
    begin
        TCSSetup.Get();
        PageTaxtype.OpenEdit();
        PageTaxtype.Filter.SetFilter(Code, TCSSetup."Tax Type");
        PageTaxtype.TaxRates.Invoke();
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

    local procedure CreateGenJournalTemplateBatch(var GenJournalTemplate: Record "Gen. Journal Template";
        var GenJournalBatch: Record "Gen. Journal Batch";
        TemplateType: Enum "Gen. Journal Template Type")
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, TemplateType);
        GenJournalTemplate.Modify(true);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure CreateGenJnlLineFromCustToGLForPayment(var GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: code[20]; TemplateType: Enum "Gen. Journal Template Type"; TCSNOC: code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
        LibraryJournals: Codeunit "Library - Journals";
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"G/L Account", GLAccount."No.",
            -LibraryRandom.RandDecInRange(10000, 20000, 2));
        GenJournalLine.Validate("TCS Nature of Collection", TCSNOC);
        GenJournalLine.Validate(Amount);
        TCSSalesLibrary.CalculateTCS(GenJournalLine);
    end;

    local procedure VerifyJournalGLEntryCount(JnlBatchName: Code[10]; ExpectedCount: Integer): code[20]
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Journal Batch Name", JnlBatchName);
        GLEntry.FindFirst();
        Assert.RecordCount(GLEntry, ExpectedCount);
        exit(GLEntry."Document No.");
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRate: TestPage "Tax Rates");
    var
        TCSPercentage: Decimal;
        NonPANTCSPercentage: Decimal;
        SurchargePercentage: Decimal;
        eCessPercentage: Decimal;
        SHECessPercentage: Decimal;
        EffectiveDate: Date;
        TCSThresholdAmount: Decimal;
        SurchargeThresholdAmount: Decimal;
    begin
        Evaluate(EffectiveDate, Storage.Get(EffectiveDateLbl), 9);
        Evaluate(TCSPercentage, Storage.Get(TCSPercentageLbl));
        Evaluate(NonPANTCSPercentage, Storage.Get(NonPANTCSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TCSThresholdAmount, Storage.Get(TCSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        TaxRate.New();
        TaxRate.AttributeValue1.SetValue(Storage.Get(TCSNOCTypeLbl));
        TaxRate.AttributeValue2.SetValue(Storage.Get(TCSAssesseeCodeLbl));
        TaxRate.AttributeValue3.SetValue(Storage.Get(TCSConcessionalCodeLbl));
        TaxRate.AttributeValue4.SetValue(EffectiveDate);
        TaxRate.AttributeValue5.SetValue(TCSPercentage);
        TaxRate.AttributeValue6.SetValue(SurchargePercentage);
        TaxRate.AttributeValue7.SetValue(NonPANTCSPercentage);
        TaxRate.AttributeValue8.SetValue(eCessPercentage);
        TaxRate.AttributeValue9.SetValue(SHECessPercentage);
        TaxRate.AttributeValue10.SetValue(TCSThresholdAmount);
        TaxRate.AttributeValue11.SetValue(SurchargeThresholdAmount);
        TaxRate.OK().Invoke();
    end;

    var
        LibraryRandom: Codeunit "Library - Random";
        LibraryTCS: Codeunit "TCS - Library";
        LibrarySales: Codeunit "Library - Sales";
        TCSSalesLibrary: Codeunit "TCS Sales - Library";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        Storage: Dictionary of [Text, Text];
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
}
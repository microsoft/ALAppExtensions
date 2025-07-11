codeunit 18919 "TCS on Sales Return"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesReturnOrderWithItemWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355265] Check if the program is calculating TCS on Lower rate/zero rate in case an invoice is raised to the Customer is having a certificate using Return Order
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN with Concessional Code, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Return Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLineType::Item,
            false);

        // [THEN] TCS Entry has been created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromReturnOrderWithGLAccWithoutThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355234] Check if the program is calculating TCS  raised to the Customer using Return Order and Threshold Overlook is not selected with G/L Account.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Return Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS Entry has been created and Verified
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromCrMemoWithGLAccWithoutThresholdAndSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355235] Check if the program is calculating TCS in Credit Memo with no threshold and surcharge overlook for NOD lines of a particular Customer with G/L Account.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Return Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS Entry has been created and Verified
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromReturnOrderWithGLAccWithoutThresholdAndSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355236] Check if the program is calculating TCS in Return Order with no threshold and surcharge overlook for NOD lines of a particular Customer with G/L Account.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Return Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS Entry has been created and Verified
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromCrMemoWithItemWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355242] Check if the program is calculating TCS using Credit Memo with Concessional codes
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Return Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS Entry has been created and Verified
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromReturnOrderWithItemWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355243] Check if the program is calculating TCS using Return Order with Concessional codes
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Return Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS Entry has been created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromCrMemoWithItemWithoutPAN()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355262] Check if the program is calculating TCS on higher rate in case an invoice is raised to the Customer which is not having PAN No. using Credit Memo.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithoutPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Return Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS Entry has been created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, false, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesRetunOrderWithItemWithoutPAN()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355263] Check if the program is calculating TCS on higher rate in case an invoice is raised to the Customer which is not having PAN No. using Return Order
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithoutPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Return Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLineType::Item,
            false);

        // [THEN] TCS Entry has been created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, false, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesCrMemoWithItemWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355264] Check if the program is calculating TCS on Lower rate/zero rate in case an invoice is raised to the Customer is having a certificate using Credit Memo.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN with Concessional Code, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Credit Memo
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLineType::Item,
            false);

        // [THEN] TCS Entry has been created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PayTax')]
    procedure SalesCreditMemoApplyInvoice()
    var
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: record "Sales Line";
        InvoiceDocumentNo: Code[20];
    begin
        //[Senerio [355285][Check if the program is calculating TCS in case of Credit Memo before depositing tax to Government]
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Gen. Journal Line & Pay TDS Amount to Govt.
        CreateGenJnlLineForTCS(GenJournalLine, Customer);
        InvoiceDocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(InvoiceDocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(InvoiceDocumentNo, TCSPostingSetup."TCS Account No.");
        //TCSLibrariesWIP.CreateTCSPayment(TCSPostingSetup."TCS Account No.");
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);
        SalesHeader.Validate("Applies-to Doc. Type", SalesHeader."Applies-to Doc. Type"::Invoice);
        SalesHeader.Validate(SalesHeader."Applies-to Doc. No.", InvoiceDocumentNo);
        SalesHeader.Modify(true);
        LibSales.PostSalesDocument(SalesHeader, false, false);
        CreateTCSPayment(TCSPostingSetup."TCS Account No.");
    end;

    local procedure CreateTCSPayment(TCSAccount: Code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        CompanyInformation: Record "Company Information";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
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
        Payment.PayTCS(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateGenJnlLineForTCS(var GenJournalLine: Record "Gen. Journal Line"; var Customer: Record Customer)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
        GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Customer, Customer."No.",
        GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNoWithDirectPosting(), LibraryRandom.RandDec(10000, 2));
        GenJournalLine.Validate(Amount, LibraryRandom.RandDec(10000, 2));
        GenJournalLine.Validate("Posting Date", WorkDate());
        GenJournalLine.Modify();
        TCSSalesLibrary.CalculateTCS(GenJournalLine);
    end;

    local procedure VerifyTCSEntry(DocumentNo: Code[20]; WithPAN: Boolean; TCSThresholdOverlook: Boolean; SurchargeOverlook: Boolean)
    var
        TCSEntry: Record "TCS Entry";
        ExpectedTCSAmount, ExpectedSurchargeAmount, ExpectedEcessAmount, ExpectedSHEcessAmount : Decimal;
        TCSPercentage, NonPANTCSPercentage, SurchargePercentage, eCessPercentage, SHECessPercentage : Decimal;
        TCSThresholdAmount, SurchargeThresholdAmount, TCSBaseAmount, CurrencyFactor : Decimal;
    begin
        Evaluate(TCSPercentage, Storage.Get(TCSPercentageLbl));
        Evaluate(NonPANTCSPercentage, Storage.Get(NonPANTCSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TCSThresholdAmount, Storage.Get(TCSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        TCSBaseAmount := GetBaseAmountForSales(DocumentNo);
        CurrencyFactor := GetCurrencyFactorForSales(DocumentNo);
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;
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

    local procedure GetBaseAmountForSales(DocumentNo: Code[20]): Decimal
    var
        SalesCreditMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCreditMemoLine.SetRange("Document No.", DocumentNo);
        if SalesCreditMemoLine.FindFirst() then
            exit(SalesCreditMemoLine.Amount);
    end;

    local procedure GetCurrencyFactorForSales(DocumentNo: Code[20]): Decimal
    var
        SalesCMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCMemoHeader.SetRange("No.", DocumentNo);
        if SalesCMemoHeader.FindFirst() then
            exit(SalesCMemoHeader."Currency Factor");
    end;

    local procedure VerifyGLEntryWithTCS(DocumentNo: Code[20]; TCSAccountNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        FindGLEntry(GLEntry, DocumentNo, TCSAccountNo);
        GLEntry.TestField(Amount, -GetTCSAmount(DocumentNo));
    end;

    local procedure FindGLEntry(var GLEntry: Record "G/L Entry"; DocumentNo: Code[20]; TCSAccountNo: Code[20])
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", TCSAccountNo);
        GLEntry.FINDSET();
    end;

    local procedure GetTCSAmount(DocumentNo: Code[20]): Decimal
    var
        TCSEntry: Record "TCS Entry";
        TCSAmount: Decimal;
    begin
        TCSEntry.SetRange("Document No.", DocumentNo);
        if TCSEntry.FindSet() then
            repeat
                TCSAmount += TCSEntry."Total TCS Including SHE CESS";
            until TCSEntry.Next() = 0;
        exit(-TCSAmount);
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

    [PageHandler]
    procedure PayTax(var PayTCS: TestPage "Pay TCS")
    begin
        PayTCS."&Pay".Invoke();
    end;

    var
        LibraryTCS: Codeunit "TCS - Library";
        TCSSalesLibrary: Codeunit "TCS Sales - Library";
        LibraryERM: Codeunit "Library - ERM";
        LibSales: Codeunit "Library - Sales";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        Payment: Codeunit "Pay-TCS";
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
        AmountErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = TCS Amount and TCS field Caption';
}
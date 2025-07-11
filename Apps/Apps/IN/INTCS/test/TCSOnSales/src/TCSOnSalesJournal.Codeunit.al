codeunit 18918 "TCS On Sales Journal"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJnlWithRoundOff()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354495] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while raising invoice or receiving advance from the customer using Sales Journal
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithoutPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create & Post General Journal Line
        SalesJnlLineForTCS(GenJournalLine, Customer, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, GenJournalLine.Amount, GenJournalLine."Currency Factor", false, True, True);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJnlWithoutAccountingPeriod()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
    begin
        // [SCENARIO] [354496] Check if the program is allowing the posting of Invoice using the Sales Journal with TCS  where Accounting Year has not been specified
        // [SCENARIO] [354497] Check if the program is allowing the posting of Invoice using the Sales Journal with TCS information where Accounting Period has been specified but Quarter for the period is not specified.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created General Journal with TCS
        SalesJnlLineForTCS(GenJournalLine, Customer, CalcDate('<-1Y>', TCSSalesLibrary.FindStartDateOnAccountingPeriod()));
        asserterror LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Show expected error
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJnlWithoutTCAN()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
    begin
        // [SCENARIO] [354498] -Check if the program is allowing the posting of Invoice using the Sales Journal with TCS calculation where TCAN No. has not been defined
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());
        LibraryTCS.RemoveTCANOnCompInfo();

        // [WHEN] Created General Journal with TCS
        SalesJnlLineForTCS(GenJournalLine, Customer, WorkDate());
        asserterror LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Expected erro: TCAN No. not defined
        Assert.ExpectedError(StrSubstNo(TCANNoErr, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJnlWithThresholdAndSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354499] Check if the program is calculating TCS using Sales Journal with threshold and surcharge overlook for NOC lines of a particular customer.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create & Post General Journal Line
        SalesJnlLineForTCS(GenJournalLine, Customer, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, GenJournalLine.Amount, GenJournalLine."Currency Factor", True, True, True);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJnlWithThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354500] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Journal and Threshold Overlook is selected.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create & Post General Journal Line
        SalesJnlLineForTCS(GenJournalLine, Customer, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, GenJournalLine.Amount, GenJournalLine."Currency Factor", True, True, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJnlWithoutThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354501] Check if the program is gcalculating TCS in case an invoice is raised to the Customer using Sales Journal and Threshold Overlook is not selected.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create & Post General Journal Line
        SalesJnlLineForTCS(GenJournalLine, Customer, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, GenJournalLine.Amount, GenJournalLine."Currency Factor", True, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJnlWithoutThresholdAndSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354502] Check if the program is calculating TCS in Sales Journal with no threshold and surcharge overlook for NOD lines of a particular Customer
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create & Post General Journal Line
        SalesJnlLineForTCS(GenJournalLine, Customer, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, GenJournalLine.Amount, GenJournalLine."Currency Factor", True, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJnlWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354504] Check if the program is calculating TCS using Sales Journal with concessional codes.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create & Post General Journal Line
        SalesJnlLineForTCS(GenJournalLine, Customer, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, GenJournalLine.Amount, GenJournalLine."Currency Factor", True, True, True);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJnlWithMultiTaxRateEffectiveDate()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354505] Check if the program is calculating TCS using Sales Journal in case of different rates for same NOC with different effective dates.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create & Post General Journal Line
        SalesJnlLineForTCS(GenJournalLine, Customer, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, GenJournalLine.Amount, GenJournalLine."Currency Factor", True, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJnlWithCurrency()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        Currency: Record Currency;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354507] Check if the program is calculating TCS using Sales Journal in case of Foreign Currency.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create & Post General Journal Line
        SalesJnlLineForTCSWithCurrency(GenJournalLine, Customer, Currency);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, GenJournalLine.Amount, GenJournalLine."Currency Factor", True, True, True);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJnlWithoutPAN()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354510] Check if the program is calculating TCS on higher rate in case an invoice is raised to the Customer which is not having PAN No. using Sales Journal.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithoutPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create & Post General Journal Line
        SalesJnlLineForTCS(GenJournalLine, Customer, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, GenJournalLine.Amount, GenJournalLine."Currency Factor", false, True, True);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJnlWithConcessionalCode()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354511] Check if the program is calculating TCS on Lower rate/zero rate in case an invoice is raised to the Customer is having a certificate using Sales Journal.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create & Post General Journal Line
        SalesJnlLineForTCS(GenJournalLine, Customer, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, GenJournalLine.Amount, GenJournalLine."Currency Factor", True, True, True);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJnlWithMultiLine()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354442] Check if the program is calculating TCS while creating a single invoice with multiple expenses using Sales Journal
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create & Post General Journal Line
        SalesJnlLineForTCS(GenJournalLine, Customer, WorkDate());
        LibraryERM.CreateGeneralJnlLineWithBalAcc(
            GenJournalLine,
            GenJournalLine."Journal Template Name",
            GenJournalLine."Journal Batch Name",
            GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Customer,
            Customer."No.",
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryERM.CreateGLAccountNoWithDirectPosting(),
            20000);
        TCSSalesLibrary.CalculateTCS(GenJournalLine);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, GenJournalLine.Amount, GenJournalLine."Currency Factor", True, True, True);
    end;

    local procedure SalesJnlLineForTCS(var GenJournalLine: Record "Gen. Journal Line"; var Customer: Record Customer; PostingDate: Date)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        CreateSalesJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
        GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Customer, Customer."No.",
        GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNoWithDirectPosting(), LibraryRandom.RandDec(100000, 2));
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Modify(true);
        TCSSalesLibrary.CalculateTCS(GenJournalLine);
    end;

    local procedure SalesJnlLineForTCSWithCurrency(var GenJournalLine: Record "Gen. Journal Line"; var Customer: Record Customer; Currency: Record Currency);
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        CreateSalesJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
        GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Customer, Customer."No.",
        GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNoWithDirectPosting(), LibraryRandom.RandDec(100000, 2));
        GenJournalLine.Validate("Posting Date", WorkDate());
        CreateCurrencyWithExchangeRate(Currency);
        GenJournalLine.Validate("Currency Code", Currency.Code);
        TCSSalesLibrary.CalculateTCS(GenJournalLine);
        GenJournalLine.Modify(true);
    end;

    local procedure VerifyTCSEntry(DocumentNo: Code[20]; TCSBaseAmount: Decimal; CurrencyFactor: Decimal; WithPAN: Boolean; TCSThresholdOverlook: Boolean; SurchargeOverlook: Boolean)
    var
        TCSEntry: Record "TCS Entry";
        ExpectedTCSAmount, ExpectedSurchargeAmount, ExpectedEcessAmount, ExpectedSHEcessAmount : Decimal;
        TCSPercentage, NonPANTCSPercentage, SurchargePercentage, eCessPercentage, SHECessPercentage : Decimal;
        TCSThresholdAmount, SurchargeThresholdAmount : Decimal;
    begin
        Evaluate(TCSPercentage, Storage.Get(TCSPercentageLbl));
        Evaluate(NonPANTCSPercentage, Storage.Get(NonPANTCSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TCSThresholdAmount, Storage.Get(TCSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

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

    local procedure CreateSalesJournalTemplate(Var GenJournalTemplate: Record "Gen. Journal Template")
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, GenJournalTemplate.Type::Sales);
        GenJournalTemplate.Modify(true);
    end;

    local procedure CreateCurrencyWithExchangeRate(var Currency: Record Currency)
    begin
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.CreateExchangeRate(Currency.Code, WorkDate(), 100, LibraryRandom.RandDecInDecimalRange(70, 80, 2));
    end;

    local procedure VerifyGLEntryWithTCS(DocumentNo: Code[20]; TCSAccountNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        FindGLEntry(GLEntry, DocumentNo, TCSAccountNo);
        GLEntry.TestField(Amount, GetTCSAmount(DocumentNo));
    end;

    local procedure FindGLEntry(var GLEntry: Record "G/L Entry"; DocumentNo: Code[20]; TCSAccountNo: Code[20])
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", TCSAccountNo);
        GLEntry.FindFirst();
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
        if not TCSSetup.Get() then
            exit;

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

    var
        LibraryTCS: Codeunit "TCS - Library";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        TCSSalesLibrary: Codeunit "TCS Sales - Library";
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
        IncomeTaxAccountingErr: Label 'Posting Date doesn''t lie in Tax Accounting Period', Locked = true;
        TCANNoErr: Label 'T.C.A.N. No. must have a value in Gen. Journal Line: Journal Template Name=%1, Journal Batch Name=%2, Line No.=%3. It cannot be zero or empty.', Comment = '%1= Template Name, %2= Batch Name,%3= Line No';
        AmountErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = TCS Amount and TCS field Caption';
}
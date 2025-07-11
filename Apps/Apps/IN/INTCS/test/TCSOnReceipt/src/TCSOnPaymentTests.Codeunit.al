codeunit 18925 "TCS On Payment Tests"
{
    Subtype = Test;

    var
        TCSLibrary: Codeunit "TCS - Library";
        TCSSalesLibrary: Codeunit "TCS Sales - Library";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryJournals: Codeunit "Library - Journals";
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        Storage: Dictionary of [Text, Text];
        AccountNoLbl: Label 'Account No', locked = true;
        CustomerCodeLbl: Label 'Customer Code', locked = true;
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
        DocumentNoLbl: Label 'DocumentNo', Locked = true;
        TemplateNameLbl: Label 'TemplateName', Locked = true;
        PostedDocumentNoLbl: Label 'Posted Document No', Locked = true;
        TCSNOCNotAllowErr: Label 'You are not allowed to select this Nature of Collection in Gen. Journal Line. Journal Template Name=%1, Journal Batch Name=%2 Line No=%3 with Document Type as Invoice.',
        Comment = '%1 = Journal Template Name, %2= Journal Batch Name, %3= Line No.';
        ExcludeGSTDocTypeErr: Label 'Exclude GST in TCS Base is allowed only for Document Type Invoice and Credit Memo.';
        TCSPayAmtErr: Label 'TCS on Recpt. Of Pmt. amount should not be greater than Amount.';
        TCSPayAmt2Err: Label ' TCS on Recpt. Of Pmt. amount should not be less than 0.';
        VerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = TCS Amount and TCS field Caption';

    [Test]
    [HandlerFunctions('TaxRatePageHandler,JournalTemplateHandler,SalesLineBufferHandler')]
    procedure PostFromCashReceiptVoucherWithTCSOnPayment()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [388964] Check if system is creating correct entries when payment receipt is posted using Cash Receipt Voucher If “TCS on Recpt. Of Pmt.” field is TRUE against a TCS Nature of Collection
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate(), Customer."No.");

        // [WHEN] Create and Post Sales Invoice with Item
        DocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            Enum::"Sales Line Type"::Item,
            false);
        Storage.Set(DocumentNoLbl, DocumentNo);

        // [THEN] Create and post cash receipt voucher with reciept of payment
        CreateGenJnlLineWithTCS(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Customer."No.",
            Enum::"Gen. Journal Template Type"::"Cash Receipt Voucher",
            TCSPostingSetup."TCS Nature of Collection");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,JournalTemplateHandler,SalesLineBufferHandler')]
    procedure PostFromCashReceiptVoucherWithTCSOnPaymentAndFCYCurrency()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period with FCY Currency
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate(), Customer."No.");
        UpdateCustomerWithFCYCurrency(Customer);

        // [WHEN] Create and Post Sales Invoice with Item
        DocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            Enum::"Sales Line Type"::Item,
            false);
        Storage.Set(DocumentNoLbl, DocumentNo);

        // [THEN] Create and post cash receipt voucher with reciept of payment
        CreateGenJnlLineWithTCS(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Customer."No.",
            Enum::"Gen. Journal Template Type"::"Cash Receipt Voucher",
            TCSPostingSetup."TCS Nature of Collection");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckOnCashPayVoucherInvoiceWithWrongTCSNOC()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate(), Customer."No.");

        // [WHEN] Create and Post Sales Invoice with Item
        DocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            Enum::"Sales Line Type"::Item,
            false);
        Storage.Set(DocumentNoLbl, DocumentNo);

        // [THEN] Create and post cash receipt voucher with Document type as Invoice
        asserterror CreateGenJnlLineWithTCS(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Invoice,
            Customer."No.",
            Enum::"Gen. Journal Template Type"::"Cash Receipt Voucher",
            TCSPostingSetup."TCS Nature of Collection");

        // [THEN] Check if system is throwing correct error
        Assert.ExpectedError(StrSubstNo(TCSNOCNotAllowErr, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,JournalTemplateHandler,SalesLineBufferHandler')]
    procedure CheckOnCashPayVoucherPaymentExclusdeGST()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate(), Customer."No.");

        // [WHEN] Create and Post Sales Invoice with Item
        DocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            Enum::"Sales Line Type"::Item,
            false);
        Storage.Set(DocumentNoLbl, DocumentNo);

        // [THEN] Create and post cash receipt voucher with Document type as payment and check Exclude GST in TCS Base
        CreateGenJnlLineWithTCS(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Customer."No.",
            Enum::"Gen. Journal Template Type"::"Cash Receipt Voucher",
            TCSPostingSetup."TCS Nature of Collection");
        asserterror GenJournalLine.Validate("Excl. GST in TCS Base", true);

        // [THEN] Check if system is throwing correct error
        Assert.ExpectedError(ExcludeGSTDocTypeErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,JournalTemplateHandler,SalesLineBufferHandler')]
    procedure CheckOnCashPayVoucherPaymentWithPaymentRcptAmountIsLess()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate(), Customer."No.");

        // [WHEN] Create and Post Sales Invoice with Item
        DocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            Enum::"Sales Line Type"::Item,
            false);
        Storage.Set(DocumentNoLbl, DocumentNo);

        // [THEN] Create and post cash receipt voucher with Document type as payment and Payment receipt Amount is less then amount
        CreateGenJnlLineWithTCS(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Customer."No.",
            Enum::"Gen. Journal Template Type"::"Cash Receipt Voucher",
            TCSPostingSetup."TCS Nature of Collection");
        asserterror GenJournalLine.Validate("TCS On Recpt. Of Pmt. Amount", GenJournalLine.Amount - 1);

        // [THEN] Check if system is throwing correct error
        Assert.ExpectedError(TCSPayAmtErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,JournalTemplateHandler,SalesLineBufferHandler')]
    procedure CheckOnCashPayVoucherPaymentWithAmountIsLessThanPmtRcptAmount()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        CashReceiptVoucher: TestPage "Cash Receipt Voucher";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate(), Customer."No.");

        // [WHEN] Create and Post Sales Invoice with Item
        DocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            Enum::"Sales Line Type"::Item,
            false);
        Storage.Set(DocumentNoLbl, DocumentNo);

        // [THEN] Create and post cash receipt voucher with Document type as payment and Amount is less than TCS On Recpt. Of Pmt. Amount
        CreateGenJnlLineWithTCS(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Customer."No.",
            Enum::"Gen. Journal Template Type"::"Cash Receipt Voucher",
            TCSPostingSetup."TCS Nature of Collection");
        CashReceiptVoucher.OpenEdit();
        CashReceiptVoucher.Filter.SetFilter("Document No.", GenJournalLine."Document No.");
        asserterror CashReceiptVoucher.Amount.SetValue(GenJournalLine."TCS On Recpt. Of Pmt. Amount" - 1);

        // [THEN] Check if system is throwing correct error
        Assert.ExpectedError(TCSPayAmtErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,JournalTemplateHandler,SalesLineBufferHandler')]
    procedure CheckOnCashPayVoucherPaymentWithPaymentRcptAmountIsLessThanZero()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate(), Customer."No.");

        // [WHEN] Create and Post Sales Invoice with Item
        DocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            Enum::"Sales Line Type"::Item,
            false);
        Storage.Set(DocumentNoLbl, DocumentNo);

        // [THEN] Create and post cash receipt voucher with Document type as payment and Payment receipt Amuount is less than Zero
        CreateGenJnlLineWithTCS(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Customer."No.",
            Enum::"Gen. Journal Template Type"::"Cash Receipt Voucher",
            TCSPostingSetup."TCS Nature of Collection");
        asserterror GenJournalLine.Validate("TCS On Recpt. Of Pmt. Amount", -1);

        // [THEN] Check if system is throwing correct error
        Assert.ExpectedError(TCSPayAmt2Err);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,JournalTemplateHandler,SalesLineBufferHandler,TCSNOCHandler')]
    procedure CheckOnCashReceiptVoucherTCSNOCLookup()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
        CashReceiptVoucher: TestPage "Cash Receipt Voucher";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate(), Customer."No.");

        // [WHEN] Create and Post Sales Invoice with Item
        DocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            Enum::"Sales Line Type"::Item,
            false);
        Storage.Set(DocumentNoLbl, DocumentNo);

        // [THEN] Create and post cash receipt voucher with Document type as payment and Select TCS NOC from lookup
        CreateGenJnlLineWithTCS(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Customer."No.",
            Enum::"Gen. Journal Template Type"::"Cash Receipt Voucher",
            TCSPostingSetup."TCS Nature of Collection");
        CashReceiptVoucher.OpenEdit();
        CashReceiptVoucher.Filter.SetFilter("Document No.", GenJournalLine."Document No.");
        CashReceiptVoucher."TCS Nature of Collection".Lookup();

        // [THEN] Check if TCS nature is collection is correct in Gen journal Line
        Assert.AreEqual(TCSPostingSetup."TCS Nature of Collection", GenJournalLine."TCS Nature of Collection",
            StrSubstNo(VerifyErr, GenJournalLine.FieldName("TCS Nature of Collection"), GenJournalLine.TableCaption()))
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,JournalTemplateHandler,TCSNOCHandler,ConfirmHandler')]
    procedure CheckOnCashReceiptVoucherWithNotAllowedTCSNOC()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate(), Customer."No.");
        RemoveTCSNOCForCustomer(Customer."No.", TCSPostingSetup."TCS Nature of Collection");

        // [WHEN] Create and post cash receipt voucher with Document type as payment and Select TCS NOC from lookup
        CreateGenJnlLineWithoutNOC(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Customer."No.",
            Enum::"Gen. Journal Template Type"::"Cash Receipt Voucher");

        // [THEN] Check if TCS nature is collection is correct in Gen journal Line
        Assert.AreEqual(GenJournalLine."TCS Nature of Collection", GenJournalLine."TCS Nature of Collection",
            StrSubstNo(VerifyErr, GenJournalLine.FieldName("TCS Nature of Collection"), GenJournalLine.TableCaption()));
    end;

    local procedure RemoveTCSNOCForCustomer(CustomerNo: Code[20]; TCSNOC: Code[20])
    var
        AllowedNOC: Record "Allowed NOC";
    begin
        if AllowedNOC.Get(CustomerNo, TCSNOC) then
            AllowedNOC.Delete(true);
    end;

    local procedure UpdateCustomerWithFCYCurrency(var Customer: Record Customer)
    begin
        Customer.Validate("Currency Code", LibraryERM.CreateCurrencyWithRandomExchRates());
        Customer.Modify(true);
    end;

    local procedure CreateAndPostSalesDocument(
            var SalesHeader: Record "Sales Header";
            DocumentType: Enum "Sales Document Type";
            CustomerNo: Code[20];
            PostingDate: Date;
            LineType: Enum "Sales Line Type";
            LineDiscount: Boolean): Code[20]
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Modify(true);

        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, LineType, LineDiscount);
        SalesLine.Validate("TCS Nature of Collection", '');
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInDecimalRange(10000, 20000, 2));
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateGenJnlLineWithTCS(
        var GenJournalLine: Record "Gen. Journal Line";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        CustomerNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        TCSNOC: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        CashReceiptVoucher: TestPage "Cash Receipt Voucher";
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, VoucherType);
        Storage.Set(TemplateNameLbl, GenJournalTemplate.Name);
        CreateVoucherSetup(VoucherType);
        LibraryJournals.CreateGenJournalLine(
            GenJournalLine,
            GenJournalTemplate.Name,
            GenJournalBatch.Name,
            GenJournalDocumentType,
            GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            (Storage.Get(AccountNoLbl)),
            -LibraryRandom.RandDecInRange(200000, 300000, 2));
        GenJournalLine.Validate("TCS Nature of Collection", TCSNOC);
        GenJournalLine.Modify(true);

        CashReceiptVoucher.OpenEdit();
        CashReceiptVoucher.Filter.SetFilter("Document No.", GenJournalLine."Document No.");
        CashReceiptVoucher."Get Open Posted Lines For TCS On Payment Calculation".Invoke();
        GenJournalLine.Validate("TCS On Recpt. Of Pmt. Amount");
        Storage.Set(PostedDocumentNoLbl, GenJournalLine."Document No.");
    end;

    local procedure CreateGenJnlLineWithoutNOC(
        var GenJournalLine: Record "Gen. Journal Line";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        CustomerNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        CashReceiptVoucher: TestPage "Cash Receipt Voucher";
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, VoucherType);
        Storage.Set(TemplateNameLbl, GenJournalTemplate.Name);
        CreateVoucherSetup(VoucherType);
        LibraryJournals.CreateGenJournalLine(
            GenJournalLine,
            GenJournalTemplate.Name,
            GenJournalBatch.Name,
            GenJournalDocumentType,
            GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            (Storage.Get(AccountNoLbl)),
            -LibraryRandom.RandDecInRange(200000, 300000, 2));
        GenJournalLine.Modify(true);

        CashReceiptVoucher.OpenEdit();
        CashReceiptVoucher.Filter.SetFilter("Document No.", GenJournalLine."Document No.");
        CashReceiptVoucher."TCS Nature of Collection".Lookup();
        Storage.Set(PostedDocumentNoLbl, GenJournalLine."Document No.");
    end;

    local procedure CreateReceiptSetup(TCSNOC: Code[20]; CustomerCode: Code[20])
    var
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        AllowedNOC: Record "Allowed NOC";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        TCSNatureOfCollection.Get(TCSNOC);
        TCSNatureOfCollection.Validate("TCS On Recpt. Of Pmt.", true);
        TCSNatureOfCollection.Modify(true);

        AllowedNOC.Get(CustomerCode, TCSNOC);
        AllowedNOC.Validate("Default NOC", false);
        AllowedNOC.Modify(true);

        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."TCS Debit Note No." = '' then begin
            GeneralLedgerSetup.Validate("TCS Debit Note No.", LibraryERM.CreateNoSeriesCode());
            GeneralLedgerSetup.Modify();
        end;
    end;

    local procedure CreateGenJournalTemplateBatch(var GenJournalTemplate: Record "Gen. Journal Template"; var GenJournalBatch: Record "Gen. Journal Batch"; VoucherType: Enum "Gen. Journal Template Type")
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, VoucherType);
        GenJournalTemplate.Modify(true);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure CreateTaxRateSetup(TCSNOC: Code[10]; AssesseeCode: Code[10]; ConcessionalCode: Code[10]; EffectiveDate: Date; CustomerCode: Code[20])
    begin
        Storage.Set(TCSNOCTypeLbl, TCSNOC);
        Storage.Set(TCSAssesseeCodeLbl, AssesseeCode);
        Storage.Set(TCSConcessionalCodeLbl, ConcessionalCode);
        Storage.Set(EffectiveDateLbl, Format(EffectiveDate, 0, 9));
        Storage.Set(CustomerCodeLbl, CustomerCode);
        GenerateTaxComponentsPercentage();
        CreateReceiptSetup(TCSNOC, CustomerCode);
        CreateTaxRate();
    end;

    local procedure CreateVoucherSetup(Type: Enum "Gen. Journal Template Type"): Code[20]
    var
        BankAccount: Record "Bank Account";
        GLAccount: Record "G/L Account";
    begin
        case Type of
            Type::"Bank Payment Voucher", Type::"Bank Receipt Voucher":
                begin
                    LibraryERM.CreateBankAccount(BankAccount);
                    Storage.Set(AccountNoLbl, BankAccount."No.");
                    CreateVoucherAccountSetup(Type, '');
                end;
            Type::"Contra Voucher", Type::"Cash Receipt Voucher":
                begin
                    LibraryERM.CreateGLAccount(GLAccount);
                    Storage.Set(AccountNoLbl, GLAccount."No.");
                    CreateVoucherAccountSetup(Type, '');
                end;
        end;
    end;

    local procedure CreateVoucherAccountSetup(SubType: Enum "Gen. Journal Template Type"; LocationCode: Code[10])
    var
        TaxBaseTestPublishers: Codeunit "Tax Base Test Publishers";
        TransactionDirection: Option " ",Debit,Credit,Both;
        AccountNo: Code[20];
    begin
        AccountNo := CopyStr(Storage.Get(AccountNoLbl), 1, MaxStrLen(AccountNo));
        case SubType of
            SubType::"Bank Payment Voucher", SubType::"Cash Payment Voucher", SubType::"Contra Voucher":
                begin
                    TaxBaseTestPublishers.InsertJournalVoucherPostingSetupWithLocationCode(SubType, LocationCode, TransactionDirection::Credit);
                    TaxBaseTestPublishers.InsertVoucherCreditAccountNoWithLocationCode(SubType, LocationCode, AccountNo);
                    Storage.Set(AccountNoLbl, AccountNo);
                end;
            SubType::"Cash Receipt Voucher", SubType::"Bank Receipt Voucher", SubType::"Journal Voucher":
                begin
                    TaxBaseTestPublishers.InsertJournalVoucherPostingSetupWithLocationCode(SubType, LocationCode, TransactionDirection::Debit);
                    TaxBaseTestPublishers.InsertVoucherDebitAccountNoWithLocationCode(SubType, LocationCode, AccountNo);
                    Storage.Set(AccountNoLbl, AccountNo);
                end;
        end;
    end;

    local procedure CreateTaxRate()
    var
        TCSSetup: Record "TCS Setup";
        PageTaxTypes: TestPage "Tax Types";
    begin
        TCSSetup.Get();
        PageTaxTypes.OpenEdit();
        PageTaxTypes.Filter.SetFilter(Code, TCSSetup."Tax Type");
        PageTaxTypes.TaxRates.Invoke();
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

    [ModalPageHandler]
    procedure TCSNOCHandler(var TCSNatureOfCollections: TestPage "TCS Nature Of Collections")
    var
        AllowedNOC: Record "Allowed NOC";
    begin
        if AllowedNOC.Get(Storage.Get(CustomerCodeLbl), Storage.Get(TCSNOCTypeLbl)) then begin
            TCSNatureOfCollections.Filter.SetFilter(Code, Storage.Get(TCSNOCTypeLbl));
            TCSNatureOfCollections.OK().Invoke();
        end else begin
            TCSNatureOfCollections.ClearFilter.Invoke();
            TCSNatureOfCollections.Filter.SetFilter(Code, Storage.Get(TCSNOCTypeLbl));
            TCSNatureOfCollections.OK().Invoke();
        end
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; VAR Reply: Boolean)
    begin
        Reply := true;
    end;

    [ModalPageHandler]
    procedure JournalTemplateHandler(var GeneralJournalTemplateList: TestPage "General Journal Template List")
    begin
        GeneralJournalTemplateList.Filter.SetFilter(Name, Storage.Get(TemplateNameLbl));
        GeneralJournalTemplateList.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure SalesLineBufferHandler(var SalesLineBufferTCSOnPmt: TestPage "Sales Line Buffer TCS On Pmt.")
    begin
        SalesLineBufferTCSOnPmt.Filter.SetFilter("Posted Invoice No.", Storage.Get(DocumentNoLbl));
        SalesLineBufferTCSOnPmt.Select.SetValue(true);
        SalesLineBufferTCSOnPmt.OK().Invoke();
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
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
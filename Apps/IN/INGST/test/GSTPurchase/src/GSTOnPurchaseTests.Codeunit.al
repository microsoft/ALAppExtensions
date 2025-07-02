codeunit 18131 "GST On Purchase Tests"
{
    Subtype = Test;

    var
        LibraryGST: Codeunit "Library GST";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryJournals: Codeunit "Library - Journals";
        libraryGSTPurchase: Codeunit "Library - GST Purchase";
        Assert: Codeunit Assert;
        ComponentPerArray: array[20] of Decimal;
        Storage: Dictionary of [Text, Text[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
        StorageDecimal: Dictionary of [Text, Decimal];
        AccountNoLbl: Label 'AccountNo', locked = true;
        NoOfLineLbl: Label 'NoOfLine', Locked = true;
        LocationStateCodeLbl: Label 'LocationStateCode', Locked = true;
        LocationCodeLbl: Label 'LocationCode', Locked = true;
        GSTGroupCodeLbl: Label 'GSTGroupCode', Locked = true;
        HSNSACCodeLbl: Label 'HSNSACCode', Locked = true;
        VendorNoLbl: Label 'VendorNo', Locked = true;
        InputCreditAvailmentLbl: Label 'InputCreditAvailment', Locked = true;
        ExemptedLbl: Label 'Exempted', Locked = true;
        LineDiscountLbl: Label 'LineDiscount', Locked = true;
        FromStateCodeLbl: Label 'FromStateCode', Locked = true;
        ToStateCodeLbl: Label 'ToStateCode', Locked = true;
        PaymentDocNoLbl: Label 'PaymentDocNo', Locked = true;
        GSTTaxPercentLbl: Label 'GSTTaxPercent', Locked = true;
        LineAmountLbl: Label 'LineAmount', Locked = true;
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        PostedDocumentNoLbl: Label 'PostedDocumentNo', Locked = true;
        AccountTypeLbl: Label 'Account Type', Locked = true;
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo', locked = true;
        PostedDistributionNoLbl: Label 'PostedDistributionNoLbl', locked = true;
        SuccessMsg: Label 'Credit Adjustment Journal posted successfully.', Locked = true;
        NotPostedErr: Label 'The entries were not posted.', locked = true;
        VendLedgerEntryVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
        TaxTransactionValueEmptyErr: Label 'Tax Transaction Value cannot be empty for %1', Comment = '%1 = Purchase Line Archive Record ID';

    // [SCENARIO] User can Apply Vendor Payments to invoice with different currency exchange rates
    // [FEATURE] [Adjust Exchange Rate] [FCY] [Post Application-Vendor]    
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostApplicationFromPurchInvImportVendorWithNormalPayment()
    var
        Currency: Record Currency;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntryPayment: Record "Vendor Ledger Entry";
        VendorLedgerEntryInvoice: Record "Vendor Ledger Entry";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
        VendorNo: Code[20];
    begin
        // [GIVEN] Create Currency, GST Setup, and tax rates for Import Vendor with input Tax Credit is availment where Jurisdiction type is Interstate
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);
        Storage.Set(NoOfLineLbl, '1');
        PrepareCurrency(Currency, 0);
        CreateExchangeRate(Currency.Code, DMY2Date(1, 1, 2022), 2, 2);
        Evaluate(VendorNo, Storage.Get(VendorNoLbl));
        UpdateVendorCurrencyAndLocation(VendorNo, Currency.Code);

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as G/L Account
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] Create new Exchange rate to Currency and and Post Bank Payment Voucher with Currency
        CreateExchangeRate(Currency.Code, WorkDate(), 3, 3);
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Post Apply Payment to Invoice
        VendorLedgerEntryInvoice.SetRange("Vendor No.", VendorNo);
        VendorLedgerEntryInvoice.SetRange("Document Type", VendorLedgerEntryInvoice."Document Type"::Invoice);

        LibraryERM.SetAppliestoIdVendor(VendorLedgerEntryInvoice);

        VendorLedgerEntryPayment.SetRange("Vendor No.", VendorNo);
        LibraryERM.FindVendorLedgerEntry(
          VendorLedgerEntryPayment, VendorLedgerEntryPayment."Document Type"::Payment, GenJournalLine."Document No.");

        LibraryERM.SetAppliestoIdVendor(VendorLedgerEntryPayment);

        LibraryERM.PostVendLedgerApplication(VendorLedgerEntryInvoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 12);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchInvServicesForRegVendorWithAdvPayment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354692]	[Check if the system is handling application of an advance payment to Invoice of Services Registered Vendor where Input Tax Credit is available - Intra-State through Purchase Invoice]

        // [GIVEN] Create GST Setup and tax rates for Registered Vendor with input Tax Credit is availment where Jurisdiction type is Intrastate
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Payment Voucher with Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Purchase Order application with advance payment where line type is G/L account
        DocumentNo := CreateAndPostPurchaseDocumentWithApplication(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 12);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchInvServicesForRegVendorWithNormalPayment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the system is handling application of Non GST payment to Invoice of Services Registered Vendor where Input Tax Credit is available - Intra-State through Purchase Invoice]

        // [GIVEN] Create GST Setup and tax rates for Registered Vendor with input Tax Credit is availment where Jurisdiction type is Intrastate
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Payment Voucher with Non GST Advance Payment
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Purchase Order application with advance payment where line type is G/L account
        DocumentNo := CreateAndPostPurchaseDocumentWithApplication(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 14);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchInvServicesForImportVendorWithAdvPayment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the system is handling application of an advance payment to Invoice of Services Import Vendor where Input Tax Credit is available - Inter-State through Purchase Invoice]

        // [GIVEN] Create GST Setup and tax rates for Import Vendor with input Tax Credit is availment where Jurisdiction type is Interstate
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Payment Voucher with Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Purchase Invoice application with advance payment where line type is G/L account
        DocumentNo := CreateAndPostPurchaseDocumentWithApplication(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchInvServicesForImportVendorWithNormalPayment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the system is handling application of Non GST payment to Invoice of Services Import Vendor where Input Tax Credit is available - Inter-State through Purchase Invoice]

        // [GIVEN] Create GST Setup and tax rates for Import Vendor with input Tax Credit is availment where Jurisdiction type is Interstate
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Payment Voucher with Non GST Advance Payment
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Purchase Invoice application with advance payment where line type is G/L account
        DocumentNo := CreateAndPostPurchaseDocumentWithApplication(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 8);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchInvServicesForRegVendorWithNormalPayment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the system is handling application of Non GST payment to Invoice of Services Registered Vendor where Input Tax Credit is available - Inter-State through Purchase Invoice]

        // [GIVEN] Create GST Setup and tax rates for Registered Vendor with input Tax Credit is availment where Jurisdiction type is Interstate
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Payment Voucher with Non GST Advance Payment
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Purchase Order application with advance payment where line type is G/L account
        DocumentNo := CreateAndPostPurchaseDocumentWithApplication(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 8);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchInvServicesForRegVendorWithAdvPayment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354750]	[Check if the system is handling application of an advance payment to Invoice of Services where Input Tax Credit is available - Inter-State through Purchase Invoice]

        // [GIVEN] Create GST Setup and tax rates for Registered Vendor with input Tax Credit is availment where Jurisdiction type is Interstate
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Payment Voucher with Advance Payment where Vendor type is Registered
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Purchase Order application with advance payment where line type is G/L account
        DocumentNo := CreateAndPostPurchaseDocumentWithApplication(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 7);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchInvServicesForRegVendorWithUnApplication()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the system is handling Un-application of Non GST payment to Invoice of Services Registered Vendor where Input Tax Credit is available - Inter-State through Purchase Invoice]

        // [GIVEN] Create GST Setup and tax rates for Registered Vendor with input Tax Credit is availment where Jurisdiction type is Interstate
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Payment Voucher with Non GST Advance Payment
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Purchase Order application with advance payment where line type is G/L account
        PostedDocumentNo := CreateAndPostPurchaseDocumentWithApplication(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Unapply Vendor Ledger Entry and Verify
        UnapplyVendLedgerEntry(GenJournalDocumentType::Invoice, PostedDocumentNo);
        VerifyAdvPaymentUnapplied();
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchInvServicesForRegVendorWithUnApplicationAdvPayment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the system is handling Un-application of GST payment to Invoice of Services Registered Vendor where Input Tax Credit is available - Inter-State through Purchase Invoice]

        // [GIVEN] Create GST Setup and tax rates for Registered Vendor with input Tax Credit is availment where Jurisdiction type is Interstate
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Payment Voucher with GST Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Purchase Order application with advance payment where line type is G/L account
        PostedDocumentNo := CreateAndPostPurchaseDocumentWithApplication(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Unapply Vendor Ledger Entry and Verify
        UnapplyVendLedgerEntry(GenJournalDocumentType::Invoice, PostedDocumentNo);
        VerifyAdvPaymentUnapplied();
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchInvServicesForRegVendorWithOfflineApplication()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the system is handling Offline application of Non GST payment to Invoice of Services Registered Vendor where Input Tax Credit is available - Inter-State through Purchase Invoice]

        // [GIVEN] Create GST Setup and tax rates for Registered Vendor with input Tax Credit is availment where Jurisdiction type is Interstate
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Payment Voucher with Non GST Advance Payment
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Purchase Order where line type is G/L account
        PostedDocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Apply Vendor Ledger Entry and Verify
        LibraryERM.ApplyVendorLedgerEntries(GenJournalDocumentType::Invoice, GenJournalDocumentType::Payment, PostedDocumentNo, (Storage.Get(PaymentDocNoLbl)));
        VerifyAdvPaymentApplied();
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchInvServicesForRegVendorWithOfflineApplicationAdvPayment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the system is handling offline application of GST payment to Invoice of Services Registered Vendor where Input Tax Credit is available - Inter-State through Purchase Invoice]

        // [GIVEN] Create GST Setup and tax rates for Registered Vendor with input Tax Credit is availment where Jurisdiction type is Interstate
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Payment Voucher with GST Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Purchase Orderwhere line type is G/L account
        PostedDocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Apply Vendor Ledger Entry and Verify
        LibraryERM.ApplyVendorLedgerEntries(GenJournalDocumentType::Invoice, GenJournalDocumentType::Payment, PostedDocumentNo, (Storage.Get(PaymentDocNoLbl)));
        VerifyAdvPaymentApplied();
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchInvServicesForRegVendorWithAdvPaymentAndNonITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354757]	[Check if the system is handling application of an advance payment to Invoice of Services where Input Tax Credit is not available - Intra-State through Purchase Invoice]

        // [GIVEN] Create GST Setup and tax rates for Registered Vendor with input Tax Credit is Non-availment where Jurisdiction type is Intrastate
        InitializeShareStep(false, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Payment Voucher with Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Purchase Order application with advance payment where line type is G/L account
        DocumentNo := CreateAndPostPurchaseDocumentWithApplication(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 10);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchInvServicesForRegVendorWithAdvPaymentAndNonITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354762]	[Check if the system is handling application of an advance payment to Invoice of Services where Input Tax Credit is not available - Inter-State through Purchase Invoice]

        // [GIVEN] Create GST Setup and tax rates for Registered Vendor with input Tax Credit is Non-availment where Jurisdiction type is Interstate
        InitializeShareStep(false, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Payment Voucher with Advance Payment where Vendor type is Registered
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Purchase Order application with advance payment where line type is G/L account
        DocumentNo := CreateAndPostPurchaseDocumentWithApplication(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ApplyAdjustmentEntries,ConfirmationHandler,PostMessageHandler')]
    procedure PostGSTCreditReversalOfPurchInvoiceWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        CreditAdjustmentType: Enum "Credit Adjustment Type";
    begin
        // [Scenario] [355875] Check if the system is handling GST Credit reversal in case of Goods

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type is Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as Item for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] Create and Post GST Credit Adjsutment journal with Credit adjustment type as Credit Reversal
        CreateAndPostAdjustmentJournal(CreditAdjustmentType::"Credit Reversal", false, 100);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ApplyAdjustmentEntries,ConfirmationHandler,PostMessageHandler')]
    procedure PostGSTCreditReAvailmentOfPurchInvoiceWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        CreditAdjustmentType: Enum "Credit Adjustment Type";
    begin
        // [Scenario] [355876] Check if the system is handling GST Credit Adjustment with  re-availment in case of Goods

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as Item for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] Create and Post GST Credit Adjsutment journal with Credit adjustment type as Credit Reversal
        CreateAndPostAdjustmentJournal(CreditAdjustmentType::"Credit Reversal", false, 40);

        // [THEN] Create and Post GST Credit Adjsutment journal with Credit adjustment type as Credit Re-Availment
        CreateAndPostAdjustmentJournal(CreditAdjustmentType::"Credit Re-Availment", false, 40);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ApplyAdjustmentEntries,ConfirmationHandler,PostMessageHandler')]
    procedure PostGSTCreditAvailmentOfPurchInvoiceWithITCAndRCM()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        CreditAdjustmentType: Enum "Credit Adjustment Type";
    begin
        // [Scenario] [355877] Check if the system is handling GST Credit availment in case of Service (RCM) through GST Credit Adjustment Journal

        //[GIVEN] Created GST Setup and tax rates for Unregistered Vendor and GST Credit adjustment is Available with GST group type is Service
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Bank Payment Voucher with Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Purchase Order application with advance payment where line type is G/L account
        CreateAndPostPurchaseDocumentWithApplication(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Create and Post GST Credit Adjsutment journal with Credit adjustment type as Availment
        CreateAndPostAdjustmentJournal(CreditAdjustmentType::"Credit Availment", true, 40);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ApplyAdjustmentEntries,ConfirmationHandler,PostMessageHandler')]
    procedure PostGSTCreditRevarsalOfPurchInvoiceWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        CreditAdjustmentType: Enum "Credit Adjustment Type";
    begin
        // [Scenario] [355878] Check if the system is handling GST Credit reversal in case of G/L Account through GST Credit Adjustment

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as G/L Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Create and Post GST Credit Adjsutment journal with Credit adjustment type as Credit Reversal
        CreateAndPostAdjustmentJournal(CreditAdjustmentType::"Credit Reversal", false, 40);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PostLiabilityEntries,ConfirmationHandler')]
    procedure PostGSTCreditLiabilityOfRCMPurchInvoiceWithGenerate()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Service with RCM
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as G/L Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Create and Post GST liability Credit Adjsutment with Nature of Adjustment is Generate
        CreateAndPostGSTLiabilityJournal(Enum::"Cr Libty Adjustment Type"::Generate);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PostLiabilityEntries,ConfirmationHandler')]
    procedure PostGSTCreditLiabilityOfRCMPurchInvoiceWithReverse()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Service with RCM
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as G/L Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Create and Post GST liability Credit Adjsutment with Nature of Adjustment is Reverse
        CreateAndPostGSTLiabilityJournal(Enum::"Cr Libty Adjustment Type"::Generate);
        CreateAndPostGSTLiabilityJournal(Enum::"Cr Libty Adjustment Type"::Reverse);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromGSTPurchCrMemoRegVendWithNonITCItemInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [381415] Check if system is calculating GST Amount for Registered Vendor Interstate with Goods on Purchase Credit Memo with Non-Availment and impact on Item Ledger Entries and Value Entries through Copy Document.
        // [FEATURE] [Goods, Purchase Credit Memo] [ITC Non Availment, Registered Vendor, Inter-State]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Non Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Create and Post Purchase Return Document with Updated Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        VerifyValueEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ApplyDistributionEntries,ConfirmationHandler,DimensionHandler,NoSeriesHandler')]
    procedure PostIntraStateInvDistributionNonITCToNonITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type";
        GSTGroupType: Enum "GST Group Type";
        DocType: Enum "BankCharges DocumentType";
        DistGSTCredit: Enum "GST Credit";
        RcptGSTCredit: Enum "GST Credit";
    begin
        // [SCENARIO] [355958] Check if the system is handling Intrastate Distribution of Invoice with No Input Tax Credit to Recipient location as Input Tax Credit is not available
        // [FEATURE] [Non ITC Distribution] [IntraState Input Distribution]

        // [GIVEN] Created GST Setup and tax rates for registered Vendor where input tax credit is not available with GST Group Code type is Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        UpdateInputServiceDistributer(true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Create and Post Distribution Document with Document type Inoivce and Distribution GST Credit is Non-Availment and Receipt GST Credit is Non-Availment
        CreateAndPostDistributionDocument(DocType::Invoice, DistGSTCredit::"Non-Availment", RcptGSTCredit::"Non-Availment", false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ApplyDistributionEntries,ConfirmationHandler,DimensionHandler,NoSeriesHandler')]
    procedure PostInterStateInvDistributionNonITCToNonITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type";
        GSTGroupType: Enum "GST Group Type";
        DocType: Enum "BankCharges DocumentType";
        DistGSTCredit: Enum "GST Credit";
        RcptGSTCredit: Enum "GST Credit";
    begin
        // [SCENARIO] [355959] Check if the system is handling Interstate Distribution of Invoice with No Input Tax Credit to Recipient location as Input Tax Credit is not available
        // [FEATURE] [Non ITC Distribution] [InterState Input Distribution]

        // [GIVEN] Created GST Setup and tax rates for registered Vendor where input tax credit is not available with GST Group Code type is Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        UpdateInputServiceDistributer(true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Create and Post Distribution Document with Document type Inoivce and Distribution GST Credit is Non-Availment and Receipt GST Credit is Non-Availment
        CreateAndPostDistributionDocument(DocType::Invoice, DistGSTCredit::"Non-Availment", RcptGSTCredit::"Non-Availment", false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ApplyDistributionEntries,ConfirmationHandler,DimensionHandler,NoSeriesHandler')]
    procedure PostIntraStateInvDistributionITCToITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type";
        GSTGroupType: Enum "GST Group Type";
        DocType: Enum "BankCharges DocumentType";
        DistGSTCredit: Enum "GST Credit";
        RcptGSTCredit: Enum "GST Credit";
    begin
        // [SCENARIO] [355960] Check if the system is handling Intra-state Distribution of Invoice with Input Tax Credit to Recipient location as Input Tax Credit is available
        // [FEATURE] [ITC Distribution] [IntraState Input Distribution]

        // [GIVEN] Created GST Setup and tax rates for registered Vendor where input tax credit is available with GST Group Code type is Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(true, false, false);
        UpdateInputServiceDistributer(true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Create and Post Distribution Document with Document type Inoivce and Distribution GST Credit is Availment and Receipt GST Credit is Availment
        CreateAndPostDistributionDocument(DocType::Invoice, DistGSTCredit::Availment, RcptGSTCredit::Availment, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ApplyDistributionEntries,ConfirmationHandler,DimensionHandler,NoSeriesHandler')]
    procedure PostInterStateInvDistributionITCToITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type";
        GSTGroupType: Enum "GST Group Type";
        DocType: Enum "BankCharges DocumentType";
        DistGSTCredit: Enum "GST Credit";
        RcptGSTCredit: Enum "GST Credit";
    begin
        // [SCENARIO] [355961] Check if the system is handling Interstate Distribution of Invoice with Input Tax Credit to Recipient location as Input Tax Credit is available
        // [FEATURE] [ITC Distribution] [InterState Input Distribution]

        // [GIVEN] Created GST Setup and tax rates for registered Vendor where input tax credit is available with GST Group Code type is Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        UpdateInputServiceDistributer(true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Create and Post Distribution Document with Document type Inoivce and Distribution GST Credit is Availment and Receipt GST Credit is Availment
        CreateAndPostDistributionDocument(DocType::Invoice, DistGSTCredit::Availment, RcptGSTCredit::Availment, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler,ApplyDistributionEntries,ConfirmationHandler,DimensionHandler,NoSeriesHandler')]
    procedure PostIntraStateCrMemoDistributionITCToITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocType: Enum "BankCharges DocumentType";
        DistGSTCredit: Enum "GST Credit";
        RcptGSTCredit: Enum "GST Credit";
    begin
        // [Scenario] [355962] Check if the system is handling Intra-state Distribution of Credit Memo with Input Tax Credit to Recipient location as Input Tax Credit is available
        // [FEATURE] [Intra-State Services, Purchase Credit Memo] [ITC, Registered Vendor]

        // [GIVEN] Created GST Setup and tax rates for registered Vendor where input tax credit is available with GST Group Code type is Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(true, false, false);
        UpdateInputServiceDistributer(true);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line Type as GL Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] Create and Post Distribution Document with Document type Inoivce and Distribution GST Credit is Availment and Receipt GST Credit is Availment
        CreateAndPostDistributionDocument(DocType::"Credit Memo", DistGSTCredit::Availment, RcptGSTCredit::Availment, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler,ApplyDistributionEntries,ConfirmationHandler,DimensionHandler,NoSeriesHandler')]
    procedure PostInterStateCrMemoDistributionITCToITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocType: Enum "BankCharges DocumentType";
        DistGSTCredit: Enum "GST Credit";
        RcptGSTCredit: Enum "GST Credit";
    begin
        // [Scenario] [355966] Check if the system is handling Interstate Distribution of Credit Memo with Input Tax Credit to Recipient location as Input Tax Credit is available
        // [FEATURE] [Inter-State Services, Purchase Credit Memo] [ITC, Registered Vendor]

        // [GIVEN] Created GST Setup and tax rates for registered Vendor where input tax credit is available with GST Group Code type is Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        UpdateInputServiceDistributer(true);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line Type as GL Account for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] Create and Post Distribution Document with Document type Inoivce and Distribution GST Credit is Availment and Receipt GST Credit is Availment
        CreateAndPostDistributionDocument(DocType::"Credit Memo", DistGSTCredit::Availment, RcptGSTCredit::Availment, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler,ApplyDistributionEntries,ConfirmationHandler,DimensionHandler,NoSeriesHandler')]
    procedure PostInterStateCrMemoDistributionNonITCToNonITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocType: Enum "BankCharges DocumentType";
        DistGSTCredit: Enum "GST Credit";
        RcptGSTCredit: Enum "GST Credit";
    begin
        // [Scenario] [355967] Check if the system is handling Intrastate Distribution of Credit Memo with No Input Tax Credit to Recipient location as Input Tax Credit is not available
        // [FEATURE] [Intra-State Services, Purchase Credit Memo] [ITC, Registered Vendor]

        // [GIVEN] Created GST Setup and tax rates for registered Vendor where input tax credit is not available with GST Group Code type is Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        UpdateInputServiceDistributer(true);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line Type as GL Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] Create and Post Distribution Document with Document type Inoivce and Distribution GST Credit is Non-Availment and Receipt GST Credit is Non-Availment
        CreateAndPostDistributionDocument(DocType::"Credit Memo", DistGSTCredit::"Non-Availment", RcptGSTCredit::"Non-Availment", false);
    end;


    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler,ApplyDistributionEntries,ConfirmationHandler,DimensionHandler,NoSeriesHandler')]
    procedure PostIntraStateCrMemoDistributionNonITCToNonITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocType: Enum "BankCharges DocumentType";
        DistGSTCredit: Enum "GST Credit";
        RcptGSTCredit: Enum "GST Credit";
    begin
        // [Scenario] [355968] Check if the system is handling Intrastate Distribution of Credit Memo with No Input Tax Credit to Recipient location as Input Tax Credit is not available
        // [FEATURE] [Intra-State Services, Purchase Credit Memo] [ITC, Registered Vendor]

        // [GIVEN] Created GST Setup and tax rates for registered Vendor where input tax credit is not available with GST Group type is Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        UpdateInputServiceDistributer(true);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line Type as GL Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] Create and Post Distribution Document with Document type Inoivce and Distribution GST Credit is Non-Availment and Receipt GST Credit is Non-Availment
        CreateAndPostDistributionDocument(DocType::"Credit Memo", DistGSTCredit::"Non-Availment", RcptGSTCredit::"Non-Availment", false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ApplyDistributionEntries,ConfirmationHandler,ReferenceInvoiceNoPageHandler,DimensionHandler,NoSeriesHandler')]
    procedure PostDistributionReversalOfCrMemoWithNonITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocType: Enum "BankCharges DocumentType";
        DistGSTCredit: Enum "GST Credit";
        RcptGSTCredit: Enum "GST Credit";
    begin
        // [Scenario] [355971] Check if the system is handling Intrastate Distribution of Credit Memo Reversal with Input Tax Credit is not available

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Jurisdiction type is Intrastate with GST group type Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        UpdateInputServiceDistributer(true);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line Type as GL Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Create and Post Purchase Credit memo with reference invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] Create and Post Distribution Document with Document type Credit Memo and Distribution GST Credit is Availment and Receipt GST Credit is Availment
        CreateAndPostDistributionDocument(DocType::"Credit Memo", DistGSTCredit::"Non-Availment", RcptGSTCredit::"Non-Availment", false);

        // [THEN] Create and Post Reversal Distribution Document where GST Credit is Availment and Receipt GST Credit is Availment
        CreateAndPostDistributionDocument(DocType::"Credit Memo", DistGSTCredit::"Non-Availment", RcptGSTCredit::"Non-Availment", true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler,PurchCredMemoPageHandler')]
    procedure PostedPurchDocumentWithRCMForCancelFeature()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[Scenario] [463547] Check if the system is cancelling Posted Purchase Invoice with RCM and posting purchase credit memo to reverse posted purchase invoice.

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit is Available with GST group type as Service with RCM
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as G/L Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        //[WHEN] Use Action Cancel On Posted Purchase Invoice To Create Posted Credit Memo to reverse posted purchase invoice. 
        CancelPostedPurchaseInvoiceToCreatePostedCreditMemo(PurchInvHeader, PurchaseHeader."No.");

        //[THEN] Verify Posted Credit Memo is created after cancelling Posted Purchase Invoice
        VerifyPostedCreditMemoCreatedAfterPosInvoiceCancelled(PurchInvHeader."No.");
    end;

    [Test]
    procedure CheckGovtVendorGSTRegistrationNo()
    var
        VendorNo: Code[20];
        LocationStateCode: Code[10];
        LocPANNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[Scenario] [468457] Creating Government as Vendor is causing issue while entering GST No.

        //[GIVEN] Created Government Vendor With Govt Pan No and GST Registration No.

        //[WHEN] Create Vendor Setup
        VendorNo := LibraryGST.CreateVendorSetup();

        //[WHEN] Create Govt Vendor PAN No
        LocPANNo := LibraryGST.CreateGovtPANNos();

        //[WHEN] Create Govt Vendor State
        LocationStateCode := LibraryGST.CreateInitialSetup();

        //[THEN] Verify Vendor GST Govt. Registration No
        Assert.IsTrue(libraryGSTPurchase.GetVendorSetupWithGovtGST(VendorNo, GSTVendorType, false, true, LocationStateCode, LocPANNo), 'Sucess');
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler,DocumentArchived')]
    procedure VerifyTaxInformationDataExistInPurchaseOrderArchive()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[Scenario] [398967] Check if the system is showing tax information in Purchase Order Archive Page

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit is Available with GST group type as Service with RCM
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as G/L Account for Intrastate Transactions.
        LibraryPurchase.SetArchiveOrders(true);
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        //[THEN] Verify Tax Transaction Value Exist for Purchase Order Archive
        VerifyTaxTransactionValueExist(PurchaseHeader."Document Type", PurchaseHeader."No.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler,DocumentArchived')]
    procedure VerifyTaxInformationDataExistInBlanketPurchaseOrderArchive()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[Scenario] [398967] Check if the system is showing tax information in Purchase Order Archive Page

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit is Available with GST group type as Service with RCM
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Archive Blanket Purchase Order with GST and Line Type as Item for Intrastate Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Item", DocumentType::"Blanket Order");
        BlanketPurchaseOrderArchive(PurchaseHeader);

        //[THEN] Verify Tax Transaction Value Exist for Purchase Order Archive
        VerifyTaxTransactionValueExist(PurchaseHeader."Document Type", PurchaseHeader."No.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler,DocumentArchived')]
    procedure VerifyTaxInformationDataExistInPurchaseQuoteArchive()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[Scenario] [398967] Check if the system is showing tax information in Purchase Quote Archive Page

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit is Available with GST group type as Service with RCM
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Archive Purchase Quote with GST and Line Type as Item for Intrastate Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Item", DocumentType::"Quote");
        PurchaseQuoteArchive(PurchaseHeader);

        //[THEN] Verify Tax Transaction Value Exist for Purchase Order Archive
        VerifyTaxTransactionValueExist(PurchaseHeader."Document Type", PurchaseHeader."No.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler,DocumentArchived')]
    procedure VerifyTaxInformationDataExistInPurchaseReturnOrderArchive()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[Scenario] [398967] Check if the system is showing tax information in Purchase Return Order Archive Page

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit is Available with GST group type as Service with RCM
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Archive Purchase Return Order with GST and Line Type as Item for Intrastate Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Item", DocumentType::"Return Order");
        PurchaseReturnOrderArchive(PurchaseHeader);

        //[THEN] Verify Tax Transaction Value Exist for Purchase Return Order Archive
        VerifyTaxTransactionValueExist(PurchaseHeader."Document Type", PurchaseHeader."No.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostApplicationFromPurchRCMInvVendorWithNormalPayment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntryPayment: Record "Vendor Ledger Entry";
        VendorLedgerEntryInvoice: Record "Vendor Ledger Entry";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
        VendorNo: Code[20];
    begin
        // [SCENARIO] [IN BC] Unapplying a payment with a RCM invoice is not reversing the GST related entries.
        InitializeShareStep(true, false, false);

        // [GIVEN] Create GST Setup, and tax rates for Unregistered Vendor with input Tax Credit is availment where Jurisdiction type is Interstate
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, false, true);
        Storage.Set(NoOfLineLbl, '1');
        Evaluate(VendorNo, Storage.Get(VendorNoLbl));

        // [GIVEN] Create and Post Purchase Invoice with GST and Line type as G/L Account
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [GIVEN] Post Bank Payment Voucher
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] Post Apply Payment to Invoice
        VendorLedgerEntryPayment.SetRange("Vendor No.", VendorNo);
        VendorLedgerEntryPayment.SetRange("Document Type", VendorLedgerEntryPayment."Document Type"::Payment);

        LibraryERM.SetAppliestoIdVendor(VendorLedgerEntryPayment);

        VendorLedgerEntryInvoice.SetRange("Vendor No.", VendorNo);
        LibraryERM.FindVendorLedgerEntry(
          VendorLedgerEntryInvoice, VendorLedgerEntryInvoice."Document Type"::Invoice, DocumentNo);

        LibraryERM.SetAppliestoIdVendor(VendorLedgerEntryInvoice);

        LibraryERM.PostVendLedgerApplication(VendorLedgerEntryPayment);

        // [WHEN] Unapply Vendor Ledger Payment Entry
        UnapplyVendLedgerEntry(VendorLedgerEntryPayment."Document Type", VendorLedgerEntryPayment."Document No.");

        // [THEN] G/L Entries are created and verified
        LibraryGST.VerifyGLEntries(VendorLedgerEntryPayment."Document Type", VendorLedgerEntryPayment."Document No.", 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvServicesForRegVendorWithOfflineApplicationApplyPaymentToInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the system is Successfully posting offline application of GST payment to Invoice of Services Registered Vendor where Input Tax Credit is available - Inter-State through Purchase Invoice]

        // [GIVEN] Create GST Setup and tax rates for Registered Vendor with input Tax Credit is availment where Jurisdiction type is Interstate
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Payment Voucher with GST Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Payment Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Purchase Orderwhere line type is G/L account
        PostedDocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Apply Vendor Ledger Entry and Verify
        LibraryERM.ApplyVendorLedgerEntries(GenJournalDocumentType::Payment, GenJournalDocumentType::Invoice, (Storage.Get(PaymentDocNoLbl)), PostedDocumentNo);
        VerifyAdvInvoiceApplied(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvRegVendWithNonITCItemInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        InventorySetup: Record "Inventory Setup";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [381415] Check if system is calculating GST Amount for Registered Vendor Interstate with Goods on Purchase Invoice with Non-Availment and impact on Item Ledger Entries.
        // [FEATURE] [Goods] [ITC Non Availment, Registered Vendor, Inter-State]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Non Available with GST group type as Goods
        CreateGeneralLedgerSetup();
        InventorySetup."Automatic Cost Posting" := true;
        InventorySetup."Automatic Cost Adjustment" := InventorySetup."Automatic Cost Adjustment"::Always;

        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as item for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocumentForPurchInv(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTLedgerEntriesAmount(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ApplyDistributionEntries,ConfirmationHandler,DimensionHandler,NoSeriesHandler')]
    procedure PostInterStateInvDistributionITCToITCWithLocationDistNo()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type";
        GSTGroupType: Enum "GST Group Type";
        DocType: Enum "BankCharges DocumentType";
        DistGSTCredit: Enum "GST Credit";
        RcptGSTCredit: Enum "GST Credit";
    begin
        // [SCENARIO]Check if the system is handling Interstate Distribution of Invoice with Input Tax Credit to Recipient location as Input Tax Credit is available
        // [FEATURE] [ITC Distribution] [InterState Input Distribution]

        // [GIVEN] Created GST Setup and tax rates for registered Vendor where input tax credit is available with GST Group Code type is Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        UpdateInputServiceDistributer(true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Create and Post Distribution Document with Document type Inoivce and Distribution GST Credit is Availment and Receipt GST Credit is Availment
        CreateAndPostDistributionDocumentNo(DocType::Invoice, DistGSTCredit::Availment, RcptGSTCredit::Availment, false);
    end;

    local procedure VerifyTaxTransactionValueExist(DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20])
    var
        PurchaseLineArchive: Record "Purchase Line Archive";
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        PurchaseLineArchive.SetRange("Document Type", DocumentType);
        PurchaseLineArchive.SetRange("Document No.", DocumentNo);
        PurchaseLineArchive.FindLast();

        TaxTransactionValue.SetFilter("Document Type Filter", '%1', DocumentType);
        TaxTransactionValue.SetFilter("Document No. Filter", '%1', DocumentNo);
        TaxTransactionValue.SetFilter("Line No. Filter", '%1', PurchaseLineArchive."Line No.");
        TaxTransactionValue.SetFilter("Version No. Filter", '%1', PurchaseLineArchive."Version No.");
        if TaxTransactionValue.IsEmpty then
            Error(TaxTransactionValueEmptyErr, PurchaseLineArchive.RecordId());
    end;

    local procedure BlanketPurchaseOrderArchive(PurchaseHeader: Record "Purchase Header")
    var
        BlanketPurchaseOrder: TestPage "Blanket Purchase Order";
    begin
        BlanketPurchaseOrder.OpenView();
        BlanketPurchaseOrder.GoToRecord(PurchaseHeader);
        BlanketPurchaseOrder."Archi&ve Document".Invoke();
    end;

    local procedure PurchaseQuoteArchive(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseQuote: TestPage "Purchase Quote";
    begin
        PurchaseQuote.OpenView();
        PurchaseQuote.GoToRecord(PurchaseHeader);
        PurchaseQuote."Archive Document".Invoke();
    end;

    local procedure PurchaseReturnOrderArchive(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseReturnOrder: TestPage "Purchase Return Order";
    begin
        PurchaseReturnOrder.OpenView();
        PurchaseReturnOrder.GoToRecord(PurchaseHeader);
        PurchaseReturnOrder."Archive Document".Invoke();
    end;

    local procedure CancelPostedPurchaseInvoiceToCreatePostedCreditMemo(PurchInvHeader: Record "Purch. Inv. Header"; PurchaseOrderNo: Code[20])
    var
        PostedPurchInvoice: TestPage "Posted Purchase Invoice";
    begin
        PurchInvHeader.SetRange("Order No.", PurchaseOrderNo);
        PurchInvHeader.FindFirst();
        PostedPurchInvoice.OpenEdit();
        PostedPurchInvoice.GoToRecord(PurchInvHeader);
        PostedPurchInvoice.CancelInvoice.Invoke();
    end;

    local procedure InitializeShareStep(InputCreditAvailment: Boolean; Exempted: Boolean; LineDiscount: Boolean)
    begin
        StorageBoolean.Set(InputCreditAvailmentLbl, InputCreditAvailment);
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
    end;

    local procedure CreateGSTSetup(GSTVendorType: Enum "GST Vendor Type"; GSTGroupType: Enum "GST Group Type"; IntraState: Boolean; ReverseCharge: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        TaxComponent: Record "Tax Component";
        CompanyInformation: Record "Company information";
        LocationStateCode: Code[10];
        VendorNo: Code[20];
        GSTGroupCode: Code[20];
        LocationCode: Code[10];
        HSNSACCode: Code[10];
        VendorStateCode: Code[10];
        LocPANNo: Code[20];
        LocationGSTRegNo: Code[15];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTComponentCode: Text[30];
    begin
        CompanyInformation.Get();

        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := LibraryGST.CreatePANNos();
            CompanyInformation.Modify();
        end else
            LocPANNo := CompanyInformation."P.A.N. No.";
        LocPANNo := CompanyInformation."P.A.N. No.";
        LocationStateCode := LibraryGST.CreateInitialSetup();
        Storage.Set(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true)
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        Storage.Set(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::"Bill-to Address", ReverseCharge);
        Storage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        Storage.Set(HSNSACCodeLbl, HSNSACCode);

        if IntraState then begin
            VendorNo := LibraryGST.CreateVendorSetup();
            libraryGSTPurchase.UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, LocationStateCode, LocPANNo);
            InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
            libraryGSTPurchase.CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
        end else begin
            VendorStateCode := LibraryGST.CreateGSTStateCode();
            VendorNo := LibraryGST.CreateVendorSetup();
            libraryGSTPurchase.UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, VendorStateCode, LocPANNo);

            if GSTVendorType in [GSTVendorType::Import, GSTVendorType::SEZ] then
                InitializeTaxRateParameters(IntraState, '', LocationStateCode)
            else begin
                InitializeTaxRateParameters(IntraState, VendorStateCode, LocationStateCode);
                libraryGSTPurchase.CreateGSTComponentAndPostingSetup(IntraState, VendorStateCode, TaxComponent, GSTComponentCode);
            end;
        end;
        Storage.Set(VendorNoLbl, VendorNo);

        CreateTaxRate();
        libraryGSTPurchase.CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
    end;

    local procedure CreateTaxRate()
    var
        GSTSetup: Record "GST Setup";
        TaxTypes: TestPage "Tax Types";
    begin
        if not GSTSetup.Get() then
            exit;

        TaxTypes.OpenEdit();
        TaxTypes.Filter.SetFilter(Code, GSTSetup."GST Tax Type");
        TaxTypes.TaxRates.Invoke();
    end;

    local procedure CreateGenJnlLineForVoucherWithAdvancePayment(
        var GenJournalLine: Record "Gen. Journal Line";
        TemplateType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VendorNo: Code[20];
        LocationCode: Code[10];
        AccountType: Enum "Gen. Journal Account Type";
    begin
        CreateLocationWithVoucherSetup(TemplateType);
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);

        VendorNo := CopyStr(Storage.Get(VendorNoLbl), 1, 20);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        Evaluate(AccountType, Storage.Get(AccountTypeLbl));

        LibraryJournals.CreateGenJournalLine(
            GenJournalLine,
            GenJournalTemplate.Name,
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Vendor,
            VendorNo,
            AccountType,
            CopyStr(Storage.Get(AccountNoLbl), 1, 20),
            LibraryRandom.RandIntInRange(1, 10000));

        GenJournalLine.Validate("Location Code", LocationCode);
        GenJournalLine.Validate("GST Group Code", CopyStr(Storage.Get(GSTGroupCodeLbl), 1, 20));
        GenJournalLine.Validate("HSN/SAC Code", CopyStr(Storage.Get(HSNSACCodeLbl), 1, 10));
        GenJournalLine.Validate("GST on Advance Payment", true);
        GenJournalLine.Modify(true);
        CalculateGST(GenJournalLine);
    end;

    local procedure CreateAndPostPurchaseDocumentWithApplication(
            var PurchaseHeader: Record "Purchase Header";
            var PurchaseLine: Record "Purchase Line";
            LineType: Enum "Purchase Line Type";
                          DocumentType: Enum "Purchase Document Type"): Code[20];
    var
        VendorNo: Code[20];
        LocationCode: Code[10];
        DocumentNo: Code[20];
        PurchaseInvoiceType: Enum "GST Invoice Type";
    begin
        Evaluate(VendorNo, Storage.Get(VendorNoLbl));
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(InputCreditAvailmentLbl), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));

        if not (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Quote) then begin
            PurchaseHeader.Validate("Applies-to Doc. Type", PurchaseHeader."Applies-to Doc. Type"::Payment);
            PurchaseHeader.Validate("Applies-to Doc. No.", Storage.Get(PaymentDocNoLbl));
            DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
            Storage.Set(PostedDocumentNoLbl, DocumentNo);
            exit(DocumentNo);
        end;
    end;

    local procedure CreateGenJnlLineForVoucher(
            var GenJournalLine: Record "Gen. Journal Line";
            TemplateType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VendorNo: Code[20];
        LocationCode: Code[10];
        AccountType: Enum "Gen. Journal Account Type";
    begin
        CreateLocationWithVoucherSetup(TemplateType);
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);

        VendorNo := CopyStr(Storage.Get(VendorNoLbl), 1, 20);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        Evaluate(AccountType, Storage.Get(AccountTypeLbl));

        LibraryJournals.CreateGenJournalLine(
            GenJournalLine,
            GenJournalTemplate.Name,
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Vendor,
            VendorNo,
            AccountType,
            CopyStr(Storage.Get(AccountNoLbl), 1, 20),
            LibraryRandom.RandIntInRange(1, 10000));

        GenJournalLine.Validate("Location Code", LocationCode);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateGenJournalTemplateBatch(
        var GenJournalTemplate: Record "Gen. Journal Template";
        var GenJournalBatch: Record "Gen. Journal Batch";
        TemplateType: Enum "Gen. Journal Template Type")
    var
        LocationCode: Code[10];
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, TemplateType);
        GenJournalTemplate.Modify(true);

        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Location Code", LocationCode);
        GenJournalBatch.Modify(true);
    end;

    local procedure UnapplyVendLedgerEntry(DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]);
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, DocumentType, DocumentNo);
        LibraryERM.UnapplyVendorLedgerEntry(VendorLedgerEntry);
    end;

    local procedure VerifyAdvPaymentUnapplied()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.SetRange("Document No.", Storage.Get(PaymentDocNoLbl));
        VendorLedgerEntry.FindFirst();

        Assert.AreEqual(true, VendorLedgerEntry.Open, StrSubstNo(VendLedgerEntryVerifyErr, VendorLedgerEntry.FieldName(Open), VendorLedgerEntry.TableCaption));
    end;

    local procedure VerifyAdvPaymentApplied()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.SetRange("Document No.", Storage.Get(PaymentDocNoLbl));
        VendorLedgerEntry.FindFirst();
        VendorLedgerEntry.CalcFields(Amount, "Remaining Amount");

        Assert.AreNotEqual(VendorLedgerEntry.Amount, VendorLedgerEntry."Remaining Amount", StrSubstNo(VendLedgerEntryVerifyErr, VendorLedgerEntry.FieldName("Remaining Amount"), VendorLedgerEntry.TableCaption));
    end;

    local procedure VerifyAdvInvoiceApplied(PostedDocumentNo: Code[20])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetRange("Document No.", PostedDocumentNo);
        VendorLedgerEntry.FindFirst();
        VendorLedgerEntry.CalcFields(Amount, "Remaining Amount");

        Assert.AreNotEqual(VendorLedgerEntry.Amount, VendorLedgerEntry."Remaining Amount", StrSubstNo(VendLedgerEntryVerifyErr, VendorLedgerEntry.FieldName("Remaining Amount"), VendorLedgerEntry.TableCaption));
    end;

    local procedure CalculateGST(GenJournalLine: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnGenJnlLine(GenJournalLine, GenJournalLine);
    end;

    local procedure CreateAndPostGSTLiabilityJournal(CrLibtyAdjustmentType: Enum "Cr Libty Adjustment Type")
    var
        location: Record Location;
        GSTLiabilityAdjustment: TestPage "GST Liability Adjustment";
    begin
        GSTLiabilityAdjustment.OpenEdit();
        location.Get(Storage.Get(LocationCodeLbl));
        GSTLiabilityAdjustment.GSTINNo2.SetValue(location."GST Registration No.");
        GSTLiabilityAdjustment.PostingDate2.SetValue(WorkDate());
        GSTLiabilityAdjustment.LiabilityDateFormula2.SetValue('0D');
        GSTLiabilityAdjustment.VendorNo2.SetValue(Storage.Get(VendorNoLbl));
        GSTLiabilityAdjustment.NatureOfAdjustment2.SetValue(CrLibtyAdjustmentType);
        GSTLiabilityAdjustment.ApplyEntries.Invoke();
    end;

    local procedure CreateAndPostAdjustmentJournal(CreditAdjustmentType: Enum "Credit Adjustment Type"; ReverseCharge: Boolean; AdjustmentPercent: Integer)
    var
        location: Record Location;
        GSTCreditAdjustment: TestPage "GST Credit Adjustment";
    begin
        GSTCreditAdjustment.OpenEdit();
        location.Get(Storage.Get(LocationCodeLbl));
        GSTCreditAdjustment.GSTINNo2.SetValue(location."GST Registration No.");
        GSTCreditAdjustment.PeriodMonth2.SetValue(Date2DMY(WorkDate(), 2));
        GSTCreditAdjustment.PeriodYear2.SetValue(Date2DMY(WorkDate(), 3));
        GSTCreditAdjustment.PostingDate2.SetValue(CalcDate('<1M>', WorkDate()));
        GSTCreditAdjustment.VendorNo2.SetValue(Storage.Get(VendorNoLbl));
        GSTCreditAdjustment.NatureOfAdjustment2.SetValue(CreditAdjustmentType);
        GSTCreditAdjustment.ReverseCharge2.SetValue(ReverseCharge);
        GSTCreditAdjustment.AdjustmentPerc2.SetValue(AdjustmentPercent);
        GSTCreditAdjustment.ApplyEntries.Invoke();

        VerifyCreditAdjustmentEntries(CreditAdjustmentType);
    end;

    local procedure VerifyCreditAdjustmentEntries(CreditAdjustmentType: Enum "Credit Adjustment Type")
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        DetailedGSTLedgerEntry.SetRange("Document No.", Storage.Get(PostedDocumentNoLbl));
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
        DetailedGSTLedgerEntry.SetRange("Credit Adjustment Type", CreditAdjustmentType);
        DetailedGSTLedgerEntry.FindFirst();

        Assert.RecordIsNotEmpty(DetailedGSTLedgerEntry);
    end;

    local procedure CreateLocationWithVoucherSetup(Type: Enum "Gen. Journal Template Type"): Code[20]
    var
        BankAccount: Record "Bank Account";
        GLAccount: Record "G/L Account";
        LocationCode: Code[10];
        AccountType: Enum "Gen. Journal Account Type";
    begin
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        case Type of
            Type::"Bank Payment Voucher", Type::"Bank Receipt Voucher":
                begin
                    LibraryERM.CreateBankAccount(BankAccount);
                    Storage.Set(AccountNoLbl, BankAccount."No.");
                    Storage.Set(AccountTypeLbl, Format(AccountType::"Bank Account"));
                    CreateVoucherAccountSetup(Type, LocationCode);
                end;
            Type::"Contra Voucher", Type::"Cash Receipt Voucher":
                begin
                    LibraryERM.CreateGLAccount(GLAccount);
                    Storage.Set(AccountNoLbl, GLAccount."No.");
                    Storage.Set(AccountTypeLbl, Format(AccountType::"G/L Account"));
                    CreateVoucherAccountSetup(Type, LocationCode);
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
                end;
            SubType::"Cash Receipt Voucher", SubType::"Bank Receipt Voucher", SubType::"Journal Voucher":
                begin
                    TaxBaseTestPublishers.InsertJournalVoucherPostingSetupWithLocationCode(SubType, LocationCode, TransactionDirection::Debit);
                    TaxBaseTestPublishers.InsertVoucherDebitAccountNoWithLocationCode(SubType, LocationCode, AccountNo);
                end;
        end;
    end;

    local procedure CreateAndPostPurchaseDocument(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
                      DocumentType: Enum "Purchase Document Type"): Code[20];
    var
        VendorNo: Code[20];
        LocationCode: Code[10];
        DocumentNo: Code[20];
        PurchaseInvoiceType: Enum "GST Invoice Type";
    begin
        Evaluate(VendorNo, Storage.Get(VendorNoLbl));
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(InputCreditAvailmentLbl), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));

        if not (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Quote) then begin
            DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
            Storage.Set(PostedDocumentNoLbl, DocumentNo);
            exit(DocumentNo);
        end;
    end;

    local procedure CreatePurchaseDocument(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
                      DocumentType: Enum "Purchase Document Type")
    var
        VendorNo: Code[20];
        LocationCode: Code[10];
        PurchaseInvoiceType: Enum "GST Invoice Type";
    begin
        Evaluate(VendorNo, Storage.Get(VendorNoLbl));
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(InputCreditAvailmentLbl), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
    end;

    local procedure InitializeTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10])
    var
        GSTTaxPercent: Decimal;
    begin
        Storage.Set(FromStateCodeLbl, FromState);
        Storage.Set(ToStateCodeLbl, ToState);
        GSTTaxPercent := LibraryRandom.RandDecInRange(10, 18, 0);
        StorageDecimal.Set(GSTTaxPercentLbl, GSTTaxPercent);
        if IntraState then begin
            ComponentPerArray[1] := (GSTTaxPercent / 2);
            ComponentPerArray[2] := (GSTTaxPercent / 2);
            ComponentPerArray[3] := 0;
        end else
            ComponentPerArray[3] := GSTTaxPercent;
    end;

    local procedure UpdateInputServiceDistributer(InputServiceDistribute: Boolean)
    var
        LocationCod: Code[10];
    begin
        LocationCod := CopyStr(Storage.Get(LocationCodeLbl), 1, 10);
        LibraryGST.UpdateLocationWithISD(LocationCod, InputServiceDistribute);
    end;

    local procedure CreatePurchaseHeaderWithGST(
        VAR PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        DocumentType: Enum "Purchase Document Type";
                          LocationCode: Code[10];
                          PurchaseInvoiceType: Enum "GST Invoice Type")
    var
        LibraryUtility: Codeunit "Library - Utility";
        Overseas: Boolean;
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Location Code", LocationCode);

        if Overseas then
            PurchaseHeader.Validate("POS Out Of India", true);

        if PurchaseInvoiceType in [PurchaseInvoiceType::"Debit Note", PurchaseInvoiceType::Supplementary] then
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.fieldno("Vendor Invoice No."), Database::"Purchase Header"))
        else
            PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.fieldno("Vendor Cr. Memo No."), Database::"Purchase Header"));

        if PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::SEZ then begin
            PurchaseHeader."Bill of Entry No." := LibraryUtility.GenerateRandomCode(PurchaseHeader.fieldno("Bill of Entry No."), Database::"Purchase Header");
            PurchaseHeader."Bill of Entry Date" := WorkDate();
            PurchaseHeader."Bill of Entry Value" := LibraryRandom.RandInt(1000);
        end;

        PurchaseHeader.Modify(true);
    end;

    local procedure CreatePurchaseLineWithGST(var PurchaseHeader: Record "Purchase Header";
                                              var PurchaseLine: Record "Purchase Line";
                                              LineType: Enum "Purchase Line Type";
                                              Quantity: Decimal;
                                              InputCreditAvailment: Boolean;
                                              Exempted: Boolean;
                                              LineDiscount: Boolean);
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LineTypeNo: Code[20];
        LineNo: Integer;
        NoOfLine: Integer;
    begin
        Exempted := StorageBoolean.Get(ExemptedLbl);
        Evaluate(NoOfLine, Storage.Get(NoOfLineLbl));
        InputCreditAvailment := StorageBoolean.Get(InputCreditAvailmentLbl);
        for LineNo := 1 to NoOfLine do begin
            case LineType of
                LineType::Item:
                    LineTypeNo := LibraryGST.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
                LineType::"G/L Account":
                    LineTypeNo := LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, FALSE);
                LineType::"Fixed Asset":
                    LineTypeNo := LibraryGST.CreateFixedAssetWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
                LineType::"Charge (Item)":
                    LineTypeNo := LibraryGST.CreateChargeItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
            end;

            LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, LineType, LineTypeno, Quantity);

            PurchaseLine.Validate("VAT Prod. Posting Group", VATPostingsetup."VAT Prod. Posting Group");
            if InputCreditAvailment then
                PurchaseLine."GST Credit" := PurchaseLine."GST Credit"::Availment
            else
                PurchaseLine."GST Credit" := PurchaseLine."GST Credit"::"Non-Availment";

            if LineDiscount then begin
                PurchaseLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
                LibraryGST.UpdateLineDiscAccInGeneralPostingSetup(PurchaseLine."Gen. Bus. Posting Group", PurchaseLine."Gen. Prod. Posting Group");
            end;

            if ((PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ])) and (PurchaseLine.Type = PurchaseLine.Type::"Fixed Asset") then
                PurchaseLine.Validate("GST Assessable Value", LibraryRandom.RandInt(1000))
            else
                if (PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ]) then begin
                    PurchaseLine.Validate("GST Assessable Value", LibraryRandom.RandInt(1000));
                    PurchaseLine.Validate("Custom Duty Amount", LibraryRandom.RandInt(1000));
                end;
            PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandInt(1000));
            StorageDecimal.set(LineAmountLbl, PurchaseLine."Line Amount");
            PurchaseLine.Modify(true);
        end;
    end;

    local procedure CreateInitialSetupForGSTDistribution()
    var
        SourceCodeSetup: Record "Source Code Setup";
        SourceCode: Record "Source Code";
        PostingNoSeries: Record "Posting No. Series";
    begin
        if SourceCodeSetup."GST Distribution" = '' then begin
            SourceCode.Init();
            SourceCode.Code := (LibraryRandom.RandText(10));
            SourceCode.Insert();

            SourceCodeSetup."GST Distribution" := SourceCode.Code;
            SourceCodeSetup.Modify();
        end;

        PostingNoSeries.SetRange("Document Type", PostingNoSeries."Document Type"::"GST Distribution");
        PostingNoSeries.SetFilter("Posting No. Series", '<>%1', '');
        if not PostingNoSeries.FindFirst() then begin
            PostingNoSeries.Init();
            PostingNoSeries.Validate("Document Type", PostingNoSeries."Document Type"::"GST Distribution");
            PostingNoSeries.Validate("Posting No. Series", LibraryERM.CreateNoSeriesCode());
            PostingNoSeries.Insert(true);
        end;

        SetupGSTComponentMapping();
    end;

    local procedure CreateInitialSetupForGSTDistributionLine()
    var
        SourceCodeSetup: Record "Source Code Setup";
        SourceCode: Record "Source Code";
        PostingNoSeries: Record "Posting No. Series";
    begin
        if SourceCodeSetup."GST Distribution" = '' then begin
            SourceCode.Init();
            SourceCode.Code := (LibraryRandom.RandText(10));
            SourceCode.Insert();

            SourceCodeSetup."GST Distribution" := SourceCode.Code;
            SourceCodeSetup.Modify();
        end;

        PostingNoSeries.SetRange("Document Type", PostingNoSeries."Document Type"::"GST Distribution Line");
        PostingNoSeries.SetFilter("Posting No. Series", '<>%1', '');
        if not PostingNoSeries.FindFirst() then begin
            PostingNoSeries.Init();
            PostingNoSeries.Validate("Document Type", PostingNoSeries."Document Type"::"GST Distribution Line");
            PostingNoSeries.Validate("Posting No. Series", LibraryERM.CreateNoSeriesCode());
            PostingNoSeries.Insert(true);
        end;

        SetupGSTComponentMapping();
    end;

    local procedure SetupGSTComponentMapping()
    var
        GSTComponentDistribution: Record "GST Component Distribution";
    begin
        if GSTComponentDistribution.IsEmpty then begin
            GSTComponentDistribution.Init();
            GSTComponentDistribution.Validate("GST Component Code", CGSTLbl);
            GSTComponentDistribution.Validate("Distribution Component Code", CGSTLbl);
            GSTComponentDistribution.Validate("Intrastate Distribution", true);
            GSTComponentDistribution.Insert(true);

            GSTComponentDistribution.Init();
            GSTComponentDistribution.Validate("GST Component Code", CGSTLbl);
            GSTComponentDistribution.Validate("Distribution Component Code", IGSTLbl);
            GSTComponentDistribution.Validate("Interstate Distribution", true);
            GSTComponentDistribution.Insert(true);

            GSTComponentDistribution.Init();
            GSTComponentDistribution.Validate("GST Component Code", SGSTLbl);
            GSTComponentDistribution.Validate("Distribution Component Code", SGSTLbl);
            GSTComponentDistribution.Validate("Intrastate Distribution", true);
            GSTComponentDistribution.Insert(true);

            GSTComponentDistribution.Init();
            GSTComponentDistribution.Validate("GST Component Code", SGSTLbl);
            GSTComponentDistribution.Validate("Distribution Component Code", IGSTLbl);
            GSTComponentDistribution.Validate("Interstate Distribution", true);
            GSTComponentDistribution.Insert(true);

            GSTComponentDistribution.Init();
            GSTComponentDistribution.Validate("GST Component Code", IGSTLbl);
            GSTComponentDistribution.Validate("Distribution Component Code", IGSTLbl);
            GSTComponentDistribution.Validate("Intrastate Distribution", true);
            GSTComponentDistribution.Validate("Interstate Distribution", true);
            GSTComponentDistribution.Insert(true);
        end;
    end;

    local procedure VerifyGSTDistribution(DocumentNo: Code[20])
    var
        PostedGSTDistributionHeader: Record "Posted GST Distribution Header";
        PostedGSTDistributionLine: Record "Posted GST Distribution Line";
    begin
        PostedGSTDistributionHeader.SetRange("Pre Distribution No.", DocumentNo);
        PostedGSTDistributionHeader.FindFirst();
        Assert.RecordIsNotEmpty(PostedGSTDistributionHeader);

        Storage.Set(PostedDistributionNoLbl, PostedGSTDistributionHeader."No.");

        PostedGSTDistributionLine.SetRange("Distribution No.", PostedGSTDistributionHeader."No.");
        PostedGSTDistributionLine.FindFirst();
        Assert.RecordIsNotEmpty(PostedGSTDistributionLine);
    end;

    procedure ApplyAndPostEntries(DocumentNo: Code[20]; Reversal: Boolean)
    var
        GSTDistribution: Codeunit "GST Distribution";
        PageGSTDistribution: TestPage "GST Distribution";
        PageGSTDistributionReversal: TestPage "GST Distribution Reversal";
    begin
        if Reversal then begin
            PageGSTDistributionReversal.OpenEdit();
            PageGSTDistributionReversal.Filter.SetFilter("No.", DocumentNo);
            PageGSTDistributionReversal."Posting Date".SetValue(WorkDate());
            PageGSTDistributionReversal."Apply Entries".Invoke();
            PageGSTDistributionReversal.Dimensions.Invoke();
        end else begin
            PageGSTDistribution.OpenEdit();
            PageGSTDistribution.Filter.SetFilter("No.", DocumentNo);
            PageGSTDistribution."Posting Date".SetValue(WorkDate());
            PageGSTDistribution."Apply Entries".Invoke();
            PageGSTDistribution.Dimensions.Invoke();
            PageGSTDistribution."No.".AssistEdit();
        end;

        GSTDistribution.InsertDistComponentAmount(DocumentNo, Reversal);
        if Reversal then
            GSTDistribution.PostGSTDistribution(DocumentNo, (Storage.Get(PostedDistributionNoLbl)), Reversal)
        else
            GSTDistribution.PostGSTDistribution(DocumentNo, '', false);
    end;

    local procedure CreateToLocation(): Code[20]
    var
        State: Record State;
        TaxComponent: Record "Tax Component";
        LocationGSTRegNo: Code[15];
        LocPANNo: Code[20];
        LocationCode: Code[10];
    begin
        LocPANNo := LibraryGST.CreatePANNos();
        LibraryGST.CreateState(State);
        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(State.Code, LocPANNo);
        LocationCode := LibraryGST.CreateLocationSetup(State.Code, LocationGSTRegNo, false);

        TaxComponent.SetFilter(Name, '%1|%2|%3', CGSTLbl, SGSTLbl, IGSTLbl);
        if TaxComponent.FindSet() then
            repeat
                LibraryGST.CreateGSTPostingSetup(TaxComponent, State.Code)
            until TaxComponent.Next() = 0;

        exit(LocationCode);
    end;

    local procedure CreateAndPostDistributionDocument(
            DocType: Enum "BankCharges DocumentType";
                         DistGSTCredit: Enum "GST Credit";
                         RcptGSTCredit: Enum "GST Credit";
                         Reversal: Boolean)
    var
        GSTDistributionHeader: Record "GST Distribution Header";
        GSTDistributionLine: Record "GST Distribution Line";
        DimensionValue: Record "Dimension Value";
        DocumentNo: Code[20];
    begin
        CreateInitialSetupForGSTDistribution();
        GSTDistributionHeader.Init();
        GSTDistributionHeader.Insert(true);
        GSTDistributionHeader.Validate("Posting Date", WorkDate());
        if Reversal then begin
            GSTDistributionHeader.Validate(Reversal, Reversal);
            GSTDistributionHeader.Validate("Reversal Invoice No.", Storage.Get(PostedDistributionNoLbl));
        end else begin
            if DocType = DocType::Invoice then
                GSTDistributionHeader.Validate("ISD Document Type", GSTDistributionHeader."ISD Document Type"::Invoice)
            else
                GSTDistributionHeader.Validate("ISD Document Type", GSTDistributionHeader."ISD Document Type"::"Credit Memo");
            GSTDistributionHeader.Validate("From Location Code", Storage.Get(LocationCodeLbl));
            GSTDistributionHeader.Validate("Dist. Document Type", DocType);
            GSTDistributionHeader.Validate("Dist. Credit Type", DistGSTCredit);
        end;
        GSTDistributionHeader.Modify(true);

        if not Reversal then begin
            GSTDistributionLine.Init();
            GSTDistributionLine.Validate("Distribution No.", GSTDistributionHeader."No.");
            GSTDistributionLine.Validate("To Location Code", CreateToLocation());
            GSTDistributionLine.Validate("Rcpt. Credit Type", RcptGSTCredit);
            GSTDistributionLine.Validate("Distribution %", 100);
            GSTDistributionLine.Insert(true);
        end;

        DimensionValue.SetRange("Global Dimension No.", 1);
        if DimensionValue.FindFirst() then
            GSTDistributionHeader.Validate("Shortcut Dimension 1 Code", DimensionValue.Code);

        DimensionValue.SetRange("Global Dimension No.", 2);
        if DimensionValue.FindFirst() then
            GSTDistributionHeader.Validate("Shortcut Dimension 2 Code", DimensionValue.Code);
        GSTDistributionHeader.Modify(true);

        DocumentNo := GSTDistributionHeader."No.";
        ApplyAndPostEntries(GSTDistributionHeader."No.", Reversal);
        VerifyGSTDistribution(DocumentNo);
    end;

    local procedure CreateAndPostDistributionDocumentNo(
            DocType: Enum "BankCharges DocumentType";
                         DistGSTCredit: Enum "GST Credit";
                         RcptGSTCredit: Enum "GST Credit";
                         Reversal: Boolean)
    var
        GSTDistributionHeader: Record "GST Distribution Header";
        GSTDistributionLine: Record "GST Distribution Line";
        DimensionValue: Record "Dimension Value";
        DocumentNo: Code[20];
    begin
        CreateInitialSetupForGSTDistribution();
        CreateInitialSetupForGSTDistributionLine();
        GSTDistributionHeader.Init();
        GSTDistributionHeader.Insert(true);
        GSTDistributionHeader.Validate("Posting Date", WorkDate());
        if Reversal then begin
            GSTDistributionHeader.Validate(Reversal, Reversal);
            GSTDistributionHeader.Validate("Reversal Invoice No.", Storage.Get(PostedDistributionNoLbl));
        end else begin
            if DocType = DocType::Invoice then
                GSTDistributionHeader.Validate("ISD Document Type", GSTDistributionHeader."ISD Document Type"::Invoice)
            else
                GSTDistributionHeader.Validate("ISD Document Type", GSTDistributionHeader."ISD Document Type"::"Credit Memo");
            GSTDistributionHeader.Validate("From Location Code", Storage.Get(LocationCodeLbl));
            GSTDistributionHeader.Validate("Dist. Document Type", DocType);
            GSTDistributionHeader.Validate("Dist. Credit Type", DistGSTCredit);
        end;
        GSTDistributionHeader.Modify(true);

        if not Reversal then begin
            GSTDistributionLine.Init();
            GSTDistributionLine.Validate("Distribution No.", GSTDistributionHeader."No.");
            GSTDistributionLine.Validate("To Location Code", CreateToLocation());
            GSTDistributionLine.Validate("Rcpt. Credit Type", RcptGSTCredit);
            GSTDistributionLine.Validate("Distribution %", 100);
            GSTDistributionLine.Insert(true);
        end;

        DimensionValue.SetRange("Global Dimension No.", 1);
        if DimensionValue.FindFirst() then
            GSTDistributionHeader.Validate("Shortcut Dimension 1 Code", DimensionValue.Code);

        DimensionValue.SetRange("Global Dimension No.", 2);
        if DimensionValue.FindFirst() then
            GSTDistributionHeader.Validate("Shortcut Dimension 2 Code", DimensionValue.Code);
        GSTDistributionHeader.Modify(true);

        DocumentNo := GSTDistributionHeader."No.";
        ApplyAndPostEntries(GSTDistributionHeader."No.", Reversal);
        VerifyGSTDistribution(DocumentNo);
    end;

    local procedure VerifyValueEntries(DocumentNo: Code[20]; TableID: Integer)
    begin
        LibraryGSTPurchase.VerifyValueEntries(DocumentNo, TableID, ComponentPerArray);
    end;

    local procedure CreateAndPostPurchaseReturnFromCopyDocument(
        var PurchaseHeader: Record "Purchase Header";
        DocumentType: Enum "Purchase Document Type")
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        ReverseDocumentNo: Code[20];
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, (Storage.Get(VendorNoLbl)));
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Location Code", CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(PurchaseHeader."Location Code")));
        PurchaseHeader.Modify(true);

        CopyDocumentMgt.SetProperties(true, false, false, false, true, false, false);
        CopyDocumentMgt.CopyPurchaseDocForInvoiceCancelling((Storage.Get(PostedDocumentNoLbl)), PurchaseHeader);
        libraryGSTPurchase.UpdateReferenceInvoiceNoAndVerify(PurchaseHeader, (Storage.Get(PostedDocumentNoLbl)));

        ReverseDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(ReverseDocumentNoLbl, ReverseDocumentNo);
    end;

    local procedure PrepareCurrency(var Currency: Record Currency; ApplnRoundingPrecision: Decimal)
    begin
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.SetCurrencyGainLossAccounts(Currency);
        with Currency do begin
            Validate("Residual Gains Account", "Realized Gains Acc.");
            Validate("Residual Losses Account", "Realized Losses Acc.");
            Validate("Appln. Rounding Precision", ApplnRoundingPrecision);
            Modify(true);
        end;
    end;

    local procedure CreateExchangeRate(CurrencyCode: Code[10]; StartingDate: Date; RelExchangeRateAmount: Decimal; RelAdjustmentExchangeRateAmount: Decimal)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        with CurrencyExchangeRate do begin
            Init();
            Validate("Currency Code", CurrencyCode);
            Validate("Starting Date", StartingDate);
            Insert(true);

            Validate("Exchange Rate Amount", 1);
            Validate("Adjustment Exch. Rate Amount", 1);

            Validate("Relational Exch. Rate Amount", RelExchangeRateAmount);
            Validate("Relational Adjmt Exch Rate Amt", RelAdjustmentExchangeRateAmount);
            Modify(true);
        end;
    end;

    local procedure UpdateVendorCurrencyAndLocation(VendorNo: Code[20]; CurrencyCode: Code[10])
    var
        Vendor: Record Vendor;
        LocationCode: Code[10];
    begin
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        Vendor.Get(VendorNo);
        Vendor.Validate("Currency Code", CurrencyCode);
        Vendor.Validate("Location Code", LocationCode);
        Vendor.Modify(true);
    end;

    local procedure VerifyPostedCreditMemoCreatedAfterPosInvoiceCancelled(InvoiceNo: Code[20])
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        PurchCrMemoHdr.SetRange("Applies-to Doc. No.", InvoiceNo);
        PurchCrMemoHdr.FindFirst();

        Assert.RecordIsNotEmpty(PurchCrMemoHdr);
    end;

    local procedure CreateGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Inv. Rounding Precision (LCY)" := 1;
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 0.00001;
        GeneralLedgerSetup."Inv. Rounding Type (LCY)" := GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Nearest;
        GeneralLedgerSetup.Modify();
    end;

    local procedure CreateAndPostPurchaseDocumentForPurchInv(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
                      DocumentType: Enum "Purchase Document Type"): Code[20];
    var
        VendorNo: Code[20];
        LocationCode: Code[10];
        DocumentNo: Code[20];
        PurchaseInvoiceType: Enum "GST Invoice Type";
    begin
        Evaluate(VendorNo, Storage.Get(VendorNoLbl));
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(InputCreditAvailmentLbl), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));

        LibraryGST.CreateGeneralPostingSetup(PurchaseLine."Gen. Bus. Posting Group", PurchaseLine."VAT Prod. Posting Group");
        if not (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Quote) then begin
            DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
            Storage.Set(PostedDocumentNoLbl, DocumentNo);
            exit(DocumentNo);
        end;
    end;

    local procedure VerifyGSTLedgerEntriesAmount(DocumentNo: Code[20])
    var
        DummyGLEntry: Record "G/L entry";
        GenLedgerSetup: Record "General Ledger Setup";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        GSTBaseAmount: Decimal;
        GSTTaxRate: Decimal;
        TotalAmount: Decimal;
    begin
        GenLedgerSetup.Get();
        DummyGLEntry.SetCurrentKey("Document No.");
        DummyGLEntry.SetRange("Document No.", DocumentNo);
        DummyGLEntry.SetRange("Document Type", DummyGLEntry."Document Type"::" ");
        DummyGLEntry.FindFirst();
        PurchaseInvoiceHeader.Get(DocumentNo);
        GSTBaseAmount := StorageDecimal.Get(LineAmountLbl);
        GSTTaxRate := StorageDecimal.Get(GSTTaxPercentLbl);
        TotalAmount := GSTBaseAmount + (GSTBaseAmount * GSTTaxRate / 100);

        Assert.AreNearlyEqual(TotalAmount, DummyGLEntry.Amount, GenLedgerSetup."Inv. Rounding Precision (LCY)", '');
    end;

    [ModalPageHandler]
    procedure ReferenceInvoiceNoPageHandler(var VendorLedgerEntries: TestPage "Vendor Ledger Entries")
    begin
    end;

    [ModalPageHandler]
    procedure ApplyAdjustmentEntries(var GSTCreditAdjustmentJournal: TestPage "GST Credit Adjustment Journal")
    begin
        GSTCreditAdjustmentJournal.Post.Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmationHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure PostMessageHandler(Message: Text[1024])
    begin
        if Message <> SuccessMsg then
            Error(NotPostedErr);
    end;

    [MessageHandler]
    procedure DocumentArchived(Msg: Text[1024])
    begin
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(GSTGroupCodeLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(HSNSACCodeLbl));
        TaxRates.AttributeValue3.SetValue(Storage.Get(FromStateCodeLbl));
        TaxRates.AttributeValue4.SetValue(Storage.Get(ToStateCodeLbl));
        TaxRates.AttributeValue5.SetValue(WorkDate());
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', WorkDate()));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]); //SGST
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]); //CGST
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[3]); //IGST
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[4]); //KFloodCess
        TaxRates.AttributeValue11.SetValue('');
        TaxRates.AttributeValue12.SetValue('');
        TaxRates.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure PostLiabilityEntries(var GSTLiabilityAdjJournal: TestPage "GST Liability Adj. Journal")
    begin
        GSTLiabilityAdjJournal."<Action1500030>".Invoke();
    end;

    [ModalPageHandler]
    procedure ApplyDistributionEntries(var DistInputGSTCredit: TestPage "Dist. Input GST Credit")
    begin
        if DistInputGSTCredit.First() then
            repeat
                DistInputGSTCredit."Dist. Input GST Credit".SetValue(true);
            until not DistInputGSTCredit.Next();
        DistInputGSTCredit.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure DimensionHandler(var EditDimensionSetEntries: TestPage "Edit Dimension Set Entries")
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
    begin
        EditDimensionSetEntries.New();
        if Dimension.FindLast() then
            EditDimensionSetEntries."Dimension Code".SetValue(Dimension.Code);
        if DimensionValue.FindLast() then
            EditDimensionSetEntries.DimensionValueCode.SetValue(DimensionValue.Code);
    end;

    [ModalPageHandler]
    procedure NoSeriesHandler(var NoSeriesList: TestPage "No. Series")
    begin
        NoSeriesList.Cancel().Invoke();
    end;

    [PageHandler]
    procedure PurchCredMemoPageHandler(var PostedPurchaseCreditMemo: TestPage "Posted Purchase Credit Memo")
    begin
    end;
}
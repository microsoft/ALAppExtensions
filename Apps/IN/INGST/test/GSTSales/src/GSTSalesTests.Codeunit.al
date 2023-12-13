codeunit 18196 "GST Sales Tests"
{
    Subtype = Test;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryGST: Codeunit "Library GST";
        LibraryGSTSales: Codeunit "Library GST Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibraryJournals: Codeunit "Library - Journals";
        Assert: Codeunit Assert;
        Storage: Dictionary of [Text, Code[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
        ComponentPerArray: array[20] of Decimal;
        LocationStateCodeLbl: Label 'LocationStateCode';
        KeralaCESSLbl: Label 'KeralaCESS';
        PartialShipLbl: Label 'PartialShip';
        WithoutPaymentofDutyLbl: Label 'WithoutPaymentofDuty';
        LocationCodeLbl: Label 'LocationCode';
        POSLbl: Label 'POS';
        NoOfLineLbl: Label 'NoOfLine';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        ExemptedLbl: Label 'Exempted';
        LineDiscountLbl: Label 'LineDiscount';
        FromStateCodeLbl: Label 'FromStateCode';
        CustomerNoLbl: Label 'CustomerNo';
        ToStateCodeLbl: Label 'ToStateCode';
        PaymentDocNoLbl: Label 'PaymentDocNo';
        AccountNoLbl: Label 'AccountNo';
        AccountTypeLbl: Label 'AccountType';
        VerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
        SuccessMsg: Label 'GST Payment Lines Posted Successfully.', Locked = true;
        NotPostedErr: Label 'The entries were not posted.', locked = true;
        NoOfLinesErr: Label 'The No. Of Lines in Detailed GST Ledger Entry Is Not Equal to Detailed GST Ledger Entry Info.', Locked = true;
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo';
        PriceInclusiveOfTaxLbl: Label 'WithPIT';
        PANErr: Label 'PAN No. must be entered in Company Information.';
        QRCodeVerifyErr: Label 'QR Code is not generated';

    [Test]
    procedure CompanyInformationPANError()
    var
        CompanyInformation: Record "Company Information";
        GSTRegistrationNos: Record "GST Registration Nos.";
        State: Record State;
    begin
        // [SCENARIO] [GST Preparation - GST Registration No., Pan No. error for company info]
        // [GIVEN] Get Company Information
        CompanyInformation.Get();
        CompanyInformation."P.A.N. No." := '';
        CompanyInformation.Modify();

        // [WHEN] Generate Record in GST registration No.
        LibraryGST.CreateState(State);
        GSTRegistrationNos.Init();
        GSTRegistrationNos.Validate("State Code", State.Code);
        asserterror GSTRegistrationNos.Validate("Code", State.Code);

        //[THEN] Verified error message for Comapny Info Pan Error.
        Assert.ExpectedError(PANErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceForRegisteredCustomerInterStatePIT()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is handling Tax Value Calculation when Price is Inclusive of GST in case of Inter-state Sales of Goods through Sale Invoice.
        // [FEATURE] [Sales Invoice] [Inter-State GST,Registered Customer]

        // [GIVEN] Created GST Setup and tax rates for Registered Customer with Interstate Jurisdiction and Price Incusive of Tax Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        SalesWithPriceInclusiveOfTax(true);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item for Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Verify GST Ledger Entries and Detailed GST Entries
        VerifyGSTEntries(PostedDocumentNo, Database::"Sales Invoice Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceForRegisteredCustomerIntraStatePIT()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is handling Tax Value Calculation when Price is Inclusive of GST in case of Intra-state Sales of Goods through Sale Invoice.
        // [FEATURE] [Sales Invoice] [Intra-State GST,Registered Customer]

        // [GIVEN] Created GST Setup and tax rates for Registered Customer with Intrastate Jurisdiction and Price Incusive of Tax Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        SalesWithPriceInclusiveOfTax(true);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item for Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Verify GST Ledger Entries and Detailed GST Entries
        VerifyGSTEntries(PostedDocumentNo, Database::"Sales Invoice Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvWithRegCustServiceIntraStateWithAdvPayment()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [354845] Check if the system is handling GST on Advance Payment received from Customer application with sales invoice - Intra-State
        // [FEATURE] [Services- Sales invoice] [Intra-State GST,Registered Customer]

        // [GIVEN] Create GST Setup and Tax rates for registered customer where GST group type is Service and Jurisdiction type is Intra-state
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Receipt Voucher with Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Create and Post Sales Invoice with GST and Line Type as G/L Account and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithApplication(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 8);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvWithRegCustServiceInterStateWithAdvPayment()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [354863] Check if the system is handling GST on Advance Payment received from Customer application with sales invoice - InterState
        // [FEATURE] [Services- Sales invoice] [Inter-State GST,Registered Customer]

        // [GIVEN] Create GST Setup and Tax rates for registered customer where GST group type is Service and Jurisdiction type is Inter-state
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Receipt Voucher with Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Create and Post Sales Invoice with GST and Line Type as G/L Account and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithApplication(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 5);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvWithRegCustServiceIntraStateWithNormalPayment()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is handling Normal Advance Payment received from Customer application with sales invoice - Intra-State
        // [FEATURE] [Services- Sales invoice] [Intra-State GST,Registered Customer]

        // [GIVEN] Create GST Setup and Tax rates for registered customer where GST group type is Service and Jurisdiction type is Intra-state
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Receipt Voucher with Non GST Advance Payment
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Create and Post Sales Invoice with GST and Line Type as G/L Account and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithApplication(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvWithRegCustServiceInterStateWithOfflineApplicationAdvPayment()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is handling GST on Advance Payment received from Customer Offline application with sales invoice - InterState
        // [FEATURE] [Services- Sales invoice] [Inter-State GST,Registered Customer]

        // [GIVEN] Create GST Setup and Tax rates for registered customer where GST group type is Service and Jurisdiction type is Inter-state
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Receipt Voucher with Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Create and Post Sales Invoice with GST and Line Type as G/L Account and Interstate Juridisction without application
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] Apply and verify Customer Ledger Entry
        LibraryERM.ApplyCustomerLedgerEntries(GenJournalDocumentType::Invoice, GenJournalDocumentType::Payment, PostedDocumentNo, (Storage.Get(PaymentDocNoLbl)));
        VerifyAdvPaymentApplied();
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvWithRegCustInterStateWithOfflineApplicationAdvPayment()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        PostedDocumentNo1: Code[20];
        PostedDocumentNo2: Code[20];
        PostedDocumentNo3: Code[20];
    begin
        // [SCENARIO] Partial payment when applied to invoice is not taking right amount during offline application
        // [FEATURE] [Services- Sales invoice] [Inter-State GST,Registered Customer]

        // [GIVEN] Create GST Setup and Tax rates for registered customer where GST group type is Service and Jurisdiction type is Inter-state
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Receipt Voucher with Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Create and Post Sales Invoice with GST and Line Type as G/L Account and Interstate Juridisction without application
        PostedDocumentNo1 := CreateAndPostSalesDocument(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Invoice);
        PostedDocumentNo2 := CreateAndPostSalesDocument(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Invoice);
        PostedDocumentNo3 := CreateAndPostSalesDocument(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] Apply and verify Customer Ledger Entry
        LibraryERM.ApplyCustomerLedgerEntries(GenJournalDocumentType::Invoice, GenJournalDocumentType::Payment, PostedDocumentNo1, (Storage.Get(PaymentDocNoLbl)));
        VerifyAdvPaymentApplied();
    end;


    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvWithRegCustServiceIntraStateWithOfflineApplication()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is handling Normal Advance Payment received from Customer offline application with sales invoice - Intra-State
        // [FEATURE] [Services- Sales invoice] [Intra-State GST,Registered Customer]

        // [GIVEN] Create GST Setup and Tax rates for registered customer where GST group type is Service and Jurisdiction type is Intra-state
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Receipt Voucher with Non GST Advance Payment
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Create and Post Sales Invoice with GST and Line Type as G/L Account and Intrastate Juridisction without application
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] Apply and verify Customer Ledger Entry
        LibraryERM.ApplyCustomerLedgerEntries(GenJournalDocumentType::Invoice, GenJournalDocumentType::Payment, PostedDocumentNo, (Storage.Get(PaymentDocNoLbl)));
        VerifyAdvPaymentApplied();
    end;


    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvWithExportCustServiceInterStateWithNormalPayment()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is handling Normal Advance Payment received from Customer application with sales invoice - Inter-State
        // [FEATURE] [Services- Sales invoice] [Inter-State GST,Export Customer]

        // [GIVEN] Create GST Setup and Tax rates for Export customer where GST group type is Service and Jurisdiction type is Inter-state
        CreateGSTSetup(GSTCustomeType::Export, GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Receipt Voucher with Non GST Advance Payment
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Create and Post Sales Invoice with GST and Line Type as G/L Account and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithApplication(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvWithRegCustServiceInterStateWithNormalPayment()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is handling GST on normal Advance Payment received from Customer application with sales invoice - InterState
        // [FEATURE] [Services- Sales invoice] [Inter-State GST,Registered Customer]

        // [GIVEN] Create GST Setup and Tax rates for registered customer where GST group type is Service and Jurisdiction type is Inter-state
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Receipt Voucher with Normal Advance Payment
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Create and Post Sales Invoice with GST and Line Type as G/L Account and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithApplication(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvWithRegCustServiceInterStateWithUnApplication()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is handling Unapplication of GST on Advance Payment received from Customer with sales invoice - InterState
        // [FEATURE] [Services- Sales invoice] [Inter-State GST,Registered Customer]

        // [GIVEN] Create GST Setup and Tax rates for registered customer where GST group type is Service and Jurisdiction type is Inter-state
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Receipt Voucher with Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Create and Post Sales Invoice with GST and Line Type as G/L Account and Interstate Juridisction with Application
        PostedDocumentNo := CreateAndPostSalesDocumentWithApplication(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] Unapply Customer ledger entry
        UnapplyCustLedgerEntry(GenJournalDocumentType::Invoice, PostedDocumentNo);

        // [THEN] Customer Ledger Entry Verified
        VerifyAdvPaymentUnapplied();
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvWithRegCustServiceIntraStateWithUnApplication()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is handling Unapplication of GST on Advance Payment received from Customer with sales invoice - IntraState
        // [FEATURE] [Services- Sales invoice] [Intra-State GST,Registered Customer]

        // [GIVEN] Create GST Setup and Tax rates for registered customer where GST group type is Service and Jurisdiction type is Intra-state
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Bank Receipt Voucher with Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Create and Post Sales Invoice with GST and Line Type as G/L Account and Intrastate Juridisction with Application
        PostedDocumentNo := CreateAndPostSalesDocumentWithApplication(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] Unapply Customer ledger entry
        UnapplyCustLedgerEntry(GenJournalDocumentType::Invoice, PostedDocumentNo);

        // [THEN] Customer Ledger Entry Verified
        VerifyAdvPaymentUnapplied();
    end;

    // [SCENARIO] [354292] Check if the system is calculating GST is case of Intra-State Sales of Goods to Registered Customer through Sale Orders
    // [FEATURE] [Goods Sales Order] [Intra-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustGoodsSalesOrderIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4)
    end;

    // [SCENARIO] [354247] Check if the system is calculating GST is case of Intra-State Sales of Goods to Registered Customer through Sale Quote
    // [FEATURE] [Goods Sales Quote] [Intra-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustGoodsSalesQuoteIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Order From Sales Qoute with GST and Line Type as Services and Interstate Juridisction
        DocumentNo := CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForSales(DocumentNo, SalesHeader."Document Type");
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354318] Check if the system is calculating GST is case of Intra-State Sales of Services to Registered Customer through Sale Orders
    // [FEATURE] [Goods Sales Order] [Intra-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceSalesOrderIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Intra-StateJuridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4)
    end;

    // [SCENARIO] [354301] Check if the system is calculating GST is case of Inter-State Sales of Goods to Registered Customer through Sale Quotes
    // [FEATURE] [Goods Sales Quotes] [Inter-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustGoodsSalesQuotesInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Order from Sales Quote with GST and Line Type as Goods and Intra-State Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForSales(SalesHeader."No.", SalesHeader."Document Type");
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354302] Check if the system is calculating GST is case of Inter-State Sales of Goods to Registered Customer through Sale Orders
    // [FEATURE] [Goods Orders] [Inter-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustGoodsSalesOrdersInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Make Quote to Sales Order with GST and Line Type as Goods and Inter-State Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
    end;

    // [SCENARIO] [354303] Check if the system is calculating GST is case of Inter-State Sales of Goods to Registered Customer through Sale Invoices
    // [FEATURE] [Goods Invoices] [Inter-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustGoodsSalesInvoicesInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Make Quote to Sales Order with GST and Line Type as Goods and Inter-State Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
    end;

    // [SCENARIO] [354307] Check if the system is calculating GST is case of Inter-State Sales of Goods to Unregistered Customer through Sale Quotes
    // [FEATURE] [Goods Sales Quotes] [Inter-State GST,Unregistered  Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerGoodsSalesQuotesInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Make Quote to Sales Order with GST and Line Type as Goods and Intra-State Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForSales(SalesHeader."No.", SalesHeader."Document Type");
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354308] Check if the system is calculating GST is case of Inter-State Sales of Goods to Unregistered Customer through Sale Orders
    // [FEATURE] [Goods Orders] [Inter-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerGoodsSalesOrdersInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Make Quote to Sales Order with GST and Line Type as Goods and Inter-State Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);

    end;

    // [SCENARIO] [354309] Check if the system is calculating GST is case of Inter-State Sales of Goods to Unregistered Customer through Sale Invoices
    // [FEATURE] [Goods Invoices] [Inter-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerGoodsSalesInvoicesInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Make Quote to Sales Order with GST and Line Type as Goods and Inter-State Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
    end;

    // [SCENARIO] [354295] Check if the system is calculating GST is case of Intra-State Sales of Goods to Unregistered Customer through Sale Quotes
    // [FEATURE] [Goods Sales Quotes] [Intra-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerGoodsSalesQuotesIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Quote with GST and Line Type as Goods and Intra-State Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item, DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForSales(SalesHeader."No.", SalesHeader."Document Type");
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354298] Check if the system is calculating GST is case of Intra-State Sales of Goods to Unregistered Customer through Sale Orders
    // [FEATURE] [Goods Sales Order] [Intra-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerGoodsSalesOrderIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Intra-StateJuridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4)
    end;

    // [SCENARIO] [354299] Check if the system is calculating GST is case of Intra-State Sales of Goods to Unregistered Customer through Sale Invoices
    // [FEATURE] [Goods Sales Invoices] [Intra-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerGoodsSalesInvoicesIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Intra-State Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4)
    end;

    // [SCENARIO] [354328] Check if the system is calculating GST is case of Intra-State Sales of Services to Unregistered Customer through Sale Quotes
    // [FEATURE] [Service Sales Quotes] [Intra-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerSalesServiceQuotesIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Make Quote to Sales Order with GST and Line Type as Service and Intra-State Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForSales(SalesHeader."No.", SalesHeader."Document Type");
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354331] Check if the system is calculating GST is case of Intra-State Sales of Services to Unregistered Customer through Sale Orders
    // [FEATURE] [Service Sales Order] [Intra-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerServiceSalesOrderIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Intra-StateJuridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4)
    end;

    // [SCENARIO] [354332] Check if the system is calculating GST is case of Intra-State Sales of Services to Unregistered Customer through Sale Invoices
    // [FEATURE] [Service Sales Invoices] [Intra-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerSalesServiceInvoicesIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Intra-State Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4)
    end;

    // [SCENARIO] [354339] Check if the system is calculating GST is case of Inter-State Sales of Services to Unregistered Customer through Sale Quotes
    // [FEATURE] [Service Sales Quotes] [Inter-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerSalesServiceQuotesInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Make Quote to Sales Order with GST and Line Type as Service and Interstate Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForSales(SalesHeader."No.", SalesHeader."Document Type");
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354341] Check if the system is calculating GST is case of Inter-State Sales of Services to Unregistered Customer through Sale Orders
    // [FEATURE] [Service Sales Order] [Inter-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerSalesServiceOrderInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3)
    end;

    // [SCENARIO] [354342] Check if the system is calculating GST is case of Inter-State Sales of Services to Unregistered Customer through Sale Invoices
    // [FEATURE] [Service Sales Invoices] [Inter-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerSalesServiceInvoicesInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3)
    end;

    // [SCENARIO] [354318] Check if the system is calculating GST is case of Intra-State Sales of Services to Registered Customer through Sale Orders
    // [FEATURE] [Service Sales Order] [Intra-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustomerSalesServiceOrderIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4)
    end;

    // [SCENARIO] [354327] Check if the system is calculating GST is case of Intra-State Sales of Services to Registered Customer through Sale Invoices
    // [FEATURE] [Service Sales Invoices] [Intra-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustomerSalesServiceInvoicesIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4)
    end;

    // [SCENARIO] [354336] Check if the system is calculating GST is case of Inter-State Sales of Services to Registered Customer through Sale Quotes
    // [FEATURE] [Service Sales Quotes] [Inter-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustomerSalesServiceQuotesInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create to Sales Quote with GST and Line Type as Service and Interstate Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForSales(SalesHeader."No.", SalesHeader."Document Type");
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354337] Check if the system is calculating GST is case of Inter-State Sales of Services to Registered Customer through Sale Orders
    // [FEATURE] [Service Sales Order] [Inter-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustomerSalesServiceOrderInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3)
    end;

    // [SCENARIO] [354338] Check if the system is calculating GST is case of Inter-State Sales of Services to Registered Customer through Sale Invoices
    // [FEATURE] [Service Sales Invoices] [Inter-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustomerSalesServiceInvoicesInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
    end;

    // [SCENARIO] [354386] Check if the system is calculating GST in case of Export of Goods to SEZ Unit Customer without Payment of Duty through Sale Quote
    // [FEATURE] [Export Goods Sale Quote Without Payment of Duty] [SEZ Unit Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesQuoteOfExportSEZUnitCustomerWithoutPaymentofDutyWithGoods()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Unit", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Quote with GST and Line Type as Goods and Interstate Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354388] Check if the system is calculating GST in case of Export of Goods to SEZ Unit Customer without Payment of Duty through Sale Order
    // [FEATURE] [Export Goods Sale Order Without Payment of Duty] [SEZ Unit Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportSEZUnitCustomerWithoutPaymentofDutyWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Unit", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4)
    end;

    // [SCENARIO] [354389] Check if the system is calculating GST in case of Export of Goods to SEZ Unit Customer without Payment of Duty through Sales Invoices
    // [FEATURE] [Export Goods Sale Invoices] [SEZ Unit Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvOfExportSEZUnitCustomerWithoutPaymentOfDutyWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Unit", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4)
    end;

    // [SCENARIO] [354357] Check if the system is calculating GST in case of Export of Services to SEZ Unit Customer with Payment of Duty through Sale Quote
    // [FEATURE] [Export Services Sale Quote With Payment of Duty] [SEZ Unit Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesQuoteOfExportSEZUnitCustomerWithPaymentOfDutyWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Unit", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Interstate Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForSales(SalesHeader."No.", SalesHeader."Document Type");
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354358] Check if the system is calculating GST in case of Export of Services to SEZ Unit Customer with Payment of Duty through Sale Order
    // [FEATURE] [Export Services Sale Order With Payment of Duty] [SEZ Unit Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportSEZUnitCustomerWithPaymentOfDutyWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Unit", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [354359] Check if the system is calculating GST in case of Export of Services to SEZ Unit Customer with Payment of Duty through Sales Invoices
    // [FEATURE] [Export Services Sale Invoices With Payment of Duty] [SEZ Unit Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvOfExportSEZUnitCustomerWithPaymentofDutyWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Unit", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [354390] Check if the system is calculating GST in case of Export of Services to SEZ Unit Customer without Payment of Duty through Sale Quote
    // [FEATURE] [Export Services Sale Quote Without Payment of Duty] [SEZ Unit Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesQuoteOfExportSEZUnitCustomerWithoutPaymentofDutyWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Unit", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        StorageBoolean.Set(WithoutPaymentofDutyLbl, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Interstate Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibrarySales.QuoteMakeOrder(SalesHeader);
        StorageBoolean.Remove(WithoutPaymentofDutyLbl);
    end;

    // [SCENARIO] [354391] Check if the system is calculating GST in case of Export of Services to SEZ Unit Customer without Payment of Duty through Sale Order
    // [FEATURE] [Export Services Sale Order Without Payment of Duty] [SEZ Unit Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportSEZUnitCustomerWithoutPaymentofDutyWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Unit", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        StorageBoolean.Set(WithoutPaymentofDutyLbl, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
        StorageBoolean.Remove(WithoutPaymentofDutyLbl);
    end;

    // [SCENARIO] [354392] Check if the system is calculating GST in case of Export of Services to SEZ Unit Customer without Payment of Duty through Sales Invoices
    // [FEATURE] [Export Services Sale Invoices Without Payment of Duty] [SEZ Unit Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvOfExportSEZUnitCustomerWithoutPaymentofDutyWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Unit", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        StorageBoolean.Set(WithoutPaymentofDutyLbl, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
        StorageBoolean.Remove(WithoutPaymentofDutyLbl);
    end;

    // [SCENARIO] [355642] Check if the system is calculating GST in case of Sales of Fixed Assets to SEZ Unit with Payment of Duty with Multiple HSN code wise through Sale Order
    // [FEATURE] [Export Services Sale Invoices With Payment of Duty] [SEZ Unit Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportSEZUnitCustomerWithPaymentofDutyWithFA()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Unit", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Fixed Asset and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] G/L Entries verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 1);
    end;

    // [SCENARIO] [355643] Check if the system is calculating GST in case of Sales of Fixed Assets to SEZ Unit with Payment of Duty with Multiple HSN code wise through Sales Invoices
    // [FEATURE] [Export Services Sale Invoices With Payment of Duty] [SEZ Unit Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvOfExportSEZUnitCustomerWithPaymentofDutyWithFA()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Unit", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] G/L Entries verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 1);
    end;

    // [SCENARIO] [355642] Check if the system is calculating GST in case of Sales of Fixed Assets to SEZ Unit without Payment of Duty with multiple HSN code wise through Sale Order
    // [FEATURE] [Services Sale Order without Payment of Duty] [SEZ Unit Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportSEZUnitCustomerWithoutPaymentofDutyWithFA()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Unit", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Fixed Asset and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] G/L Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6)
    end;

    // [SCENARIO] [354393] Check if the system is calculating GST in case of Export of Goods to SEZ Development Customer without Payment of duty through Sale Quotes
    // [FEATURE] [Export Goods Sale Quote] [SEZ Development Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesQuoteOfExportSEZDevCustWithoutPaymentofDutyWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Quote with GST and Line Type as Goods and Interstate Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForSales(SalesHeader."No.", SalesHeader."Document Type");
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354394] Check if the system is calculating GST in case of Export of Goods to SEZ Development Customer without Payment of Duty through Sale Order
    // [FEATURE] [Export Goods Sale Order] [SEZ Development Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportSEZDevCustWithoutPaymentofDutyWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [354360] Check if the system is calculating GST in case of Export of Goods to SEZ Development Customer with Payment of Duty through Sale Quote
    // [FEATURE] [Export Goods Sale Quote with Payment of Duty ] [SEZ Development Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesQuoteOfExportSEZDevCustWithPaymentofDutyWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Quote with GST and Line Type as Goods and Interstate Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForSales(SalesHeader."No.", SalesHeader."Document Type");
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354361] Check if the system is calculating GST in case of Export of Goods to SEZ Development Customer with Payment of Duty through Sale Order
    // [FEATURE] [Export Goods Sale Order with Payment of Duty] [SEZ Development Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportSEZDevCustWithPaymentofDutyWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [354363] Check if the system is calculating GST in case of Export of Goods to SEZ Development Customer with Payment of Duty through Sales Invoices
    // [FEATURE] [Export Goods Sale Invoices with Payment of Duty] [SEZ Development Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvOfExportSEZDevCustWithPaymentofDutyWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [354364] Check if the system is calculating GST in case of Export of Services to SEZ Development Customer with Payment of Duty through Sale Quote
    // [FEATURE] [Export Services Sale Quote with Payment of Duty ] [SEZ Development Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesQuoteOfExportSEZDevCustWithPaymentofDutyWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Quote with GST and Line Type as Services and Interstate Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForSales(SalesHeader."No.", SalesHeader."Document Type");
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354365] Check if the system is calculating GST in case of Export of Services to SEZ Development Customer with Payment of Duty through Sale Order
    // [FEATURE] [Export Goods Sale Services with Payment of Duty] [SEZ Development Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportSEZDevCustWithPaymentofDutyWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [354366] Check if the system is calculating GST in case of Export of Services to SEZ Development Customer with Payment of Duty through Sales Invoices
    // [FEATURE] [Export Services Sale Invoices with Payment of Duty] [SEZ Development Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvOfExportSEZDevCustWithPaymentofDutyWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [355681] Check if the system is calculating GST in case of Sales of Fixed Assets to SEZ Development Customer without Payment of Duty with multiple HSN code wise through Sale Order
    // [FEATURE] [Fixed Asset Sale Order] [SEZ Development Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfSEZDevelopmentCustomerWithoutPaymentofDutyWithFA()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');
        StorageBoolean.Set(WithoutPaymentofDutyLbl, true);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] G/L Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
        StorageBoolean.Remove(WithoutPaymentofDutyLbl);
    end;

    // [SCENARIO] [355680] Check if the system is calculating GST in case of Sales of Fixed Assets to SEZ Development Customer with Payment of Duty with multiple HSN code wise through Sale Order
    // [FEATURE] [Fixed Asset Sale Order] [SEZ Development Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfSEZDevelopmentCustomerWithPaymentofDutyWithFA()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"Fixed Asset", DocumentType::Order);

        // [THEN] G/L Entries verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 1);
    end;

    // [SCENARIO] [354400] Check if the system is calculating GST in case of Export of Goods to Deemed Export Customer with Payment of Duty through Sale Order
    // [FEATURE] [Export Goods Sale Order With Payment of Duty] [Deemed Export Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportOfDeemedExportCustomerWithPaymentofDutyWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"Deemed Export", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354401] Check if the system is calculating GST in case of Export of Goods to Deemed Export Customer with Payment of Duty through Sales Invoices
    // [FEATURE] [Export Goods Sale Invoices With Payment of Duty ] [Deemed Export Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvOfExportOfDeemedExportCustomerWithPaymentofDutyWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"Deemed Export", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354402] Check if the system is calculating GST in case of Export of Services to Deemed Export Customer with Payment of Duty through Sale Quote
    // [FEATURE] [Export Services Sale Quote with Payment of Duty ] [Deemed Export Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesQuoteOfExportOfDeemedExportCustomerWithPaymentofDutyWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"Deemed Export", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Quote with GST and Line Type as Services and Interstate Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354407] Check if the system is calculating GST in case of Export of Services to Deemed Export Customer with Payment of Duty through Sale Order
    // [FEATURE] [Export Services Sale Order] [Deemed Export Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportOfDeemedExportCustomeWithPaymentofDutyrWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"Deemed Export", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354409] Check if the system is calculating GST in case of Export of Services to Deemed Export Customer without Payment of Duty through Sale Quote
    // [FEATURE] [Export Services Sale Quote without Payment of Duty] [Deemed Export Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesQuoteOfExportOfDeemedExportCustomerWithoutPaymentofDutyWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"Deemed Export", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Quote with GST and Line Type as Services and Interstate Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354410] Check if the system is calculating GST in case of Export of Services to Deemed Export Customer without Payment of Duty through Sale Order
    // [FEATURE] [Export Services Sale Order without Payment of Duty] [Deemed Export Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportOfDeemedExportCustomerWithoutPaymentOfDutyWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"Deemed Export", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354412] Check if the system is calculating GST in case of Export of Services to Deemed Export Customer without Payment of Duty through Sales Invoices
    // [FEATURE] [Export Services Sale Invoices without Payment of Duty] [Deemed Export Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvOfExportOfDeemedExportCustomerWithoutPaymentofDutyWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"Deemed Export", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354615] Check if the system is calculating Kerala Flood CESS on GST in case of Intra-State sale of Services through Sale Quotes
    // [FEATURE] [Services Sales Quotes] [Intra-State GST With Kerala Flood CESS ,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromWithKFCRegisteredCustomerServicesSalesQuotesInteraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');
        StorageBoolean.Set(KeralaCESSLbl, true);

        // [WHEN] Create and Make Quote to Sales Order with GST and Line Type as Service and Intra-State Juridisction
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForSales(SalesHeader."No.", SalesHeader."Document Type");
        LibrarySales.QuoteMakeOrder(SalesHeader);
        StorageBoolean.Remove(KeralaCESSLbl);
    end;

    // [SCENARIO] [354643] Check if the system is calculating GST in case of Intra-State Sales of Services to Overseas Place of Supply to registered customer through Sale Orders
    // [FEATURE] [Services Sales Orders] [Intra-State Overseas Place of Supply,Registered,customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSaleOrderOfServiceToOverseasPlaceOfSupply()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        StorageBoolean.Set(POSLbl, true);
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Intra-State Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
        StorageBoolean.Remove(POSLbl);
    end;

    // [SCENARIO] [354669] Check if the system is calculating GST in case of Intra-State Sales of Services to Overseas Place of Supply to registered customer through Sale Invoices
    // [FEATURE] [Services Sales Invoices] [Intra-State Overseas Place of Supply,Registered customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSaleInvoicesOfServiceToOverseasPlaceOfSupply()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        StorageBoolean.Set(POSLbl, true);
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Intra-State Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
        StorageBoolean.Remove(POSLbl);
    end;

    // [SCENARIO] [354395] Check if the system is calculating GST in case of Export of Goods to SEZ Development Customer without Payment of Duty through Sale Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvOfExportSEZDevCustWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Item for Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [354396] Check if the system is calculating GST in case of Export of Services to SEZ Development Customer without Payment of Duty through Sale Quote.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesQuoteOfExportSEZDevCustWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::"SEZ Development", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Quote and Convert to Order
        CreateSalesDocument(SalesHeader, SalesLine, LineType::Item, DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForSales(SalesHeader."No.", SalesHeader."Document Type");
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354397] Check if the system is calculating GST in case of Export of Services to SEZ Development Customer without Payment of Duty through Sale Order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportSEZDevCustWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::"SEZ Development", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Item for Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [354398] Check if the system is calculating GST in case of Export of Services to SEZ Development Customer without Payment of Duty through Sales Invoices
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvOfExportSEZDevCustWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::"SEZ Development", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as GLAccount for Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] G/L Entries Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [355682] Check if the system is calculating GST in case of Inter-state sales of Fixed Assets to a Deemed Export Customer with Payment of Duty with multiple HSN code wise through Sale Order
    // [FEATURE] [Export Services Sale Quote with Payment of Duty] [Deemed Export Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportOfDeemedExportCustomerWithPaymentofDutyWithFA()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"Deemed Export", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354410] Check if the system is calculating GST in case of Export of Services to Deemed Export Customer without Payment of Duty through Sale Order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportDeemedExportCustomerWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::"Deemed Export", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as GLAccount for Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354415] Check if the system is calculating GST in case of Export of Goods to Deemed Export Customer without Payment of Duty through Sale Order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrdOfExportDeemedCustomerWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::"Deemed Export", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Item for Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354416] Check if the system is calculating GST in case of Export of Goods to Deemed Export Customer without Payment of Duty through Sale Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvOfExportDeemedCustomerWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::"Deemed Export", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item for Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354409] Check if the system is calculating GST in case of Export of Services to Deemed Export Customer without Payment of Duty through Sale Quote.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesQuoteOfExportDeemedCustomerWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::"Deemed Export", GSTGroupType::Service, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Quote and Convert to Order
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354421] Check if the system is not calculating GST in case of GST Exempted Sales of Goods to Exempted Customer - Inter-State through Sale Order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterstateSalesOrderOfExemptedCustomeriWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::Exempted, GSTGroupType::Goods, false);
        InitializeShareStep(true, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with Line Type Item for Interstate Transactions
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354423] Check if the system is not calculating GST in case of GST Exempted Sales of Goods to Exempted Customer - Inter-State through Sale Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterstateSalesInvoiceOfExemptedCustomeriWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::Exempted, GSTGroupType::Goods, false);
        InitializeShareStep(true, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with Line Type item for Interstate Transactions
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354515] Check if the system is not calculating GST in case of GST Exempted Sales of Services to Exempted Customer -Inter-State through Sale Order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterstateSalesOrderOfExemptedCustomeriWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::Exempted, GSTGroupType::Service, false);
        InitializeShareStep(true, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with Line Type GLAccount for Interstate Transactions
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354516] Check if the system is not calculating GST in case of GST Exempted Sales of Services to Exempted Customer - Inter-State through Sale Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterstateSalesInvoiceOfExemptedCustomeriWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::Exempted, GSTGroupType::Service, false);
        InitializeShareStep(true, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with Line Type GLAccount for Interstate Transactions
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] G/L Entries Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354417] Check if the system is not calculating GST in case of GST Exempted Sales of Goods to Exempted Customer - Inter-State through Sales Quotes.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterstateSalesQuoteOfExemptedCustomeriWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::Exempted, GSTGroupType::Goods, false);
        InitializeShareStep(true, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Quote and Convert to Order
        CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354420] Check if the system is not calculating GST in case of GST Exempted Sales of Services to Exempted Customer - Inter-State through Sales Quotes.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterstateSalesQuoteOfExemptedCustomeriWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::Exempted, GSTGroupType::Service, false);
        InitializeShareStep(true, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Quote and Convert to Order
        CreateSalesDocument(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354522] Check if the system is not calculating GST in case of GST Exempted Sales of Goods to Exempted Customer - Intra-State through Sales Quotes.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntrastateSalesQuoteOfExemptedCustomeriWithItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::Exempted, GSTGroupType::Goods, true);
        InitializeShareStep(true, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Quote and Convert to Order
        CreateSalesDocument(SalesHeader, SalesLine, LineType::Item, DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354531] Check if the system is not calculating GST in case of GST Exempted Sales of Services to Exempted Customer - Intra-State through Sale Quotes.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntrastateSalesQuoteOfExemptedCustomeriWithGLAccount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomerType::Exempted, GSTGroupType::Service, true);
        InitializeShareStep(true, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Sales Quote and Convert to Order
        CreateSalesDocument(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustGoodsBlanketSalesOrderIntraState()
    var
        SalesOrderHeader: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        BlanketSalesOrdertoOrder: Codeunit "Blanket Sales Order to Order";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Interstate Juridisction
        CreateSalesDocument(SalesHeader, SalesLine, LineType::Item, DocumentType::"Blanket Order");
        BlanketSalesOrdertoOrder.Run(SalesHeader);
        BlanketSalesOrdertoOrder.GetSalesOrderHeader(SalesOrderHeader);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyTaxTransactionForSales(SalesOrderHeader."No.", SalesOrderHeader."Document Type");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceBlanketSalesOrderIntraState()
    var
        SalesOrderHeader: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        BlanketSalesOrdertoOrder: Codeunit "Blanket Sales Order to Order";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Interstate Juridisction
        CreateSalesDocument(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::"Blanket Order");
        BlanketSalesOrdertoOrder.Run(SalesHeader);
        BlanketSalesOrdertoOrder.GetSalesOrderHeader(SalesOrderHeader);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyTaxTransactionForSales(SalesOrderHeader."No.", SalesOrderHeader."Document Type");
    end;

    // [SCENARIO] [355696] Check if the system is calculating GST in case of Inter-state Sales of goods to Registered Customer  with multiple HSN code wise, ship and invoice with Partial qty through Sale Orders
    // [FEATURE] [Goods Sales Order] [Inter-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustGoodsSalesOrderPartialQtyInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');
        StorageBoolean.Set(PartialShipLbl, true);

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
        StorageBoolean.Remove(PartialShipLbl);
    end;

    // [SCENARIO] [355697] Check if the system is calculating GST in case of Inter-state Sales of goods to Registered Customer  with multiple HSN code wise, ship and invoice  through Sale Invoices
    // [FEATURE] [Goods Sales Invoice] [Inter-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustGoodsSalesInvoiceInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
    end;

    // [SCENARIO] [355699] Check if the system is calculating GST in case of Inter-state Sales of goods to Unregistered Customer  with multiple HSN code wise, ship and invoice with Partial qty through Sale Orders
    // [FEATURE] [Goods Sales Order] [Inter-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerGoodsSalesOrderPartialQtyInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');
        StorageBoolean.Set(PartialShipLbl, true);

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
        StorageBoolean.Remove(PartialShipLbl);
    end;

    // [SCENARIO] [355700] Check if the system is calculating GST in case of Inter-state Sales of goods to Unregistered Customer  with multiple HSN code wise, ship and invoice through Sale Invoices
    // [FEATURE] [Goods Sales Invoice] [Inter-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerGoodsSalesInvoiceInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Inoice with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
    end;

    // [SCENARIO] [355701] Check if the system is calculating GST in case of Intra-state Sales of goods to Registered Customer  with multiple HSN code wise, ship and invoice with Partial qty through Sale Orders
    // [FEATURE] [Goods Sales Order] [Intra-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustGoodsSalesOrderPartialQtyIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');
        StorageBoolean.Set(PartialShipLbl, true);

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
        StorageBoolean.Remove(PartialShipLbl);
    end;

    // [SCENARIO] [355704] Check if the system is calculating GST in case of Intra-state Sales of goods to Registered Customer  with multiple HSN code wise, ship and invoice through Sale Invoices
    // [FEATURE] [Goods Sales Invoice] [Intra-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustGoodsSalesInvoiceIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [355699] Check if the system is calculating GST in case of Intra-state Sales of goods to Unregistered Customer  with multiple HSN code wise, ship and invoice with Partial qty through Sale Orders
    // [FEATURE] [Goods Sales Order] [Inter-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerGoodsSalesOrderPartialQtyIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');
        StorageBoolean.Set(PartialShipLbl, true);

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
        StorageBoolean.Remove(PartialShipLbl);
    end;

    // [SCENARIO] [355706] Check if the system is calculating GST in case of Intra-state Sales of goods to Unregistered Customer  with multiple HSN code wise, ship and invoice through Sale Invoices
    // [FEATURE] [Goods Sales Invoice] [Intra-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerGoodsSalesInvoiceIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [355506] Check if the system is calculating GST is case of Intra-State Sales of Fixed Assets to Registered Customer with multiple HSN code wise through Sale Orders
    // [FEATURE] [Sales Order] [Intra-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegisteredCustomerSalesofFixedAssetsOrdersIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Fixed Assets and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 2)
    end;

    // [SCENARIO] [355507]	Check if the system is calculating GST is case of Intra-State Sales of Fixed Assets to Registered Customer with multiple HSN code wise through Sale Invoice
    // [FEATURE] [Sales Invoice] [Intra-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegisteredCustomerSalesInvoiceofFixedAssetsOrdersIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Fixed Assets and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 2);
    end;

    // [SCENARIO] [355541]	Check if the system is calculating GST is case of Intra-State Sales of Fixed Assets to Unregistered Customer with invoice discount/line discount and multiple HSN code wise through Sale Orders
    // [FEATURE] [Sales Order] [Intra-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerSalesInvoiceofFixedAssetsOrdersIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, true);
        InitializeShareStep(false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Fixed Assets and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 2)
    end;

    // [SCENARIO] [355542]	Check if the system is calculating GST is case of Intra-State Sales of Fixed Assets to Unregistered Customer with invoice discount/line discount and multiple HSN code wise through Sale Invoice
    // [FEATURE] [Sales Invoice] [Intra-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerSalesInvoiceofFixedAssetsInvoiceIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, true);
        InitializeShareStep(false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Fixed Assets and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 2);
    end;

    // [SCENARIO] [355547]	Check if the system is calculating GST is case of Intra-State Sales of Fixed Assets to Registered Customer with invoice discount/line discount with multiple HSN code wise through Sale Orders
    // [FEATURE] [Sales Invoice] [Intra-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegisteredCustomerSalesOrderofFixedAssetsIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Fixed Assets and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 2);
    end;

    // [SCENARIO] [355549]	Check if the system is calculating GST is case of Intra-State Sales of Fixed Assets to Registered Customer with invoice discount/line discount with multiple HSN code wise through Sale Invoice
    // [FEATURE] [Sales Invoice] [Intra-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegisteredCustomerSalesOrderofFixedAssetsWithLineDiscountIntraState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Fixed Assets and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 2);
    end;

    // [SCENARIO] [355553]	Check if the system is calculating GST is case of Inter-State Sales of Fixed Assets to Registered Customer with invoice discount/line discount and multiple HSN code wise through Sale Orders
    // [FEATURE] [Sales Order] [Inter-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegisteredCustomerSalesOrderofFixedAssetsWithLineDiscountInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Fixed Assets and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 1);
    end;

    // [SCENARIO] [355554]	Check if the system is calculating GST is case of Inter-State Sales of Fixed Assets to Registered Customer with invoice discount/line discount and multiple HSN code wise through Sale Invoice
    // [FEATURE] [Sales Invoice] [Inter-State GST,Registered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegisteredCustomerSalesInvoiceofFixedAssetsWithLineDiscountInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Fixed Assets and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 1);
    end;

    // [SCENARIO] [355562]	Check if the system is calculating GST is case of Inter-State Sales of Fixed Assets to Unregistered Customer with invoice discount/line discount and multiple HSN code wise through Sale Orders
    // [FEATURE] [Sales Order] [Inter-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerSalesOrderofFixedAssetsWithLineDiscountInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Fixed Assets and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader,
            SalesLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 1);
    end;

    // [SCENARIO] [355564]	Check if the system is calculating GST is case of Inter-State Sales of Fixed Assets to Unregistered Customer with invoice discount/line discount and multiple HSN code wise through Sale Invoice
    // [FEATURE] [Sales Invoice] [Inter-State GST,Unregistered Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerSalesInvoiceofFixedAssetsWithLineDiscountInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Fixed Assets and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader,
            SalesLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 1);
    end;

    // [SCENARIO] [355683]	Check if the system is calculating GST in case of Inter-state sales of Fixed Assets to a Deemed Export Customer with Payment of Duty with multiple HSN code wise through Sales Invoices
    // [FEATURE] [Sales Invoice] [Inter-State GST,Deemed Export Customer]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromDeemedExportCustomerSalesInvoiceofFixedAssetsWithPaymentDutyInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"Deemed Export", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Fixed Assets and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromSalesCrMemoForRegisteredCustomerInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [SCENARIO] Check if the system is calculating GST in case of Inter-state sales of Item to Registered Customer through Sales Credit Memo
        // [FEATURE] [Sales Credit Memo] [Inter-State GST,Registered Customer]

        // [GIVEN] Created GST Setup and tax rates for registered customer with interstate jurisdiction
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item and Interstate Juridisction
        CreateAndPostSalesDocument(SalesHeader, SalesLine, LineType::Item, DocumentType::Invoice);

        // [THEN] crate and post return document with copy document and updated reference invoice number
        CreateAndPostSalesDocumentFromCopyDocument(SalesHeader, DocumentType::"Credit Memo");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderForRegisteredCustomerInterStatePIT()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [354696] Check if the system is handling Tax Value calculation when price is inclusive of GST in case of Inter-state Sales of Goods through Sale Orders
        // [FEATURE] [Sales Order] [Inter-State GST,Registered Customer]

        // [GIVEN] Created GST Setup and tax rates for registered customer with interstate jurisdiction and Price incusive of tax setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        SalesWithPriceInclusiveOfTax(true);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, LineType::Item, DocumentType::Order);

        // [THEN] Verify G/L entry
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreateSalesOrderForRegisteredCustomerIntraStatePOSOutOfIndia()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [SCENARIO] Check Place of Supply state code GST PLace of Supply if blank and POS Out of India
        // [FEATURE] [Sales Order] [Inter-State GST,Registered Customer]

        // [GIVEN] Created GST Setup and tax rates for registered customer with intrastate jurisdiction and POS Out of India
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);

        // [WHEN] Create Sales Invoice with GST and Line Type as Item and Intrastate Juridisction
        CreateSalesDocument(SalesHeader, SalesLine, LineType::Item, DocumentType::Invoice);
        SalesHeader.Validate("GST Invoice", true);
        SalesHeader.Validate("POS Out Of India", true);

        // [THEN] Verify Place of supply state code
        VerifyPlaceOfSupplyStateCode(SalesHeader, SalesLine);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreateSalesOrderForExportCustomerInterStateWithShipToCustomer()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        ShipToCustomer: Code[20];
    begin
        // [SCENARIO] Check if system is allowing to select GST ship to customer if GST customer type is export
        // [FEATURE] [Sales Order] [Inter-State GST,Export Customer]

        // [GIVEN] Created GST Setup and tax rates for Export customer with interstate jurisdiction
        CreateGSTSetup(GSTCustomeType::Export, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item and Interstate Jurisdisction
        CreateSalesDocument(SalesHeader, SalesLine, LineType::Item, DocumentType::Invoice);
        ShipToCustomer := CreateShipToCustomer();
        SalesHeader.Validate("Ship-to Customer", ShipToCustomer);

        // [THEN] Verify ship to customer selected on sales header
        Assert.AreEqual(ShipToCustomer, SalesHeader."Ship-to Customer",
            StrSubstNo(VerifyErr, SalesHeader.FieldName("Ship-to Customer"), SalesHeader.TableCaption));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ApplyAdjustmentEntries,ConfirmationHandler,PostMessageHandler')]
    procedure PostGSTSettlementEntriesForSalesInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Created GST Setup and tax rates for registered customer with intrastate jurisdiction and GST Group Type is Goods
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item and Interstate Juridisction
        CreateAndPostSalesDocument(SalesHeader, SalesLine, LineType::Item, DocumentType::Order);

        // [THEN] Create and post GST Settlement entry
        CreateAndPostAdjustmentJournal();
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerGoodsSalesInvoiceInterStateWithEinvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EInvoiceJsonHandler: Codeunit "e-Invoice Json Handler";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Inoice with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        SalesInvoiceHeader.Get(PostedDocumentNo);
        EInvoiceJsonHandler.GenerateQRCodeforB2C(SalesInvoiceHeader);

        // [THEN] Posted Sales Invoice QR Code verified
        Assert.IsTrue(SalesInvoiceHeader."QR Code".HasValue, QRCodeVerifyErr);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerGoodsSalesInvoiceIntraStateWithEinvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EInvoiceJsonHandler: Codeunit "e-Invoice Json Handler";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        SalesInvoiceHeader.Get(PostedDocumentNo);
        EInvoiceJsonHandler.GenerateQRCodeforB2C(SalesInvoiceHeader);

        // [THEN] Posted Sales Invoice QR Code verified
        Assert.IsTrue(SalesInvoiceHeader."QR Code".HasValue, QRCodeVerifyErr);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerGoodsSalesOrderIntraStateWithEinvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EInvoiceJsonHandler: Codeunit "e-Invoice Json Handler";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Intra-StateJuridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        SalesInvoiceHeader.Get(PostedDocumentNo);
        EInvoiceJsonHandler.GenerateQRCodeforB2C(SalesInvoiceHeader);

        // [THEN] Posted Sales Invoice QR Code verified
        Assert.IsTrue(SalesInvoiceHeader."QR Code".HasValue, QRCodeVerifyErr);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustomerGoodsSalesOrdersInterStateWithEinvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EInvoiceJsonHandler: Codeunit "e-Invoice Json Handler";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Make Quote to Sales Order with GST and Line Type as Goods and Inter-State Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        SalesInvoiceHeader.Get(PostedDocumentNo);
        EInvoiceJsonHandler.GenerateQRCodeforB2C(SalesInvoiceHeader);

        // [THEN] Posted Sales Invoice QR Code verified
        Assert.IsTrue(SalesInvoiceHeader."QR Code".HasValue, QRCodeVerifyErr);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustSalesOrderIntraStateForEInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvHeader: Record "Sales Invoice Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedSalesInvoice: TestPage "Posted Sales Invoice";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentForEInvoice(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
        SalesInvHeader.Get(PostedDocumentNo);
        PostedSalesInvoice.OpenEdit();
        PostedSalesInvoice.GoToRecord(SalesInvHeader);
        PostedSalesInvoice."Generate E-Invoice".Invoke();
        PostedSalesInvoice.Close();
        Assert.IsTrue(true, 'E-Invoice generated');
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustomerSalesServiceInvoicesIntraStateWithTwoLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [460710] Detailed GST ledger entry getting doubled up, when advance receipt and Invoice paid are made through Sales Invoice
        // [FEATURE] [Service Sales Invoices] [Intra-State GST,Registered Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Services and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithNegativeAndPostiveUnitPrice(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithPartialShipForRegisteredCustomerIntraStatePIT()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is handling Tax Value Calculation when Price is Inclusive of GST in case of Intra-state Sales of Goods through Sale Invoice.
        // [FEATURE] [Sales Invoice] [Intra-State GST,Registered Customer]

        // [GIVEN] Created GST Setup and tax rates for Registered Customer with Intrastate Jurisdiction and Price Incusive of Tax Setup
        InitializeShareStep(false, true);
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        SalesWithPartialPriceInclusiveOfTax(true, true);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item for Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] Verify G/L Entries
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 5);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustSalesOrderIntraStateForEInvoiceWithTenLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvHeader: Record "Sales Invoice Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedSalesInvoice: TestPage "Posted Sales Invoice";
        PostedDocumentNo: Code[20];
    begin
        //[Scenario] Bug 467092: [Master][BC IN] E-Invoice with more then 10 lines giving an error
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '11');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentForEInvoice(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
        SalesInvHeader.Get(PostedDocumentNo);
        PostedSalesInvoice.OpenEdit();
        PostedSalesInvoice.GoToRecord(SalesInvHeader);
        PostedSalesInvoice."Generate E-Invoice".Invoke();
        PostedSalesInvoice.Close();
        Assert.IsTrue(true, 'E-Invoice generated');
    end;

    [Test]
    [HandlerFunctions('TransferToInvoiceHandler,MessageHandler')]
    procedure CreateSalesInvoiceFromJobPlanningLine()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        SalesHeader: Record "Sales Header";
        LibraryJob: Codeunit "Library - Job";
        LineType: Enum "Job Planning Line Line Type";
        Type: Enum "Job Planning Line Type";
    begin
        //[Scenario] Bug 468662: [IcM] Job Planning lines expects location code to be of customer location code
        // [GIVEN] Create Job, Job Task and Job Planning Line
        LibraryJob.CreateJob(Job);
        LibraryJob.CreateJobTask(Job, JobTask);
        LibraryJob.CreateJobPlanningLine(LineType::Billable, Type::Item, JobTask, JobPlanningLine);

        // [WHEN] Create Sales Invoice From Job Planning Line
        TransferJobPlanningLine(JobPlanningLine, 1, false);

        // [THEN] Sales Invoice Document is Created
        VerifySalesDocumentCreated(JobPlanningLine, SalesHeader."Document Type"::Invoice, SalesHeader);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure VerifyNoOfLinesInDGLEInfoFromDetailedGSTLedgerEntryOnBasisOfDocumentNo()
    var
        SalesHeader: Record "Sales Header";
        SalesLine, SalesLine2 : Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
        DetailedGSTLedgerEntryCount, DetailedGSTLedgerEntryInfoCount : Integer;
    begin
        // [Scenario] No. of line in Document in Detailed GST Ledger Entry must be Equal to No. Of Line For same document in Detailed GST Ledger Entry Info.
        // [GIVEN] Create Sales Document with 2 lines.
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Post Sales Document 
        PostedDocumentNo := CreateAndPostSalesDocumentWithMultipleLine(SalesHeader, SalesLine, SalesLine2, LineType::Item, DocumentType::Order);

        //[THEN] Verify No. Of Line IN Detailed GST Ledger Entry and Detailed GST Ledger Entry Info.
        CountDetailedGstLedgerEntryLines(DetailedGSTLedgerEntryCount, DetailedGSTLedgerEntryInfoCount, PostedDocumentNo);
        Assert.AreEqual(DetailedGSTLedgerEntryCount, DetailedGSTLedgerEntryInfoCount, NoOfLinesErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure VerifyExemptNonGSTSalesInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [Scenario] To verify the exempted Non-GST supplies sales invoice amount
        // [GIVEN] Create Sales Document
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Post Sales Document 
        PostedDocumentNo := CreateAndPostSalesDocumentWithNonGSTSupplies(SalesHeader, SalesLine, LineType::Item, DocumentType::Invoice);

        //[THEN] Verify G/L Entries
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustSalesOrderIntraStateWithDecimalValuesForEInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvHeader: Record "Sales Invoice Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedSalesInvoice: TestPage "Posted Sales Invoice";
        PostedDocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Order with GST and Line Type as Item With Decimal Value and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithDecimalValuesForEInvoice(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] G/L Entries and Detailed GST Ledger Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4);
        SalesInvHeader.Get(PostedDocumentNo);
        PostedSalesInvoice.OpenEdit();
        PostedSalesInvoice.GoToRecord(SalesInvHeader);
        PostedSalesInvoice."Generate E-Invoice".Invoke();
        PostedSalesInvoice.Close();
        Assert.IsTrue(true, 'E-Invoice generated');
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure VerifyNatureofSupplyforUnregisteredCustomer()
    var
        SalesHeader: Record "Sales Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        NatureofSupply: Enum "GST Nature of Supply";
    begin
        // [GIVEN] Created GST Setup for Registered Customer and Unregistered Customer
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, true);
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType::Order, (Storage.Get(CustomerNoLbl)));
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);

        // [WHEN] Change Sell-to Customer with registerd Customer
        SalesHeader.Validate("Sell-to Customer No.", (Storage.Get(CustomerNoLbl)));
        SalesHeader.Modify();

        // [THEN] Nature of Supply should be B2B
        Assert.Equal(NatureofSupply::B2B, SalesHeader."Nature of Supply");
    end;

    local procedure CountDetailedGstLedgerEntryLines(var DetailedGSTLedgerEntryCount: Integer; var DetailedGSTLedgerEntryInfoCount: Integer; PostedDocumentNo: code[20])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin

        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
        DetailedGSTLedgerEntry.SetRange("Document No.", PostedDocumentNo);
        DetailedGSTLedgerEntry.FindSet();
        DetailedGSTLedgerEntryCount := DetailedGSTLedgerEntry.Count;
        repeat
            if DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.") then
                DetailedGSTLedgerEntryInfoCount += 1;
        until DetailedGSTLedgerEntry.Next() = 0;
    end;

    local procedure TransferJobPlanningLine(var JobPlanningLine: Record "Job Planning Line"; Fraction: Decimal; Credit: Boolean)
    var
        Location: Record Location;
        LibraryWarehouse: Codeunit "Library - Warehouse";
        JobCreateInvoice: Codeunit "Job Create-Invoice";
        QtyToTransfer: Decimal;
    begin
        // Transfer Fraction of JobPlanningLine to a sales invoice
        JobPlanningLine.Validate("Location Code", LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location));
        QtyToTransfer := Fraction * JobPlanningLine.Quantity;
        JobPlanningLine.Validate("Qty. to Transfer to Invoice", QtyToTransfer);
        JobPlanningLine.Modify(true);
        JobPlanningLine.SetRecFilter();

        Commit();

        JobCreateInvoice.CreateSalesInvoice(JobPlanningLine, Credit);
    end;

    local procedure VerifySalesDocumentCreated(JobPlanningLine: Record "Job Planning Line"; DocumentType: Enum "Sales Document Type"; var SalesHeader: Record "Sales Header")
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
    begin
        JobPlanningLineInvoice.SetRange("Job No.", JobPlanningLine."Job No.");
        JobPlanningLineInvoice.SetRange("Job Task No.", JobPlanningLine."Job Task No.");
        JobPlanningLineInvoice.SetRange("Job Planning Line No.", JobPlanningLine."Line No.");
        if DocumentType = SalesHeader."Document Type"::Invoice then
            JobPlanningLineInvoice.SetRange("Document Type", JobPlanningLineInvoice."Document Type"::Invoice)
        else
            JobPlanningLineInvoice.SetRange("Document Type", JobPlanningLineInvoice."Document Type"::"Credit Memo");
        JobPlanningLineInvoice.FindFirst();
        Assert.RecordIsNotEmpty(JobPlanningLineInvoice);

        SalesHeader.Get(DocumentType, JobPlanningLineInvoice."Document No.");
        Assert.RecordIsNotEmpty(SalesHeader);
    end;

    local procedure CreateAndPostSalesDocumentForEInvoice(
            var SalesHeader: Record "Sales Header";
            var SalesLine: Record "Sales Line";
            LineType: Enum "Sales Line Type";
                          DocumentType: Enum "Sales Document Type"): Code[20];
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CustomerNo: Code[20];
        LocationCode: Code[10];
        PostedDocumentNo: Code[20];
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Generate E-Inv. on Sales Post" = false then begin
            GeneralLedgerSetup."Generate E-Inv. on Sales Post" := true;
            GeneralLedgerSetup.Modify();
        end;

        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        SalesHeader.Validate("Vehicle No.", LibraryRandom.RandText(10));
        SalesHeader.Validate("Vehicle Type", SalesHeader."Vehicle Type"::Regular);
        SalesHeader.Validate("Distance (Km)", LibraryRandom.RandInt(3));
        SalesHeader.Modify(true);
        CreateSalesLineWithGST(SalesHeader, SalesLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, PostedDocumentNo);
        exit(PostedDocumentNo);
    end;

    local procedure CreateAndPostSalesDocumentWithDecimalValuesForEInvoice(
            var SalesHeader: Record "Sales Header";
            var SalesLine: Record "Sales Line";
            LineType: Enum "Sales Line Type";
                          DocumentType: Enum "Sales Document Type"): Code[20];
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CustomerNo: Code[20];
        LocationCode: Code[10];
        PostedDocumentNo: Code[20];
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Generate E-Inv. on Sales Post" = false then begin
            GeneralLedgerSetup."Generate E-Inv. on Sales Post" := true;
            GeneralLedgerSetup.Modify();
        end;

        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        SalesHeader.Validate("Vehicle No.", LibraryRandom.RandText(10));
        SalesHeader.Validate("Vehicle Type", SalesHeader."Vehicle Type"::Regular);
        SalesHeader.Validate("Distance (Km)", LibraryRandom.RandInt(3));
        SalesHeader.Modify(true);
        CreateSalesLineWithDecimalValueAndGST(SalesHeader, SalesLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, PostedDocumentNo);
        exit(PostedDocumentNo);
    end;

    local procedure CreateAndPostAdjustmentJournal()
    var
        location: Record Location;
        GSTSettlement: TestPage "GST Settlement";
    begin
        GSTSettlement.OpenEdit();
        location.Get(Storage.Get(LocationCodeLbl));
        GSTSettlement."GSTINNo.".SetValue(location."GST Registration No.");
        GSTSettlement."Posting Date".SetValue(CalcDate('<1M>', WorkDate()));
        GSTSettlement.AccountType.SetValue(Enum::"GST Settlement Account Type"::"G/L Account");
        GSTSettlement."Account No".SetValue(LibraryERM.CreateGLAccountNoWithDirectPosting());
        GSTSettlement."BankReference No".SetValue(LibraryRandom.RandText(10));
        GSTSettlement."Bank Reference Date".SetValue(WorkDate());
        GSTSettlement.ApplyEntries.Invoke();

        VerifySettlementEntries();
    end;

    local procedure VerifySettlementEntries()
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        DetailedGSTLedgerEntry.SetRange("Document No.", Storage.Get(PostedDocumentNoLbl));
        DetailedGSTLedgerEntry.FindFirst();

        Assert.AreEqual(true, DetailedGSTLedgerEntry.Paid, StrSubstNo(VerifyErr, DetailedGSTLedgerEntry.FieldName(Paid), DetailedGSTLedgerEntry.TableCaption));
    end;

    local procedure CreateShipToCustomer(): Code[20]
    var
        CompanyInformation: Record "Company Information";
        CustomerNo: Code[20];
        LocPANNo: Code[20];
    begin
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := LibraryGST.CreatePANNos();
            CompanyInformation.Modify();
        end else
            LocPANNo := CompanyInformation."P.A.N. No.";

        CustomerNo := LibraryGST.CreateCustomerSetup();
        UpdateCustomerSetupWithGST(CustomerNo, Enum::"GST Customer Type"::Registered, (Storage.Get(LocationStateCodeLbl)), LocPANNo);

        exit(CustomerNo);
    end;

    local procedure VerifyPlaceOfSupplyStateCode(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PlaceOfSupplyStateCode: Code[20];
    begin
        SalesReceivablesSetup.Get();
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        case SalesLine."GST Place Of Supply" of
            SalesLine."GST Place Of Supply"::"Bill-to Address":
                PlaceOfSupplyStateCode := SalesHeader."GST Bill-to State Code";
            SalesLine."GST Place Of Supply"::"Ship-to Address":
                PlaceOfSupplyStateCode := SalesHeader."GST Ship-to State Code";
            SalesLine."GST Place Of Supply"::"Location Address":
                PlaceOfSupplyStateCode := SalesHeader."Location State Code";
            SalesLine."GST Place Of Supply"::" ":
                if SalesReceivablesSetup."GST DepEndency Type" = SalesReceivablesSetup."GST DepEndency Type"::"Bill-to Address" then
                    PlaceOfSupplyStateCode := SalesHeader."GST Bill-to State Code"
                else
                    if SalesReceivablesSetup."GST DepEndency Type" = SalesReceivablesSetup."GST DepEndency Type"::"Ship-to Address" then
                        PlaceOfSupplyStateCode := SalesHeader."GST Ship-to State Code"
        end;

        Assert.AreEqual(PlaceOfSupplyStateCode, SalesHeader.State,
            StrSubstNo(VerifyErr, SalesHeader.FieldName(State), SalesHeader.TableCaption));
    end;

    local procedure SalesWithPriceInclusiveOfTax(WithPIT: Boolean)
    begin
        StorageBoolean.Set(PriceInclusiveOfTaxLbl, WithPIT);
    end;

    local procedure SalesWithPartialPriceInclusiveOfTax(WithPIT: Boolean; ParitalShip: Boolean)
    begin
        StorageBoolean.Set(PriceInclusiveOfTaxLbl, WithPIT);
        StorageBoolean.Set(PartialShipLbl, ParitalShip);
    end;

    local procedure CreateAndPostSalesDocumentFromCopyDocument(
            var SalesHeader: Record "Sales Header";
            DocumentType: Enum "Sales Document Type")
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        ReverseDocumentNo: Code[20];
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, Storage.Get(CustomerNoLbl));
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Validate("Location Code", Storage.Get(LocationCodeLbl));
        SalesHeader.Modify(true);
        CopyDocumentMgt.SetProperties(true, false, false, false, true, false, false);
        CopyDocumentMgt.CopySalesDocForInvoiceCancelling(Storage.Get(PostedDocumentNoLbl), SalesHeader);

        UpdateReferenceInvoiceNoAndVerify(SalesHeader);
        ReverseDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Storage.Set(ReverseDocumentNoLbl, ReverseDocumentNo);
    end;

    local procedure UpdateReferenceInvoiceNoAndVerify(SalesHeader: Record "Sales Header")
    var
        SalesReturnOrder: TestPage "Sales Return Order";
        SalesCreditMemo: TestPage "Sales Credit Memo";
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then begin
            SalesReturnOrder.OpenEdit();
            SalesReturnOrder.Filter.SetFilter("No.", SalesHeader."No.");
            SalesReturnOrder."Update Reference Invoice No.".Invoke();
        end else begin
            SalesCreditMemo.OpenEdit();
            SalesCreditMemo.Filter.SetFilter("No.", SalesHeader."No.");
            SalesCreditMemo."Update Reference Invoice No.".Invoke();
        end;
    end;

    local procedure UpdateCustomerSetupWithGST(
        CustomerNo: Code[20];
        GSTCustomerType: Enum "GST Customer Type";
                             StateCode: Code[10];
                             PANNo: Code[20])
    var
        Customer: Record Customer;
        State: Record State;
    begin
        Customer.Get(CustomerNo);
        if GSTCustomerType <> GSTCustomerType::Export then begin
            State.Get(StateCode);
            Customer.Validate("State Code", StateCode);
            Customer.Validate("P.A.N. No.", PANNo);
            if not ((GSTCustomerType = GSTCustomerType::" ") or (GSTCustomerType = GSTCustomerType::Unregistered)) then
                Customer.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo));
        end;

        Customer.Validate(Address, CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(Customer.Address)));
        Customer.Validate("GST Customer Type", GSTCustomerType);
        if GSTCustomerType = GSTCustomerType::Export then
            Customer.Validate("Currency Code", LibraryGST.CreateCurrencyCode());
        Customer.Modify(true);
    end;

    local procedure CreateGSTSetup(
        GSTCustomerType: Enum "GST Customer Type";
                             GSTGroupType: Enum "GST Group Type";
                             IntraState: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        TaxComponent: Record "Tax Component";
        CompanyInformation: Record "Company information";
        LocationStateCode: Code[10];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        CustomerStateCode: Code[10];
        LocPANNo: Code[20];
        HSNSACCode: Code[10];
        GSTGroupCode: Code[20];
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
            CompanyInformation.Modify(true);
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        Storage.Set(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::" ", false);
        Storage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        Storage.Set(HSNSACCodeLbl, HSNSACCode);

        if IntraState then begin
            CustomerNo := LibraryGST.CreateCustomerSetup();
            UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, LocationStateCode, LocPANNo);
            InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
        end else begin
            CustomerStateCode := LibraryGST.CreateGSTStateCode();
            CustomerNo := LibraryGST.CreateCustomerSetup();
            UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, CustomerStateCode, LocPANNo);
            if GSTCustomerType in [GSTCustomerType::Export, GSTCustomerType::"SEZ Unit", GSTCustomerType::"SEZ Development"] then
                InitializeTaxRateParameters(IntraState, '', LocationStateCode)
            else
                InitializeTaxRateParameters(IntraState, CustomerStateCode, LocationStateCode);
        end;
        Storage.Set(CustomerNoLbl, CustomerNo);

        CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);

        CreateTaxRate();
    end;

    local procedure InitializeShareStep(Exempted: Boolean; LineDiscount: Boolean)
    begin
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
    end;

    local procedure CreateSalesDocument(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
                      DocumentType: Enum "Sales Document Type"): Code[20]
    var
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        CreateSalesLineWithGST(SalesHeader, SalesLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        exit(SalesHeader."No.");
    end;

    local procedure CreateGSTComponentAndPostingSetup(
        IntraState: Boolean;
        LocationStateCode: Code[10];
        TaxComponent: Record "Tax Component";
        GSTComponentCode: Text[30])
    var
        POS: Boolean;
    begin
        if StorageBoolean.ContainsKey(POSLbl) then
            POS := StorageBoolean.Get(POSLbl);

        if IntraState then begin
            if POS then begin
                GSTComponentCode := IGSTLbl;
                LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
                LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
            end else begin
                GSTComponentCode := CGSTLbl;
                LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
                LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

                GSTComponentCode := SGSTLbl;
                LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
                LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
            end;
        end else begin
            GSTComponentCode := IGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end;
    end;

    local procedure InitializeTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10])
    var
        GSTTaxPercent: Decimal;
        KFCCESS: Boolean;
        POS: Boolean;
    begin
        Storage.Set(FromStateCodeLbl, FromState);
        Storage.Set(ToStateCodeLbl, ToState);

        if StorageBoolean.ContainsKey(KeralaCESSLbl) then
            KFCCESS := StorageBoolean.Get(KeralaCESSLbl);

        if StorageBoolean.ContainsKey(POSLbl) then
            POS := StorageBoolean.Get(POSLbl);

        GSTTaxPercent := LibraryRandom.RandDecInRange(10, 18, 0);

        if IntraState then begin
            if POS then
                ComponentPerArray[4] := GSTTaxPercent
            else begin
                ComponentPerArray[1] := (GSTTaxPercent / 2);
                ComponentPerArray[2] := (GSTTaxPercent / 2);
                if KFCCESS then
                    ComponentPerArray[3] := LibraryRandom.RandDecInRange(1, 4, 0);
            end;
        end else
            ComponentPerArray[4] := GSTTaxPercent;
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

    local procedure CreateAndPostSalesDocument(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
                      DocumentType: Enum "Sales Document Type"): Code[20];
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CustomerNo: Code[20];
        LocationCode: Code[10];
        PostedDocumentNo: Code[20];
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Generate E-Inv. on Sales Post" = false then begin
            GeneralLedgerSetup."Generate E-Inv. on Sales Post" := true;
            GeneralLedgerSetup.Modify();
        end;

        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        CreateSalesLineWithGST(SalesHeader, SalesLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, PostedDocumentNo);
        exit(PostedDocumentNo);
    end;

    local procedure CreateAndPostSalesDocumentWithMultipleLine(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        var SalesLine2: Record "Sales Line";
        LineType: Enum "Sales Line Type";
                      DocumentType: Enum "Sales Document Type"): Code[20];
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CustomerNo: Code[20];
        LocationCode: Code[10];
        PostedDocumentNo: Code[20];
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Generate E-Inv. on Sales Post" = false then begin
            GeneralLedgerSetup."Generate E-Inv. on Sales Post" := true;
            GeneralLedgerSetup.Modify();
        end;

        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        CreateSalesLineWithGST(SalesHeader, SalesLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        CreateSalesLineWithGST(SalesHeader, SalesLine2, LineType, LibraryRandom.RandDecInRange(2, 12, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, PostedDocumentNo);
        exit(PostedDocumentNo);
    end;

    local procedure CreateAndPostSalesDocumentWithNegativeAndPostiveUnitPrice(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
                      DocumentType: Enum "Sales Document Type"): Code[20];
    var
        CustomerNo: Code[20];
        LocationCode: Code[10];
        PostedDocumentNo: Code[20];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        CreateSalesLineWithNegativeAndPositiveUnitPriceWithGST(SalesHeader, SalesLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, PostedDocumentNo);
        exit(PostedDocumentNo);
    end;

    local procedure CreateAndPostSalesDocumentWithApplication(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
                      DocumentType: Enum "Sales Document Type"): Code[20];
    var
        CustomerNo: Code[20];
        LocationCode: Code[10];
        PostedDocumentNo: Code[20];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        CreateSalesLineWithGST(SalesHeader, SalesLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        SalesHeader.Validate("Applies-to Doc. Type", SalesHeader."Applies-to Doc. Type"::Payment);
        SalesHeader.Validate("Applies-to Doc. No.", Storage.Get(PaymentDocNoLbl));

        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        exit(PostedDocumentNo);
    end;

    local procedure CreateSalesHeaderWithGST(
        var SalesHeader: Record "Sales Header";
        CustomerNo: Code[20];
        DocumentType: Enum "Sales Document Type";
                          LocationCode: Code[10])
    var
        WithoutPaymentofDuty: Boolean;
        POS: Boolean;
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Validate("Location Code", LocationCode);

        if StorageBoolean.ContainsKey(WithoutPaymentofDutyLbl) then begin
            WithoutPaymentofDuty := StorageBoolean.Get(WithoutPaymentofDutyLbl);
            if WithoutPaymentofDuty then
                SalesHeader.Validate("GST Without Payment of Duty", true);
        end;
        if StorageBoolean.ContainsKey(POSLbl) then begin
            POS := StorageBoolean.Get(POSLbl);
            if POS then begin
                SalesHeader.Validate("GST Invoice", true);
                SalesHeader.Validate("POS Out Of India", true);
            end;
        end;
        SalesHeader.Modify(true);
    end;

    local procedure CreateSalesLineWithGST(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
                      Quantity: Decimal;
                      Exempted: Boolean;
                      LineDiscount: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LineTypeNo: Code[20];
        LineNo: Integer;
        NoOfLine: Integer;
    begin
        if not Storage.ContainsKey(NoOfLineLbl) then
            NoOfLine := 1
        else
            Evaluate(NoOfLine, Storage.Get(NoOfLineLbl));
        for LineNo := 1 to NoOfLine do begin
            case LineType of
                LineType::Item:
                    LineTypeNo := LibraryGST.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
                LineType::"G/L Account":
                    LineTypeNo := LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
                LineType::"Fixed Asset":
                    LineTypeNo := LibraryGST.CreateFixedAssetWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
            end;

            LibrarySales.CreateSalesLine(SalesLine, SalesHeader, LineType, LineTypeno, Quantity);
            SalesLine.Validate("VAT Prod. Posting Group", VATPostingsetup."VAT Prod. Posting Group");
            if StorageBoolean.ContainsKey(PartialShipLbl) then begin
                if StorageBoolean.Get(PartialShipLbl) then
                    SalesLine.Validate(SalesLine."Qty. to Ship", Quantity / 2);
                SalesLine.Validate(SalesLine."Qty. to Invoice", Quantity / 2);
                StorageBoolean.Remove(PartialShipLbl);
            end;
            if LineDiscount then begin
                SalesLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
                LibraryGST.UpdateLineDiscAccInGeneralPostingSetup(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
            end;

            if StorageBoolean.ContainsKey(PriceInclusiveOfTaxLbl) then
                if StorageBoolean.Get(PriceInclusiveOfTaxLbl) = true then
                    SalesLine.Validate("Price Inclusive of Tax", true);
            SalesLine.Validate("Unit Price Incl. of Tax", LibraryRandom.RandInt(10000));

            SalesLine.Validate("Unit Price", LibraryRandom.RandInt(10000));
            SalesLine.Modify(true);
            CalculateGSTOnSalesLine(SalesLine);
        end;
    end;

    local procedure CreateSalesLineWithDecimalValueAndGST(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
                      Quantity: Decimal;
                      Exempted: Boolean;
                      LineDiscount: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LineTypeNo: Code[20];
        LineNo: Integer;
        NoOfLine: Integer;
    begin
        if not Storage.ContainsKey(NoOfLineLbl) then
            NoOfLine := 1
        else
            Evaluate(NoOfLine, Storage.Get(NoOfLineLbl));
        for LineNo := 1 to NoOfLine do begin
            case LineType of
                LineType::Item:
                    LineTypeNo := LibraryGST.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
                LineType::"G/L Account":
                    LineTypeNo := LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
                LineType::"Fixed Asset":
                    LineTypeNo := LibraryGST.CreateFixedAssetWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
            end;

            LibrarySales.CreateSalesLine(SalesLine, SalesHeader, LineType, LineTypeno, Quantity);
            SalesLine.Validate("VAT Prod. Posting Group", VATPostingsetup."VAT Prod. Posting Group");
            if StorageBoolean.ContainsKey(PartialShipLbl) then begin
                if StorageBoolean.Get(PartialShipLbl) then
                    SalesLine.Validate(SalesLine."Qty. to Ship", Quantity / 2);
                SalesLine.Validate(SalesLine."Qty. to Invoice", Quantity / 2);
                StorageBoolean.Remove(PartialShipLbl);
            end;
            if LineDiscount then begin
                SalesLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
                LibraryGST.UpdateLineDiscAccInGeneralPostingSetup(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
            end;

            if StorageBoolean.ContainsKey(PriceInclusiveOfTaxLbl) then
                if StorageBoolean.Get(PriceInclusiveOfTaxLbl) = true then
                    SalesLine.Validate("Price Inclusive of Tax", true);
            SalesLine.Validate("Unit Price Incl. of Tax", LibraryRandom.RandInt(10000));

            SalesLine.Validate("Unit Price", LibraryRandom.RandDec(10000, 4));
            SalesLine.Modify(true);
            CalculateGSTOnSalesLine(SalesLine);
        end;
    end;

    local procedure CreateSalesLineWithNegativeAndPositiveUnitPriceWithGST(
            var SalesHeader: Record "Sales Header";
            var SalesLine: Record "Sales Line";
            LineType: Enum "Sales Line Type";
                          Quantity: Decimal;
                          Exempted: Boolean;
                          LineDiscount: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LineTypeNo: Code[20];
        LineNo: Integer;
        NoOfLine: Integer;
    begin
        if not Storage.ContainsKey(NoOfLineLbl) then
            NoOfLine := 1
        else
            Evaluate(NoOfLine, Storage.Get(NoOfLineLbl));
        for LineNo := 1 to NoOfLine do begin
            case LineType of
                LineType::Item:
                    LineTypeNo := LibraryGST.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
                LineType::"G/L Account":
                    LineTypeNo := LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
                LineType::"Fixed Asset":
                    LineTypeNo := LibraryGST.CreateFixedAssetWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
            end;

            LibrarySales.CreateSalesLine(SalesLine, SalesHeader, LineType, LineTypeno, Quantity);
            SalesLine.Validate("VAT Prod. Posting Group", VATPostingsetup."VAT Prod. Posting Group");
            if StorageBoolean.ContainsKey(PartialShipLbl) then begin
                if StorageBoolean.Get(PartialShipLbl) then
                    SalesLine.Validate(SalesLine."Qty. to Ship", Quantity / 2);
                SalesLine.Validate(SalesLine."Qty. to Invoice", Quantity / 2);
                StorageBoolean.Remove(PartialShipLbl);
            end;
            if LineDiscount then begin
                SalesLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
                LibraryGST.UpdateLineDiscAccInGeneralPostingSetup(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
            end;

            if LineNo = 1 then
                SalesLine.Validate("Unit Price", 10000)
            else
                SalesLine.Validate("Unit Price", -10000);

            SalesLine.Modify(true);
            CalculateGSTOnSalesLine(SalesLine);
        end;
    end;


    local procedure CreateGenJnlLineForVoucherWithAdvancePayment(
        var GenJournalLine: Record "Gen. Journal Line";
        TemplateType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        CustomerNo: Code[20];
        LocationCode: Code[10];
        AccountType: Enum "Gen. Journal Account Type";
    begin
        CreateLocationWithVoucherSetup(TemplateType);
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);

        CustomerNo := CopyStr(Storage.Get(CustomerNoLbl), 1, 20);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        Evaluate(AccountType, Storage.Get(AccountTypeLbl));

        LibraryJournals.CreateGenJournalLine(
            GenJournalLine,
            GenJournalTemplate.Name,
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Customer,
            CustomerNo,
            AccountType,
            CopyStr(Storage.Get(AccountNoLbl), 1, 20),
            -LibraryRandom.RandIntInRange(1, 10000));

        GenJournalLine.Validate("Location Code", LocationCode);
        GenJournalLine.Validate("GST Group Code", CopyStr(Storage.Get(GSTGroupCodeLbl), 1, 20));
        GenJournalLine.Validate("HSN/SAC Code", CopyStr(Storage.Get(HSNSACCodeLbl), 1, 10));
        GenJournalLine.Validate("GST on Advance Payment", true);
        GenJournalLine.Modify(true);
        CalculateGST(GenJournalLine);
    end;

    local procedure CreateGenJnlLineForVoucher(
            var GenJournalLine: Record "Gen. Journal Line";
            TemplateType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        CustomerNo: Code[20];
        LocationCode: Code[10];
        AccountType: Enum "Gen. Journal Account Type";
    begin
        CreateLocationWithVoucherSetup(TemplateType);
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);

        CustomerNo := CopyStr(Storage.Get(CustomerNoLbl), 1, 20);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        Evaluate(AccountType, Storage.Get(AccountTypeLbl));

        LibraryJournals.CreateGenJournalLine(
            GenJournalLine,
            GenJournalTemplate.Name,
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Customer,
            CustomerNo,
            AccountType,
            CopyStr(Storage.Get(AccountNoLbl), 1, 20),
            -LibraryRandom.RandIntInRange(1, 10000));

        GenJournalLine.Validate("Location Code", LocationCode);
        GenJournalLine.Modify(true);
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

    local procedure CalculateGST(GenJournalLine: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnGenJnlLine(GenJournalLine, GenJournalLine);
    end;

    local procedure CalculateGSTOnSalesLine(SalesLine: Record "Sales Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnSalesLine(SalesLine, SalesLine);
    end;

    local procedure UnapplyCustLedgerEntry(DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]);
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        LibraryERM.FindCustomerLedgerEntry(CustLedgerEntry, DocumentType, DocumentNo);
        LibraryERM.UnapplyCustomerLedgerEntry(CustLedgerEntry);
    end;

    local procedure VerifyAdvPaymentApplied()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
        CustLedgerEntry.SetRange("Document No.", Storage.Get(PaymentDocNoLbl));
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields(Amount, "Remaining Amount");

        Assert.AreNotEqual(CustLedgerEntry.Amount, CustLedgerEntry."Remaining Amount",
            StrSubstNo(VerifyErr, CustLedgerEntry.FieldName("Remaining Amount"), CustLedgerEntry.TableCaption));
    end;

    local procedure VerifyGSTEntries(DocumentNo: Code[20]; TableID: Integer)
    begin
        LibraryGSTSales.VerifyGSTEntries(DocumentNo, TableID, ComponentPerArray);
    end;

    local procedure VerifyAdvPaymentUnapplied()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
        CustLedgerEntry.SetRange("Document No.", Storage.Get(PaymentDocNoLbl));
        CustLedgerEntry.FindFirst();

        Assert.AreEqual(true, CustLedgerEntry.Open, StrSubstNo(VerifyErr, CustLedgerEntry.FieldName(Open), CustLedgerEntry.TableCaption));
    end;

    local procedure CreateAndPostSalesDocumentWithNonGSTSupplies(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
        DocumentType: Enum "Sales Document Type"): Code[20];
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CustomerNo: Code[20];
        LocationCode: Code[10];
        PostedDocumentNo: Code[20];
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Generate E-Inv. on Sales Post" = false then begin
            GeneralLedgerSetup."Generate E-Inv. on Sales Post" := true;
            GeneralLedgerSetup.Modify();
        end;

        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, LineType, '', LibraryRandom.RandDecInRange(2, 10, 0));
        LibraryGST.CreateGeneralPostingSetup(SalesHeader."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, PostedDocumentNo);
        exit(PostedDocumentNo);
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    var
        POS: Boolean;
    begin
        if StorageBoolean.ContainsKey(POSLbl) then
            POS := StorageBoolean.Get(POSLbl);
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(GSTGroupCodeLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(HSNSACCodeLbl));
        TaxRates.AttributeValue3.SetValue(Storage.Get(FromStateCodeLbl));
        TaxRates.AttributeValue4.SetValue(Storage.Get(ToStateCodeLbl));
        TaxRates.AttributeValue5.SetValue(Today);
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', Today));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]);
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]);
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]);
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[3]);
        if POS then
            TaxRates.AttributeValue11.SetValue(POS)
        else
            TaxRates.AttributeValue11.SetValue(POS);
        TaxRates.OK().Invoke();
        POS := false;
    end;

    [PageHandler]
    procedure ReferencePageHandler(var UpdateReferenceInvoiceNo: TestPage "Update Reference Invoice No")
    begin
        UpdateReferenceInvoiceNo."Reference Invoice Nos.".Lookup();
        UpdateReferenceInvoiceNo."Reference Invoice Nos.".SetValue(Storage.Get(PostedDocumentNoLbl));
        UpdateReferenceInvoiceNo.Verify.Invoke();
    end;

    [ModalPageHandler]
    procedure CustomerLedgerEntries(var CustomerLedgerEntries: TestPage "Customer Ledger Entries")
    begin
        CustomerLedgerEntries.Filter.SetFilter("Document No.", Storage.Get(PostedDocumentNoLbl));
        CustomerLedgerEntries.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ApplyAdjustmentEntries(var PayGST: TestPage "Pay GST")
    begin
        PayGST.Post.Invoke();
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

    [RequestPageHandler]
    procedure TransferToInvoiceHandler(var RequestPage: TestRequestPage "Job Transfer to Sales Invoice")
    begin
        RequestPage.OK().Invoke()
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin
    end;
}
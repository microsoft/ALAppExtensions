codeunit 18198 "GST Service Tests"
{
    Subtype = Test;

    var
        LibraryService: Codeunit "Library - Service";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        LibraryGST: Codeunit "Library GST";
        LibraryERM: Codeunit "Library - ERM";
        LibraryJournals: Codeunit "Library - Journals";
        Storage: Dictionary of [Text, Code[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
        ComponentPerArray: array[20] of Decimal;
        ServicePeriodOneMonthLbl: Label '<1M>', Locked = true;
        GSTLEVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
        AppliesToDocErr: Label 'You must remove Applies-to Doc No. before modifying Exempted value.';
        InvoiceTypeErr: Label 'You can not select the Invoice Type %1 for GST Customer Type %2.', Comment = '%1 =Invoice Type , %2 = GST Customer Type';
        GSTPlaceOfSuppErr: Label 'You can not select POS Out Of India field on header if GST Place of Supply is %1', Comment = '%1 = GST Place of Supply Address';
        GSTPaymentDutyErr: Label 'You can only select GST Without Payment of Duty in Export or Deemed Export Customer.';
        CustLedgerEntryVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
        VerifyNonGSTLineCheckErr: Label 'Non GST Line Check not Verified';
        LocationStateCodeLbl: Label 'LocationStateCode';
        LocationCodeLbl: Label 'LocationCode';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        LocPANNoLbl: Label 'LocPANNo';
        CGSTLbl: Label 'CGST';
        ServiceItemLbl: Label 'ServiceItem';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        CESSLbl: label 'CESS';
        ExemptedLbl: Label 'Exempted';
        ServiceItemNoLbl: Label 'ServiceItemNo';
        LineDiscountLbl: Label 'LineDiscount';
        FromStateCodeLbl: Label 'FromStateCode';
        CustomerNoLbl: Label 'CustomerNo';
        ToStateCodeLbl: Label 'ToStateCode';
        GSTGroupReverseChargeErr: Label 'GST Group Code %1 with Reverse Charge cannot be selected for Service transactions.', Comment = '%1 = GST Group Code %1.';
        PaymentDocNoLbl: Label 'PaymentDocNo';
        AccountTypeLbl: Label 'AccountType';
        AccountNoLbl: Label 'AccountNo';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceOrdIntraStateWithItemResAppWithAdvPayment()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [380516] Check if the system is calculating GST in case of Intrastate Service Order and Invoice For Customer - Registered with Service Item and Resource and Application with GST on Advance.

        // [GIVEN] Created GST Setup and tax rates for Registered Customer where GST Group Type is service and GST jurisdiction is Intrastate
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Bank Receipt Voucher with Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Intrastate Transactions
        CreateServiceHeaderWithServiceItemAndApplication(ServiceHeader, DocumentType::Order);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Item, false, false, true);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Resource, false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 13)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceOrdInterStateWithItemResAppWithAdvPayment()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [380521] Check if the system is calculating GST in case of Interstate Service Invoice For Customer - Registered with Service Item and Resource and Application with GST on Advance.

        // [GIVEN] Created GST Setup and tax rates for Registered Customer where GST Group Type is service and GST jurisdiction is Interstate
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Bank Receipt Voucher with Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Interstate Transactions
        CreateServiceHeaderWithServiceItemAndApplication(ServiceHeader, DocumentType::Order);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Item, false, false, true);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Resource, false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceOrdInterStateWithItemResAppWithNormalPayment()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [380525] Check if the system is calculating GST in case of Interstate Service Invoice For Customer - Registered with Service Item and Resource and Application with Normal Advance.

        // [GIVEN] Created GST Setup and tax rates for Registered Customer where GST Group Type is service and GST jurisdiction is Interstate
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Bank Receipt Voucher with Normal Advance Payment
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Interstate Transactions
        CreateServiceHeaderWithServiceItemAndApplication(ServiceHeader, DocumentType::Order);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Item, false, false, true);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Resource, false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 4)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceOrdInterStateWithItemResOfflineAppWithAdvPayment()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is calculating GST in case of Interstate Service Invoice For Customer - Registered with Service Item and Resource and offline Application with GST on Advance.

        // [GIVEN] Created GST Setup and tax rates for Registered Customer where GST Group Type is service and GST jurisdiction is Interstate
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Bank Receipt Voucher with Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Interstate Transactions
        CreateServiceItemLine(ServiceHeader, DocumentType::Order);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Item, false, false, true);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Resource, false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] Apply and verify Customer Ledger Entry
        LibraryERM.ApplyCustomerLedgerEntries(GenJournalDocumentType::Invoice, GenJournalDocumentType::Payment, PostedDocumentNo, (Storage.Get(PaymentDocNoLbl)));
        VerifyAdvPaymentApplied();
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceOrdInterStateWithItemResWithOfflineApplication()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is calculating GST in case of Interstate Service Invoice For Customer - Registered with Service Item and Resource and Offline Application with Normal Advance.

        // [GIVEN] Created GST Setup and tax rates for Registered Customer where GST Group Type is service and GST jurisdiction is Interstate
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Bank Receipt Voucher with Normal Advance Payment
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Interstate Transactions without application
        CreateServiceItemLine(ServiceHeader, DocumentType::Order);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Item, false, false, true);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Resource, false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] Apply and verify Customer Ledger Entry
        LibraryERM.ApplyCustomerLedgerEntries(GenJournalDocumentType::Invoice, GenJournalDocumentType::Payment, PostedDocumentNo, (Storage.Get(PaymentDocNoLbl)));
        VerifyAdvPaymentApplied();
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnregCustServiceOrdIntraStateWithItemResAppWithNormalPayment()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [380579] Check if the system is calculating GST in case of Intrastate Service Invoice for Un-Registered Customer with Service Item and Resource and Application with Normal Advance.

        // [GIVEN] Created GST Setup and tax rates for Unregistered Customer where GST Group Type is service and GST jurisdiction is Intrastate
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Bank Receipt Voucher with Normal Advance Payment
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Intrastate Transactions
        CreateServiceHeaderWithServiceItemAndApplication(ServiceHeader, DocumentType::Order);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Item, false, false, true);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Resource, false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 5)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromExportCustServiceOrdInterStateWithItemResAppWithNormalPayment()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is calculating GST in case of Interstate Service Invoice For Customer - Export with Service Item and Resource and Application with Normal Advance.

        // [GIVEN] Created GST Setup and tax rates for Export Customer where GST Group Type is service and GST jurisdiction is Interstate
        CreateGSTSetup(GSTCustomeType::Export, GSTGroupType::Service, false);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Bank Receipt Voucher with Normal Advance Payment
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Interstate Transactions
        CreateServiceHeaderWithServiceItemAndApplication(ServiceHeader, DocumentType::Order);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Item, false, false, true);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Resource, false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 5)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceOrdInterStateWithItemResWithUnApplication()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is calculating GST in case Un-application of Interstate Service Invoice For Customer - Registered with Service Item and Resource with GST on Advance.

        // [GIVEN] Created GST Setup and tax rates for Registered Customer where GST Group Type is service and GST jurisdiction is Interstate
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Bank Receipt Voucher with Advance Payment
        CreateGenJnlLineForVoucherWithAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Interstate Transactions
        CreateServiceHeaderWithServiceItemAndApplication(ServiceHeader, DocumentType::Order);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Item, false, false, true);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Resource, false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] Unapply Customer Ledger Entry and Verify
        UnapplyCustLedgerEntry(GenJournalDocumentType::Invoice, PostedDocumentNo);
        VerifyAdvPaymentUnapplied();
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceOrdInterStateWithItemResWithNoramlPaymentUnapplication()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is calculating GST in case of Interstate Service Invoice For Customer - Registered with Service Item and Resource and Un-Application with Normal Advance.

        // [GIVEN] Created GST Setup and tax rates for Registered Customer where GST Group Type is service and GST jurisdiction is Interstate
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Bank Receipt Voucher with Normal Advance Payment
        CreateGenJnlLineForVoucher(GenJournalLine, TemplateType::"Bank Receipt Voucher");
        Storage.Set(PaymentDocNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Interstate Transactions and application with Normal advance payment
        CreateServiceHeaderWithServiceItemAndApplication(ServiceHeader, DocumentType::Order);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Item, false, false, true);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::Resource, false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] Unapply Customer Ledger Entry and Verify
        UnapplyCustLedgerEntry(GenJournalDocumentType::Invoice, PostedDocumentNo);
        VerifyAdvPaymentUnapplied();
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustServiceInvoiceIntraStateWithGLRes()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [378014] Check if the system is calculating GST in case of Intrastate Service Invoice for Un-Registered Customer  with Service G/L and Resource.
        // [GIVEN] Created GST Setup for Unregistered Customer for Intrastate Transactions
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as G/L Account and Resource for Intrastate Transactions
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            false, false, false);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckAppliestoDocNoValidationForExemptedItem()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] Check Applies-to Doc No. for Exempted Value';.
        // [GIVEN] Created GST Setup for Registered Customer with Exempted true
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(true, false, false);

        // [WHEN] Create Service Invoice with GST and Line Type as Item for Intrastate Transactions
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Invoice);
        ServiceHeader.Validate("Applies-to ID", LibraryRandom.RandText(10));
        ServiceHeader.Modify(true);

        // [THEN] Assert Error Verified for LineTyoe Item for Exempted Item
        asserterror ServiceLine.Validate(Exempted, true);
        Assert.ExpectedError(AppliesToDocErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckInvoiceTypeValidationOnServiceOrdForUnregCust()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] Check Validation in Service Order - Invoice type Bill of Supply not allowed for Unregistered Customer.
        // [GIVEN] Created GST Setup for Unregistered Customer with GSTGroupType Goods
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false, false);

        // [WHEN] Create Service Order with GST and Line Type as Item for Interstate Juridisction
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Order);
        asserterror ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"Bill of Supply");
        ServiceHeader.Validate("GST Customer Type", GSTCustomeType::Unregistered);
        ServiceHeader.Modify(true);

        // [THEN] Assert Error Verified for Unregistered Customer
        Assert.ExpectedError(StrSubstNo(InvoiceTypeErr, ServiceHeader."Invoice Type"::"Bill of Supply", ServiceHeader."GST Customer Type"));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckGSTGroupRevChargeForServiceInvWithGLAccount()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] Check GST Group Code with Reverse Charge cannot be selected for Service transactions with G/L Account.
        // [GIVEN] Created GST Setup for Unregistered Customer with Reverse Charge true
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);

        // [WHEN] Create Service Invoice with GST and Line Type as G/L Account for Intrastate Transactions
        asserterror CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] Assert Error Verified for LineTyoe G/L Account
        Assert.ExpectedError(StrSubstNo(GSTGroupReverseChargeErr, Storage.Get(GSTGroupCodeLbl)));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckGSTAssesabelValueValiadtionsWithGLAccount()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] Check GST Assesable Value Validation in Service Line with Line Type G/L Account.
        // [GIVEN] Created GST Setup for Registered Customer with GSTGroupType Goods
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false, false);

        // [WHEN] Create Service Invoice with GST and Line Type as G/L Account for Intrastate Transactions
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        ServiceLine.Validate("Currency Code", LibraryGST.CreateCurrencyCode());
        ServiceLine.Validate("GST On Assessable Value", true);
        ServiceLine.Modify(true);

        // [THEN] Service Entries Verified
        VerifyServiceEntries(ServiceHeader."No.")
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckGSTAssesabelValueLCYValiadtionsWithGLAccount()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] Check GST Assesable Value LCY Validation in Service Line with Line Type G/L Account.
        // [GIVEN] Created GST Setup for Unregistered Customer with GSTGroupType Goods
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false, false);

        // [WHEN] Create Service Invoice with GST and Line Type as G/L Account for Intrastate Transactions
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        ServiceLine.Validate("Currency Code", LibraryGST.CreateCurrencyCode());
        ServiceLine.Validate("GST On Assessable Value", true);
        ServiceLine.Validate("GST Assessable Value (LCY)", LibraryRandom.RandDecInRange(100, 1000, 0));
        ServiceLine.Modify(true);

        // [THEN] Service Entries Verified
        VerifyServiceEntries(ServiceHeader."No.")
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckGSTGroupRevChargeForServiceInvWithItem()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] Check GST Group Code with Reverse Charge cannot be selected for Service transactions with Item.
        // [GIVEN] Created GST Setup for Unregistered Customer with Reverse Charge true
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);

        // [WHEN] Create Service Invoice with GST and Line Type as Item for Intrastate Transactions
        asserterror CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Assert Error Verified for GSTReversCharge
        Assert.ExpectedError(StrSubstNo(GSTGroupReverseChargeErr, Storage.Get(GSTGroupCodeLbl)));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckGSTGroupRevChargeValidationForItem()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] Check GST Group Code with Reverse Charge cannot be selected for Service transactions with Item.
        // [GIVEN] Created GST Setup for Unregistered Customer with Reverse Charge true
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);

        // [WHEN] Create Service Invoice with GST and Line Type as Item for Intrastate Transactions
        asserterror CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Assert Error Verified for GSTReverseCharge
        asserterror ServiceLine.Validate("GST Group Code", Storage.Get(GSTGroupCodeLbl));
        Assert.ExpectedError(StrSubstNo(GSTGroupReverseChargeErr, Storage.Get(GSTGroupCodeLbl)));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckGSTGroupRevChargeForServiceInvWithResource()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] Check GST Group Code with Reverse Charge cannot be selected for Service transactions with Resource.
        // [GIVEN] Created GST Setup for Registered Customer with Reverse Charge true
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);

        // [WHEN] Create Service Invoice with GST and Line Type as Resource for Intrastate Transactions
        asserterror CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            DocumentType::Invoice);

        // [THEN] Assert Error Verified for GSTReverseCharge
        Assert.ExpectedError(StrSubstNo(GSTGroupReverseChargeErr, Storage.Get(GSTGroupCodeLbl)));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckGSTGroupRevChargeForServiceInvWithCost()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] Check GST Group Code with Reverse Charge cannot be selected for Service transactions with Cost.
        // [GIVEN] Created GST Setup for Registered Customer with Reverse Charge true
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);

        // [WHEN] Create Service Invoice with GST and Line Type as Cost for Intrastate Transactions
        asserterror CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Cost,
            DocumentType::Invoice);

        // [THEN] Assert Error Verified for GSTReverseCharge
        Assert.ExpectedError(StrSubstNo(GSTGroupReverseChargeErr, Storage.Get(GSTGroupCodeLbl)));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceInvoiceIntraStateWithResCost()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [378536] Check if the system is calculating GST in case of Intrastate Service Invoice For Registered Customer with Resource and Cost.
        // [GIVEN] Created GST Setup for Registered Customer for Intrastate Transactions
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as Resource and Cost for Intrastate Transactions
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            DocumentType::Invoice);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Cost,
            false, false, false);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceInvoiceInterStateWithResCost()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [378801] Check if the system is calculating GST in case of Interastate Service Invoice For Registered Customer with Resource and Cost.
        // [GIVEN] Created GST Setup for Registered Customer for InterState Transactions
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as Resource and Cost for Interstate Transactions
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            DocumentType::Invoice);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Cost,
            false, false, false);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromExemptCustServiceInvoiceIntraStateWithResCost()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [378932] Check if the system is calculating GST in case of Intrastate Service Invoice For Exempted Customer with Resource and Cost.
        // [GIVEN] Created GST Setup for Exempted Customer for IntraState Transactions
        CreateGSTSetup(GSTCustomeType::Exempted, GSTGroupType::Service, true);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as Resource and Cost for Intrastate Transactions
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            DocumentType::Invoice);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Cost,
            false, false, false);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromExemptCustServiceInvoiceInterStateWithResCost()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [379035] Check if the system is calculating GST in case of Interstate Service Invoice For Exempted Customer with Resource and Cost.
        // [GIVEN] Created GST Setup for Exempted Customer with GSTGroupType Service
        CreateGSTSetup(GSTCustomeType::Exempted, GSTGroupType::Service, false);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as Resource and Cost for Interstate Transactions
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            DocumentType::Invoice);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Cost,
            false, false, false);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustServiceOrdIntraStateWithItemRes()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [377995] Check if the system is calculating GST in case of Intrastate Service Order For Un-Registered Customer  with Service Item and Resource.
        // [GIVEN] Created GST Setup for Unregistered Customer for GSTGroupType Service
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Intrastate Transactions
        CreateServiceItemLine(
            ServiceHeader,
            DocumentType::Order);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustServiceOrdInterStateWithItemResCost()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [378505] Check if the system is calculating GST in case of Interstate Service Order and Invoice For Un-Registered Customer with Service Item and Resource, Cost.
        // [GIVEN] Created GST Setup for Unregistered Customer with ServiceItem
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Interstate Transactions
        CreateServiceItemLine(
            ServiceHeader,
            DocumentType::Order);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Cost,
            false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceOrdIntraStateWithItemResCost()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [378507] Check if the system is calculating GST in case of Intrastate Service Order and Invoice For Registered Customer with Service Item and Resource, Cost.
        // [GIVEN] Created GST Setup for Registered Customer with Service Item
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Intrastate Transactions
        CreateServiceItemLine(
            ServiceHeader,
            DocumentType::Order);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Cost,
            false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceOrdInterStateWithItemResCost()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [378669] Check if the system is calculating GST in case of Interstate Service Order and Invoice For Registered Customer with Service Item and Resource, Cost.
        // [GIVEN] Created GST Setup for Reistered Customer with Service Item
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Interstate Transactions
        CreateServiceItemLine(
            ServiceHeader,
            DocumentType::Order);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Cost,
            false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromExemptCustServiceOrdIntraStateWithItemResCost()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [378920] Check if the system is calculating GST in case of Intrastate Service Order and Invoice For Exempted  Customer with Service Item and Resource, Cost.
        // [GIVEN] Created GST Setup for Intrastate Exmepted Customer with Service Item
        CreateGSTSetup(GSTCustomeType::Exempted, GSTGroupType::Service, true);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Intrastate Transactions
        CreateServiceItemLine(
            ServiceHeader,
            DocumentType::Order);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Cost,
            false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromExemptCustServiceOrdInterStateWithItemResCost()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [379027] Check if the system is calculating GST in case of Interstate Service Order and Invoice For Exempted  Customer with Service Item and Resource, Cost.
        // [GIVEN] Created GST Setup for Interstate Exmepted Customer with Service Item
        CreateGSTSetup(GSTCustomeType::Exempted, GSTGroupType::Service, false);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Interstate Transactions
        CreateServiceItemLine(
            ServiceHeader,
            DocumentType::Order);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Cost,
            false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSEZUnitCustServiceOrdInterStateWithItemResCost()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [379277] Check if the system is calculating GST in case of Interstate Service Order and Invoice For Customer - SEZ Unit with Service Item and Resource, Cost.
        // [GIVEN] Created GST Setup for Sez Unit Customer 
        CreateGSTSetup(GSTCustomeType::"SEZ Unit", GSTGroupType::Service, false);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource and Cost for Interstate Transactions
        CreateServiceItemLine(
            ServiceHeader,
            DocumentType::Order);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Cost,
            false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSEZUnitCustServiceOrdWithItemResCostWithoutPaymntDuty()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [380344] Check if the system is calculating GST in case of Interstate Service Order and Invoice For Customer - SEZ Unit with Service Item and Resource, GST without Payment of Duty.
        // [GIVEN] Created GST Setup for Sez Unit Customer with Service Item
        CreateGSTSetup(GSTCustomeType::"SEZ Unit", GSTGroupType::Service, false);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource and Cost for Interstate Transactions
        CreateServiceItemLine(
            ServiceHeader,
            DocumentType::Order);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Cost,
            false, false, true);
        DocumentNo := ServiceHeader."No.";
        ServiceHeader.Validate("GST Without Payment of Duty", true);
        ServiceHeader.Modify(true);
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;


    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromExportCustServiceOrdInterStateWithItemResCost()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [379913] Check if the system is calculating GST in case of Interstate Service Order and Invoice For Customer - Export with Service Item and Resource, Cost.
        // [GIVEN] Created GST Setup for Export Customer
        CreateGSTSetup(GSTCustomeType::Export, GSTGroupType::Service, false);
        InitializeShareStep(false, true, true);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource and Cost for Interstate Transactions
        CreateServiceItemLine(
            ServiceHeader,
            DocumentType::Order);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            false, true, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Cost,
            false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSEZDevUnitCustServiceOrdInterStateWithItemResCost()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [379395] Check if the system is calculating GST in case of Interstate Service Order and Invoice For Customer - SEZ Development with Service Item and Resource, Cost. With Discount.
        // [GIVEN] Created GST Setup for SEZ Development Customer
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Service, false);
        InitializeShareStep(false, false, true);

        // [WHEN] Create and Post Service Order with GST and Line Type as Item and Resource for Interstate Transactions
        CreateServiceItemLine(
            ServiceHeader,
            DocumentType::Order);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            false, true, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            false, false, true);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Cost,
            false, false, true);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckInvoiceTypeValidationOnServiceOrdForExpCust()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] [380224] Check Validation in Service Order - Invoice type taxable not allowed for Export/Deemed Export Customer.
        // [GIVEN] Created GST Setup fro Export Customer with GSTGroupType Goods
        CreateGSTSetup(GSTCustomeType::Export, GSTGroupType::Goods, false);
        InitializeShareStep(false, true, false);

        // [WHEN] Create Service Order with GST and Line Type as Item for Interstate Juridisction
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Order);
        asserterror ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::Taxable);
        ServiceHeader.Validate(ServiceHeader."GST Customer Type", GSTCustomeType::Export);
        ServiceHeader.Modify(true);

        // [THEN] Assert Error Verified
        Assert.ExpectedError(StrSubstNo(InvoiceTypeErr, ServiceHeader."Invoice Type"::Taxable, ServiceHeader."GST Customer Type"));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckInvoiceTypeValidationOnServiceOrdForExemptedCust()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] [380224] Check Validation in Service Order - Invoice type taxable not allowed for Exempted Customer.
        // [GIVEN] Created GST Setup for Exempted Customer with GSTGroupType Goods
        CreateGSTSetup(GSTCustomeType::Exempted, GSTGroupType::Goods, false);
        InitializeShareStep(false, true, false);

        // [WHEN] Create Service Order with GST and Line Type as Item for Interstate Juridisction
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Order);
        asserterror ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::Taxable);
        ServiceHeader.Validate(ServiceHeader."GST Customer Type", GSTCustomeType::Exempted);
        ServiceHeader.Modify(true);

        // [THEN] Assert Error Verified
        Assert.ExpectedError(StrSubstNo(InvoiceTypeErr, ServiceHeader."Invoice Type"::Taxable, ServiceHeader."GST Customer Type"));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckPOSOutofIndiaValidationOnServiceOrdForExportCust()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] Check Validation in Service Order - POS Out of India not selected if GST Place of Supply is Location Address.
        // [GIVEN] Created GST Setup for Export Customer with GSTGroupType Goods
        CreateGSTSetup(GSTCustomeType::Export, GSTGroupType::Goods, false);
        InitializeShareStep(false, true, false);

        // [WHEN] Create Service Order with GST and Line Type as Item for Interstate Juridisction
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Order);
        ServiceLine.Validate("GST Place Of Supply", ServiceLine."GST Place Of Supply"::"Location Address");
        ServiceLine.Modify(true);

        // [THEN] Assert Error Verified for Export Customer
        asserterror ServiceHeader.Validate("POS Out Of India", true);
        Assert.ExpectedError(StrSubstNo(GSTPlaceOfSuppErr, ServiceLine."GST Place Of Supply"));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckGSTWithoutPaymntofDutyValidationForRegCust()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] Check Validation in Service Order - GST Without Payment of Duty not selected for Export/Deemed Export Customer.
        // [GIVEN] Created GST Setup for Registered Customer with GSTGroupType Goods
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, true, false);

        // [WHEN] Create Service Order with GST and Line Type as Item for Interstate Juridisction
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] Assert Error Verified
        asserterror ServiceHeader.Validate("GST Without Payment of Duty", true);
        Assert.ExpectedError(GSTPaymentDutyErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckInvoiceTypeValidationOnServiceInvForDeemedExpCust()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] [380224] Check Validation in Service Order - Invoice type taxable not allowed for Export/Deemed Export Customer.
        // [GIVEN] Created GST Setup for Deemed Export Customer with GSTGroupType Goods
        CreateGSTSetup(GSTCustomeType::"Deemed Export", GSTGroupType::Goods, false);
        InitializeShareStep(false, true, false);

        // [WHEN] Create Service Order with GST and Line Type as Item for Interstate Juridisction
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Order);
        asserterror ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::Taxable);
        ServiceHeader.Validate(ServiceHeader."GST Customer Type", GSTCustomeType::"Deemed Export");
        ServiceHeader.Modify(true);

        // [THEN] Assert Error Verified
        Assert.ExpectedError(StrSubstNo(InvoiceTypeErr, ServiceHeader."Invoice Type"::Taxable, ServiceHeader."GST Customer Type"));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure VerifyNonGSTLineCheckOnServiceInvoice()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] [380238] Check Validation in Service Order/Invoice - If apply Non-GST on line then GST Group and HSN/SAC Code should be blank and GST not Calculated.
        // [GIVEN] Created GST Setup for NonGST InterState Registered Customer 
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false, false);

        // [WHEN] Create Service Invoice with GST and Line Type as Item for Interstate Juridisction
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Invoice);
        ServiceLine.Validate("Non-GST Line", true);
        ServiceLine.Modify(true);

        // [THEN] Non GST Line Check Verified
        VerifyNonGSTLineCheckOnServiceLine(ServiceLine);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceInvoiceIntraStateWithGLResNonGST()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] [379465] Check if the system is calculating GST in case of Intrastate Service Invoice For Registered Customer with Resource and Cost - Non GST.
        // [GIVEN] Created GST Setup for NonGST IntraState Registered Customer 
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as G/L Account and Resource for Intrastate Transactions
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            false, false, false);
        ServiceLine.Validate("Non-GST Line", true);
        ServiceLine.Modify(true);

        // [THEN] Service Entries Verified
        VerifyServiceEntries(ServiceHeader."No.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceInvoiceInterStateWithGLResNonGST()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
    begin
        // [SCENARIO] [379522] Check if the system is calculating GST in case of Interastate Service Invoice For Registered Customer with Resource and Cost- Non GST.
        // [GIVEN] Created GST Setup for NonGST Registered Customer
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as G/L Account and Resource for Interstate Transactions
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::Resource,
            false, false, false);
        ServiceLine.Validate("Non-GST Line", true);
        ServiceLine.Modify(true);

        // [THEN] Service Entries Verified
        VerifyServiceEntries(ServiceHeader."No.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustServiceInvoiceThroughServContrctWithItem()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [378348] Check if the system is calculating GST in case of Intrastate Service Invoice through Service Contract For Un-Registered Customer  with Service Item.
        // [GIVEN] Created GST Setup for Unregistered Customer 
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as Item for Intrastate Transactions
        CreateServiceContractDocument(true);
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Invoice);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceInvoiceThroughServContrctWithItem()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [378556] Check if the system is calculating GST in case of Intrastate Service Invoice through Service Contract For Registered Customer  with Service Item.
        // [GIVEN] Created GST Setup for Registered Customer with GSTGroupType Service
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as Item for Intrastate Transactions
        CreateServiceContractDocument(true);
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Invoice);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustServiceInvoiceThroughServContrctWithItemGL()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [378556] Check if the system is calculating GST in case of Intrastate Service Invoice through Service Contract For Registered Customer  with Service Item.
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as Item and G/L for Intrastate Transactions
        CreateServiceContractDocument(true);
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::"G/L Account",
            false, false, false);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromExemptCustServiceInvoiceThroughServContrctWithItem()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [379266] Check if the system is calculating GST in case of Interstate Service Invoice through Service Contract For Exempted Customer with Service Item.
        // [GIVEN] Created GST Setup for InterState Exmepted Customer
        CreateGSTSetup(GSTCustomeType::Exempted, GSTGroupType::Service, false);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as Item for Interstate Transactions
        CreateServiceContractDocument(true);
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Invoice);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromExemptCustServiceInvoiceThroughServContrctWithItemGL()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [379242] Check if the system is calculating GST in case of Intrastate Service Invoice through Service Contract For Exempted Customer with Service Item and G/L Account.
        // [GIVEN] Created GST Setup for IntraState Exempted Customer 
        CreateGSTSetup(GSTCustomeType::Exempted, GSTGroupType::Service, true);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as Item and G/L for Intrastate Transactions
        CreateServiceContractDocument(true);
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::"G/L Account",
            false, false, false);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromUnRegCustServiceInvoiceThroughServQuoteWithItem()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [378400] Check if the system is calculating GST in case of Interstate Service Quote to Order For Un-Registered Customer  with Service Item
        // [GIVEN] Created GST Setup for InterState Unregsitered Customer
        CreateGSTSetup(GSTCustomeType::Unregistered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as Item for Interstate Transactions
        CreateServiceContractDocument(false);
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Invoice);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromExemptCustServiceInvoiceThroughServQuoteWithItemGL()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [379253] Check if the system is calculating GST in case of Interstate Service Invoice through Service Contract Quote For Exempted Customer with Service Item and G/L Account.
        // [GIVEN] Created GST Setup for InterState Exempted Customer
        CreateGSTSetup(GSTCustomeType::Exempted, GSTGroupType::Service, false);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as Item and G/L for Interstate Transactions
        CreateServiceContractDocument(false);
        CreateServiceDocument(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateServiceLineWithGST(
            ServiceHeader,
            ServiceLine,
            LineType::"G/L Account",
            false, false, false);

        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntryHandler')]
    procedure PostFromServiceCrMemoForRegCustomerWithRefInv()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is calculating GST in case of Interstate Service Credit memo through Copy Document For Registered Customer with Service Item and G/L Account.

        // [GIVEN] Created GST Setup and tax rates for registerd customer and interstate jurisdiction
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, false);

        // [WHEN] Create and Post Service Invoice with GST and Line Type as Item and G/L for Interstate Transactions
        CreateServiceDocument(ServiceHeader, ServiceLine, LineType::Item, DocumentType::Invoice);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::"G/L Account", false, false, false);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);
        Storage.Set(PostedDocumentNoLbl, PostedDocumentNo);

        // [THEN] Create and Post service credit memo with update reference invoice number
        Clear(ServiceHeader);
        Clear(ServiceLine);
        CreateServiceDocument(ServiceHeader, ServiceLine, LineType::Item, DocumentType::"Credit Memo");
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, LineType::"G/L Account", false, false, false);
        UpdateReferenceInvoiceNoAndVerify(ServiceHeader);
        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostServiceInvWithGSTWithoutPaymntofDutyForExportCust()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Service Document Type";
        LineType: Enum "Service Line Type";
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check and Post Service Invoice - GST Without Payment of Duty is selected for Export Customer.
        // [GIVEN] Created GST Setup for Export Customer with GSTGroupType Goods
        CreateGSTSetup(GSTCustomeType::Export, GSTGroupType::Goods, false);
        InitializeShareStep(false, true, false);

        // [WHEN] Create Service Order with GST and Line Type as Item for Interstate Juridisction
        CreateServiceDocumentwithGstWithoutPaymentofDuty(
            ServiceHeader,
            ServiceLine,
            LineType::Item,
            DocumentType::Invoice);

        DocumentNo := ServiceHeader."No.";
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        PostedDocumentNo := GetPostedServiceInvNo(DocumentNo);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        LibraryGST.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 3);
        VerifyGSTEntries(PostedDocumentNo);
    end;

    local procedure UpdateReferenceInvoiceNoAndVerify(ServiceHeader: Record "Service Header")
    var
        ServiceCreditMemo: TestPage "Service Credit Memo";
    begin
        ServiceCreditMemo.OpenEdit();
        ServiceCreditMemo.Filter.SetFilter("No.", ServiceHeader."No.");
        ServiceCreditMemo."Update Reference Invoice No.".Invoke();
    end;

    local procedure GetServiceLineType(ServiceLineType: Enum "Service Line Type"): Enum Type
    begin
        case ServiceLineType of
            ServiceLineType::Item:
                exit(Type::Item);
            ServiceLineType::"G/L Account":
                exit(Type::"G/L Account");
            ServiceLineType::Resource:
                exit(Type::Resource);
            ServiceLineType::Cost:
                exit(Type::"G/L Account")
        end;
    end;

    local procedure InitializeShareStep(Exempted: Boolean; LineDiscount: Boolean; ServiceItem: Boolean)
    begin
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
        StorageBoolean.Set(ServiceItemLbl, ServiceItem);
    end;

    local procedure CreateServiceDocument(
        var ServiceHeader: Record "Service Header";
        var ServiceLine: Record "Service Line";
        ServiceLineType: Enum "Service Line Type";
        DocumentType: Enum "Service Document Type"): Code[20];
    var
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateServiceHeaderWithGST(ServiceHeader, CustomerNo, DocumentType, LocationCode);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, ServiceLineType, StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl), StorageBoolean.Get(ServiceItemLbl));
    end;

    local procedure CreateServiceDocumentwithGstWithoutPaymentofDuty(
        var ServiceHeader: Record "Service Header";
        var ServiceLine: Record "Service Line";
        ServiceLineType: Enum "Service Line Type";
        DocumentType: Enum "Service Document Type"): Code[20];
    var
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateServiceHeaderWithGSTWithoutPaymentofDuty(ServiceHeader, CustomerNo, DocumentType, LocationCode);
        CreateServiceLineWithGST(ServiceHeader, ServiceLine, ServiceLineType, StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl), StorageBoolean.Get(ServiceItemLbl));
    end;

    local procedure CreateServiceHeaderWithGST(
        var ServiceHeader: Record "Service Header";
        CustomerNo: Code[20];
        DocumentType: Enum "Service Document Type";
        LocationCode: Code[10])
    begin
        LibraryService.CreateServiceHeader(ServiceHeader, DocumentType, CustomerNo);
        ServiceHeader.Validate("Customer No.", CustomerNo);
        ServiceHeader.Validate("Posting Date", WorkDate());
        ServiceHeader.Validate("Location Code", LocationCode);
        ServiceHeader.Modify(true);
    end;

    local procedure CreateServiceHeaderWithGSTWithoutPaymentofDuty(
        var ServiceHeader: Record "Service Header";
        CustomerNo: Code[20];
        DocumentType: Enum "Service Document Type";
        LocationCode: Code[10])
    begin
        LibraryService.CreateServiceHeader(ServiceHeader, DocumentType, CustomerNo);
        ServiceHeader.Validate("Customer No.", CustomerNo);
        ServiceHeader.Validate("Posting Date", WorkDate());
        ServiceHeader.Validate("Location Code", LocationCode);
        ServiceHeader.Validate("GST Without Payment of Duty", true);
        ServiceHeader.Modify(true);
    end;

    local procedure CreateServiceLineWithGST(
        var ServiceHeader: Record "Service Header";
        var ServiceLine: Record "Service Line";
        LineType: Enum "Service Line Type";
        Exempted: Boolean;
        LineDiscount: Boolean;
        ServiceItem: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LineTypeNo: Code[20];
    begin
        case LineType of
            LineType::Item:
                LineTypeNo := LibraryGST.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), false, Exempted);
            LineType::"G/L Account":
                LineTypeNo := LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), false, Exempted);
            LineType::Cost:
                LineTypeNo := LibraryGST.CreateServiceCostWithGSTDetails(VATPostingSetup, Storage.Get(GSTGroupCodeLbl), (Storage.Get(HSNSACCodeLbl)));
            LineType::Resource:
                LineTypeNo := LibraryGST.CreateResourceWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), false);
        end;
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, LineType, LineTypeNo);
        if ServiceItem then
            ServiceLine.Validate("Service Item No.", Storage.Get(ServiceItemNoLbl));

        ServiceLine.Validate(Quantity, LibraryRandom.RandInt(1));
        if LineDiscount then begin
            ServiceLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
            LibraryGST.UpdateLineDiscAccInGeneralPostingSetup(ServiceLine."Gen. Bus. Posting Group", ServiceLine."Gen. Prod. Posting Group");
        end;
        ServiceLine.Validate("Unit Price", LibraryRandom.RandInt(10000));
        ServiceLine.Modify(true);
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
        Storage.Set(LocPANNoLbl, LocPANNo);

        LibraryGST.CreateNoVatSetup();

        LocationStateCode := LibraryGST.CreateInitialSetup();
        Storage.Set(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true);
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        Storage.Set(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::"Bill-to Address", false);
        Storage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        Storage.Set(HSNSACCodeLbl, HSNSACCode);

        CustomerNo := LibraryGST.CreateCustomerSetup();
        Storage.Set(CustomerNoLbl, CustomerNo);

        if IntraState then
            CreateSetupForIntraStateCustomer(GSTCustomerType, IntraState)
        else
            CreateSetupForInterStateCustomer(GSTCustomerType, IntraState);

        CreateTaxRate();
        CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
    end;

    local procedure VerifyServiceEntries(DocumentNo: Code[20])
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
    begin
        ServiceHeader.SetRange("No.", DocumentNo);
        ServiceHeader.FindFirst();
        Assert.RecordIsNotEmpty(ServiceHeader);

        ServiceLine.SetRange(ServiceLine."Document No.", ServiceHeader."No.");
        ServiceLine.FindFirst();
        Assert.RecordIsNotEmpty(ServiceLine);
    end;

    local procedure CreateSetupForIntraStateCustomer(GSTCustomerType: Enum "GST Customer Type"; IntraState: Boolean)
    var
        LocationStateCode: Code[10];
        CustomerNo: Code[20];
        LocPANNo: Code[20];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        LocPANNo := Storage.Get(LocPANNoLbl);
        UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, LocationStateCode, LocPANNo);
        InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
    end;

    local procedure CreateSetupForInterStateCustomer(GSTCustomerType: Enum "GST Customer Type"; IntraState: Boolean)
    var
        LocationStateCode: Code[10];
        CustomerStateCode: Code[10];
        CustomerNo: Code[20];
        LocPANNo: Code[20];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        LocPANNo := Storage.Get(LocPANNoLbl);
        CustomerStateCode := LibraryGST.CreateGSTStateCode();
        UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, CustomerStateCode, LocPANNo);

        if GSTCustomerType in [GSTCustomerType::Export, GSTCustomerType::"SEZ Unit", GSTCustomerType::"SEZ Development", GSTCustomerType::"Deemed Export"] then
            InitializeTaxRateParameters(IntraState, '', LocationStateCode)
        else
            InitializeTaxRateParameters(IntraState, CustomerStateCode, LocationStateCode);
    end;

    local procedure CreateGSTComponentAndPostingSetup(
        IntraState: Boolean;
        LocationStateCode: Code[10];
        TaxComponent: Record "Tax Component";
        GSTComponentcode: Text[30])
    begin
        if IntraState then begin
            GSTComponentcode := CGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentcode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTComponentcode := SGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentcode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTComponentcode := IGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentcode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end;
    end;

    local procedure InitializeTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10])
    var
        GSTTaxPercent: Decimal;
    begin
        Storage.Set(FromStateCodeLbl, FromState);
        Storage.Set(ToStateCodeLbl, ToState);

        GSTTaxPercent := LibraryRandom.RandDecInRange(10, 18, 0);

        if IntraState then begin
            ComponentPerArray[1] := (GSTTaxPercent / 2);
            ComponentPerArray[2] := (GSTTaxPercent / 2);
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

    local procedure CreateServiceContractDocument(Contract: Boolean)
    var
        ServiceContractHeader: Record "Service Contract Header";
        ServiceContractLine: Record "Service Contract Line";
        ServiceContractAccountGroup: Record "Service Contract Account Group";
        ServiceContractTemplate: Record "Service Contract Template";
        ServiceItem: Record "Service Item";
        ContractType: Option " ","Quote","Contract";
        CustomerNo: Code[20];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LibraryService.CreateServiceItem(ServiceItem, CustomerNo);
        LibraryService.CreateServiceContractAcctGrp(ServiceContractAccountGroup);

        LibraryService.CreateServiceContractTemplate(ServiceContractTemplate, ServiceContractTemplate."Default Service Period");
        if Contract then
            CreateServiceContractHeader(ServiceContractHeader, ContractType::Contract, CustomerNo)
        else
            CreateServiceContractHeader(ServiceContractHeader, ContractType::Quote, CustomerNo);
        LibraryService.CreateServiceContractLine(ServiceContractLine, ServiceContractHeader, ServiceItem."No.");

        ServiceContractLine.Validate("Line Value", LibraryRandom.RandInt(10000));
        ServiceContractLine.Validate("Line Amount", LibraryRandom.RandInt(10000));
        ServiceContractLine.Modify(true);

        if Contract then
            ServiceContractHeader.Validate(Status, ServiceContractHeader.Status::Signed);
        ServiceContractHeader.Modify(true);
    end;

    local procedure CreateServiceContractHeader(var ServiceContractHeader: Record "Service Contract Header"; ContractType: Option; CustomerNo: Code[20])
    var
        ServiceContractAccountGroup: Record "Service Contract Account Group";
        ServiceMgtSetup: Record "Service Mgt. Setup";
        NoSeries: Codeunit "No. Series";
    begin
        ServiceContractHeader.Init();
        ServiceMgtSetup.Get();
        if ServiceContractHeader."Contract No." = '' then begin
            ServiceMgtSetup.TestField("Service Contract Nos.");
                ServiceContractHeader."No. Series" := ServiceMgtSetup."Service Contract Nos.";
                ServiceContractHeader."Contract No." := NoSeries.GetNextNo(ServiceContractHeader."No. Series");
        end;

        ServiceContractHeader."Starting Date" := WorkDate();
        ServiceContractHeader."First Service Date" := WorkDate();
        ServiceContractHeader.Validate("Contract Type", ContractType);
        ServiceContractHeader.Insert();
        ServiceContractHeader.Validate("Customer No.", CustomerNo);
        Evaluate(ServiceContractHeader."Service Period", ServicePeriodOneMonthLbl);
        LibraryService.CreateServiceContractAcctGrp(ServiceContractAccountGroup);
        ServiceContractHeader.Validate("Serv. Contract Acc. Gr. Code", ServiceContractAccountGroup.Code);
        ServiceContractHeader.Validate("Your Reference", ServiceContractHeader."Customer No.");
        ServiceContractHeader.Modify(true);
    end;

    local procedure CreateServiceItemLine(
        var ServiceHeader: Record "Service Header";
        DocumentType: Enum "Service Document Type")
    var
        ServiceItem: Record "Service Item";
        ServiceItemLine: Record "Service Item Line";
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ServiceItemNo: Code[20];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateServiceHeaderWithGST(ServiceHeader, CustomerNo, DocumentType, LocationCode);
        LibraryService.CreateServiceItem(ServiceItem, CustomerNo);
        LibraryService.CreateServiceItemLine(ServiceItemLine, ServiceHeader, ServiceItem."No.");
        ServiceItemNo := ServiceItem."No.";
        Storage.Set(ServiceItemNoLbl, ServiceItemNo);
    end;

    local procedure VerifyNonGSTLineCheckOnServiceLine(var ServiceLine: Record "Service Line")
    begin
        ServiceLine.SetFilter("GST Group Code", '=%1', '');
        ServiceLine.SetFilter("HSN/SAC Code", '=%1', '');
        if ServiceLine.IsEmpty then
            Error(VerifyNonGSTLineCheckErr);
    end;

    local procedure GetPostedServiceInvNo(DocumentNo: Code[20]): Code[20]
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
    begin
        ServiceInvoiceHeader.SetRange("Pre-Assigned No.", DocumentNo);
        if ServiceInvoiceHeader.FindFirst() then
            exit(ServiceInvoiceHeader."No.")
        else begin
            ServiceInvoiceHeader.SetRange("Pre-Assigned No.");
            ServiceInvoiceHeader.SetRange("Order No.", DocumentNo);
            ServiceInvoiceHeader.FindFirst();
            exit(ServiceInvoiceHeader."No.")
        end;
    end;

    local procedure VerifyGSTEntries(PostedDocumentNo: Code[20])
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
        ComponentList: List of [Code[30]];
    begin
        ServiceInvoiceLine.SetRange("Document No.", PostedDocumentNo);
        ServiceInvoiceLine.SetFilter("No.", '<>%1', '');
        if ServiceInvoiceLine.FindSet() then
            repeat
                FillComponentList(ServiceInvoiceLine."GST Jurisdiction Type", ComponentList, ServiceInvoiceLine."GST Group Code");
                VerifyGSTEntriesForService(ServiceInvoiceLine, PostedDocumentNo, ComponentList);
                VerifyDetailedGSTEntriesForService(ServiceInvoiceLine, PostedDocumentNo, ComponentList);
            until ServiceInvoiceLine.Next() = 0;
    end;

    local procedure FillComponentList(
        GSTJurisdictionType: Enum "GST Jurisdiction Type";
        var ComponentList: List of [Code[30]];
        GSTGroupCode: Code[20])
    var
        GSTGroup: Record "GST Group";
    begin
        GSTGroup.Get(GSTGroupCode);
        Clear(ComponentList);
        if GSTJurisdictionType = GSTJurisdictionType::Intrastate then begin
            ComponentList.Add(CGSTLbl);
            ComponentList.Add(SGSTLbl);
        end else
            ComponentList.Add(IGSTLbl);

        if GSTGroup."Component Calc. Type" <> GSTGroup."Component Calc. Type"::General then
            ComponentList.Add(CESSLbl);
    end;

    local procedure GetServiceGSTAmount(
        ServiceInvoiceLine: Record "Service Invoice Line"): Decimal
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
    begin
        ServiceInvoiceHeader.Get(ServiceInvoiceLine."Document No.");

        if ServiceInvoiceHeader."GST Customer Type" in [ServiceInvoiceHeader."GST Customer Type"::Registered,
                  ServiceInvoiceHeader."GST Customer Type"::Unregistered,
                  ServiceInvoiceHeader."GST Customer Type"::Export,
                  ServiceInvoiceHeader."GST Customer Type"::"Deemed Export",
                  ServiceInvoiceHeader."GST Customer Type"::"SEZ Development",
                  ServiceInvoiceHeader."GST Customer Type"::"SEZ Unit"] then
            if ServiceInvoiceLine."GST Jurisdiction Type" = ServiceInvoiceLine."GST Jurisdiction Type"::Interstate then begin
                if ServiceInvoiceHeader."GST Without Payment of Duty" then
                    exit(0.00)
                else
                    exit((ServiceInvoiceLine.Amount * ComponentPerArray[4]) / 100);
            end
            else
                exit(ServiceInvoiceLine.Amount * ComponentPerArray[1] / 100)
        else
            if ServiceInvoiceHeader."GST Customer Type" = ServiceInvoiceHeader."GST Customer Type"::Exempted then
                exit(0.00);
    end;

    local procedure VerifyGSTEntriesForService(
        var ServiceInvoiceLine: Record "Service Invoice Line";
        PostedDocumentNo: Code[20];
        var ComponentList: List of [Code[30]])
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        SourceCodeSetup: Record "Source Code Setup";
        GLEntry: Record "G/L Entry";
        ComponentCode: Code[30];
    begin
        ServiceInvoiceHeader.Get(PostedDocumentNo);

        SourceCodeSetup.Get();
        GLEntry.SetRange("Document No.", PostedDocumentNo);
        GLEntry.FindFirst();

        foreach ComponentCode in ComponentList do begin
            GSTLedgerEntry.Reset();
            GSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            GSTLedgerEntry.SetRange("Document No.", PostedDocumentNo);
            GSTLedgerEntry.FindFirst();
        end;

        Assert.AreEqual(ServiceInvoiceLine."Gen. Bus. Posting Group", GSTLedgerEntry."Gen. Bus. Posting Group",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldName("Gen. Bus. Posting Group"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(ServiceInvoiceLine."Gen. Prod. Posting Group", GSTLedgerEntry."Gen. Prod. Posting Group",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Gen. Prod. Posting Group"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(ServiceInvoiceHeader."Posting Date", GSTLedgerEntry."Posting Date",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Posting Date"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Document Type"::Invoice, GSTLedgerEntry."Document Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Document Type"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Transaction Type"::Sales, GSTLedgerEntry."Transaction Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction Type"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Source Type"::Customer, GSTLedgerEntry."Source Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Type"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."GST Component Code", GSTLedgerEntry."GST Component Code",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Component Code"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(ServiceInvoiceHeader."Customer No.", GSTLedgerEntry."Source No.",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source No."), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(UserId, GSTLedgerEntry."User ID",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("User ID"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(SourceCodeSetup."Service Management", GSTLedgerEntry."Source Code",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Code"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GLEntry."Transaction No.", GSTLedgerEntry."Transaction No.",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction No."), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Entry Type"::"Initial Entry", GSTLedgerEntry."Entry Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Entry Type"), GSTLedgerEntry.TableCaption));
    end;

    local procedure VerifyDetailedGSTEntriesForService(
        var ServiceInvoiceLine: Record "Service Invoice Line";
        PostedDocumentNo: Code[20];
        var ComponentList: List of [Code[30]])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        SourceCodeSetup: Record "Source Code Setup";
        Customer: Record Customer;
        GLEntry: Record "G/L Entry";
        GSTAmount: Decimal;
        ComponentCode: Code[30];
        CurrencyFactor: Decimal;
    begin
        ServiceInvoiceHeader.Get(PostedDocumentNo);

        Customer.Get(ServiceInvoiceHeader."Customer No.");
        SourceCodeSetup.Get();

        CurrencyFactor := ServiceInvoiceHeader."Currency Factor";
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        GLEntry.SetRange("Document No.", PostedDocumentNo);
        GLEntry.FindFirst();

        foreach ComponentCode in ComponentList do begin
            DetailedGSTLedgerEntry.Reset();
            DetailedGSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            DetailedGSTLedgerEntry.SetRange("Document No.", PostedDocumentNo);
            DetailedGSTLedgerEntry.SetRange("Document Line No.", ServiceInvoiceLine."Line No.");
            DetailedGSTLedgerEntry.FindFirst();
        end;

        GSTAmount := GetServiceGSTAmount(ServiceInvoiceLine);

        DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");

        Assert.AreEqual(DetailedGSTLedgerEntry."Entry Type"::"Initial Entry", DetailedGSTLedgerEntry."Entry Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Entry Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Transaction Type"::Sales, DetailedGSTLedgerEntry."Transaction Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Document Type"::Invoice, DetailedGSTLedgerEntry."Document Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Document Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ServiceInvoiceHeader."Posting Date", DetailedGSTLedgerEntry."Posting Date",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Posting Date"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(GetServiceLineType(ServiceInvoiceLine.Type), DetailedGSTLedgerEntry.Type,
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption(Type), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Product Type", DetailedGSTLedgerEntry."Product Type",
        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Product Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Source Type"::Customer, DetailedGSTLedgerEntry."Source Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(LibraryGST.GetGSTPayableAccountNo(ServiceInvoiceHeader."Location State Code", DetailedGSTLedgerEntry."GST Component Code"), DetailedGSTLedgerEntry."G/L Account No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("G/L Account No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ServiceInvoiceHeader."Customer No.", DetailedGSTLedgerEntry."Source No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ServiceInvoiceLine."HSN/SAC Code", DetailedGSTLedgerEntry."HSN/SAC Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("HSN/SAC Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ServiceInvoiceLine."GST Group Code", DetailedGSTLedgerEntry."GST Group Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Group Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ServiceInvoiceLine."GST Jurisdiction Type", DetailedGSTLedgerEntry."GST Jurisdiction Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Jurisdiction Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ComponentCode, DetailedGSTLedgerEntry."GST Component Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Component Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreNearlyEqual(-ServiceInvoiceLine.Amount / CurrencyFactor, DetailedGSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Base Amount"), DetailedGSTLedgerEntry.TableCaption));

        if ServiceInvoiceHeader."GST Customer Type" in [ServiceInvoiceHeader."GST Customer Type"::Registered,
           ServiceInvoiceHeader."GST Customer Type"::Unregistered,
           ServiceInvoiceHeader."GST Customer Type"::Export,
           ServiceInvoiceHeader."GST Customer Type"::"Deemed Export",
           ServiceInvoiceHeader."GST Customer Type"::"SEZ Development",
           ServiceInvoiceHeader."GST Customer Type"::"SEZ Unit"] then
            if DetailedGSTLedgerEntry."GST Jurisdiction Type" = DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate then
                Assert.AreEqual(ComponentPerArray[4], DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
            else
                Assert.AreEqual(ComponentPerArray[1], DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
        else
            Assert.AreEqual(0.00, DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreNearlyEqual(-GSTAmount / CurrencyFactor, DetailedGSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Amount"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(-ServiceInvoiceLine.Quantity, DetailedGSTLedgerEntry.Quantity,
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName(Quantity), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(UserId, DetailedGSTLedgerEntryInfo."User ID",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("User ID"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(false, DetailedGSTLedgerEntryInfo.Positive,
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(Positive), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(ServiceInvoiceLine."Line No.", DetailedGSTLedgerEntry."Document Line No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Reverse Charge"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ServiceInvoiceHeader."Nature of Supply", DetailedGSTLedgerEntryInfo."Nature of Supply",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Nature of Supply"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(ServiceInvoiceHeader."Location State Code", DetailedGSTLedgerEntryInfo."Location State Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Location State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(Customer."State Code", DetailedGSTLedgerEntryInfo."Buyer/Seller State Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Buyer/Seller State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(ServiceInvoiceHeader."Location GST Reg. No.", DetailedGSTLedgerEntry."Location  Reg. No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Location  Reg. No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ServiceInvoiceHeader."Customer GST Reg. No.", DetailedGSTLedgerEntry."Buyer/Seller Reg. No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Buyer/Seller Reg. No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ServiceInvoiceLine."GST Group Type", DetailedGSTLedgerEntry."GST Group Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Group Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."GST Credit", DetailedGSTLedgerEntry."GST Credit",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Credit"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(GLEntry."Transaction No.", DetailedGSTLedgerEntry."Transaction No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntryInfo."Original Doc. Type"::Invoice, DetailedGSTLedgerEntryInfo."Original Doc. Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. Type"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(PostedDocumentNo, DetailedGSTLedgerEntryInfo."Original Doc. No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. No."), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(ServiceInvoiceHeader."Location Code", DetailedGSTLedgerEntry."Location Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Location Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ServiceInvoiceHeader."GST Customer Type", DetailedGSTLedgerEntry."GST Customer Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Vendor Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ServiceInvoiceLine."Gen. Bus. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Bus. Posting Group",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldName("Gen. Bus. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(ServiceInvoiceLine."Gen. Prod. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Prod. Posting Group",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Gen. Prod. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(ServiceInvoiceHeader."Invoice Type", DetailedGSTLedgerEntryInfo."Sales Invoice Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Sales Invoice Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntryInfo."Component Calc. Type"::General, DetailedGSTLedgerEntryInfo."Component Calc. Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Component Calc. Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ServiceInvoiceLine."Unit of Measure Code", DetailedGSTLedgerEntryInfo.UOM,
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(UOM), DetailedGSTLedgerEntryInfo.TableCaption));
    end;

    local procedure CreateServiceHeaderWithServiceItemAndApplication(
            var ServiceHeader: Record "Service Header";
            DocumentType: Enum "Service Document Type")
    var
        ServiceItem: Record "Service Item";
        ServiceItemLine: Record "Service Item Line";
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ServiceItemNo: Code[20];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateServiceHeaderWithGST(ServiceHeader, CustomerNo, DocumentType, LocationCode);
        ServiceHeader.Validate("Applies-to Doc. Type", ServiceHeader."Applies-to Doc. Type"::Payment);
        ServiceHeader.Validate("Applies-to Doc. No.", Storage.Get(PaymentDocNoLbl));
        ServiceHeader.Modify();

        LibraryService.CreateServiceItem(ServiceItem, CustomerNo);
        LibraryService.CreateServiceItemLine(ServiceItemLine, ServiceHeader, ServiceItem."No.");
        ServiceItemNo := ServiceItem."No.";
        Storage.Set(ServiceItemNoLbl, ServiceItemNo);
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
            StrSubstNo(CustLedgerEntryVerifyErr, CustLedgerEntry.FieldName("Remaining Amount"), CustLedgerEntry.TableCaption));
    end;

    local procedure VerifyAdvPaymentUnapplied()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
        CustLedgerEntry.SetRange("Document No.", Storage.Get(PaymentDocNoLbl));
        CustLedgerEntry.FindFirst();

        Assert.AreEqual(true, CustLedgerEntry.Open, StrSubstNo(CustLedgerEntryVerifyErr, CustLedgerEntry.FieldName(Open), CustLedgerEntry.TableCaption));
    end;

    [PageHandler]
    procedure ReferencePageHandler(var UpdateReferenceInvoiceNo: TestPage "Update Reference Invoice No")
    begin
        UpdateReferenceInvoiceNo."Reference Invoice Nos.".Lookup();
        UpdateReferenceInvoiceNo."Reference Invoice Nos.".SetValue(Storage.Get(PostedDocumentNoLbl));
        UpdateReferenceInvoiceNo.Verify.Invoke();
    end;

    [ModalPageHandler]
    procedure CustomerLedgerEntryHandler(var CustomerLedgerEntries: TestPage "Customer Ledger Entries")
    begin
        CustomerLedgerEntries.Filter.SetFilter("Document No.", Storage.Get(PostedDocumentNoLbl));
        CustomerLedgerEntries.OK().Invoke();
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
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]);
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]);
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]);
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[5]);
        TaxRates.OK().Invoke();
    end;
}
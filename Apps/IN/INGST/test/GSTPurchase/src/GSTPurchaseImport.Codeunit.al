codeunit 18133 "GST Purchase Import"
{
    Subtype = Test;

    var
        LibraryGST: Codeunit "Library GST";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryGSTPurchase: Codeunit "Library - GST Purchase";
        Storage: Dictionary of [Text, Text];
        ComponentPerArray: array[20] of Decimal;
        StorageBoolean: Dictionary of [Text, Boolean];
        NoOfLineLbl: Label 'NoOfLine';
        LocationStateCodeLbl: Label 'LocationStateCode';
        LocationCodeLbl: Label 'LocationCode';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        VendorNoLbl: Label 'VendorNo';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        InputCreditAvailmentLbl: Label 'InputCreditAvailment';
        ExemptedLbl: Label 'Exempted';
        LineDiscountLbl: Label 'LineDiscount';
        FromStateCodeLbl: Label 'FromStateCode';
        ToStateCodeLbl: Label 'ToStateCode';
        AssociateEnterpriseLbl: Label 'AssociateEnterprise';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo';

    // [SCENARIO] [353874] Check if the system is calculating GST in case of Import of Goods from Foreign Vendor where Input Tax Credit is available through Purchase Quote
    // [FEATURE] [Inter-State Services, Purchase Quote] [ITC, Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreatePurchQuoteForImportVendWithITCGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Create GST Setup and tax rates
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Purchase Quote with line type as Item and inter state transaction
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Quote);

        //Verified GST Amount and Make Quote to Order
        LibraryGSTPurchase.VerifyTaxTransactionForPurchaseQuote(PurchaseHeader);
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [353889] Check if the system is calculating GST in case of Import of Services from Foreign Vendor where Input Tax Credit is available through Purchase Order
    // [FEATURE] [Imported Services, Purchase Order] [ITC, Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdImportVendWithITCServices()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line type as G/L Account for interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [354130] Check if the system is calculating GST in case of Import of Service from Associates Enterprises Vendor where Input Tax Credit is not available through Purchase Order
    // [FEATURE] [Imported Services, Purchase Order] [ITC Non Availment, Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdImportVendWithNonITCServices()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line type as G/L Account for interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [Scenario] [354185] Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Goods where Input Tax Credit is available through purchase return order
    // [FEATURE] [Imported Goods, Purchase Return Order] [ITC, Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdToImportVendWithITCSGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as Item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [354189] Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Goods where Input Tax Credit is not available through purchase Credit Memo Copy with Document
    // [FEATURE] [Imported Goods, Purchase Credit Memo] [ITC Not Available, Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToImportVendWithNonITCSGoodsCopyDoc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as Item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [354194] Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Goods where Input Tax Credit is not available through Credit Memo 
    // [FEATURE] [Imported Goods, Purchase Credit Memo] [ITC Not Available, Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToImportVendWithNonITCSGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as Item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [354195] Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Goods where Input Tax Credit is not available through Purchase Credit Memo with get reversed posted document
    // [FEATURE] [Imported Goods, Purchase Credit Memo] [ITC Not Available, Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToImportVendWithNonITCSGoodsGetReverse()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as Item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [354212] Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Services where Input Tax Credit is available through Purchase Credit Memo with get reversed posted document
    // [FEATURE] [Imported Goods, Purchase Credit Memo] [ITC Available, Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToImportVendWithITCServicesGetReverse()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as G/L Account for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [354217] Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Services where Input Tax Credit is not available through Purchase Credit Memo with get reversed posted document
    // [FEATURE] [Imported Services, Purchase Credit Memo] [ITC Not Available, Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToImportVendWithNonITCSServicesGetReverse()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as G/L Account for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [354222] Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Services from Associates Enterprises Vendor where Input Tax Credit is available through Purchase Credit Memo with get reversed posted document
    // [FEATURE] [Imported Services, Purchase Credit Memo] [ITC Available, Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToImportAssoEntVendWithITCServicesGetReverse()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as G/L Account for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [SCENARIO] [355443] Check if the system is calculating GST in case of Import Purchase of Fixed Assets from Foreign Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order
    // [FEATURE] [Imported Fixed Asset, Purchase Order] [ITC, Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithImportVendWithITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line type as Fixed Asset for interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [355920] Check if the system is calculating GST in case of Import of Services from Associates Enterprises Vendor where Input Tax Credit is available  through Purchase Invoice
    // [FEATURE] [Imported Service, Purchase Invoice] [ITC, Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithImportAssoEntVendWithITCServices()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as G/L Account for interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [355921] Check if the system is calculating GST in case of Import of Services from Associates Enterprises Vendor where Input Tax Credit is not available  through Purchase Invoice
    // [FEATURE] [Imported Fixed Asset, Purchase Invoice] [ITC Non Availment, Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithImportAssoEntVendWithNonITCServices()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as G/L Account for interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [355915] Check if the system is calculating GST in case of Import of Goods from Foreign Vendor where Input Tax Credit is available  through Purchase Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvImportofGoodsFromForeignVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Item for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    // [SCENARIO] [355916] Check if the system is calculating GST in case of Import of Services from Foreign Vendor where Input Tax Credit is available  through Purchase Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvImportofServicesFromForeignVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as GLAccount for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    // [SCENARIO] [355917] Check if the system is calculating GST in case of Import of Goods from Foreign Vendor where Input Tax Credit is not available  through Purchase Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvImportofGoodsFromForeignVendorWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as GLAccount for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    // [SCENARIO] [355919] Check if the system is calculating GST in case of Import of Services from Foreign Vendor where Input Tax Credit is not available  through Purchase Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvImportofServicesFromForeignVendorWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as GLAccount for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    // [SCENARIO] [355396] Check if the system is calculating GST in case of Import Purchase of Fixed Assets from Foreign Vendor where Input Tax Credit is available with invoice discount/line discount and multiple HSN code wise through Purchase Order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdImportofGoodsFromForeignVendorwithMultipleHSNCode()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as FixedAsset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    // [SCENARIO] [355397] Check if the system is calculating GST in case of Import Purchase of Fixed Assets from Foreign Vendor where Input Tax Credit is available with invoice discount/line discount and multiple HSN code wise through Purchase Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvImportofGoodsFromForeignVendorWithMultipleHSNCode()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as FixedAsset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    // [SCENARIO] [355428] Check if the system is calculating GST in case of Import Purchase of Fixed Assets from Foreign Vendor where Input Tax Credit is not available with invoice discount/line discount and multiple HSN code wise through Purchase order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdImportofGoodsFromForeignVendorWithoutITCWithMultipleHSNCode()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as FixedAsset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    // [SCENARIO] [355429] Check if the system is calculating GST in case of Import Purchase of Fixed Assets from Foreign Vendor where Input Tax Credit is not available with invoice discount/line discount and multiple HSN code wise through Purchase Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvImportofGoodsFromForeignVendorWithoutITCWithMultipleHSNCode()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as FixedAsset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    // [SCENARIO] [355437] Check if the system is calculating GST in case of Import Purchase of Fixed Assets from Foreign Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdImportofGoodsFromForeignVendorWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as FixedAsset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    // [SCENARIO] [355438] Check if the system is calculating GST in case of Import Purchase of Fixed Assets from Foreign Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvImportofGoodsFromForeignVendorWithoutITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as FixedAsset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    // [SCENARIO] [354127] Check if the system is calculating GST in case of Services from Associates Enterprises Vendor where Input Tax Credit is available through Purchase Quote.
    // [FEATURE] [Services Purchase Quote] [Inter-State GST,Associate Vendor Input Tax Credit is available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseServicesQuoteForAssociateVendorWithITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeAssociateVendor(true);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Created Purchase Quote with GST and Line Type as GLAccount for Interstate Transactions.
        DocumentNo := CreatePurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Quote);

        // [THEN] Quote to Make Order
        LibraryGST.VerifyTaxTransactionForPurchase(DocumentNo, PurchaseLine."Document Type"::Quote);
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [354128] Check if the system is calculating GST in case of Import of Goods from Associates Enterprises Vendor where Input Tax Credit is available through Purchase Order.
    // [FEATURE] [Goods Purchase Order] [Inter-State GST,Associate Vendor Input Tax Credit is available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseGoodsOrderForAssociateVendorWithITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeAssociateVendor(true);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Item for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            PurchaseHeader."Document Type"::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    // [SCENARIO] [354129] Check if the system is calculating GST in case of Services from Associates Enterprises Vendor where Input Tax Credit is not available through Purchase Quote.
    // [FEATURE] [Services Purchase Quote] [Inter-State GST,Associate Vendor Input Tax Credit is not available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseServicesQuoteForAssociateVendorWithoutITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        InitializeAssociateVendor(true);
        InitializeShareStep(false, false, false);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Created Purchase Quote with GST and Line Type as GLAccount for Interstate Transactions.
        DocumentNo := CreatePurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Quote);

        // [THEN] Quote to Make Order
        LibraryGST.VerifyTaxTransactionForPurchase(DocumentNo, PurchaseLine."Document Type"::Quote);
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [354874] Check if the system is calculating GST in case of Import of Goods from Foreign Vendor where Input Tax Credit is available through Purchase Quote.
    // [FEATURE] [Goods Purchase Quote] [Inter-State GST,Import Vendor Input Tax Credit is available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseGoodsQuoteForImportVendorWithITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Created Purchase Quote with GST and Line Type as Item for Interstate Transactions.
        DocumentNo := CreatePurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            PurchaseHeader."Document Type"::Quote);

        // [THEN] Quote to Make Order
        LibraryGST.VerifyTaxTransactionForPurchase(DocumentNo, PurchaseLine."Document Type"::Quote);
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [354889] Check if the system is calculating GST in case of Import of Services from Foreign Vendor where Input Tax Credit is available through Purchase Order.
    // [FEATURE] [Services Purchase Order] [Inter-State GST,Import Vendor Input Tax Credit is available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseServicesOrderForImportVendorWithITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as GLAccount for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    // [SCENARIO] [354118] Check if the system is calculating GST in case of Import of Service from Foreign Vendor where Input Tax Credit is not available through Purchase Order.
    // [FEATURE] [Services Purchase Order] [Inter-State GST,Import Vendor Input Tax Credit is not available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseServicesOrderForImportVendorWithoutITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as GLAccount for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    // [SCENARIO] [353900] Check if the system is calculating GST in case of Import of Services from Foreign Vendor where Input Tax Credit is available through Purchase Quote
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreatePurchOrdFromQuoteForServiceImportWithITCIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        OrderNo: Code[20];
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);

        // [WHEN] Create Purchase Order from Purchase Quote
        Storage.Set(NoOfLineLbl, '1');
        CreatePurchaseDocument(
             PurchaseHeader,
             PurchaseLine,
             LineType::"G/L Account",
             DocumentType::Quote);

        //Make Quote to Order
        OrderNo := LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
        LibraryGST.VerifyTaxTransactionForPurchase(OrderNo, DocumentType::Order);
    end;

    // [SCENARIO] [353905] Check if the system is calculating GST in case of Import of Goods from Foreign Vendor where Input Tax Credit is available through Purchase Order
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdForImportVendorWithITCInterSate()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Purchase Journal
        Storage.Set(NoOfLineLbl, '1');
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Order);

        //Verified GST Ledger Entries
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    // [SCENARIO] [353914] Check if the system is calculating GST in case of Import of Goods from Foreign Vendor where Input Tax Credit is not available through Purchase Quote
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreatePurchOrdFromQuoteForImportVendorWithITCIntraSate()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Purchase Quote
        Storage.Set(NoOfLineLbl, '1');
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Quote);

        //Make Quote to Order
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [354113] Check if the system is calculating GST in case of Import of service from Foreign Vendor where Input Tax Credit is not available through Purchase Order with multiple line
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdForServiceImportWithoutITCInterSate()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(false, false, false);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);

        // [WHEN] Create and Post Purchase Order
        Storage.Set(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Order);

        //Verified GST Ledger Entries
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    // [SCENARIO] GST not calculating for import vendor in case of Input Tax Credit is non-availment in Purchase order
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdForGoodsImportWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(false, false, false);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Purchase Order
        Storage.Set(NoOfLineLbl, '1');
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Order);

        //Verified GST Ledger Entries
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    local procedure UpdateVendorSetupWithGST(
        VendorNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        AssociateEnterprise: Boolean;
        StateCode: Code[10];
        PANNo: Code[20])
    var
        Vendor: Record Vendor;
        State: Record State;
    begin
        Vendor.Get(VendorNo);
        if (GSTVendorType <> GSTVendorType::Import) then begin
            State.Get(StateCode);
            Vendor.Validate("State Code", StateCode);
            Vendor.Validate("P.A.N. No.", PANNo);
            if not ((GSTVendorType = GSTVendorType::" ") or (GSTVendorType = GSTVendorType::Unregistered)) then
                Vendor.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo));
        end;

        Vendor.Validate("GST Vendor Type", GSTVendorType);
        if Vendor."GST Vendor Type" = vendor."GST Vendor Type"::Import then
            Vendor.Validate("Associated Enterprises", AssociateEnterprise);
        Vendor.Modify(true);
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

    local procedure CreateGSTSetup(
        GSTVendorType: Enum "GST Vendor Type";
        GSTGroupType: Enum "GST Group Type";
        IntraState: Boolean;
        ReverseCharge: Boolean)
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
            CompanyInformation.Modify(true);
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        Storage.Set(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::"Bill-to Address", ReverseCharge);
        Storage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        Storage.Set(HSNSACCodeLbl, HSNSACCode);

        if IntraState then begin
            VendorNo := LibraryGST.CreateVendorSetup();
            UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, LocationStateCode, LocPANNo);
            InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
            CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
        end else begin
            VendorStateCode := LibraryGST.CreateGSTStateCode();
            VendorNo := LibraryGST.CreateVendorSetup();
            if StorageBoolean.ContainsKey(AssociateEnterpriseLbl) then begin
                UpdateVendorSetupWithGST(VendorNo, GSTVendorType, StorageBoolean.Get(AssociateEnterpriseLbl), VendorStateCode, LocPANNo);
                StorageBoolean.Remove(AssociateEnterpriseLbl)
            end else
                UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, VendorStateCode, LocPANNo);

            if GSTVendorType in [GSTVendorType::Import, GSTVendorType::SEZ] then
                InitializeTaxRateParameters(IntraState, '', LocationStateCode)
            else begin
                InitializeTaxRateParameters(IntraState, VendorStateCode, LocationStateCode);
                CreateGSTComponentAndPostingSetup(IntraState, VendorStateCode, TaxComponent, GSTComponentCode);
            end;
        end;
        Storage.Set(VendorNoLbl, VendorNo);

        CreateTaxRate();

        CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
    end;

    local procedure InitializeShareStep(InputCreditAvailment: Boolean; Exempted: Boolean; LineDiscount: Boolean)
    begin
        StorageBoolean.Set(InputCreditAvailmentLbl, InputCreditAvailment);
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
    end;

    local procedure InitializeAssociateVendor(AssociateEnterprise: Boolean)
    begin
        StorageBoolean.Set(AssociateEnterpriseLbl, AssociateEnterprise);
    end;

    local procedure CreateAndPostPurchaseDocument(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type"): Code[20];
    var
        LibraryRandom: Codeunit "Library - Random";
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
        DocumentType: Enum "Purchase Document Type"): Code[20]
    var
        LibraryRandom: Codeunit "Library - Random";
        VendorNo: Code[20];
        LocationCode: Code[10];
        PurchaseInvoiceType: Enum "GST Invoice Type";
    begin
        Evaluate(VendorNo, Storage.Get(VendorNoLbl));
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(InputCreditAvailmentLbl), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        exit(PurchaseHeader."No.");
    end;

    local procedure CreatePurchaseHeaderWithGST(
        var PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        DocumentType: Enum "Purchase Document Type";
        LocationCode: Code[10];
        PurchaseInvoiceType: Enum "GST Invoice Type")
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        Overseas: Boolean;
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Location Code", LocationCode);
        if Overseas then
            PurchaseHeader.Validate("POS Out Of India", true);
        if PurchaseInvoiceType in [PurchaseInvoiceType::"Debit Note", PurchaseInvoiceType::Supplementary] then
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Vendor Invoice No."), Database::"Purchase Header"))
        else
            PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Vendor Cr. Memo No."), Database::"Purchase Header"));
        if PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ] then begin
            PurchaseHeader."Bill of Entry No." := LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Bill of Entry No."), Database::"Purchase Header");
            PurchaseHeader."Bill of Entry Date" := WorkDate();
            PurchaseHeader."Bill of Entry Value" := LibraryRandom.RandInt(1000);
        end;
        PurchaseHeader.Modify(true);
    end;

    local procedure CreatePurchaseLineWithGST(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        Quantity: Decimal;
        InputCreditAvailment: Boolean;
        Exempted: Boolean;
        LineDiscount: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryRandom: Codeunit "Library - Random";
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
                    LineTypeNo := LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, false);
                LineType::"Fixed Asset":
                    LineTypeNo := LibraryGST.CreateFixedAssetWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
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
            PurchaseLine.Modify(true);
        end;
    end;

    local procedure CreateGSTComponentAndPostingSetup(
        IntraState: Boolean;
        LocationStateCode: Code[10];
        TaxComponent: Record "Tax Component";
        GSTComponentCode: Text[30])
    begin
        if IntraState then begin
            GSTComponentCode := CGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTComponentCode := SGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTComponentCode := IGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end;
    end;

    local procedure InitializeTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10])
    var
        LibraryRandom: Codeunit "Library - Random";
        GSTTaxPercent: Decimal;
    begin
        Storage.Set(FromStateCodeLbl, FromState);
        Storage.Set(ToStateCodeLbl, ToState);
        GSTTaxPercent := LibraryRandom.RandDecInRange(10, 18, 0);
        if IntraState then begin
            ComponentPerArray[1] := (GSTTaxPercent / 2);
            ComponentPerArray[2] := (GSTTaxPercent / 2);
            ComponentPerArray[3] := 0;
        end else
            ComponentPerArray[3] := GSTTaxPercent;
    end;

    local procedure VerifyGSTEntries(DocumentNo: Code[20]; TableID: Integer)
    begin
        LibraryGSTPurchase.VerifyGSTEntries(DocumentNo, TableID, ComponentPerArray);
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
        UpdateReferenceInvoiceNoAndVerify(PurchaseHeader);
        ReverseDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(ReverseDocumentNoLbl, ReverseDocumentNo);
    end;

    local procedure UpdateReferenceInvoiceNoAndVerify(var PurchaseHeader: Record "Purchase Header")
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        ReferenceInvoiceNoMgt: Codeunit "Reference Invoice No. Mgt.";
    begin
        ReferenceInvoiceNo.Init();
        ReferenceInvoiceNo.Validate("Document No.", PurchaseHeader."No.");
        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::"Credit Memo":
                ReferenceInvoiceNo.Validate("Document Type", ReferenceInvoiceNo."Document Type"::"Credit Memo");

            PurchaseHeader."Document Type"::"Return Order":
                ReferenceInvoiceNo.Validate("Document Type", ReferenceInvoiceNo."Document Type"::"Return Order");
        end;

        ReferenceInvoiceNo.Validate("Source Type", ReferenceInvoiceNo."Source Type"::Vendor);
        ReferenceInvoiceNo.Validate("Source No.", PurchaseHeader."Buy-from Vendor No.");
        ReferenceInvoiceNo.Validate("Reference Invoice Nos.", Storage.Get(PostedDocumentNoLbl));
        ReferenceInvoiceNo.Insert(true);

        ReferenceInvoiceNoMgt.UpdateReferenceInvoiceNoforVendor(ReferenceInvoiceNo, ReferenceInvoiceNo."Document Type", ReferenceInvoiceNo."Document No.");
        ReferenceInvoiceNoMgt.VerifyReferenceNo(ReferenceInvoiceNo);
    end;

    [ModalPageHandler]
    procedure ReferenceInvoiceNoPageHandler(var VendorLedgerEntries: TestPage "Vendor Ledger Entries")
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
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]); // SGST
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]); // CGST
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[3]); // IGST
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[4]); // Cess
        TaxRates.OK().Invoke();
    end;
}
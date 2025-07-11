codeunit 18137 "GST Purchase SEZ"
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
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
        WithoutBillOfEntryLbl: Label 'WithoutBillOfEntry';

    // [Scenario] [354289] Check if the system is calculating GST in case of Purchase Return/Credit Memo of Goods from SEZ Vendor where Input Tax Credit is not available without Bill of Entry through Purchase Credit Memo through Copy document 
    // [FEATURE] [Goods, Purchase Credit Memo] [ITC Not Available, SEZ Vendor, Without Bill Of Entry]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToSEZVendWithNonITCGoodsCopyDoc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false, 1, true);

        //[WHEN] Create and Post Purchase Invoice with GST and Line type as Item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [354290] Check if the system is calculating GST in case of Purchase Retrun/Credit Memoof Goods from SEZ Vendor where Input Tax Credit is not available without Bill of Entry through Purchase Credit Memo
    // [FEATURE] [Goods, Purchase Credit Memo] [ITC Not Available, SEZ Vendor, Without Bill Of Entry]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToSEZVendWithNonITCGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false, 1, true);

        //[WHEN] Create and Post Purchase Invoice with GST and Line type as Item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355067] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from SEZ Vendor where Input Tax Credit is not available with invoice discount/line discount multiple HSN code wise through Purchase order
    // [FEATURE] [Fixed Asset, Purchase Order] [ITC Not Available, SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrderToSEZVendWithNonITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true, 1, false);

        //[WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Order);

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(PostedDocumentNoLbl)), Database::"Purch. Inv. Header");
    end;

    // [Scenario] [354269] Check if the system is calculating GST in case of Purchase of Services from SEZ Vendor where Input Tax Credit is not available with cover of Bill of Entry though Purchase order
    // [FEATURE] [Services, Purchase Order] [ITC Not Available, SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrderToSEZVendWithNonITCServices()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false, 1, false);

        //[WHEN] Create and Post Purchase Order with GST and Line type as G/L Account for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(PostedDocumentNoLbl)), Database::"Purch. Inv. Header");
    end;

    // [Scenario] [354270] Check if the system is calculating GST in case of Purchase of Services from SEZ Vendor where Input Tax Credit is not available with cover of Bill of Entry though Purchase Invoice
    // [FEATURE] [Services, Purchase Invoice] [ITC Not Available, SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvoiceToSEZVendWithNonITCServices()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false, 1, false);

        //[WHEN] Create and Post Purchase Invoice with GST and Line type as G/L Account for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(PostedDocumentNoLbl)), Database::"Purch. Inv. Header");
    end;

    // [Scenario] [354273] Check if the system is calculating GST in case of Purchase of Goods from SEZ Vendor where Input Tax Credit is not available without  Bill of Entry though Purchase order/Invoice
    // [FEATURE] [Goods, Purchase Order] [ITC Not Available, SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdToSEZVendWithNonITCGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false, 1, true);

        //[WHEN] Create and Post Purchase Order with GST and Line type as Item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(PostedDocumentNoLbl)), Database::"Purch. Inv. Header");
    end;

    // [Scenario] [354236] Check if the system is calculating GST in case of Purchase of Goods from SEZ Vendor where Input Tax Credit is available without  Bill of Entry though Purchase order/Invoice
    // [FEATURE] [Goods, Purchase Order] [ITC Available, SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdToSEZVendWithITCGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false, 1, true);

        //[WHEN] Create and Post Purchase Order with GST and Line type as Item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(PostedDocumentNoLbl)), Database::"Purch. Inv. Header");
    end;

    // [Scenario] [354268] Check if the system is calculating GST in case of Purchase of Goods from SEZ Vendor where Input Tax Credit is available without  Bill of Entry though Purchase order/Invoice with Exempted items
    // [FEATURE] [Goods, Purchase Order] [ITC Available, SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdToSEZVendWithITCExempetedGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, true, false, 1, true);

        //[WHEN] Create and Post Purchase Order with GST and Line type as Item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(PostedDocumentNoLbl)), Database::"Purch. Inv. Header");
    end;

    // [Scenario] [355060] Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to SEZ Vendor where Input Tax Credit is available with invoice /line discount & multiple HSN through Purchase Return Orders
    // [FEATURE] [Fixed Asset, Purchase Return Order] [ITC Available, SEZ Vendor, Line Discount/ Invoice Discount]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrderToSEZVendWithITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true, 1, false);

        //[WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355061] Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to SEZ Vendor where Input Tax Credit is available with invoice/line discount & multiple HSN through Purchase Credit Memos
    // [FEATURE] [Fixed Asset, Purchase Credit Memo] [ITC Available, SEZ Vendor, Line Discount/ Invoice Discount]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToSEZVendWithITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true, 1, false);

        //[WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355069] Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to SEZ Vendor where Input Tax Credit is not available with invoice /line discount & multiple HSN through Purchase Return Orders
    // [FEATURE] [Fixed Asset, Purchase Return Order] [ITC Not Available, SEZ Vendor, Line Discount/ Invoice Discount]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrderToSEZVendWithNonITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true, 1, false);

        //[WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355070] Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to SEZ Vendor where Input Tax Credit is not available with invoice/line discount & multiple HSN through Purchase Credit Memos
    // [FEATURE] [Fixed Asset, Purchase Credit Memo] [ITC Not Available, SEZ Vendor, Line Discount/ Invoice Discount]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToSEZVendWithNonITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true, 1, false);

        //[WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355075] Check if the system is calculating GST in case of Intra-state Purchase Return of Fixed Assets to SEZ Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Return Orders
    // [FEATURE] [Fixed Asset, Purchase Return Order] [ITC Available, SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrderToSEZVendWithITCFAIntra()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false, 1, false);

        //[WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355076] Check if the system is calculating GST in case of Intra-state Purchase Return of Fixed Assets to SEZ Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Credit Memos
    // [FEATURE] [Fixed Asset, Purchase Credit Memo] [ITC Available, SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToSEZVendWithITCFAIntra()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false, 1, false);

        //[WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355079] Check if the system is calculating GST in case of Intra-state Purchase Return of Fixed Assets to SEZ Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Return Orders
    // [FEATURE] [Fixed Asset, Purchase Return Order] [ITC Not Available, SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrderToSEZVendWithNonITCFAIntra()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false, 1, false);

        //[WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355080] Check if the system is calculating GST in case of Intra-state Purchase Return of Fixed Assets to SEZ Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Credit Memos
    // [FEATURE] [Fixed Asset, Purchase Credit Memo] [ITC Not Available, SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToSEZVendWithNonITCFAIntra()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false, 1, false);

        //[WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Posted Return document with GST and Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [SCENARIO] [355068] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from SEZ Vendor where Input Tax Credit is not available with invoice discount/line discount multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Fixed Assets Purchase Invoice] [invoice discount/line discount Not ITC,SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvSEZVendorWithoutITCLineDiscountForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true, 2, false);

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 7);
    end;

    // [SCENARIO] [355073] Check if the system is calculating GST in case of Intra-state Purchase of Fixed Assets from SEZ Vendor where Input Tax Credit is available with multiple HSN code wise. through Purchase order
    // [FEATURE] [Fixed Assets Purchase Order] [invoice discount/line discount ITC,SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdSEZVendorWithITCLineDiscountForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true, 2, false);

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    // [SCENARIO] [355074] Check if the system is calculating GST in case of Intra-state Purchase of Fixed Assets from SEZ Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Fixed Assets Purchase Invoice] [invoice discount/line discount ITC,SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvSEZVendorWithITCWithLineDiscountForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true, 2, false);

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    // [SCENARIO] [355077] Check if the system is calculating GST in case of Intra-state Purchase of Fixed Assets from SEZ Vendor where Input Tax Credit is not available with multiple HSN code wise. through Purchase order
    // [FEATURE] [Fixed Assets Purchase Order] [invoice discount/line discount ITC,SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdSEZVendorWithoutITCLineDiscountForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true, 2, false);

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 7);
    end;

    // [SCENARIO] [355078] Check if the system is calculating GST in case of Intra-state Purchase of Fixed Assets from SEZ Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Fixed Assets Purchase Invoice] [invoice discount/line discount ITC,SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvSEZVendorWithoutITCLineDiscForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true, 2, false);

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 7);
    end;

    // [SCENARIO] [354234] Check if the system is calculating GST in case of Purchase of Goods from SEZ Vendor where Input Tax Credit is available with cover of Bill of Entry though Purchase order
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithITCGSTForSEZVendorWithBillofEntry()
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
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false, 2, false);

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354235] Check if the system is calculating GST in case of Purchase of Goods from SEZ Vendor where Input Tax Credit is not available with cover of Bill of Entry though Purchase order
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseOrderWithoutITCForSEZVendorWithBillofEntry()
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
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false, 2, false);

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354269] Check if the system is calculating GST in case of Purchase of Services from SEZ Vendor where Input Tax Credit is not available with cover of Bill of Entry though Purchase order
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseServiceOrderWithITCForSEZVendorWithBillofEntry()
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
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false, 2, false);

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [355058] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from SEZ Vendor where Input Tax Credit is available with invoice discount/line discount multiple HSN code wise through Purchase Order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineInterstatePurchaseOrderWithITCForSEZVendor()
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
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false, 2, false);

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [355059] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from SEZ Vendor where Input Tax Credit is available with invoice discount/line discount multiple HSN code wise through Purchase Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineInterstatePurchaseInvoiceWithITCForSEZVendor()
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
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false, 2, false);

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 5);
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
            vendor.Validate("Associated Enterprises", AssociateEnterprise);
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

    local procedure InitializeShareStep(InputCreditAvailment: Boolean; Exempted: Boolean; LineDiscount: Boolean; NoOfLine: Integer; WithoutBillOfEntry: Boolean)
    begin
        StorageBoolean.Set(InputCreditAvailmentLbl, InputCreditAvailment);
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
        StorageBoolean.Set(WithoutBillOfEntryLbl, WithoutBillOfEntry);
        Storage.Set(NoOfLineLbl, Format(NoOfLine));
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
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, DocumentNo);

        exit(DocumentNo);
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
        if PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::SEZ then begin
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

            if (PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ]) and
                    (not (PurchaseLine.Type in [PurchaseLine.Type::" ", PurchaseLine.Type::"Charge (Item)"])) then begin
                PurchaseLine.Validate("GST Assessable Value", LibraryRandom.RandInt(1000));
                if PurchaseLine.Type in [PurchaseLine.Type::Item, PurchaseLine.Type::"G/L Account"] then
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

    local procedure InitializeTaxRateParameters(IntraState: Boolean; FromState: Code[10]; LocationStateCode: Code[10])
    var
        LibraryRandom: Codeunit "Library - Random";
        GSTTaxPercent: Decimal;
    begin
        Storage.Set(FromStateCodeLbl, FromState);
        Storage.Set(LocationStateCodeLbl, LocationStateCode);
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

    local procedure CreateAndPostPurchaseReturnFromCopyDocument(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type")
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
        VendorLedgerEntries.OK().Invoke();
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(GSTGroupCodeLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(HSNSACCodeLbl));
        TaxRates.AttributeValue3.SetValue(Storage.Get(FromStateCodeLbl));
        TaxRates.AttributeValue4.SetValue(Storage.Get(LocationStateCodeLbl));
        TaxRates.AttributeValue5.SetValue(WorkDate());
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', WorkDate()));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]); //SGST
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]); //CGST
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[3]); //IGST
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[4]); //KFloodCess
        TaxRates.OK().Invoke();
    end;
}
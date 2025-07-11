codeunit 18132 "GST Purchase Composite"
{
    Subtype = Test;

    var
        LibraryGST: Codeunit "Library GST";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryGSTPurchase: Codeunit "Library - GST Purchase";
        Storage: Dictionary of [Text, Text];
        ComponentPerArray: array[10] of Decimal;
        StorageBoolean: Dictionary of [Text, Boolean];
        NoOfLineLbl: Label 'NoOfLine';
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo';
        LocationStateCodeLbl: Label 'LocationStateCode';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
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

    // [SCENARIO] [353801] Check if the system is handling Purchase of Services from Composite Vendor/Supplier of exempted services with no GST Impact through Purchase Order
    // [FEATURE] [Services, Purchase Order] [ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrderCompositeVendorWithITCForServiceIntraState()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Service, true, false);
        InitializeShareStep(true, true, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as G/L Account for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 2);
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [353805] Check if the system is handling Purchase of Services from Composite Vendor/Supplier of exempted Services with no GST Impact through Purchase Quote
    // [FEATURE] [Services, Purchase Quote] [ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreatePurchQuoteExemptedServicesForCompositeWithAvailmentIntraSate()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Create GST Setup and tax rates
        InitializeShareStep(true, true, false);
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Service, true, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Quote
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Quote);

        //Verified GST Amount and Make Quote to Order
        LibraryGSTPurchase.VerifyTaxTransactionForPurchaseQuote(PurchaseHeader);
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [Scenario] [353811] Check if the system is handling Purchase Return of Goods to Composite Vendor/Supplier of exempted goods with no GST Impact through Purchase Return order
    // [FEATURE] [Goods, Purchase Return Order] [ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdToCompositeVendWithGoodsIntraStateAvailment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, true, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line Type as Item for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [353814] Check if the system is handling Purchase Return of Services to Composite Vendor/Supplier of exempted goods with no GST Impact through Purchase Return Order
    // [FEATURE] [Exempted Services, Purchase Return Order] [ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdToCompositeVendWithServiceIntraStateAvailment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Service, true, false);
        InitializeShareStep(true, true, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line Type as GL Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [353835] Check if the system is handling Purchase Return of Services to Composite Vendor/Supplier of exempted services with no GST Impact through Purchase Credit Memo and copy document
    // [FEATURE] [Exempted Services, Purchase Credit Memo] [ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToCompositeVendWithServiceIntraStateAvailment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Service, true, false);
        InitializeShareStep(true, true, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Purchase Credit Memo with GST and Line Type as G/L Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [353837] Purchase Return of Services to Composite Vendor/Supplier of exempted services with no GST Impact through Purchase Credit Memo with Get posted doc to reversed
    // [FEATURE] [Exempted Services, Purchase Credit Memo] [ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToCompositeVendWithServiceIntraStateAvailmentGetPosted()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Service, true, false);
        InitializeShareStep(true, true, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Purchase Credit Memo with GST and Line Type as G/L Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [SCENARIO] [355911] Check if the system is handling Purchase of Goods from Composite Vendor/Supplier of exempted goods with no GST Impact through Purchase Invoice
    // [FEATURE] [Exempted Goods, Purchase Order] [ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvCompositeVendorWithITCForGoodsIntraState()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, true, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 2);
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [Scenario] [355180] Check if the system is calculating GST in case of Inter-state Purchase Return of Fixed Assets to composite Vendor where Input Tax Credit is not available and multiple HSN code wise through Purchase Return Orders
    // [FEATURE] [Fixed Asset, Purchase Return Order] [ITC Non Availment, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdToCompositeVendWithInterStateNonITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line type as Fixed Asset for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355181] Check if the system is calculating GST in case of Inter-state Purchase Return of Fixed Assets to composite Vendor where Input Tax Credit is not available and multiple HSN code wise through Purchase Credit Memos
    // [FEATURE] [Fixed Asset, Purchase Credit Memo] [ITC Non Availment, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToCompositeVendWithInterStateNonITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line type as Fixed Asset for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355256] Check if the system is calculating GST in case of Intra-state Purchase Return of Fixed Assets from Composite Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Return Orders
    // [FEATURE] [Fixed Asset, Purchase Return Order] [ITC Availment, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdToCompositeVendWithIntraStateITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line type as Fixed Asset for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355258] Check if the system is calculating GST in case of Intra-state Purchase Return of Fixed Assets from Composite Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Credit Memos
    // [FEATURE] [Fixed Asset, Purchase Credit Memo] [ITC Availment, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToCompositeVendWithIntraStateITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line type as Fixed Asset for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355266] Check if the system is calculating GST in case of Intra-state Purchase Return of Fixed Assets from Composite Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Return Orders
    // [FEATURE] [Fixed Asset, Purchase Return Order] [ITC Non Availment, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdToCompositeVendWithIntraStateNonITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line type as Fixed Asset for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [SCENARIO] [355253] Check if the system is calculating GST in case of Intra-state Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order
    // [FEATURE] [Fixed Assets Purchase Order] [ITC Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrdCompositeVendorWithITCForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [355254] Check if the system is calculating GST in case of Intra-state Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Fixed Assets Purchase Invoice] [ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvCompositeVendorWithITCForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [355260] Check if the system is calculating GST in case of Intra-state Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase order
    // [FEATURE] [Fixed Assets Purchase Order] [Without ITC Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrdCompositeVendorWithoutITCForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [355261] Check if the system is calculating GST in case of Intra-state Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Fixed Assets Purchase Invoice] [Without ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvCompositeVendorWithoutITCForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [355081] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is available with invoice discount/line discount multiple HSN code wise through Purchase order
    // [FEATURE] [Fixed Assets Purchase Invoice] [invoice discount/line discount ITC Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvCompositeVendorWitITCWithLineDiscountForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [355185] Check if the system is calculating GST in case of Intra-state Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is available with invoice discount/line discount and multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Fixed Assets Purchase Invoice] [invoice discount/line discount ITC,Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrdCompositeVendorWithITCWithLineDiscountForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [355196] Check if the system is calculating GST in case of Intra-state Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is not available with invoice discount/line discount and multiple HSN code wise through Purchase order
    // [FEATURE] [Fixed Assets Purchase Order] [invoice discount/line discount ITC,Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrdCompositeVendorWithoutITCWithLineDiscountForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [355197] Check if the system is calculating GST in case of Intra-state Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is Not available with invoice discount/line discount and multiple HSN code wise. through Purchase Invoice
    // [FEATURE] [Fixed Assets Purchase Order] [invoice discount/line discount ITC,Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvCompositeVendorWithoutITCWithLineDiscountForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [355082] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is available with invoice discount/line discount multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Fixed Assets Purchase Invoice] [Line Discount ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostInterStateGSTPurchaseInvoiceCompositeVendorWithITCWithDiscountForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [355183] Check if the system is calculating GST in case of Intra-state Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is available with invoice discount/line discount and multiple HSN code wise through Purchase order
    // [FEATURE] [Fixed Assets Purchase Invoice] [Line Discount ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrdCompositeVendorWithITCDiscountForGoodsInterState()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [355089] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is not available with invoice discount/line discount multiple HSN code wise through Purchase order
    // [FEATURE] [Fixed Assets Purchase Invoice] [Line Discount ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostInterStateGSTPurchaseInvoiceCompositeVendorWithoutITCWithDiscountForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [355090] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is not available with invoice discount/line discount multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Fixed Assets Purchase Invoice] [Line Discount ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdCompositeVendorWithoutITCDiscountForGoodsInterState()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [355169] Check if the system is calculating GST in case of Inter-state Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is available and multiple HSN code wise through Purchase order
    // [FEATURE] [Fixed Assets Purchase Order] [ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdCompositeVendorWithITCForGoodsInterState()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [355170] Check if the system is calculating GST in case of Inter-state Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is available and multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Fixed Assets Purchase Invoice] [ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostInterStateGSTPurchaseInvoiceCompositeVendorWithITCForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [355177] Check if the system is calculating GST in case of Inter-state Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is not available and multiple HSN code wise through Purchase order
    // [FEATURE] [Fixed Assets Purchase Order] [Without ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdCompositeVendorWithoutITCForGoodsInterState()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [355178] Check if the system is calculating GST in case of Inter-state Purchase of Fixed Assets from Composite Vendor where Input Tax Credit is not available and multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Fixed Assets Purchase Invoice] [Without ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvCompositeVendorWithoutITCForGoodsInterState()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [355912] Check if the system is handling Purchase of Services from Composite Vendor/Supplier of exempted services with no GST Impact through Purchase Invoice
    // [FEATURE] [Service Purchase Invoice] [ITC, Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvCompositeVendorWithITCForServiceInterState()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [353787] Check if the system is handling Purchase of Goods from Composite Vendor/Supplier of exempted goods with no GST Impact  through Purchase Quote
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreatePurchOrdFromQuoteForCompositeWithAvailmentIntraSate()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Purchase Quote
        Storage.Set(NoOfLineLbl, '2');
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Quote);

        //Make Quote to Order
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [353799] Check if the system is handling Purchase of Goods from Composite Vendor/Supplier of exempted goods with no GST Impact through Purchase Order
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseOrderForCompostiteWithAvailmentIntraSate()
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
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Purchase Order
        Storage.Set(NoOfLineLbl, '1');
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Order);

        //Verified GST Ledger Entried
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 0);
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

    local procedure InitializeShareStep(InputCreditAvailment: Boolean; Exempted: Boolean; LineDiscount: Boolean)
    begin
        StorageBoolean.Set(InputCreditAvailmentLbl, InputCreditAvailment);
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
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
        if Vendor."GST Vendor Type" = Vendor."GST Vendor Type"::Import then
            Vendor.Validate("Associated Enterprises", AssociateEnterprise);
        Vendor.Modify(true);
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
                    LineTypeNo := LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
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
            CalculateGST(PurchaseLine);
        end;
    end;

    local procedure CalculateGST(PurchaseLine: Record "Purchase Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnPurchaseLine(PurchaseLine, PurchaseLine);
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
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]);
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]);
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[3]);
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[4]);
        TaxRates.AttributeValue11.SetValue('');
        TaxRates.AttributeValue12.SetValue('');
        TaxRates.OK().Invoke();
    end;
}
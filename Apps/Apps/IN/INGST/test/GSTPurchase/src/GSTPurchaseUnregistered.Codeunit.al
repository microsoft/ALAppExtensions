codeunit 18135 "GST Purchase Unregistered"
{
    Subtype = Test;

    var
        LibraryGST: Codeunit "Library GST";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryGSTPurchase: Codeunit "Library - GST Purchase";
        LibraryRandom: Codeunit "Library - Random";
        Storage: Dictionary of [Text[20], Text[20]];
        ComponentPerArray: array[20] of Decimal;
        StorageBoolean: Dictionary of [Text[20], Boolean];
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
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';

    // [SCENARIO] [383154] Check if system is calculating GST Amount for Un-Registered Vendor Interstate with Goods with RCM on Purchase Invoice and Non-Availment with impact on Item Ledger Entries.
    // [FEATURE] [Goods, Purchase Invoice] [ITC Non Availment, Unregistered Vendor, Inter-State]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvUnRegVendWithNonITCItemInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyValueEntries((Storage.Get(PostedDocumentNoLbl)), Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [383564] Check if system is calculating GST Amount for Un-Registered Vendor Interstate with Goods with RCM on Purchase Credit Memo and Non-Availment with impact on Item Ledger Entries.
    // [FEATURE] [Goods, Purchase Credit Memo] [ITC Non Availment, Unregistered Vendor, Inter-State]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromGSTPurchCrMemoUnRegVendWithNonITCItemInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Create and Post Purchase Return Document
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        VerifyValueEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [SCENARIO] [382415] Check if system is calculating GST Amount for Import Vendor Interstate with Goods on Purchase Return order with Non-Availment and impact on Item Ledger Entries and Value Entries through Get Posted Document line to reverse, if Automatic cost Posting Yes.
    // [FEATURE] [Goods, Purchase Return Memo] [ITC Non Availment, import Vendor, Inter-State]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromGSTPurchRetOrdImportVendWithNonITCItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Create and Post Purchase Return Document
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        VerifyValueEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [SCENARIO] [382414] Check if system is calculating GST Amount for Import Vendor Interstate with Goods on Purchase Invoice and Non-Availment with impact on Item Ledger Entries and Value Entries, if Automatic cost Posting Yes.
    // [FEATURE] [Goods, Purchase Invoice] [ITC Non Availment, Import Vendor, Inter-State]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvImportVendWithNonITCItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyValueEntries((Storage.Get(PostedDocumentNoLbl)), Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [353878] Check if the system is calculating GST in case of Intra-State Purchase of Goods to Unregistered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Quote
    // [FEATURE] [Intra-State Goods, Purchase Quote] [ITC Available, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchQuoteUnregVendorWithITCForItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup and Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Created Purchase order from purchase Quote
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Quote);

        // [THEN] GST ledger entries are created and Verified
        LibraryGSTPurchase.VerifyTaxTransactionForPurchaseQuote(PurchaseHeader);
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [353882] Check if the system is Calculating GST in case of Intra-State Purchase of Goods to Unregistered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Order
    // [FEATURE] [Intra-State Goods, Purchase Order] [ITC Available, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdUnregVendorWithITCForItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup adn Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Item for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [353884] Check if the system is calculating GST in case of Intra-State Purchase of Goods to Unregistered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Invoice
    // [FEATURE] [Intra-State Goods, Purchase Invoice] [ITC Available, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvUnregVendorWithITCItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup adn Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Item for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [353891] Check if the system is calculating GST in case of Intra-State Purchase of Goods from an Unregistered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Quote
    // [FEATURE] [Intra-State Goods, Purchase Quote] [ITC Not Available, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchQuoteUnregVendorWithNonITCForItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup and Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Created Purchase order from purchase Quote
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Quote);

        // [THEN] GST ledger entries are created and Verified
        LibraryGSTPurchase.VerifyTaxTransactionForPurchaseQuote(PurchaseHeader);
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [353892] Check if the system is calculating GST in case of Intra-State Purchase of Goods from an Unregistered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Order
    // [FEATURE] [Intra-State Goods, Purchase Order] [ITC Not Available, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdUnregVendorWithNonITCForItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup adn Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Item for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [353899] Check if the system is calculating GST in case of Intra-State Purchase of Goods from an Unregistered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Invoice
    // [FEATURE] [Intra-State Goods, Purchase Invoice] [ITC Not Available, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvUnregVendorWithNonITCForItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup adn Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Item for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [Scenario] [353907] Check if the system is calculating GST in case of Intra-State Purchase Return of Goods to Unregistered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Return Orders
    // [FEATURE] [Intra-State Goods, Purchase Return Order] [ITC Availment, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromPurchRetOrdToUnregVendWithGoodsIntraStateITCRCM()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Item for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Create and Post Return Document with update reference Invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [353908] Check if the system is calculating GST in case of Intra-State Purchase Return of Goods to Unregistered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Credit Memos
    // [FEATURE] [Intra-State Goods, Purchase Credit Memo] [ITC Availment, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromPurchCrMemoToUnregVendWithGoodsIntraStateITCRCM()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Item for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Create and Post Return Document with update reference Invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [SCENARIO] [354115] Check if the system is calculating GST in case of Intra-State Purchase of Services from an Unregistered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Order
    // [FEATURE] [Intra-State Services, Purchase Order] [ITC Available, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdUnregVendorWithITCServices()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup adn Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as G/L Account for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [354116] Check if the system is calculating GST in case of Intra-State Purchase of Services from an Unregistered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Invoice
    // [FEATURE] [Intra-State Services, Purchase Invoice] [ITC Available, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvUnregVendorWithITCServices()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup adn Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as G/L Account for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [354121] Check if the system is calculating GST in case of Intra-State Purchase of Services from an Unregistered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Quote
    // [FEATURE] [Intra-State Services, Purchase Quote] [ITC Not Available, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreatePurchQuoteUnregVendorWithNonITCIntraStateServices()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup and Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Created Purchase order from purchase Quote with Line Type as G/L Account
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Quote);

        // [THEN] GST ledger entries are created and Verified
        LibraryGSTPurchase.VerifyTaxTransactionForPurchaseQuote(PurchaseHeader);
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [354122] Check if the system is calculating GST in case of Intra-State Purchase of Services from an Unregistered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Order
    // [FEATURE] [Intra-State Services, Purchase Order] [ITC Not Available, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdUnregVendorWithIntraStateNonITCServices()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup adn Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as G/L Account for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [354123] Check if the system is calculating GST in case of Intra-State Purchase of Services from an Unregistered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Invoice
    // [FEATURE] [Intra-State Services, Purchase Invoice] [ITC Not Available, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvUnregVendorWithIntraStateNonITCServices()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup adn Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as G/L Account for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [Scenario] [354119] Check if the system is calculating GST in case of Intra-State Purchase Return of Services to Unregistered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Return Orders
    // [FEATURE] [Intra-State Services, Purchase Return Order] [ITC Availment, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromPurchRetOrdToUnregVendWithIntraStateITCRCMServices()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as G/L Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] Create and Post Return Document with update reference Invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [354120] Check if the system is calculating GST in case of Intra-State Purchase Return of Services to Unregistered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Credit Memos
    // [FEATURE] [Intra-State Goods, Purchase Credit Memo] [ITC Availment, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromPurchCrMemoToUnregVendWithIntraStateGoodsITCRCM()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as G/L Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] Create and Post Return Document with update reference Invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [SCENARIO] [354905] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Unregistered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order
    // [FEATURE] [Intra-State Fixed Asset, Purchase Order] [ITC Available, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdUnregVendorWithIntraStateITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup adn Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line type as Fixed Asset for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [Scenario] [354907] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Return Orders
    // [FEATURE] [Intra-State Fixed Asset, Purchase Return Order] [ITC Availment, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromPurchRetOrdToUnregVendWithIntraStateITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Create and Post Return Document with update reference Invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [354908] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Credit Memos
    // [FEATURE] [Intra-State Fixed Asset, Purchase Credit Memo] [ITC Availment, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromPurchCrMemoToUnregVendWithIntraStateITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Create and Post Return Document with update reference Invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [354912] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Return Orders
    // [FEATURE] [Intra-State Fixed Asset, Purchase Return Order] [ITC Non Availment, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromPurchRetOrdToUnregVendWithIntraStateNonITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Create and Post Return Document with update reference Invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [354992] Check if the system is calculating GST in case of Inter-state Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Return Orders
    // [FEATURE] [Inter-State Fixed Asset, Purchase Return Order] [ITC Availment, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromPurchRetOrdToUnregVendWithInterStateITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Create and Post Return Document with update reference Invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [354993] Check if the system is calculating GST in case of Inter-state Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Credit Memos
    // [FEATURE] [Inter-State Fixed Asset, Purchase Credit Memo] [ITC Availment, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromPurchCrMemoToUnregVendWithInterStateITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Create and Post Return Document with update reference Invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355000] Check if the system is calculating GST in case of Inter-state Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Return Orders
    // [FEATURE] [Inter-State Fixed Asset, Purchase Return Order] [ITC Non Availment, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromPurchRetOrdToUnregVendWithInterStateNonITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Create and Post Return Document with update reference Invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355042] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is available with invoice /line discount & multiple HSN through Purchase Return Orders
    // [FEATURE] [Intra-State Fixed Asset, Purchase Return Order] [ITC Availment, Unregistered Vendor, Line Discount]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromPurchRetOrdToUnregVendWithIntraStateITCFALineDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset with Line Discount for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Create and Post Return Document with update reference Invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355043] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is available with invoice/line discount & multiple HSN through Purchase Credit Memos
    // [FEATURE] [Intra-State Fixed Asset, Purchase Credit Memo] [ITC Availment, Unregistered Vendor, Line Discount]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromPurchCrMemoToUnregVendWithIntraStateITCFALineDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset with Line Discount for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Create and Post Return Document with update reference Invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [Scenario] [355057] Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is not available with invoice/line discount & multiple HSN through Purchase Credit Memos
    // [FEATURE] [Inter-State Fixed Asset, Purchase Credit Memo] [ITC Non Availment, Unregistered Vendor, Line Discount]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromPurchCrMemoToUnregVendWithInterStateNonITCFALineDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[GIVEN] Created GST Setup and tax rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as Fixed Asset with Line Discount for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Create and Post Return Document with update reference Invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    // [SCENARIO] [355044] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Unregistered Vendor where Input Tax Credit is not available with invoice discount/line discount multiple HSN code wise through Purchase order
    // [FEATURE] [Intra-State Fixed Asset, Purchase Order] [ITC Not Available, Unregistered Vendor, Line Discount]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdUnregVendorWithIntraStateNonITCSFAWithLineDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup adn Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line type as Fixed Asset for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [355045] Check if the system is calculating GST in case of IntraState/Intra Union Territory Purchase of Fixed Asset from Unregistered Vendor where Input Tax Credit is not available with invoice discount/line discount multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Intra-State Fixed Asset, Purchase Invoice] [ITC Not Available, Unregistered Vendor, Line Discount]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvUnregVendorWithIntraStateNonITCFAWithLineDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup adn Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [354906] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Un-registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Intra-State Fixed Asset, Purchase Invoice] [ITC Available, Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvUnregVendorWithIntraStateITCFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup adn Tax Rates
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    // [SCENARIO] [355050] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Unregistered Vendor where Input Tax Credit is available with invoice discount/line discount multiple HSN code wise through Purchase order
    // [FEATURE] [Fixed Assets Purchase Order] [invoice discount/line discount,Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdUnregVendorWithITCLineDiscForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    // [SCENARIO] [355051] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Unregistered Vendor where Input Tax Credit is available with invoice discount/line discount multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Fixed Assets Purchase Invoice] [invoice discount/line discount,Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvUnRegVendorWithITCLineDiscForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    // [SCENARIO] [355054] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Unregistered Vendor where Input Tax Credit is not available with invoice discount/line discount multiple HSN code wise through Purchase order
    // [FEATURE] [Fixed Assets Purchase Order] [invoice discount/line discount Not ITC,Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdUnRegVendorWithoutITCLineDiscForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    // [SCENARIO] [355055] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Unregistered Vendor where Input Tax Credit is not available with invoice discount/line discount multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Fixed Assets Purchase Invoice] [invoice discount/line discount Not ITC,Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvUnRegVendorWithoutITCLineDiscForFixedAsset()
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
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    // [SCENARIO] [354909] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Unregistered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchOrdUnRegVendorWithITCWithMultipleHSNCode()
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
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with Fixed Asset
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 7);
    end;

    // [SCENARIO] [354910] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Unregistered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchInvUnRegVendorWithITCMultipleHSNCode()
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
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with Fixed Asset
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 7);
    end;

    // [SCENARIO] [354914] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Unregistered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStateUnRegVendorPurchOrdWithITCWithMultipleHSNCode()
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
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with Fixed Asset
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354991] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Unregistered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStateUnRegVendorPurchInvWithITCWithMultipleHSNCod()
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
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with Fixed Asset
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354994] Check if the system is calculating GST in case of Inter-state Purchase of Fixed Assets from Unregistered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStateUnRegVendorPurchOrdWithoutITCWithMultipleHSNCode()
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
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with Fixed Asset
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354995] Check if the system is calculating GST in case of Inter-state Purchase of Fixed Assets from Unregistered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStateUnRegVendorPurchInvWithoutITCWithMultipleHSNCode()
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
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Purchase Order with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [353917] Check if the system is calculating GST in case of Intra-State Purchase of Goods and Services from an Unregistered Vendor with Reverse Charge Exempt through Purchase Quote
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreateIntraStatePurchOrdFromQuoteForGoodsUnRegVendorWithReverseExempt()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(false, true, false);
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Quote        
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Quote);

        //Make Quote to Order
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [354111] Check if the system is calculating GST in case of Intra-State Purchase of Goods from an Unregistered Vendor with Reverse Charge Exempt through Purchase Order
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchOrdForServiceUnRegVendorWithReverseExempt()
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
        InitializeShareStep(true, true, false);
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Order);

        //Verified GST Ledger Entried
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    // [SCENARIO] [354112] Check if the system is calculating GST in case of Intra-State Purchase of Goods from an Unregistered Vendor with Reverse Charge Exempt through Purchase Invoice
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchInvForServiceUnRegVendorWithReverseExempt()
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
        InitializeShareStep(true, true, false);
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        //verified GST Ledger Entried
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    // [SCENARIO] [354114] Check if the system is calculating GST in case of Intra-State Purchase of Services from an Unregistered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Quote
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreateIntraStatePurchOrdFromQuoteForServiceUnRegVendorWithReverseExempt()
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
        InitializeShareStep(true, true, false);
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Quote
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Quote);

        //Make Quote to Order
        OrderNo := LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
        LibraryGST.VerifyTaxTransactionForPurchase(OrderNo, DocumentType::Order);
    end;

    //[Senerio[355040]	[Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Unregistered Vendor where Input Tax Credit is available with invoice discount/line discount multiple HSN code wise through Purchase order]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchOrdUnRegVendorForFALineDiscWithITC()
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
        InitializeShareStep(true, false, true);
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with Fixed Asset
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 8);
    end;

    //[Senerio[355041]	[Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Unregistered Vendor where Input Tax Credit is available with invoice discount/line discount multiple HSN code wise through Purchase Invoice]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchInvUnRegVendorForFALineDiscWithITC()
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
        InitializeShareStep(true, false, true);
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with Fixed Asset
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 8);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromIntraStatePurchCrMemoUnRegVendorForItemWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [Senerio] [Check if the system is calculating GST in case of Intra-State Purchase of Item from Unregistered Vendor where Input Tax Credit is available through Purchase Credit Memo]

        // [GIVEN] Create GST Setup and tax rates for unregistered customer with intra-state transactions
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Purchase Invoice with item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] crate and post return document with copy document and update reference invoice number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");
    end;

    local procedure VerifyGSTEntries(DocumentNo: Code[20]; TableID: Integer)
    begin
        LibraryGSTPurchase.VerifyGSTEntries(DocumentNo, TableID, ComponentPerArray);
    end;

    local procedure VerifyValueEntries(DocumentNo: Code[20]; TableID: Integer)
    begin
        LibraryGSTPurchase.VerifyValueEntries(DocumentNo, TableID, ComponentPerArray);
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
        SetStorageLibraryPurchaseText(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true);
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        SetStorageLibraryPurchaseText(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::"Bill-to Address", ReverseCharge);
        SetStorageLibraryPurchaseText(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        SetStorageLibraryPurchaseText(HSNSACCodeLbl, HSNSACCode);

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
        SetStorageLibraryPurchaseText(VendorNoLbl, VendorNo);

        CreateTaxRate();
        CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
    end;

    local procedure InitializeShareStep(InputCreditAvailment: Boolean; Exempted: Boolean; LineDiscount: Boolean)
    begin
        SetStorageBooleanLibraryPurchaseText(InputCreditAvailmentLbl, InputCreditAvailment);
        SetStorageBooleanLibraryPurchaseText(ExemptedLbl, Exempted);
        SetStorageBooleanLibraryPurchaseText(LineDiscountLbl, LineDiscount);
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
            SetStorageLibraryPurchaseText(PostedDocumentNoLbl, DocumentNo);
            exit(DocumentNo);
        end;
    end;

    local procedure CreatePurchaseDocument(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type"): Code[20]
    var
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
        if (PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::SEZ) or (PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::Import) then begin
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
        LineTypeNo: Code[20];
        LineNo: Integer;
        NoOfLine: Integer;
    begin
        Exempted := StorageBoolean.Get(ExemptedLbl);
        if not Storage.ContainsKey(NoOfLineLbl) then
            NoOfLine := 1
        else
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

    local procedure InitializeTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10])
    var
        GSTTaxPercent: Decimal;
    begin
        SetStorageLibraryPurchaseText(FromStateCodeLbl, FromState);
        SetStorageLibraryPurchaseText(ToStateCodeLbl, ToState);
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
        SetStorageLibraryPurchaseText(ReverseDocumentNoLbl, ReverseDocumentNo);
    end;

    local procedure UpdateReferenceInvoiceNoAndVerify(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseReturnOrder: TestPage "Purchase Return Order";
        PurchaseCreditMemo: TestPage "Purchase Credit Memo";
    begin
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Return Order" then begin
            PurchaseReturnOrder.OpenEdit();
            PurchaseReturnOrder.Filter.SetFilter("No.", PurchaseHeader."No.");
            PurchaseReturnOrder."Update Reference Invoice No.".Invoke();
        end else begin
            PurchaseCreditMemo.OpenEdit();
            PurchaseCreditMemo.Filter.SetFilter("No.", PurchaseHeader."No.");
            PurchaseCreditMemo."Update Reference Invoice No.".Invoke();
        end;
    end;

    local procedure SetStorageLibraryPurchaseText(KeyValue: Text[20]; Value: Text[20])
    begin
        Storage.Set(KeyValue, Value);
        LibraryGSTPurchase.SetStorageLibraryPurchaseText(Storage);
    end;

    local procedure SetStorageBooleanLibraryPurchaseText(KeyValue: Text[20]; Value: Boolean)
    begin
        StorageBoolean.Set(KeyValue, Value);
        LibraryGSTPurchase.SetStorageLibraryPurchaseBoolean(StorageBoolean);
    end;

    [PageHandler]
    procedure ReferencePageHandler(var UpdateReferenceInvoiceNo: TestPage "Update Reference Invoice No")
    begin
        UpdateReferenceInvoiceNo."Reference Invoice Nos.".Lookup();
        UpdateReferenceInvoiceNo."Reference Invoice Nos.".SetValue(Storage.Get(PostedDocumentNoLbl));
        UpdateReferenceInvoiceNo.Verify.Invoke();
    end;

    [ModalPageHandler]
    procedure CustomerLedgerEntries(var VendorLedgerEntries: TestPage "Vendor Ledger Entries")
    begin
        VendorLedgerEntries.Filter.SetFilter("Document No.", Storage.Get(PostedDocumentNoLbl));
        VendorLedgerEntries.OK().Invoke();
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
}
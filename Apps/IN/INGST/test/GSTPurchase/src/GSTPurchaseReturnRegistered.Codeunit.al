codeunit 18138 "GST Purchase Return Registered"
{
    Subtype = Test;

    var
        LibraryGST: Codeunit "Library GST";
        LibraryPurchase: Codeunit "Library - Purchase";
        Storage: Dictionary of [Text, Code[20]];
        ComponentPerArray: array[20] of Decimal;
        StorageBoolean: Dictionary of [Text, Boolean];
        NoOfLineLbl: Label 'NoOfLine';
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
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
        AssociatedVendorLbl: Label 'AssociatedVendor';
        PlaceofSupplyLbl: Label 'PlaceofSupply';

    // [SCENARIO] [353866]	[Check if the system is calculating GST in case of Inter-State Purchase Return of Service to Registered Vendor where Input Tax Credit is available through Purchase Return orders]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdRegVendorWithITCForServiceInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as G/L Account for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [353867] [Check if the system is calculating GST in case of Inter-State Purchase Return of Service to Registered Vendor where Input Tax Credit is available through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoRegVendorWithITCForServiceInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [353871] [Check if the system is calculating GST in case of Inter-State Purchase Return of Services to Registered Vendor where Input Tax Credit is not available through Purchase Return Orders]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdRegVendorForServiceInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Service for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 3);
    end;

    // [SCENARIO] [353872] [Check if the system is calculating GST in case of Inter-State Purchase Return of Services to Registered Vendor where Input Tax Credit is not available through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoRegVendorForServiceInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Service for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 3);
    end;

    // [SCENARIO] [353806] [Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase Return of Service to Registered Vendor where Input Tax Credit is Non-available through Purchase Return Orders]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdRegVendorForServiceIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Service for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [353807] [Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase Return of Service to Registered Vendor where Input Tax Credit is Non-available through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoRegVendorForServiceIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Service for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [353795]	[Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase Return of Service to Registered Vendor where Input Tax Credit is available through Purchase Return Orders]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdRegVendorWithITCForServiceIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Service for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [354205] [Check if the system is calculating GST in case of Purchase Return Order for Imported Services where Input Tax Credit is available on purchase return order]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdImportVendorWithITCForServiceIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Service for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [354206] [Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Services where Input Tax Credit is available through purchase return order]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdImportVendorWithITCForService()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Service for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [354208] [Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Services where Input Tax Credit is available through purchase Credit Memo Copy with Document]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoImportVendorWithITCForServiceWithCopyDoc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Service for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [354143]	[Check if the system is calculating GST in case of Purchase Return Order for Imported Goods where Input Tax Credit is available on purchase return order]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdImportGoodsWithITCForIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Goods.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [354167]	[Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Goods where Input Tax Credit is available through purchase return order]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdImportedGoodsWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Goods.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [354168]	[Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Goods where Input Tax Credit is available through purchase Credit Memo Copy with Document]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoImportedGoodsWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invocie with GST and Line Type as Goods.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [354170]	[Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Goods where Input Tax Credit is available through Credit Memo]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchaseCreditMemoImportedGoodsWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invocie with GST and Line Type as Goods.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [354171]	[Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Goods where Input Tax Credit is available through Purchase Credit Memo with get reversed posted document]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchaseCreditMemoOfImportedGoodsUsingGetDocument()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invocie with GST and Line Type as Goods.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [355659]	[Check if the system is calculating GST in case of Intra-State Purchase Return/Credit Memo of Services from Registered Vendor with Multiple Lines by Input Service Distributor where Input Tax Credit is not available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchaseReturnOrderRegisterdVendorForServiceIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup and 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        UpdateInputServiceDistributer(true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Service for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 2);
    end;

    // [SCENARIO] [353785]	[Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Goods to Registered Vendor where Input Tax Credit is Non-available through Purchase Return Orders]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrderOfGoodsFromRegVendorWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Item.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [353808]	[Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Goods to Registered Vendor where Input Tax Credit is available through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoOfGoodsFromRegVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Item.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 2);
    end;

    // [SCENARIO] [353810]	[Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase Return of Service to Registered Vendor where Input Tax Credit is available through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoOfServicesFromRegVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Services.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [353809]	[Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase Return of Service to Registered Vendor where Input Tax Credit is available through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoOfGoodsFromRegVendorWithITCIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as G/L Account.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [354124] [Check if the system is calculating GST in case of Intra-State Purchase Return of Services to Unregistered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Return Orders]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdUnRegVendorForServicesIntraStateRevChargeWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as G/L Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 6);
    end;

    // [SCENARIO] [354126] [Check if the system is calculating GST in case of Intra-State Purchase Return of Services to Unregistered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoUnRegVendorForServicesIntraStateRevChargeWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as G/L Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 6);
    end;

    // [SCENARIO] [353856] Check if the system is calculating GST in case of Inter-State Purchase Return of Goods to Registered Vendor where Input Tax Credit is not available through Purchase Credit Memos
    // [FEATURE] [Fixed Assets Purchase Credit Memo] [Without ITC Register Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromGSTPurchaseCreditMemoVendorWithoutITCForItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Return Order with GST and Line Type as Goods for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 3);
    end;

    // [SCENARIO] [353850] Check if the system is calculating GST in case of Inter-State Purchase Return of Goods to Registered Vendor where Input Tax Credit is not available through Purchase Return Orders
    // [FEATURE] [Item Purchase Return Order] [Without ITC Register Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchaseReturnOrderRegVendorWithoutITCForGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Return Order with GST and Line Type as Goods for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 3);
    end;

    // [SCENARIO] [354210] Check if the system is calculating GST in case of Purchase Credit Memo for Imported Services where Input Tax Credit is available
    // [FEATURE] [Fixed Assets Purchase Credit Memo] [Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoImportVendorWithITCForService()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Servicefor Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 5);
    end;

    // [SCENARIO] [354213] Check if the system is calculating GST in case of Purchase Return Order for Imported Services where Input Tax Credit is not available on purchase return order
    // [FEATURE] [Fixed Assets Purchase Return Order] [Without ITC Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrderImportVendorWithoutITCForService()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Service for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
    end;

    // [SCENARIO] [354216] Check if the system is calculating GST in case of Purchase Credit Memo for Imported Services where Input Tax Credit is not available
    // [FEATURE] [Fixed Assets Purchase Credit Memo] [Without ITC Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoImportVendorWithoutITCForService()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Servicefor Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
    end;

    // [SCENARIO] [354214] Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Services where Input Tax Credit is not available through purchase return order
    // [FEATURE] [Service Purchase Return Order] [Without ITC Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdImportVendorWithoutITCForService()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Return Order with GST and Line Type as Servicefor Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
    end;

    // [SCENARIO] [354215] Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Services where Input Tax Credit is not available through purchase Credit Memo Copy with Document
    // [FEATURE] [Fixed Assets Purchase Crdit Memo] [Without ITC Import Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoCopyDocumentImportVendorWithoutITCForService()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Servicefor Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
    end;

    // [SCENARIO] [354862] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Return Orders
    // [FEATURE] [Fixed Assets Purchase Return Order] [Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdRegVendorWithITCForGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 5);
    end;

    // [SCENARIO] [354866] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Credit Memos
    // [FEATURE] [Fixed Assets Purchase Credit Memo] [Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoRegVendorWithITCForGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 5);
    end;

    // [SCENARIO] [354877] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Return Orders
    // [FEATURE] [Fixed Assets Purchase Return Order] [Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdRegVendorWithoutITCForGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 7);
    end;

    // [SCENARIO] [354884] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Credit Memos
    // [FEATURE] [Fixed Assets Purchase Credit Memo] [Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoRegVendorWithoutITCForGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 7);
    end;

    // [SCENARIO] [354218] Check if the system is calculating GST in case of Purchase Return Order for Imported Services from Associates Enterprises Vendor where Input Tax Credit is available on purchase return order
    // [FEATURE] [Service Purchase Return Order] [ITC Associates Enterprises Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdAssociatedVendorWithITCForService()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeAssociateVendor(false, false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Servicefor Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
        StorageBoolean.Remove(AssociatedVendorLbl);
    end;

    // [SCENARIO] [354219] Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Services from Assioiates Enterprises Vendor where Input Tax Credit is available through purchase return order 
    // [FEATURE] [Service Purchase Return Order] [ITC Associates Enterprises Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdAssociatedTypeVendorWithITCForService()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeAssociateVendor(false, false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Servicefor Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
        StorageBoolean.Remove(AssociatedVendorLbl);
    end;

    // [SCENARIO] [354220]  Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Services from Associated Enterprises Vendor where Input Tax Credit is available through purchase Credit Memo Copy with Document
    // [FEATURE] [Service Purchase Credit Memo] [ITC Associates Enterprises Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoAssociatedVendorWithCopyDocumentWithITCForService()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeAssociateVendor(false, false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Servicefor Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
        StorageBoolean.Remove(AssociatedVendorLbl);
    end;

    // [SCENARIO] [354221] Check if the system is calculating GST in case of Purchase Credit Memo for Imported Services from Associate Enterprises Vendor where Input Tax Credit is available
    // [FEATURE] [Service Purchase Credit Memo] [ITC Associates Enterprises Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoAssociatedTypeVendorWithITCForService()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeAssociateVendor(false, false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Servicefor Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
        StorageBoolean.Remove(AssociatedVendorLbl);
    end;

    // [SCENARIO] [353913] [Check if the system is calculating GST in case of Intra-State Purchase Return of Goods to Unregistered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchasCreditMemoUnRegVendorForGoodsIntraStateRevChargeWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Item for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 6);
    end;

    // [SCENARIO] [353910] [Check if the system is calculating GST in case of Intra-State Purchase Return of Goods to Unregistered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Return Orders]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdUnRegVendorForGoodsIntraStateWithoutITCRevCharge()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Item for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 6);
    end;

    // [SCENARIO] [354227] [Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Services from Assiciates Enterprises Vendor where Input Tax Credit is not available through purchase return order]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchaseCreditMemoForImportedServiceFromAssociates()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);
        InitializeAssociateVendor(false, false, false, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invocie with GST and Line Type as G/L Account.
        CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
        StorageBoolean.Remove(AssociatedVendorLbl);
    end;

    // [SCENARIO] [354228] [Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Services from Associated Enterprises Vendor where Input Tax Credit is not available through purchase Credit Memo Copy with Document]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoForImportedServiceFromAssociatesWithCopyDoc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);
        InitializeAssociateVendor(false, false, false, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invocie with GST and Line Type as Goods.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
        StorageBoolean.Remove(AssociatedVendorLbl);
    end;

    // [SCENARIO] [354229] [Check if the system is calculating GST in case of Purchase Credit Memo for Imported Services from Associate Enterprises Vendor where Input Tax Credit is not available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoForImportedServiceFromAssociatesWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);
        InitializeAssociateVendor(false, false, false, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invocie with GST and Line Type as G/L Account.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
        StorageBoolean.Remove(AssociatedVendorLbl);
    end;

    // [354231] [Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Services from Associates Enterprises Vendor where Input Tax Credit is not available through Purchase Credit Memo with get reversed posted document]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoForImportedServiceFromAssociatesWithGetReversedDoc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);
        InitializeAssociateVendor(false, false, false, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as G/L Account.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
        StorageBoolean.Remove(AssociatedVendorLbl);
    end;

    // [SCENARIO] [355087] Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Composite Vendor where Input Tax Credit is available with invoice discount /line discount & multiple HSN through Purchase Return Orders
    // [FEATURE] [Fixed Assets Purchase Return Order] [Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdCompositeVendorWithITCForFixedAsset()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [355167] Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Composite Vendor where Input Tax Credit is not available with invoice discount /line discount & multiple HSN through Purchase Return Orders
    // [FEATURE] [Fixed Assets Purchase Return Order] [Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdCompositeVendorWithoutITCForGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [355088] Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Composite Vendor where Input Tax Credit is available with invoice/line discount & multiple HSN through Purchase Credit Memos
    // [FEATURE] [Fixed Assets Purchase Credit Memos] [Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoCompositeVendorWithITCForGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Inter-State Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [355168] Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Composite Vendor where Input Tax Credit is not available with invoice/line discount & multiple HSN through Purchase Credit Memos
    // [FEATURE] [Fixed Assets Purchase Credit Memos] [Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemosCompositeVendorWithoutITCForGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Inter-State Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [355187] Check if the system is calculating GST in case of Intra-State Purchase Return of Fixed Assets to Composite Vendor where Input Tax Credit is available with invoice discount /line discount & multiple HSN through Purchase Return Orders
    // [FEATURE] [Fixed Assets Purchase  Return Order] [Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchaseReturnCompositeVendorWithITCForGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset for Intra-State Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [355188] Check if the system is calculating GST in case of Intra-State Purchase Return of Fixed Assets to Composite Vendor where Input Tax Credit is available with invoice/line discount & multiple HSN through Purchase Credit Memos
    // [FEATURE] [Fixed Assets Purchase  Credit Memo] [Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoCompositeVendorWithITCForGoodsIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset for Intra-State Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [355241] Check if the system is calculating GST in case of Intra-State Purchase Return of Fixed Assets to Composite Vendor where Input Tax Credit is not available with invoice/line discount & multiple HSN through Purchase Credit Memos
    // [FEATURE] [Fixed Assets Purchase  Credit Memo] [Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoCompositeVendorWithoutITCForFixedAsset()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset for Intra-State Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [355240] Check if the system is calculating GST in case of Intra-State Purchase Return of Fixed Assets to Composite Vendor where Input Tax Credit is not available with invoice discount /line discount & multiple HSN through Purchase Return Orders
    // [FEATURE] [Fixed Assets Purchase  Return Order] [Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchaseReturnCompositeVendorWithoutITCForFixedAsset()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset for Intra-State Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [353812] Check if the system is handling Purchase Return of Goods to Composite Vendor/Supplier of exempted goods with no GST Impact through Purchase Credit Memo and copy document
    // [FEATURE] [Item Purchase Credit Memo] [Composite Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchaseCreditMemoCompositeVendorWithITCForGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, true, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Return Order with GST and Line Type as Goods for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 2);
    end;

    // [SCENARIO] [353818] Check if the system is calculating GST in case of Inter-State Purchase Return of Goods to Registered Vendor where Input Tax Credit is available through Purchase Return Orders
    // [FEATURE] [Fixed Assets Purchase Return Order] [With ITC Register Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchaseReturnOrderVendorWithoutITCForGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Return Order with GST and Line Type as Goods for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 3);
    end;

    // [SCENARIO] [353836] Check if the system is calculating GST in case of Inter-State Purchase Return of Goods to Registered Vendor where Input Tax Credit is available through Purchase Credit Memos
    // [FEATURE] [Fixed Assets Purchase Credit Memo] [With ITC Register Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchaseReturnOrderRegVendorWithITCForGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Return Order with GST and Line Type as Goods for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 3);
    end;

    // [SCENARIO] [354135] Check if the system is calculating GST in case of Intra-State Purchase Return of Services to Registered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Credit Memos
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoForRegVendorWithITC()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);

        // [WHEN] Create and Post Purchase Credit Memo
        Storage.Set(NoOfLineLbl, '1');
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 6);
    end;

    // [SCENARIO] [354140] Check if the system is calculating GST in case of Intra-State Purchase Return of Services to Registered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Credit Memos
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoForRegVendorWithoutITCIntraStateCopyDoc()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Purchase Credit memo
        Storage.Set(NoOfLineLbl, '1');
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 3);
    end;

    // [SCENARIO] [354520] Check if the system is calculating GST in case of Intra-State Return/Credit Note of Services for Overseas Place of Supply from Registered Vendor where Input Tax Credit is available through Purchase credit memo
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoForRegVendorWithITCGoodsIntraState()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        StorageBoolean.Set(PlaceofSupplyLbl, true);

        // [WHEN] Create and Post Purchase Journal
        Storage.Set(NoOfLineLbl, '1');
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [354521] Check if the system is calculating GST in case of Intra-State Return/Credit Note of Services for Overseas Place of Supply from Registered Vendor where Input Tax Credit is not available through Purchase credit memo
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoForRegVendorWithoutITCGoodsIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(false, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        StorageBoolean.Set(PlaceofSupplyLbl, true);

        // [WHEN] Create and Post Purchase Journal
        Storage.Set(NoOfLineLbl, '1');
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [354181] Check if the system is calculating GST in case of Purchase Credit Memo/Return Order for Imported Goods where Input Tax Credit is not available on purchase return order
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrdForeGoodWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(false, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Purchase Return Order
        Storage.Set(NoOfLineLbl, '1');
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 3);
    end;

    // [SCENARIO] [354913] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Credit Memos
    // [FEATURE] [Fixed Assets Purchase Credit Memos] [Unregistered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoUnregistredVendorForGoods()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset for Intra-State Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 6);
    end;

    // [SCENARIO] [355007] [Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is not available with invoice/line discount & multiple HSN through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoOfGoodsFromRegVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Assets.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 8);
    end;

    // [SCENARIO] [355039] [Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is not available with invoice discount/line discount & multiple HSN through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoOfFixedAssetFromRegVendorWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Assets.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 6);
    end;

    // [SCENARIO] [355035] [Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is available with invoice discount/line discount & multiple HSN through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoOfFixedAssetFromRegVendorWitLineDiscount()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Assets.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 5);
    end;

    // [SCENARIO] [355053] [Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is available with invoice/line discount & multiple HSN through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoOfFixedAssetFromUnRegVendorInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 6);
    end;

    // [SCENARIO] [355001] [Check if the system is calculating GST in case of Inter-state Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoOfFixedAssetFromUnRegVendorWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Assets.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 5);
    end;

    // [SCENARIO] [355047] [Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is not available with invoice/line discount & multiple HSN through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoOfFixedAssetFromUnRegVendorWithoutITCIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Assets.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 12);
    end;

    // [SCENARIO] [353813]	[Check if the system is handling Purchase Return of Goods to Composite Vendor/Supplier of exempted goods with no GST Impact through Purchase Credit Memo]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCreditMemoOfGoodsFromCompositeVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, true, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with no GST Impact and Line Type as Item.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 2);
    end;

    // [SCENARIO] [353849] [Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Goods to Registered Vendor where Input Tax Credit is Non-available through Purchase Credit Memos]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchaseCreditMemoOfGoodsFromRegVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Goods.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    // [SCENARIO] [354223] [Check if the system is calculating GST in case of Purchase Return Order for Imported Services from Associates Enterprises Vendor where Input Tax Credit is not available on purchase return order]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrderOfImportedServiceFromAssociates()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);
        InitializeAssociateVendor(false, false, false, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invocie with GST and Line Type as Goods.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
        StorageBoolean.Remove(AssociatedVendorLbl);
    end;

    // [SCENARIO] [355002] [Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is available with invoice discount/line discount & multiple HSN through Purchase Return Orders]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrderOfGoodsFromRegVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 6);
    end;

    // [SCENARIO] [355034] [Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is available with invoice discount/line discount & multiple HSN through Purchase Return Orders]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrderOfGoodsFromRegVendorWithITCWithLineDis()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 5);
    end;

    // [SCENARIO] [355006] [Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is not available with invoice/line discount & multiple HSN through Purchase Return Orders]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrderOfGoodsFromRegVendorWithLineDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 8);
    end;

    // [SCENARIO] [355038] [Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is not available with invoice discount/line discount & multiple HSN through Purchase Return Orders]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrderOfGoodsFromRegVendorWithoutITCWithLineDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 6);
    end;

    // [SCENARIO] [355052] [Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is available with invoice /line discount & multiple HSN through Purchase Return Orders]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrderOfGoodsFromUnRegVendorWithITCWithLineDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 6);
    end;

    // [SCENARIO] [355056] [Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is not available with invoice /line discount & Multiple HSN through Purchase Return Orders]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrderOfGoodsFromUnRegVendorWithoutITCWithDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 6);
    end;

    // [SCENARIO] [355046] [Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Unregistered Vendor where Input Tax Credit is not available with invoice /line discount & multiple HSN through Purchase Return Orders]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchReturnOrderOfGoodsFromUnRegVendorWithoutITCWithLineDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 12);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchaseCreditMemoOfGoodsFromRegVendorForPOSAsVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [In localization - POS as Vendor State is not working properly in Credit Memo]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Goods with Pos As Vendor.
        CreateAndPostPurchaseDocumentWithPosAsVendor(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocumentWithPosAsVendor(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchCrMemoOfServicesFromRegVendorNonAvailmentForPOSAsVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [In localization - POS as Vendor State is not working properly in Credit Memo in case of Non Availment]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Service with Non availment with Pos As Vendor.
        CreateAndPostPurchaseDocumentWithNonAvailmentPosAsVendor(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        CreateAndPostPurchaseReturnFromCopyDocumentWithPosAsVendor(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 4);
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
        if Vendor."GST Vendor Type" = vendor."GST Vendor Type"::Import then begin
            Vendor.Validate("Currency Code", LibraryGST.CreateCurrencyCode());
            if StorageBoolean.ContainsKey(AssociatedVendorLbl) then
                vendor.Validate("Associated Enterprises", AssociateEnterprise);
        end;
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

    local procedure CreateAndPostPurchaseReturnFromCopyDocument(
        var PurchaseHeader: Record "Purchase Header";
        DocumentType: Enum "Purchase Document Type")
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        ReverseDocumentNo: Code[20];
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, Storage.Get(VendorNoLbl));
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Location Code", CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(PurchaseHeader."Location Code")));
        PurchaseHeader.Modify(true);
        CopyDocumentMgt.SetProperties(true, false, false, false, true, false, false);
        CopyDocumentMgt.CopyPurchaseDocForInvoiceCancelling(Storage.Get(PostedDocumentNoLbl), PurchaseHeader);
        UpdateReferenceInvoiceNoAndVerify(PurchaseHeader);
        ReverseDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(ReverseDocumentNoLbl, ReverseDocumentNo);
    end;

    local procedure UpdateReferenceInvoiceNoAndVerify(var PurchaseHeader: Record "Purchase Header")
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        ReferenceInvoiceNoMgt: Codeunit "Reference Invoice No. Mgt.";
    begin
        UpdatePurchaseLine(PurchaseHeader);
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

    local procedure UpdatePurchaseLine(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                PurchaseLine.Validate("Direct Unit Cost");
                PurchaseLine.Modify(true);
            until PurchaseLine.Next() = 0;
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

    local procedure InitializeShareStep(
        InputCreditAvailment: Boolean;
        Exempted: Boolean;
        LineDiscount: Boolean)
    begin
        StorageBoolean.Set(InputCreditAvailmentLbl, InputCreditAvailment);
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
    end;

    local procedure InitializeAssociateVendor(
        InputCreditAvailment: Boolean;
        Exempted: Boolean;
        LineDiscount: Boolean;
        AssociatedVendor: Boolean)
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get(Storage.Get(VendorNoLbl)) and AssociatedVendor then begin
            Vendor.Validate("Associated Enterprises", true);
            Vendor.Modify();
        end;
        StorageBoolean.Set(InputCreditAvailmentLbl, InputCreditAvailment);
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
    end;

    local procedure UpdateInputServiceDistributer(InputServiceDistribute: Boolean)
    var
        LocationCode: Code[10];
    begin
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        LibraryGST.UpdateLocationWithISD(LocationCode, InputServiceDistribute);
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
        VendorNo := Storage.Get(VendorNoLbl);
        Evaluate(LocationCode, CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode)));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(InputCreditAvailmentLbl), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        if not (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Quote) then begin
            DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
            Storage.Set(PostedDocumentNoLbl, DocumentNo);
            exit(DocumentNo);
        end;
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

    local procedure InitializeTaxRateParameters(
        IntraState: Boolean;
        FromState: Code[10];
        ToState: Code[10])
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
            ComponentPerArray[4] := GSTTaxPercent;
    end;

    local procedure CreateAndPostPurchaseDocumentWithPosAsVendor(
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
        VendorNo := Storage.Get(VendorNoLbl);
        Evaluate(LocationCode, CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode)));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        PurchaseHeader.Validate("POS as Vendor State", true);
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(InputCreditAvailmentLbl), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        if not (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Quote) then begin
            DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
            Storage.Set(PostedDocumentNoLbl, DocumentNo);
            exit(DocumentNo);
        end;
    end;

    local procedure CreateAndPostPurchaseReturnFromCopyDocumentWithPosAsVendor(
        var PurchaseHeader: Record "Purchase Header";
        DocumentType: Enum "Purchase Document Type")
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        ReverseDocumentNo: Code[20];
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, Storage.Get(VendorNoLbl));
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Location Code", CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(PurchaseHeader."Location Code")));
        PurchaseHeader.Validate("POS as Vendor State", true);
        PurchaseHeader.Modify(true);
        CopyDocumentMgt.SetProperties(true, false, false, false, true, false, false);
        CopyDocumentMgt.CopyPurchaseDocForInvoiceCancelling(Storage.Get(PostedDocumentNoLbl), PurchaseHeader);
        UpdateReferenceInvoiceNoAndVerify(PurchaseHeader);
        ReverseDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(ReverseDocumentNoLbl, ReverseDocumentNo);
    end;

    local procedure CreateAndPostPurchaseDocumentWithNonAvailmentPosAsVendor(
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
        VendorNo := Storage.Get(VendorNoLbl);
        Evaluate(LocationCode, CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode)));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        PurchaseHeader.Validate("POS as Vendor State", true);
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), false, StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        if not (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Quote) then begin
            DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
            Storage.Set(PostedDocumentNoLbl, DocumentNo);
            exit(DocumentNo);
        end;
    end;

    [ModalPageHandler]
    procedure VendorLedgerEntries(var VendorLedgerEntries: TestPage "Vendor Ledger Entries")
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
        TaxRates.AttributeValue4.SetValue(Storage.Get(ToStateCodeLbl));
        TaxRates.AttributeValue5.SetValue(WorkDate());
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', WorkDate()));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]); // SGST
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]); // CGST
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]); // IGST
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[5]); // Cess
        TaxRates.OK().Invoke();
    end;
}
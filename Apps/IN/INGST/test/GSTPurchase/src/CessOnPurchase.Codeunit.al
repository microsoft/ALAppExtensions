codeunit 18128 "Cess On Purchase"
{
    Subtype = Test;

    var
        LibraryGST: Codeunit "Library GST";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryGSTPurchase: Codeunit "Library - GST Purchase";
        Storage: Dictionary of [Text[20], Text[20]];
        ComponentPerArray: array[10] of Decimal;
        StorageBoolean: Dictionary of [Text[20], Boolean];
        NoOfLineLbl: Label 'NoOfLine', Locked = true;
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo', Locked = true;
        LocPanLbl: Label 'LocPan', Locked = true;
        LocationStateCodeLbl: Label 'LocationStateCode', Locked = true;
        LocationCodeLbl: Label 'LocationCode', Locked = true;
        GSTGroupCodeLbl: Label 'GSTGroupCode', Locked = true;
        HSNSACCodeLbl: Label 'HSNSACCode', Locked = true;
        VendorNoLbl: Label 'VendorNo', Locked = true;
        CGSTLbl: Label 'CGST', Locked = true;
        SGSTLbl: Label 'SGST', Locked = true;
        IGSTLbl: Label 'IGST', Locked = true;
        CessLbl: Label 'CESS', Locked = true;
        InputCreditAvailmentLbl: Label 'InputCreditAvailment', Locked = true;
        ExemptedLbl: Label 'Exempted', Locked = true;
        LineDiscountLbl: Label 'LineDiscount', Locked = true;
        PostedDocumentNoLbl: Label 'PostedDocumentNo', Locked = true;
        FromStateCodeLbl: Label 'FromStateCode', Locked = true;
        ToStateCodeLbl: Label 'ToStateCode', Locked = true;
        TaxTypeLbl: Label 'TaxType', Locked = true;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrderImportVendWithITCForGoodsThreshold()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [383745] Inter-State Purchase Goods from Import Vendor with Cess Calculation Type - Threshold where GST Credit is Availment on Purchase Order and Line Amount is more than Threshold Amount
        // [FEATURE] [Cess on Goods, Purchase Order] [ITC, Import Vendor, Calculation Type - Threshold]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Threshold where GST Credit is Availment
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::Threshold, false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Cess, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrderImportVendWithNonITCForGoodsThreshold()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [383767] Inter-State Purchase Goods from Import Vendor with Cess Calculation Type - Threshold where GST Credit is Non-Availment on Purchase Invoice and Line Amount is less than Threshold Amount
        // [FEATURE] [Cess on Goods, Purchase Order] [ITC Non Availment, Import Vendor, Calculation Type - Threshold]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Threshold where GST Credit is Non- Availment
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::Threshold, false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Cess, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchQuoteImportVendWithITCForGoodsCessPercent()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [380362] Inter-State Purchase Goods from Import Vendor with Cess Calculation Type - Cess% where GST Credit is Availment on Purchase Order created from Quote
        // [FEATURE] [Cess on Goods, Purchase Quote] [ITC, Import Vendor, Calculation Type - Cess %]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess % where GST Credit is Availment
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess %", false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Created Purchase Quote with GST and Cess, Line Type as Item
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Quote);

        // [THEN] Make Quote to Order and posted purchase Order
        DocumentNo := ConvertQuoteToOrderAndPost(PurchaseHeader);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvImportVendWithNonITCForGoodsCess()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [380363] Inter-State Purchase Goods from Import Vendor with Cess Calculation Type - Cess% where GST Credit is Non-Availment on Purchase Invoice
        // [FEATURE] [Cess on Goods, Purchase Invoice] [ITC Non Availment, Import Vendor, Calculation Type - Cess %]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess % where GST Credit is Non- Availment
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess %", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithITCImportedGoodsCessOrUFactor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [384338] Inter-State Purchase Goods from Import Vendor with Cess Calculation Type - Cess% or Amount/Unit Factor whichever is higher where GST Credit is Availment on Purchase Order.
        // [FEATURE] [Cess on Goods, Purchase Order] [ITC Availment, Import Vendor, Calculation Type - Cess % Or Amount / Unit Factor Whichever Higher]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess % or amount per unit factor whichever is higher where input tax credit is Availment
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess % Or Amount / Unit Factor Whichever Higher", false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Cess, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithNonITCImportedGoodsCessOrUFactor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [384339] Inter-State Purchase Goods from Import Vendor with Cess Calculation Type - Cess% or Amount/Unit Factor whichever is higher where GST Credit is Non-Availment on Purchase Invoice.
        // [FEATURE] [Cess on Goods, Purchase Invoice] [ITC Non Availment, Import Vendor, Calculation Type - Cess% or Amount/Unit Factor whichever is higher]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess % or Amount per unit factor whichever is higher where input tax credit is Non-Availment
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess % Or Amount / Unit Factor Whichever Higher", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithITCImportedGoodsCessPlusUFactor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [384175] Inter-State Purchase Goods from Import Vendor with Cess Calculation Type - Cess%+Amount/Unit Factor where GST Credit is Availment on Purchase Order.
        // [FEATURE] [Cess on Goods, Purchase Order] [ITC Availment, Import Vendor, Calculation Type - Cess%+Amount/Unit Factor]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess % Plus amount / Unit Factor where input tax credit is Availment
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess % + Amount / Unit Factor", false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Cess, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithNonITCImportedGoodsCessPlusUFactor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [384296] Inter-State Purchase Goods from Import Vendor with Cess Calculation Type - Cess%+Amount/Unit Factor where GST Credit is Non-Availment on Purchase Invoice
        // [FEATURE] [Cess on Goods, Purchase Invoice] [ITC Non Availment, Import Vendor, Calculation Type - Cess%+Amount/Unit Factor]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess % + Amount / Unit Factor where input tax credit is Non-Availment
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess % + Amount / Unit Factor", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithITCImportedGoodsCessUFactor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [384106] Inter-State Purchase Goods from Import Vendor with Cess Calculation Type - Amount/Unit Factor where GST Credit is Availment on Purchase Order.
        // [FEATURE] [Cess on Goods, Purchase Order] [ITC Availment, Import Vendor, Calculation Type - Amount/Unit Factor]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Amount / Unit Factor where input tax credit is Availment
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Amount / Unit Factor", false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Cess, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithNonITCImportedGoodsCessUFactor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [384107] Inter-State Purchase Goods from Import Vendor with Cess Calculation Type - Amount/Unit Factor where GST Credit is Non-Availment on Purchase Invoice
        // [FEATURE] [Cess on Goods, Purchase Invoice] [ITC Non Availment, Import Vendor, Calculation Type - Amount/Unit Factor]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Amount/ Unit Factor where input tax credit is Non-Availment
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Amount / Unit Factor", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdWithITCImportedGoodsCessThreshold()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [383746] Inter-State Purchase Return of Goods to Import Vendor with Cess Calculation Type - Threshold where GST Credit is Availment on Purchase Return Order with Get Reversed Posted Lines and Line Amount is more than Threshold Amount
        // [FEATURE] [Cess on Goods, Purchase Return Order] [ITC Availment, Import Vendor, Calculation Type - Threshold]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Threshold where input tax credit is Availment
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::Threshold, false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase invoice with GST and Cess, Line Type as Item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document created and Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoWithNonITCImportedGoodsThreshold()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [383768] Inter-State Purchase Return of Goods to Import Vendor with Cess Calculation Type - Threshold where GST Credit is Non-Availment on Purchase Credit Memo with Copy Document and Line Amount is less than Threshold Amount
        // [FEATURE] [Cess on Goods, Purchase Credit Memo] [ITC Non Availment, Import Vendor, Calculation Type - Threshold]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Threshold where input tax credit is Non-Availment
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::Threshold, false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document Create and Post with Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdWithITCImportedGoodsCessPercent()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [380364] Inter-State Purchase Return of Goods to Import Vendor with Cess Calculation Type - Cess% where GST Credit is Availment on Purchase Return Order with Get Reversed Posted Lines.
        // [FEATURE] [Cess on Goods, Purchase Return Order] [ITC Availment, Import Vendor, Calculation Type - Cess %]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess % where input tax credit is Availment and GST Group Type is Goods
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess %", false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document created and Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoWithNonITCImportedGoodsCessPercent()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [380365] Inter-State Purchase Return of Goods to Import Vendor with Cess Calculation Type - Cess% where GST Credit is Non-Availment on Purchase Credit Memo with Copy Document.
        // [FEATURE] [Cess on Goods, Purchase Credit Memo] [ITC Non Availment, Import Vendor, Calculation Type - Cess %]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess % where input tax credit is Non-Availment and GST Group Type is Goods
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess %", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document Create and Post with Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdWithITCImportedGoodsCessOrUFactor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [384340] Inter-State Purchase Return of Goods to Import Vendor with Cess Calculation Type - Cess% or Amount/Unit Factor whichever is higher where GST Credit is Availment on Purchase Return Order with Get Reversed Posted Lines.
        // [FEATURE] [Cess on Goods, Purchase Return Order] [ITC Availment, Import Vendor, Calculation Type - Cess% or Amount/Unit Factor whichever is higher]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess % or Amount / Unit Factor whichever higher where input tax credit is Availment and GST Group Type is Goods
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess % Or Amount / Unit Factor Whichever Higher", false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document created and Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoWithNonITCImportedGoodsCessOrUFactor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [384341] Inter-State Purchase Return of Goods to Import Vendor with Cess Calculation Type - Cess% or Amount/Unit Factor whichver is higher where GST Credit is Non-Availment on Purchase Credit Memo with Copy Document.
        // [FEATURE] [Cess on Goods, Purchase Credit Memo] [ITC Non Availment, Import Vendor, Calculation Type - Cess% or Amount/Unit Factor whichver is higher]

        // [GIVEN] Created GST Setup and tax rates  with Component calculation Type Cess % or Amount / Unit Factor whichever is Higher where input tax credit is Non-Availment and GST Group Type is Goods
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess % Or Amount / Unit Factor Whichever Higher", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document Create and Post with Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdWithITCImportedGoodsCessPlusUFactor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [384176] Inter-State Purchase Return of Goods to Import Vendor with Cess Calculation Type - Cess%+Amount/Unit Factor where GST Credit is Availment on Purchase Return Order with Get Reversed Posted Lines.
        // [FEATURE] [Cess on Goods, Purchase Return Order] [ITC Availment, Import Vendor, Calculation Type - Cess%+Amount/Unit Factor]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess% plus amount / unit Factor where input tax credit is Availment and GST Group Type is Goods
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess % + Amount / Unit Factor", false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document created and Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoWithNonITCImportedGoodsCessPlusUFactor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [384297] Inter-State Purchase Return of Goods to Import Vendor with Cess Calculation Type - Cess%+Amount/Unit Factor where GST Credit is Non-Availment on Purchase Credit Memo with Copy Document.
        // [FEATURE] [Cess on Goods, Purchase Credit Memo] [ITC Non Availment, Import Vendor, Calculation Type - Cess%+Amount/Unit Factor]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess% plus Amount / Unit Factor where input tax credit is Non-Availment and GST Group Type is Goods
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess % + Amount / Unit Factor", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document Create and Post with Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdWithITCImportedGoodsCessUFactor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [384108] Inter-State Purchase Return of Goods to Import Vendor with Cess Calculation Type - Amount/Unit Factor where GST Credit is Availment on Purchase Return Order with Get Reversed Posted Lines.
        // [FEATURE] [Cess on Goods, Purchase Return Order] [ITC Availment, Import Vendor, Calculation Type - Amount/Unit Factor]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Amount/ Unit Factor where input tax credit is Availment and GST Group Type is Goods
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Amount / Unit Factor", false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document created and Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoWithNonITCImportedGoodsCessUFactor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [384109] Inter-State Purchase Return of Goods to Import Vendor with Cess Calculation Type - Amount/Unit Factor where GST Credit is Non-Availment on Purchase Credit Memo with Copy Document.
        // [FEATURE] [Cess on Goods, Purchase Credit Memo] [ITC Non Availment, Import Vendor, Calculation Type - Amount/Unit Factor]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Amount/ Unit Factor where input tax credit is Non-Availment and GST Group Type is Goods
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Amount / Unit Factor", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document Create and Post with Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithITCImportedServicesCessPercent()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [383522] Inter-State Purchase Service from Import Vendor with Cess Calculation Type - Cess% where GST Credit is Availment on Purchase Invoice
        // [FEATURE] [Cess on Services, Purchase Invoice] [ITC Availment, Import Vendor, Calculation Type - Cess%]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess Percent where input tax credit is Availment and GST Group Type is Service
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, CompCalcType::"Cess %", false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as G/L Account
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithNonITCImportedServicesCessPercent()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [383523] Inter-State Purchase Service from Import Vendor with Cess Calculation Type - Cess% where GST Credit is Non-Availment on Purchase Invoice
        // [FEATURE] [Cess on Services, Purchase Invoice] [ITC Non Availment, Import Vendor, Calculation Type - Cess%]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess Percent where input tax credit is Non-Availment and GST Group Type is Service
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, CompCalcType::"Cess %", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as G/L Account
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdWithITCImportedServicesCessPercent()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [383525] Inter-State Purchase Return of Service to Import Vendor with Cess Calculation Type - Cess% where GST Credit is Availment on Purchase Return Order with Get Reversed Posted Lines.
        // [FEATURE] [Cess on Services, Purchase Return Order] [ITC Availment, Import Vendor, Calculation Type - Cess %]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess Percent where input tax credit is Availment and GST Group Type is Service
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, CompCalcType::"Cess %", false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase invoice with GST and Cess, Line Type as G/L Account
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] Purchase Return Document created and Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoWithNonITCImportedServicesCessPercent()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [383526] Inter-State Purchase Return of Service to Import Vendor with Cess Calculation Type - Cess% where GST Credit is Non-Availment on Purchase Credit Memo with Copy Document.
        // [FEATURE] [Cess on Services, Purchase Credit Memo] [ITC Non Availment, Import Vendor, Calculation Type - Cess %]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess Percent where input tax credit is Non-Availment and GST Group Type is Service
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, CompCalcType::"Cess %", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as G/L Account
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] Purchase Return Document Create and Post with Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithITCImportedFACessPercent()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [383693] Inter-State Purchase FA (Goods) from Import Vendor with Cess Calculation Type - Cess% where GST Credit is Availment on Purchase Invoice
        // [FEATURE] [Cess on Fixed Asset, Purchase Invoice] [ITC Availment, Import Vendor, Calculation Type - Cess%]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess Percent where input tax credit is Availment and GST Group Type is Goods
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess %", false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Fixed Asset
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithNonITCImportedFACessPercent()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [383694] Inter-State Purchase FA (Goods) from Import Vendor with Cess Calculation Type - Cess% where GST Credit is Non-Availment on Purchase Invoice.
        // [FEATURE] [Cess on Fixed Asset, Purchase Invoice] [ITC Non Availment, Import Vendor, Calculation Type - Cess%]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess Percent where input tax credit is Non-Availment and GST Group Type is Goods
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess %", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Fixed Asset
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdWithITCImportedFACessPercent()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [383695] Inter-State Purchase Return of FA (Goods) to Import Vendor with Cess Calculation Type - Cess% where GST Credit is Availment on Purchase Return Order with Get Reversed Posted Lines.
        // [FEATURE] [Cess on Fixed Asset, Purchase Return Order] [ITC Availment, Import Vendor, Calculation Type - Cess %]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess Percent where input tax credit is Availment and GST Group Type is Goods
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess %", false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Fixed Asset
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Purchase Return Document created and Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoWithNonITCImportedFACessPercent()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [383696] Inter-State Purchase Return of FA (Goods) to Import Vendor with Cess Calculation Type - Cess% where GST Credit is Non-Availment on Purchase Credit Memo with Copy Document.
        // [FEATURE] [Cess on Fixed Asset, Purchase Credit Memo] [ITC Non Availment, Import Vendor, Calculation Type - Cess %]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Cess Percent where input tax credit is Non-Availment and GST Group Type is Goods
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, CompCalcType::"Cess %", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as Fixed Asset
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] Purchase Return Document Create and Post with Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithITCImportedServicesCessThreshold()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [383935] Inter-State Purchase Service from Import Vendor with Cess Calculation Type - Threshold where GST Credit is Availment on Purchase Invoice and Line Amount is more than Thrashold Amount
        // [FEATURE] [Cess on Services, Purchase Invoice] [ITC Availment, Import Vendor, Calculation Type - Threshold]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Threshold where input tax credit is Availment and GST Group Type is Service
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, CompCalcType::Threshold, false, false);
        InitializeShareStep(true, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as G/L Account
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithNonITCImportedServicesCessThreshold()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [383936] Inter-State Purchase Service from Import Vendor with Cess Calculation Type - Threshold where GST Credit is Non-Availment on Purchase Invoice and Line Amount is less than Threshold Amount
        // [FEATURE] [Cess on Services, Purchase Invoice] [ITC Non Availment, Import Vendor, Calculation Type - Threshold]

        // [GIVEN] Created GST Setup and tax rates with Component calculation Type Threshold where input tax credit is Non-Availment and GST Group Type is Service
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, CompCalcType::Threshold, false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Cess, Line Type as G/L Account
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrdRegVendWithNonITCItemIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [381615] Check if system is calculating GST Amount alongwith Cess Amount for Registered Vendor Intrastate with Goods and Charge Item on Purchase Order and and Non-Availment with impact on Item Ledger Entries Value Entry.
        // [FEATURE] [Goods and Charge Item, Purchase Order] [ITC Non Availment, Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup and tax rates for Registered Customer GST Credit is availment
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, CompCalcType::"Cess %", true, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line type as item for Intrastate Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] New Purchase Line Created With Charge Item and assigned with Item
        DocumentNo := CreateAndPostPurchaseDocWithChargeItem(PurchaseHeader);

        // [THEN] Value Entry Created and Verified
        VerifyValueEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvRegVendWithNonITCItemIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [381621] Check if system is calculating GST Amount alongwith Cess Amount for Registered Vendor Intrastate with Goods and Charge Item on Purchase Invoice and and Non-Availment with impact on Item Ledger Entries Value Entry.
        // [FEATURE] [Goods and Charge Item, Purchase Invoice] [ITC Non Availment, Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup and tax rates where Customer is Registered and Jurisdiction is Intrastate
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, CompCalcType::"Cess %", true, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as item for Intrastate Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] New Purchase Line Created With Charge Item and assigned with Item
        DocumentNo := CreateAndPostPurchaseDocWithChargeItem(PurchaseHeader);

        // [THEN] Value Entry Created and Verified
        VerifyValueEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrdUnregVendWithNonITCItemInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [381676] Check if system is calculating GST Amount alongwith Cess Amount for Un-Registered Vendor Interstate with Goods with Charge on Purchase Order and Non-Availment with impact on Item Ledger Entries.
        // [FEATURE] [Goods and Charge Item, Purchase Order] [ITC Non Availment, Unregistered Vendor, Inter-State]

        // [GIVEN] Created GST Setup and tax rates Customer type is unregistered and Jurisdition is Intrastate
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, CompCalcType::"Cess %", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line type as item for Interstate Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] New Purchase Line Created With Charge Item and assigned with Item
        DocumentNo := CreateAndPostPurchaseDocWithChargeItem(PurchaseHeader);

        // [THEN] Value Entry Created and Verified
        VerifyValueEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvUnregVendWithNonITCItemInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [381732] Check if system is calculating GST Amount alongwith Cess amount for Un-Registered Vendor Interstate with Goods and Charge Item on Purchase Invoice and Non-Availment with impact on Item Ledger Entries and Value Entries.
        // [FEATURE] [Goods and Charge Item, Purchase Invoice] [ITC Non Availment, Unregistered Vendor, Inter-State]

        // [GIVEN] Created GST Setup and tax rates Customer type is Registered with GST Credit is Avilment
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, CompCalcType::"Cess %", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as item for Interstate Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] New Purchase Line Created With Charge Item and assigned with Item
        DocumentNo := CreateAndPostPurchaseDocWithChargeItem(PurchaseHeader);

        // [THEN] Value Entry Created and Verified
        VerifyValueEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrdSEZVendWithNonITCItemInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [381450] Check if system is calculating GST Amount alongwith Cess Amount for SEZ Vendor Interstate with Goods on Purchase Order and Non-availment with impact on Item Ledger Entries and Value Entries.
        // [FEATURE] [Goods and Charge Item, Purchase Order] [ITC Non Availment, SEZ Vendor, Inter-State]

        // [GIVEN] Created GST Setup and tax rates Customer and Calculation type is Cess %
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, CompCalcType::"Cess %", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line type as item for Interstate Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] New Purchase Line Created With Charge Item and assigned with Item
        DocumentNo := CreateAndPostPurchaseDocWithChargeItem(PurchaseHeader);

        // [THEN] Value Entry Created and Verified
        VerifyValueEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvSEZVendWithNonITCItemInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [382240] Check if system is calculating GST Amount alongwith Cess (Component Calc. Type : Cess%) amount for SEZ Vendor Interstate with Goods on Purchase Invoice and Non-Availment with impact on Item Ledger Entries and Value Entries. Without Bill of Entry.
        // [FEATURE] [Goods and Charge Item, Purchase Invoice] [ITC Non Availment, SEZ Vendor, Inter-State]

        // [GIVEN] Created GST Setup and tax rates Customer type is Unregistered and Calculation type is Cess %
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, CompCalcType::"Cess %", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as item for Interstate Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] New Purchase Line Created With Charge Item and assigned with Item
        DocumentNo := CreateAndPostPurchaseDocWithChargeItem(PurchaseHeader);

        // [THEN] Value Entry Created and Verified
        VerifyValueEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoSEZVendorWithNonITCGoodsAndChItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        CompCalcType: Enum "Component Calc Type";
    begin
        // [SCENARIO] [382354] Check if system is calculating GST and Cess (Comp Calc. Type : Cess%) Amount for SEZ Vendor Interstate with Goods on Purchase Credit Memo with Non-Availment and impact on Item Ledger Entries and Value Entries through Copy Document. Without Bill of Entry
        // [FEATURE] [Goods, Purchase Credit Memo] [ITC Non Availment, SEZ Vendor, Calculation Type - Cess %]

        // [GIVEN] Created GST Setup and tax rates and Component calculation type is Cess %
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, CompCalcType::"Cess %", false, false);
        InitializeShareStep(false, false, false);
        SetStorageGSTPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document created and Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] Value Entry Created and Verified
        VerifyValueEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    local procedure CreateGSTSetup(
        GSTVendorType: Enum "GST Vendor Type";
        GSTGroupType: Enum "GST Group Type";
        CompCalcType: Enum "Component Calc Type";
        IntraState: Boolean;
        ReverseCharge: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        CompanyInformation: Record "Company information";
        LocationStateCode: Code[10];
        VendorNo: Code[20];
        GSTGroupCode: Code[20];
        LocationCode: Code[10];
        HSNSACCode: Code[10];
        LocPan: Code[20];
        LocationGSTRegNo: Code[15];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTcomponentcode: Text[30];
    begin
        CompanyInformation.Get();

        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := LibraryGST.CreatePANNos();
            CompanyInformation.Modify();
        end else
            LocPan := CompanyInformation."P.A.N. No.";
        LocPan := CompanyInformation."P.A.N. No.";
        SetStorageGSTPurchaseText(LocPanLbl, LocPan);

        LocationStateCode := LibraryGST.CreateInitialSetup();
        SetStorageGSTPurchaseText(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPan);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true);
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        SetStorageGSTPurchaseText(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryGST.CreateCessGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::"Bill-to Address", CompCalcType, ReverseCharge);
        SetStorageGSTPurchaseText(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        SetStorageGSTPurchaseText(HSNSACCodeLbl, HSNSACCode);

        VendorNo := LibraryGST.CreateVendorSetup();
        SetStorageGSTPurchaseText(VendorNoLbl, VendorNo);

        if IntraState then
            CreateSetupForIntraStateVendor(GSTVendorType, IntraState)
        else
            CreateSetupForInterStateVendor(GSTVendorType, IntraState);

        CreateTaxRate();
        CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, GSTcomponentcode);
    end;

    local procedure CreateSetupForIntraStateVendor(GSTVendorType: Enum "GST Vendor Type"; IntraState: Boolean)
    var
        LocationStateCode: Code[10];
        VendorNo: Code[20];
        LocPan: Code[20];
    begin
        VendorNo := (Storage.Get(VendorNoLbl));
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        LocPan := (Storage.Get(LocPanLbl));
        UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, LocationStateCode, LocPan);
        InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
    end;

    local procedure CreateSetupForInterStateVendor(GSTVendorType: Enum "GST Vendor Type"; IntraState: Boolean)
    var
        LocationStateCode: Code[10];
        VendorStateCode: Code[10];
        VendorNo: Code[20];
        LocPan: Code[20];
    begin
        VendorNo := (Storage.Get(VendorNoLbl));
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        LocPan := (Storage.Get(LocPanLbl));
        VendorStateCode := LibraryGST.CreateGSTStateCode();
        UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, VendorStateCode, LocPan);
        if GSTVendorType in [GSTVendorType::Import, GSTVendorType::SEZ] then
            InitializeTaxRateParameters(IntraState, '', LocationStateCode)
        else
            InitializeTaxRateParameters(IntraState, VendorStateCode, LocationStateCode);
    end;

    local procedure CreateGSTComponentAndPostingSetup(
        IntraState: Boolean;
        LocationStateCode: Code[10];
        GSTComponentCode: Text[30])
    begin
        if IntraState then begin
            GSTComponentCode := CGSTLbl;
            LibraryGST.CreateGSTCessPostingSetup(GSTComponentCode, LocationStateCode);

            GSTComponentCode := SGSTLbl;
            LibraryGST.CreateGSTCessPostingSetup(GSTComponentCode, LocationStateCode);

            GSTComponentCode := CessLbl;
            LibraryGST.CreateGSTCessPostingSetup(GSTComponentCode, LocationStateCode);
        end else begin
            GSTComponentCode := IGSTLbl;
            LibraryGST.CreateGSTCessPostingSetup(GSTComponentCode, LocationStateCode);

            GSTComponentCode := CessLbl;
            LibraryGST.CreateGSTCessPostingSetup(GSTComponentCode, LocationStateCode);
        end;
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
        Currency: Record Currency;
        LibraryERM: Codeunit "Library - ERM";
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
        if Vendor."GST Vendor Type" = Vendor."GST Vendor Type"::Import then begin
            LibraryERM.CreateCurrency(Currency);
            LibraryERM.CreateRandomExchangeRate(Currency.Code);
            Vendor.Validate("Currency Code", Currency.Code);
            Vendor.Validate("Associated Enterprises", AssociateEnterprise);
        end;
        Vendor.Modify(true);
    end;

    local procedure InitializeShareStep(InputCreditAvailment: Boolean; Exempted: Boolean; LineDiscount: Boolean)
    begin
        SetStorageBooleanGSTPurchaseText(InputCreditAvailmentLbl, InputCreditAvailment);
        SetStorageBooleanGSTPurchaseText(ExemptedLbl, Exempted);
        SetStorageBooleanGSTPurchaseText(LineDiscountLbl, LineDiscount);
    end;

    local procedure CreateAndPostPurchaseDocWithChargeItem(var PurchaseHeader: Record "Purchase Header"): Code[20]
    var
        NewPurchaseLine: Record "Purchase Line";
        PurchaseLine: Record "Purchase Line";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        DocumentNo: Code[20];
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetFilter("No.", '<>%1', '');
        PurchaseLine.FindFirst();

        CreatePurchaseLineWithGST(
            PurchaseHeader,
            NewPurchaseLine,
            NewPurchaseLine.Type::"Charge (Item)",
            1,
            StorageBoolean.Get(InputCreditAvailmentLbl),
            StorageBoolean.Get(ExemptedLbl),
            StorageBoolean.Get(LineDiscountLbl));

        LibraryGSTPurchase.CreateItemChargeAssignment(
            ItemChargeAssignmentPurch,
            NewPurchaseLine,
            PurchaseHeader."Document Type",
            PurchaseHeader."No.",
            PurchaseLine."Line No.",
            PurchaseLine."No.");

        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, DocumentNo);

        exit(DocumentNo);
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

    local procedure ConvertQuoteToOrderAndPost(PurchaseHeader: Record "Purchase Header"): Code[20]
    var
        OrderPurchaseHeader: Record "Purchase Header";
        OrderNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        OrderNo := LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
        OrderPurchaseHeader.Get(OrderPurchaseHeader."Document Type"::Order, OrderNo);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(OrderPurchaseHeader, true, true);

        exit(PostedDocumentNo);
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
            SetStorageGSTPurchaseText(PostedDocumentNoLbl, DocumentNo);
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
        if PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::SEZ, PurchaseHeader."GST Vendor Type"::Import] then begin
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
                LineType::"Charge (Item)":
                    LineTypeNo := LibraryGST.CreateChargeItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
            end;

            LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, LineType, LineTypeno, Quantity);

            PurchaseLine.Validate("VAT Prod. Posting Group", VATPostingsetup."VAT Prod. Posting Group");
            if InputCreditAvailment then
                PurchaseLine."GST Credit" := PurchaseLine."GST Credit"::Availment
            else
                PurchaseLine."GST Credit" := PurchaseLine."GST Credit"::"Non-Availment";
            UpdateGSTGroup(LineTypeNo);

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
        SetStorageGSTPurchaseText(ReverseDocumentNoLbl, ReverseDocumentNo);
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

    local procedure UpdateGSTGroup(ItemNo: Code[20])
    var
        GSTGroup: Record "GST Group";
        Item: Record Item;
    begin
        GSTGroup.Get(Storage.Get(GSTGroupCodeLbl));
        if Item.Get(ItemNo) then
            GSTGroup.Validate("Cess UOM", Item."Base Unit of Measure");

        if StorageBoolean.Get(InputCreditAvailmentLbl) then
            GSTGroup.Validate("Cess Credit", GSTGroup."Cess Credit"::Availment)
        else
            GSTGroup.Validate("Cess Credit", GSTGroup."Cess Credit"::"Non-Availment");
        GSTGroup.Modify(true);
    end;

    local procedure VerifyGSTEntries(DocumentNo: Code[20]; TableID: Integer)
    begin
        LibraryGSTPurchase.VerifyGSTEntries(DocumentNo, TableID, ComponentPerArray);
    end;

    local procedure VerifyValueEntries(DocumentNo: Code[20]; TableID: Integer)
    begin
        LibraryGSTPurchase.VerifyValueEntries(DocumentNo, TableID, ComponentPerArray);
    end;

    local procedure InitializeTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10])
    var
        GSTTaxPercent: Decimal;
    begin
        SetStorageGSTPurchaseText(FromStateCodeLbl, FromState);
        SetStorageGSTPurchaseText(ToStateCodeLbl, ToState);
        GSTTaxPercent := LibraryRandom.RandDecInRange(10, 18, 0);
        if IntraState then begin
            ComponentPerArray[1] := (GSTTaxPercent / 2);
            ComponentPerArray[2] := (GSTTaxPercent / 2);
            ComponentPerArray[5] := LibraryRandom.RandDecInRange(8, 10, 0);
            ComponentPerArray[6] := LibraryRandom.RandDecInRange(4, 6, 0);
            ComponentPerArray[7] := LibraryRandom.RandDecInRange(900, 1100, 0);
            ComponentPerArray[8] := LibraryRandom.RandDecInRange(900, 100, 0);
            ComponentPerArray[9] := LibraryRandom.RandDecInRange(1, 2, 0);
        end else begin
            ComponentPerArray[3] := GSTTaxPercent;
            ComponentPerArray[5] := LibraryRandom.RandDecInRange(8, 10, 0);
            ComponentPerArray[6] := LibraryRandom.RandDecInRange(4, 6, 0);
            ComponentPerArray[7] := LibraryRandom.RandDecInRange(900, 1100, 0);
            ComponentPerArray[8] := LibraryRandom.RandDecInRange(900, 100, 0);
            ComponentPerArray[9] := LibraryRandom.RandDecInRange(1, 2, 0);
        end;
    end;

    local procedure CreateTaxRate()
    var
        GSTSetup: Record "GST Setup";
        TaxTypes: TestPage "Tax Types";
    begin
        GSTSetup.Get();
        TaxTypes.OpenEdit();
        SetStorageGSTPurchaseText(TaxTypeLbl, GSTSetup."GST Tax Type");
        TaxTypes.Filter.SetFilter(Code, GSTSetup."GST Tax Type");
        TaxTypes.TaxRates.Invoke();

        SetStorageGSTPurchaseText(TaxTypeLbl, GSTSetup."Cess Tax Type");
        TaxTypes.Filter.SetFilter(Code, GSTSetup."Cess Tax Type");
        TaxTypes.TaxRates.Invoke();
    end;

    local procedure SetStorageGSTPurchaseText(KeyValue: Text[20]; Value: Text[20])
    begin
        Storage.Set(KeyValue, Value);
        LibraryGSTPurchase.SetStorageLibraryPurchaseText(Storage);
    end;

    local procedure SetStorageBooleanGSTPurchaseText(KeyValue: Text[20]; Value: Boolean)
    begin
        StorageBoolean.Set(KeyValue, Value);
        LibraryGSTPurchase.SetStorageLibraryPurchaseBoolean(StorageBoolean);
    end;

    [ModalPageHandler]
    procedure ReferenceInvoiceNoPageHandler(var VendorLedgerEntries: TestPage "Vendor Ledger Entries")
    begin
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    var
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        if Storage.Get(TaxTypeLbl) = GSTSetup."GST Tax Type" then begin
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
        end else
            if Storage.Get(TaxTypeLbl) = GSTSetup."Cess Tax Type" then begin
                TaxRates.New();
                TaxRates.AttributeValue1.SetValue(Storage.Get(GSTGroupCodeLbl));
                TaxRates.AttributeValue2.SetValue(Storage.Get(HSNSACCodeLbl));
                TaxRates.AttributeValue3.SetValue(Storage.Get(FromStateCodeLbl));
                TaxRates.AttributeValue4.SetValue(Storage.Get(ToStateCodeLbl));
                TaxRates.AttributeValue5.SetValue(WorkDate());
                TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', WorkDate()));
                TaxRates.AttributeValue7.SetValue(ComponentPerArray[5]); //Cess
                TaxRates.AttributeValue8.SetValue(ComponentPerArray[6]); //Before Threshold Cess
                TaxRates.AttributeValue9.SetValue(ComponentPerArray[7]); //Threshold Amount
                TaxRates.AttributeValue10.SetValue(ComponentPerArray[8]); //Cess Amount Per Unit Factor
                TaxRates.AttributeValue11.SetValue(ComponentPerArray[9]); //Cess Factor Quantity
                TaxRates.OK().Invoke();
            end;
    end;
}
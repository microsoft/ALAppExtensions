codeunit 18126 "GST Purch Return Resource"
{
    Subtype = Test;

    var
        LibraryGST: Codeunit "Library GST";
        LibraryRandom: Codeunit "Library - Random";
        LibraryGSTPurchase: Codeunit "Library - GST Purchase";
        LibraryPurchase: Codeunit "Library - Purchase";
        Assert: Codeunit Assert;
        Storage: Dictionary of [Text, Code[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
        ComponentPerArray: array[20] of Decimal;
        GSTLEVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
        NoOfLineLbl: Label 'NoOfLine';
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo';
        LocPanLbl: Label 'LocPan';
        LocationStateCodeLbl: Label 'LocationStateCode';
        LocationCodeLbl: Label 'LocationCode';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        VendorNoLbl: Label 'VendorNo';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        CessLbl: Label 'CESS';
        InputCreditAvailmentLbl: Label 'InputCreditAvailment';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
        LineDiscountLbl: Label 'LineDiscount';
        FromStateCodeLbl: Label 'FromStateCode';
        ToStateCodeLbl: Label 'ToStateCode';
        AssociatedVendorLbl: Label 'AssociatedVendor';

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostGSTReturnOrderToRegVendorWithResInterStateITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[SCENARIO] [377769] Check if the program is calculating GST on  Purchase Return Order for Registered Vendor with Availemnt - Interstate Trough Get Reversed Posted Lines with line discount.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeSharedStep(true, true);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Return Order with GST and Line Type as Resource for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries,VendorInvoiceDiscountPageHandler')]
    procedure PostGSTReturnOrderToRegVendorWithResInterStateITCInvDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchCalcDiscount: Codeunit "Purch.-Calc.Discount";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        //[SCENARIO] [377946] Check if the program is calculating GST on  Purchase Return Order with Resource (RCM) for Registered Vendor with Availment - Interstate Trough Get Reversed Posted Lines with Invoice Discount.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeSharedStep(true, false);
        CreateVendorInvoiceDiscount(PurchaseHeader."Buy-from Vendor No.");
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Return Order with GST and Line Type as Resource for Interstate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Order);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindFirst() then begin
            PurchaseLine.Validate("Allow Invoice Disc.", true);
            PurchaseLine.Modify(true);
            PurchCalcDiscount.Run(PurchaseLine);
            PurchaseLine.Validate("Direct Unit Cost");
        end;
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, DocumentNo);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries,VendorInvoiceDiscountPageHandler')]
    procedure PostGSTReturnOrderToUnRegVendorWithResInterStateITCInvDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchCalcDiscount: Codeunit "Purch.-Calc.Discount";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        //[SCENARIO] [378135] Check if the program is calculating GST on  Purchase Return with Resource Order for Unregistered Vendor with Availemnt - Interstate Trough Get Reversed Posted Lines with Invoice Discount
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, false, false);
        InitializeSharedStep(true, false);
        CreateVendorInvoiceDiscount(PurchaseHeader."Buy-from Vendor No.");
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Return Order with GST and Line Type as Resource for Interstate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Order);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindFirst() then begin
            PurchaseLine.Validate("Allow Invoice Disc.", true);
            PurchaseLine.Modify(true);
            PurchCalcDiscount.Run(PurchaseLine);
            PurchaseLine.Validate("Direct Unit Cost");
        end;
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, DocumentNo);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries,VendorInvoiceDiscountPageHandler')]
    procedure PostGSTReturnOrderToSEZVendorWithResInterStateITCInvDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchCalcDiscount: Codeunit "Purch.-Calc.Discount";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        //[SCENARIO] [378800] Check if the program is calculating GST on  Purchase Return Order with Resource for SEZ Vendor with Availment - Interstate Trough Get Reversed Posted Lines with Invoice discount.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Service, false, false);
        InitializeSharedStep(true, false);
        CreateVendorInvoiceDiscount(PurchaseHeader."Buy-from Vendor No.");
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Return Order with GST and Line Type as Resource for Interstate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Order);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindFirst() then begin
            PurchaseLine.Validate("Allow Invoice Disc.", true);
            PurchaseLine.Modify(true);
            PurchCalcDiscount.Run(PurchaseLine);
            PurchaseLine.Validate("Direct Unit Cost");
        end;
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, DocumentNo);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries,VendorInvoiceDiscountPageHandler')]
    procedure PostGSTReturnOrderToImportVendorWithResInterStateITCInvDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchCalcDiscount: Codeunit "Purch.-Calc.Discount";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        //[SCENARIO] [378668] Check if the program is calculating GST on  Purchase Return Order with Resource for Import Vendor with Availment - Interstate Trough Get Reversed Posted Lines. - Interstate with Invoice Discount.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeSharedStep(true, false);
        CreateVendorInvoiceDiscount(PurchaseHeader."Buy-from Vendor No.");
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Return Order with GST and Line Type as Resource for Interstate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Order);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindFirst() then begin
            PurchaseLine.Validate("Allow Invoice Disc.", true);
            PurchaseLine.Modify(true);
            PurchCalcDiscount.Run(PurchaseLine);
            PurchaseLine.Validate("Direct Unit Cost");
        end;
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, DocumentNo);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries,VendorInvoiceDiscountPageHandler')]
    procedure PostGSTReturnOrderToCompositeVendorWithResInterStateITCInvDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchCalcDiscount: Codeunit "Purch.-Calc.Discount";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        //[SCENARIO] [378445] Check if the program is calculating GST on  Purchase Return Order with Resource for Composite Vendor with Availment - Interstate Trough Get Reversed Posted Lines with invoice discount.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Service, false, false);
        InitializeSharedStep(true, false);
        CreateVendorInvoiceDiscount(PurchaseHeader."Buy-from Vendor No.");
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Return Order with GST and Line Type as Resource for Interstate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Order);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindFirst() then begin
            PurchaseLine.Validate("Allow Invoice Disc.", true);
            PurchaseLine.Modify(true);
            PurchCalcDiscount.Run(PurchaseLine);
            PurchaseLine.Validate("Direct Unit Cost");
        end;
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, DocumentNo);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostGSTCreditMemoToRegVendorWithResInterStateWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[SCENARIO] [377770] Check if the program is calculating GST on  Purchase Credit Memo for Registered Vendor with Non-Availemnt - Interstate through Copy Document.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeSharedStep(false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Resource for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostGSTCreditMemoToRegVendorWithResWithoutITCRevCharge()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[SCENARIO] [377951] Check if the program is calculating GST on  Purchase Credit Memo with Resource (RCM) for Registered Vendor with Non-Availment - Interstate through Copy Document.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, true);
        InitializeSharedStep(false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Resource for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Invoice);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostGSTCreditMemoToUnRegVendorWithResWithoutITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[SCENARIO] [378364] Check if the program is calculating GST on  Purchase Credit Memo with Resource for Unregistered Vendor with Non-Availemnt - Interstate through Copy Document.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, false, true);
        InitializeSharedStep(false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Resource for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Invoice);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostGSTCreditMemoToCompositeVendorWithResWithoutITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[SCENARIO] [378539] Check if the program is calculating GST on  Purchase Credit Memo with Credit Memo for Composite Vendor with Non-Availment - Interstate through Copy Document.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Service, false, false);
        InitializeSharedStep(false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Resource for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Invoice);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostGSTCreditMemoToImportVendorWithResWithoutITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[SCENARIO] [378680] Check if the program is calculating GST on  Purchase Credit Memo with Resource for Import Vendor with Non-Availment - Interstate through Copy Document with Line Discount.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeSharedStep(false, true);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Resource for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Invoice);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostGSTCreditMemoToSEZVendorWithResWithoutITCLineDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[SCENARIO] [378867] Check if the program is calculating GST on  Purchase Credit Memo with Resource for SEZ Vendor with Non-Availment - Interstate through Copy Document with Line discount.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);
        InitializeSharedStep(false, true);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Resource for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Invoice);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostGSTReturnOrderToRegVendorWithResIntraStateWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[SCENARIO] [377817] Check if the program is calculating GST on  Purchase Return Order with Resource for Registered Vendor with Non-Availemnt - Intrastate through Get Reversed Posted Lines.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeSharedStep(false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Return Order with GST and Line Type as Resource for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries,VendorInvoiceDiscountPageHandler')]
    procedure PostGSTReturnOrderToRegVendorWithResIntraStateITCInvDisc()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchCalcDiscount: Codeunit "Purch.-Calc.Discount";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        //[SCENARIO] [377831] Check if the program is calculating GST on  Purchase Credit Memo with Resource for Registered Vendor with Availemnt - Intrastate through Copy Document with invoice discount.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeSharedStep(true, false);
        CreateVendorInvoiceDiscount(PurchaseHeader."Buy-from Vendor No.");
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Resource for Intrastate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Invoice);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindFirst() then begin
            PurchaseLine.Validate("Allow Invoice Disc.", true);
            PurchaseLine.Modify(true);
            PurchCalcDiscount.Run(PurchaseLine);
            PurchaseLine.Validate("Direct Unit Cost");
        end;
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, DocumentNo);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostGSTReturnOrderToRegVendorWithResIntraStateWithITCRevChrge()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[SCENARIO] [377958] Check if the program is calculating GST on  Purchase Credit Memo with Resource (RCM) for Registered Vendor with Availment - Intrastate through Copy Document with Line Discount.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        InitializeSharedStep(true, true);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Resource for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Invoice);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostGSTReturnOrderToRegVendorWithResIntraStateWithoutITCRevChrge()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[SCENARIO] [378016] Check if the program is calculating GST on  Purchase Return Order with Resource (RCM) for Registered Vendor with Non-Availment - Intrastate through Get Reversed Posted Lines.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        InitializeSharedStep(false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Return Order with GST and Line Type as Resource for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostGSTReturnOrderToCompositeVendorWithResIntraStateWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[SCENARIO] [378504] Check if the program is calculating GST on  Purchase Return Order with Resource for Composite Vendor with Availment - Intrastate through Get Reversed Posted Lines with Line Discount.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Service, true, false);
        InitializeSharedStep(true, true);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Return Order with GST and Line Type as Resource for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure PostGSTCreditMemoToCompositeVendorWithResIntraStateWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        //[SCENARIO] [378543] Check if the program is calculating GST on  Purchase Credit Memo with Resource for Composite Vendor with Non-Availment - Intrastate through Copy Document.
        //[GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Service, true, false);
        InitializeSharedStep(false, false);
        Storage.Set(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Credit Memo with GST and Line Type as Resource for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Resource,
            DocumentType::Invoice);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl));
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
        Storage.Set(LocPanLbl, LocPan);

        LocationStateCode := LibraryGST.CreateInitialSetup();
        Storage.Set(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPan);
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

        VendorNo := LibraryGST.CreateVendorSetup();
        Storage.Set(VendorNoLbl, VendorNo);

        if IntraState then
            CreateSetupForIntraStateVendor(GSTVendorType, IntraState)
        else
            CreateSetupForInterStateVendor(GSTVendorType, IntraState);

        CreateTaxRate();
        CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTcomponentcode);
    end;

    local procedure CreateSetupForIntraStateVendor(GSTVendorType: Enum "GST Vendor Type"; IntraState: Boolean)
    var
        LocationStateCode: Code[10];
        VendorNo: Code[20];
        LocPan: Code[20];
    begin
        VendorNo := Storage.Get(VendorNoLbl);
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        LocPan := Storage.Get(LocPanLbl);
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
        VendorNo := Storage.Get(VendorNoLbl);
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        LocPan := Storage.Get(LocPanLbl);
        VendorStateCode := LibraryGST.CreateGSTStateCode();
        UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, VendorStateCode, LocPan);

        if GSTVendorType in [GSTVendorType::Import, GSTVendorType::SEZ] then
            InitializeTaxRateParameters(IntraState, '', LocationStateCode)
        else
            InitializeTaxRateParameters(IntraState, VendorStateCode, LocationStateCode);
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
        VendorNo := Storage.Get(VendorNoLbl);
        Evaluate(LocationCode, CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode)));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(InputCreditAvailmentLbl), StorageBoolean.Get(LineDiscountLbl));
        if not (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Quote) then begin
            DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
            Storage.Set(PostedDocumentNoLbl, DocumentNo);
            exit(DocumentNo);
        end;
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

    local procedure InitializeSharedStep(InputCreditAvailment: Boolean; LineDiscount: Boolean)
    begin
        StorageBoolean.Set(InputCreditAvailmentLbl, InputCreditAvailment);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
    end;

    local procedure UpdateVendorSetupWithGST(
        VendorNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        AssociateEnterprise: Boolean;
        StateCode: Code[10];
        Pan: Code[20])
    var
        Vendor: Record Vendor;
        State: Record State;
    begin
        Vendor.Get(VendorNo);
        if (GSTVendorType <> GSTVendorType::Import) then begin
            State.Get(StateCode);
            Vendor.Validate("State Code", StateCode);
            Vendor.Validate("P.A.N. No.", Pan);
            if not ((GSTVendorType = GSTVendorType::" ") or (GSTVendorType = GSTVendorType::Unregistered)) then
                Vendor.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", Pan));
        end;
        Vendor.Validate("GST Vendor Type", GSTVendorType);
        if Vendor."GST Vendor Type" = vendor."GST Vendor Type"::Import then begin
            Vendor.Validate("Currency Code", LibraryGST.CreateCurrencyCode());
            if StorageBoolean.ContainsKey(AssociatedVendorLbl) then
                vendor.Validate("Associated Enterprises", AssociateEnterprise);
        end;
        Vendor.Modify(true);
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
            ComponentPerArray[3] := 0;
        end else
            ComponentPerArray[4] := GSTTaxPercent;
    end;

    local procedure CreateGSTComponentAndPostingSetup(
        IntraState: Boolean;
        LocationStateCode: Code[10];
        TaxComponent: Record "Tax Component";
        GSTcomponentcode: Text[30])
    begin
        if IntraState then begin
            GSTcomponentcode := CGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTcomponentcode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTcomponentcode := SGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTcomponentcode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTcomponentcode := IGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTcomponentcode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
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
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Vendor Invoice No."), Database::"Purchase Header"));

        if (PurchaseHeader."GST Vendor Type" IN [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ]) then begin
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
        LineDiscount: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LineTypeNo: Code[20];
        LineNo: Integer;
        NoOfLine: Integer;
    begin
        Evaluate(NoOfLine, Storage.Get(NoOfLineLbl));
        InputCreditAvailment := StorageBoolean.Get(InputCreditAvailmentLbl);
        for LineNo := 1 to NoOfLine do begin
            case LineType of
                LineType::Resource:
                    LineTypeNo := LibraryGST.CreateResourceWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment);
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

    local procedure CreateTaxRate()
    var
        GSTSetup: Record "GST Setup";
        TaxTypes: TestPage "Tax Types";
    begin
        GSTSetup.Get();
        TaxTypes.OpenEdit();
        TaxTypes.Filter.SetFilter(Code, GSTSetup."GST Tax Type");
        TaxTypes.TaxRates.Invoke();
    end;

    local procedure GetCurrencyFactorForPurchase(DocumentNo: Code[20]): Decimal
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        PurchCrMemoHdr.SetRange("No.", DocumentNo);
        if PurchCrMemoHdr.FindFirst() then
            exit(PurchCrMemoHdr."Currency Factor");
    end;

    local procedure CreateVendorInvoiceDiscount(VendorNo: Code[20])
    var
        VendorTestPage: TestPage "Vendor Card";
    begin
        VendorTestPage.OpenEdit();
        VendorTestPage.Filter.SetFilter("No.", VendorNo);
        VendorTestPage."Invoice &Discounts".Invoke();
    end;

    local procedure CreatePurchaseDocument(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type"): Code[20]
    var
        LocationCode: Code[10];
        VendorNo: Code[20];
        PurchaseInvoiceType: Enum "GST Invoice Type";
    begin
        VendorNo := Storage.Get(VendorNoLbl);
        Evaluate(LocationCode, CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode)));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(InputCreditAvailmentLbl), StorageBoolean.Get(LineDiscountLbl));
        exit(PurchaseHeader."No.")
    end;

    local procedure VerifyGSTEntries(DocumentNo: Code[20])
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        ComponentList: List of [Code[30]];
    begin
        PurchCrMemoLine.SetRange("Document No.", DocumentNo);
        PurchCrMemoLine.SetFilter("No.", '<>%1', '');
        if PurchCrMemoLine.FindSet() then
            VerifyGSTEntriesForPurchaseReturn(DocumentNo);
        repeat
            FillComponentList(PurchCrMemoLine."GST Jurisdiction Type", ComponentList, PurchCrMemoLine."GST Group Code");
            VerifyDetailedGSTEntriesForPurchaseReturn(PurchCrMemoLine, DocumentNo, ComponentList);
        until PurchCrMemoLine.Next() = 0;
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
            ComponentList.Add(CessLbl);
    end;

    local procedure GetPurchReturnGSTAmount(
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line"): Decimal
    begin
        if PurchCrMemoHdr."GST Vendor Type" IN [PurchCrMemoHdr."GST Vendor Type"::Registered,
            PurchCrMemoHdr."GST Vendor Type"::Unregistered,
            PurchCrMemoHdr."GST Vendor Type"::Import,
            PurchCrMemoHdr."GST Vendor Type"::SEZ] then
            if PurchCrMemoLine."GST Jurisdiction Type" = PurchCrMemoLine."GST Jurisdiction Type"::Interstate then
                exit(-(PurchCrMemoLine.Amount * ComponentPerArray[4] / 100))
            else
                exit(-(PurchCrMemoLine.Amount * ComponentPerArray[1] / 100))
        else
            if PurchCrMemoHdr."GST Vendor Type" IN [PurchCrMemoHdr."GST Vendor Type"::Composite,
           PurchCrMemoHdr."GST Vendor Type"::Exempted] then
                exit(0.00);
    end;

    local procedure VerifyGSTEntriesForPurchaseReturn(DocumentNo: Code[20])
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        SourceCodeSetup: Record "Source Code Setup";
        GSTAmount: Decimal;
        CurrencyFactor: Decimal;
        TransactionNo: Decimal;
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        PurchCrMemoHdr.Get(DocumentNo);

        PurchCrMemoLine.SetRange("Document No.", DocumentNo);
        PurchCrMemoLine.SetFilter("No.", '<>%1', '');
        PurchCrMemoLine.FindFirst();

        CurrencyFactor := GetCurrencyFactorForPurchase(DocumentNo);
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        SourceCodeSetup.Get();

        TransactionNo := LibraryGSTPurchase.GetTransactionNo(
            DocumentNo,
            PurchCrMemoHdr."Posting Date",
            DocumentType::"Credit Memo");

        GSTLedgerEntry.SetRange("Document No.", DocumentNo);
        GSTLedgerEntry.FindFirst();

        GSTAmount := GetPurchReturnGSTAmount(PurchCrMemoHdr, PurchCrMemoLine);

        Assert.AreEqual(PurchCrMemoLine."Gen. Bus. Posting Group", GSTLedgerEntry."Gen. Bus. Posting Group",
           StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldName("Gen. Bus. Posting Group"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoLine."Gen. Prod. Posting Group", GSTLedgerEntry."Gen. Prod. Posting Group",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Gen. Prod. Posting Group"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoHdr."Posting Date", GSTLedgerEntry."Posting Date",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Posting Date"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Document Type"::"Credit Memo", GSTLedgerEntry."Document Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Document Type"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Transaction Type"::Purchase, GSTLedgerEntry."Transaction Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction Type"), GSTLedgerEntry.TableCaption));

        Assert.AreNearlyEqual(-PurchCrMemoLine.Amount / CurrencyFactor, GSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Base Amount"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Source Type"::Vendor, GSTLedgerEntry."Source Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Type"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoHdr."Pay-to Vendor No.", GSTLedgerEntry."Source No.",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source No."), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(UserId, GSTLedgerEntry."User ID",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("User ID"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(SourceCodeSetup.Purchases, GSTLedgerEntry."Source Code",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Code"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(TransactionNo, GSTLedgerEntry."Transaction No.",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction No."), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoLine."GST Reverse Charge", GSTLedgerEntry."Reverse Charge",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Reverse Charge"), GSTLedgerEntry.TableCaption));

        Assert.AreNearlyEqual(GSTAmount / CurrencyFactor, GSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Amount"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Entry Type"::"Initial Entry", GSTLedgerEntry."Entry Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Entry Type"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoHdr."GST Input Service Distribution", GSTLedgerEntry."Input Service Distribution",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Input Service Distribution"), GSTLedgerEntry.TableCaption));
    end;

    local procedure VerifyDetailedGSTEntriesForPurchaseReturn(
        var PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        DocumentNo: Code[20];
        var ComponentList: List of [Code[30]])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        SourceCodeSetup: Record "Source Code Setup";
        Vendor: Record Vendor;
        GSTAmount: Decimal;
        CurrencyFactor: Decimal;
        EligibilityforITC: Enum "Eligibility for ITC";
        ComponentCode: Code[30];
        TransactionNo: Decimal;
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        PurchCrMemoHdr.Get(DocumentNo);

        Vendor.Get(PurchCrMemoHdr."Pay-to Vendor No.");
        SourceCodeSetup.Get();

        CurrencyFactor := GetCurrencyFactorForPurchase(DocumentNo);
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        EligibilityforITC := GetPurchReturnResEligibilityForITC(PurchCrMemoHdr, PurchCrMemoLine);

        TransactionNo := LibraryGSTPurchase.GetTransactionNo(DocumentNo, PurchCrMemoHdr."Posting Date", DocumentType::"Credit Memo");

        GSTAmount := GetPurchReturnGSTAmount(PurchCrMemoHdr, PurchCrMemoLine);

        foreach ComponentCode in ComponentList do begin
            DetailedGSTLedgerEntry.Reset();
            DetailedGSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Document Line No.", PurchCrMemoLine."Line No.");
            DetailedGSTLedgerEntry.FindFirst();
        end;

        DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");

        Assert.AreEqual(DetailedGSTLedgerEntry."Entry Type"::"Initial Entry", DetailedGSTLedgerEntry."Entry Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Entry Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Transaction Type"::Purchase, DetailedGSTLedgerEntry."Transaction Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Document Type"::"Credit Memo", DetailedGSTLedgerEntry."Document Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Document Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoHdr."Posting Date", DetailedGSTLedgerEntry."Posting Date",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Posting Date"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoLine.Type, DetailedGSTLedgerEntry.Type,
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption(Type), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoLine."No.", DetailedGSTLedgerEntry."No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ComponentCode, DetailedGSTLedgerEntry."GST Component Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Component Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Product Type"::" ", DetailedGSTLedgerEntry."Product Type",
        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Product Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Source Type"::Vendor, DetailedGSTLedgerEntry."Source Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoHdr."Pay-to Vendor No.", DetailedGSTLedgerEntry."Source No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoLine."HSN/SAC Code", DetailedGSTLedgerEntry."HSN/SAC Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("HSN/SAC Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoLine."GST Group Code", DetailedGSTLedgerEntry."GST Group Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Group Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoLine."GST Jurisdiction Type", DetailedGSTLedgerEntry."GST Jurisdiction Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Jurisdiction Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreNearlyEqual(-PurchCrMemoLine.Amount / CurrencyFactor, DetailedGSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Base Amount"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreNearlyEqual(-PurchCrMemoLine.Amount / CurrencyFactor, DetailedGSTLedgerEntry."Remaining Base Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Remaining Base Amount"), DetailedGSTLedgerEntry.TableCaption));

        if PurchCrMemoHdr."GST Vendor Type" IN [PurchCrMemoHdr."GST Vendor Type"::Registered,
            PurchCrMemoHdr."GST Vendor Type"::Unregistered,
            PurchCrMemoHdr."GST Vendor Type"::Import,
            PurchCrMemoHdr."GST Vendor Type"::SEZ] then
            if DetailedGSTLedgerEntry."GST Jurisdiction Type" = DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate then
                Assert.AreEqual(ComponentPerArray[4], DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
            else
                Assert.AreEqual(ComponentPerArray[1], DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
        else
            if PurchCrMemoHdr."GST Vendor Type" IN [PurchCrMemoHdr."GST Vendor Type"::Composite,
                PurchCrMemoHdr."GST Vendor Type"::Exempted] then
                Assert.AreEqual(0.00, DetailedGSTLedgerEntry."GST %",
                       StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreNearlyEqual(GSTAmount / CurrencyFactor, DetailedGSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Amount"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreNearlyEqual(GSTAmount / CurrencyFactor, DetailedGSTLedgerEntry."Remaining GST Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Remaining GST Amount"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoHdr."Vendor Cr. Memo No.", DetailedGSTLedgerEntry."External Document No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("External Document No."), DetailedGSTLedgerEntry.TableCaption));

        if DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::"Non-Availment" then
            Assert.AreNearlyEqual(GSTAmount / CurrencyFactor, DetailedGSTLedgerEntry."Amount Loaded on Item", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Amount Loaded on Item"), DetailedGSTLedgerEntry.TableCaption))
        else
            Assert.AreEqual(0, DetailedGSTLedgerEntry."Amount Loaded on Item",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Amount Loaded on Item"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoLine.Quantity, DetailedGSTLedgerEntry.Quantity,
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName(Quantity), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(UserId, DetailedGSTLedgerEntryInfo."User ID",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("User ID"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(false, DetailedGSTLedgerEntryInfo.Positive,
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(Positive), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(PurchCrMemoLine."GST Reverse Charge", DetailedGSTLedgerEntry."Reverse Charge",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Reverse Charge"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoHdr."Nature of Supply", DetailedGSTLedgerEntryInfo."Nature of Supply",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Nature of Supply"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(PurchCrMemoLine.Exempted, DetailedGSTLedgerEntry."GST Exempted Goods",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Exempted Goods"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoHdr."Location State Code", DetailedGSTLedgerEntryInfo."Location State Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Location State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(Vendor."State Code", DetailedGSTLedgerEntryInfo."Buyer/Seller State Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Buyer/Seller State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(PurchCrMemoHdr."Location GST Reg. No.", DetailedGSTLedgerEntry."Location  Reg. No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Location  Reg. No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoHdr."Vendor GST Reg. No.", DetailedGSTLedgerEntry."Buyer/Seller Reg. No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Buyer/Seller Reg. No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoLine."GST Group Type", DetailedGSTLedgerEntry."GST Group Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Group Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoLine."GST Credit", DetailedGSTLedgerEntry."GST Credit",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Credit"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(TransactionNo, DetailedGSTLedgerEntry."Transaction No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntryInfo."Original Doc. Type"::"Credit Memo", DetailedGSTLedgerEntryInfo."Original Doc. Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. Type"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(DocumentNo, DetailedGSTLedgerEntryInfo."Original Doc. No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. No."), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(PurchCrMemoHdr."Location Code", DetailedGSTLedgerEntry."Location Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Location Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoHdr."GST Vendor Type", DetailedGSTLedgerEntry."GST Vendor Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Vendor Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoLine."Gen. Bus. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Bus. Posting Group",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldName("Gen. Bus. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(PurchCrMemoLine."Gen. Prod. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Prod. Posting Group",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Gen. Prod. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(PurchCrMemoLine."Unit of Measure Code", DetailedGSTLedgerEntryInfo.UOM,
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(UOM), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(EligibilityforITC, DetailedGSTLedgerEntry."Eligibility for ITC",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Eligibility for ITC"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchCrMemoHdr."GST Input Service Distribution", DetailedGSTLedgerEntry."Input Service Distribution",
           StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Input Service Distribution"), DetailedGSTLedgerEntry.TableCaption));
    end;

    local procedure GetPurchReturnResEligibilityForITC(
       PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
       PurchCrMemoLine: Record "Purch. Cr. Memo Line"): Enum "Eligibility for ITC"
    var
        EligibilityForITC: Enum "Eligibility for ITC";
    begin
        if PurchCrMemoHdr."GST Vendor Type" IN [PurchCrMemoHdr."GST Vendor Type"::Registered,
            PurchCrMemoHdr."GST Vendor Type"::Unregistered,
            PurchCrMemoHdr."GST Vendor Type"::Import,
            PurchCrMemoHdr."GST Vendor Type"::Exempted,
            PurchCrMemoHdr."GST Vendor Type"::SEZ] then
            exit(LibraryGSTPurchase.GetEligibilityforITC(PurchCrMemoLine."GST Credit", PurchCrMemoLine."GST Group Type", PurchCrMemoLine.Type))
        else
            exit(EligibilityForITC::"Input Services");
    end;

    [PageHandler]
    procedure VendorInvoiceDiscountPageHandler(var VendInvDisc: TestPage "Vend. Invoice Discounts");
    begin
        VendInvDisc."Discount %".SetValue(LibraryRandom.RandIntInRange(1, 4));
        VendInvDisc.OK().Invoke();
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
        TaxRates.AttributeValue7.SetValue(componentPerArray[1]);
        TaxRates.AttributeValue8.SetValue(componentPerArray[2]);
        TaxRates.AttributeValue9.SetValue(componentPerArray[4]);
        TaxRates.AttributeValue10.SetValue(componentPerArray[3]);
        TaxRates.OK().Invoke();
    end;
}
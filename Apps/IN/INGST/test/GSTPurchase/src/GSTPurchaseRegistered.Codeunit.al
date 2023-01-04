codeunit 18134 "GST Purchase Registered"
{
    Subtype = Test;

    var
        LibraryGST: Codeunit "Library GST";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryGSTPurchase: Codeunit "Library - GST Purchase";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        Storage: Dictionary of [Text[20], Text[20]];
        ComponentPerArray: array[10] of Decimal;
        StorageBoolean: Dictionary of [Text[20], Boolean];
        OrderAddr: Boolean;
        WithPaymentMethodCode: Boolean;
        PaymentMethodCode: Code[10];
        ErrorLbl: Label 'State Code must have a value in Vendor: No.=%1.', Comment = '%1 = Vendor No.';
        OrderAddressLbl: Label 'Order Address are not Equal', Locked = true;
        PANNoErr: Label 'PAN No. must be entered.', Locked = true;
        POSLbl: Label 'POS as Vendor State is false', locked = true;
        SupplementaryLbl: Label 'Supplementary if false', Locked = true;
        NoOfLineLbl: Label 'NoOfLine';
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo';
        LocationStateCodeLbl: Label 'LocationStateCode';
        LocationCodeLbl: Label 'LocationCode';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        VendorNoLbl: Label 'VendorNo';
        InputCreditAvailmentLbl: Label 'InputCreditAvailment';
        ExemptedLbl: Label 'Exempted';
        LineDiscountLbl: Label 'LineDiscount';
        FromStateCodeLbl: Label 'FromStateCode';
        ToStateCodeLbl: Label 'ToStateCode';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
        NotEqualLbl: Label 'Not Equal';
        InvoiceTypeLbl: Label 'InvoiceType';

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrderRegVendWithPaymentMethodCodeITCForItemIntraState()
    var
        PaymentMethod: Record "Payment Method";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LibraryERM: Codeunit "Library - ERM";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [397988] [Check if the system is calculating GST in case of Payment Method Code available with Bal. Account No. on Purchase Order]
        // [FEATURE] [Goods, Purchase Order] [ITC, Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup, Payment Method Code tax rates for Registered Vendor and GST Credit adjustment is Non Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        LibraryERM.CreatePaymentMethodWithBalAccount(PaymentMethod);
        WithPaymentMethodCode := true;
        PaymentMethodCode := PaymentMethod.Code;
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Item for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
        WithPaymentMethodCode := false;
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrderRegVendWithITCForItemIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [397988] [Check if the system is calculating GST in case of Inter-State Purchase of Services from Registered Vendor where Input Tax Credit is available through Purchase Order]
        // [FEATURE] [Goods, Purchase Order] [ITC, Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Non Available with GST group type as Goods
        OrderAddr := true;
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Item for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromGSTPurchRetOrdRegVendWithNonITCItemInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [381426] Check if system is calculating GST Amount for Registered Vendor Interstate with Goods on Purchase Return Order with Non-Availment and impact on Item Ledger Entries and Value Entries through get posted document line to reverse
        // [FEATURE] [Goods, Purchase Return Order] [ITC Non Availment, Registered Vendor, Inter-State]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Non Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line type as item for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Create and Post Purchase Return Document with Updated Reference Number
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        // [THEN] GST ledger entries are created and Verified
        VerifyValueEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrderRegVendWithNonITCItemInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [381383] Check if system is calculating GST Amount for Registered Vendor Interstate for  Goods on Purchase Order with Non-Availment 
        // [FEATURE] [Goods, Purchase Order] [ITC Non Availment, Registered Vendor, Inter-State]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Non Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line type as item for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyValueEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrderRegVendWithITCForServiceInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [353860] Check if the system is calculating GST in case of Inter-State Purchase of Services from Registered Vendor where Input Tax Credit is available through Purchase Order
        // [FEATURE] [Services, Purchase Order] [ITC, Registered Vendor, Inter-State]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Non Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as GL Account for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvRegVendWithITCForServiceInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [353865] Check if the system is calculating GST in case of Inter-State Purchase of Services from Registered Vendor where Input Tax Credit is available through Purchase Order
        // [FEATURE] [Services, Purchase Invoice] [ITC, Registered Vendor, Inter-State]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as GL Account for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvRegVendWithNonITCForServiceInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [353870] Check if the system is calculating GST in case of Inter-State Purchase of Services from Registered Vendor where Input Tax Credit is not available through Purchase Invoice
        // [FEATURE] [Services, Purchase Invoice] [ITC Non-Availment, Registered Vendor, Inter-State]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Not Available with GST group type as Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as GL Account for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdToRegVendWithServiceIntraStateNonAvailmentRCM()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [Scenario] [354139] Check if the system is calculating GST in case of Intra-State Purchase Return of Services to Registered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Return Orders
        // [FEATURE] [Services, Purchase Return Order] [ITC Non Availment, Registered Vendor]

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Not Available with GST group type as Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line Type as GL Account for Intrastate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdToRegVendWithServiceInterStateAvailmentRCM()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [Scenario] [354151] Check if the system is calculating GST in case of Inter-State Purchase Return of Services to Registered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Return Orders through copy document
        // [FEATURE] [Inter-Sate Services, Purchase Return Order] [ITC, Reverse Charge, Registered Vendor]

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, true);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line Type as GL Account for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdToRegVendWithServiceInterStateAvailmentRCMGetPosted()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [Scenario] [354152] Check if the system is calculating GST in case of Inter-State Purchase Return of Services to Registered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Return Orders through Get Posted Document Lines to Reverse
        // [FEATURE] [Inter-Sate Services, Purchase Return Order] [ITC, Reverse Charge, Registered Vendor]

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, true);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Return Order with GST and Line Type as GL Account for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToRegVendWithServiceInterStateAvailmentRCMGetPosted()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [Scenario] [354153] Check if the system is calculating GST in case of Inter-State Purchase Return of Services to Registered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Credit Memos
        // [FEATURE] [Inter-Sate Services, Purchase Credit Memo] [ITC, Reverse Charge, Registered Vendor]

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, true);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Purchase Credit Memo with GST and Line Type as GL Account for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdToRegVendWithServiceInterStateNonAvailmentRCMGetPosted()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [Scenario] [354157] Check if the system is calculating GST in case of Inter-State Purchase Return of Services to Registered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Return Orders
        // [FEATURE] [Inter-Sate Services, Purchase Return Order] [ITC Non Availment, Reverse Charge, Registered Vendor]

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Non Available with GST group type as Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, true);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order and Purchase Return order with GST and Line Type as GL Account for Interstate Transactions.
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrdRegVendWithNonITCForServiceIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [354137] Check if the system is calculating GST in case of Intra-State Purchase of Services from an Registered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Orders
        // [FEATURE] [Services, Purchase Order] [ITC Non-Availment, Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Non Available with GST group type as Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as GL Account for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvRegVendWithNonITCForServiceIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [354138] Check if the system is calculating GST in case of Intra-State Purchase of Services from an Registered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Invoices
        // [FEATURE] [Services, Purchase Invoice] [ITC Non-Availment, Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Not Available with GST group type as Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase invoice with GST and Line Type as GL Account for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchOrdRegVendWithNonITCForFAIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [354873] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase order
        // [FEATURE] [Fixed Asset, Purchase order] [ITC Non-Availment, Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Not Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase invoice with GST and Line Type as Fixed Asset for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvRegVendWithNonITCForFAIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [354876] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Invoice
        // [FEATURE] [Fixed Asset, Purchase Invoice] [ITC Non-Availment, Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Not Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase invoice with GST and Line Type as Fixed Asset for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdToRegVendWithFAInterStateAvailment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [Scenario] [354887] Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Return Orders
        // [FEATURE] [Inter-Sate Fixed Asset, Purchase Return Order] [ITC Availment, Registered Vendor]

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Invoice 
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        //[THEN]  Create and Post Purchase Return Order with GST and Line Type as Fixed for Interstate Transactions.
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToRegVendWithFAInterStateAvailment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [Scenario] [354888] Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Credit Memos
        // [FEATURE] [Inter-Sate Fixed Asset, Purchase Return Order] [ITC Availment, Registered Vendor]

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Invoice with line type as Fixed Asset
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        //[THEN]  Create and Post Purchase Credit Memo with GST and Line Type as Fixed for Interstate Transactions.
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchRetOrdToRegVendWithFAInterStateNonAvailment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [Scenario] [354903] Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Return Orders
        // [FEATURE] [Inter-Sate Fixed Asset, Purchase Return Order] [ITC Non Availment, Registered Vendor]

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Not Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Invoice as Line type as fixed asset
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        //[THEN]  Create and Post Purchase Return Order with GST and Line Type as Fixed for Interstate Transactions.
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Return Order");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToRegVendWithFAInterStateNonAvailment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [Scenario] [354904] Check if the system is calculating GST in case of Inter-State Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Credit Memos
        // [FEATURE] [Inter-Sate Fixed Asset, Purchase Credit Memo] [ITC Non Availment, Registered Vendor]

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Not Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Invoice
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        //[THEN]  Create and Post Purchase Credit Memo with GST and Line Type as Fixed for Interstate Transactions.
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler')]
    procedure PostFromPurchCrMemoToRegVendWithFAIntraStateAvailment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [Scenario] [355003] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase Return of Fixed Assets to Registered Vendor where Input Tax Credit is available with invoice discount/line discount & multiple HSN through Purchase Credit Memos
        // [FEATURE] [Intra-Sate Fixed Asset, Purchase Return Order] [ITC Availment, Registered Vendor]

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Invoice
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        //[THEN]  Create and Post Purchase Credit Memo with GST and Line Type as Fixed Asset for Intrastate Transactions.
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdToRegVendWithFAIntraStateAvailment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        // [Scenario] [354760] Check if the system is considering Discounts while calculating GST in case of Intra-State Purchase of Goods from Registered Vendor where ITC is available  through Purchase order
        // [FEATURE] [Intra-Sate Item, Purchase Order] [ITC Availment, Registered Vendor]

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvToRegVendWithFAIntraStateAvailment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        // [Scenario] [354761] Check if the system is considering Discounts while calculating GST in case of Intra-State Purchase of Goods from Registered Vendor where ITC is available through Purchase Invoice
        // [FEATURE] [Intra-Sate Item, Purchase Invoice] [ITC Availment, Registered Vendor]

        //[GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        //[WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreatePurchQuoteServicesForRegVendorWithAvailmentIntraSate()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [SCENARIO] [354758] Check if the system is considering Discounts while calculating GST in case of Intra-State Purchase of Goods from Registered Vendor where ITC is available through Purchase Quote
        // [FEATURE] [Intra-State,Goods, Purchase Quote] [ITC, Registered Vendor]

        // [GIVEN] Create GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods
        InitializeShareStep(true, false, true);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create Purchase Order from Purchase Quote with Line type as Item
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Quote);

        //Verified GST Amount and Make Quote to Order
        LibraryGSTPurchase.VerifyTaxTransactionForPurchaseQuote(PurchaseHeader);
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvSEZVendorWithoutITCLineDisForFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [355068] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from SEZ Vendor where Input Tax Credit is not available with invoice discount/line discount multiple HSN code wise through Purchase Invoice
        // [FEATURE] [Fixed Assets Purchase Invoice] [invoice discount/line discount Not ITC,SEZ Vendor]

        // [GIVEN] Created GST Setup adn Tax rates for Registered Vendor and GST Credit adjustment is Not Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, PurchaseLine.Type::"Fixed Asset", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 7);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchOrdWithITCWithMultipleHSNCode()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [354852] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order.
        // [FEATURE] [Fixed Assets Purchase Order] [Intra-State GST,Registered Vendor]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, PurchaseLine.Type::"Fixed Asset", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 5);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchInvWithITCWithMultipleHSNCode()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [354852] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order.
        // [FEATURE] [Fixed Assets Purchase Order] [Intra-State GST,Registered Vendor]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 5);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchOrdWithITCWithMultipleHSNCode()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [354852] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order.
        // [FEATURE] [Fixed Assets Purchase Order] [Intra-State GST,Registered Vendor]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineIntrastatePurchOrdWithITCRegVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [354852] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order.
        // [FEATURE] [Fixed Assets Purchase Order] [Intra-State GST,Registered Vendor]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 5);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineIntrastatePurchInvWithITCForRegVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [354861] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Invoice.
        // [FEATURE] [Fixed Assets Purchase Order] [Intra-State GST,Registered Vendor]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineInterstatePurchOrdWithITCForRegVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [354885] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order.
        // [FEATURE] [Fixed Assets Purchase Order] [InterState GST,Registered Vendor]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified 
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineInterstatePurchInvWithITCForRegVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [354886] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Invoice.
        // [FEATURE] [Fixed Assets Purchase Order] [InterState GST,Registered Vendor]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineInterstatePurchOrdWithoutITCForRegVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [354890] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase order.
        // [FEATURE] [Fixed Assets Purchase Order] [InterState GST,Registered Vendor]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Not Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Order);

        // [WHEN] G.L Entries Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 5);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineInterstatePurchInvWithoutITCTForRegVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [354891] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Invoice.
        // [FEATURE] [Fixed Assets Purchase Invoice] [InterState GST,Registered Vendor]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Not Available with GST group type as Goods
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"Fixed Asset", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntrastatePurchOrdForRegVendorbyISDWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        GSTGroupType: Enum "GST Group Type";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type";
    Begin
        // [SCENARIO] [355646] Check if the system is calculating GST in case of Intra-State Purchase of Services from Registered Vendor by Input Service Distributor where Input Tax Credit is available
        // [FEATURE] [Services Purchase Order] [Intra-State GST,Registered Vendor by Input Service Distributor(ISD)]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Not Available with GST group type as Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(true, false, false);
        UpdateInputServiceDistributer(true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineIntrastatePurchOrdForRegVendorbyISDWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [SCENARIO] [355647] Check if the system is calculating GST in case of Intra-State Purchase of Services from Registered Vendor with Multiple Lines by Input Service Distributor where Input Tax Credit is available
        // [FEATURE] [MultipleLine Services Purchase Order] [Intra-State GST,Registered Vendor by Input Service Distributor(ISD)]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Available with GST group type as Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(true, false, false);
        UpdateInputServiceDistributer(true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", PurchaseHeader."Document Type"::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchOrdRegVendorbyISDWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [SCENARIO] [355648] Check if the system is calculating GST in case of Intra-State Purchase of Services from Registered Vendor by Input Service Distributor where Input Tax Credit is not available
        // [FEATURE] [Services Purchase Order] [Intra-State GST,Registered Vendor by Input Service Distributor(ISD) Input Tax Credit is not available  ]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Not Available with GST group type as Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        UpdateInputServiceDistributer(true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchOrdMultipleLineRegVendorbyISDWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Purchase Document Type";
    Begin
        // [SCENARIO] [355649] Check if the system is calculating GST in case of Intra-State Purchase of Services from Registered Vendor with Multiple lines by Input Service Distributor where Input Tax Credit is not available
        // [FEATURE] [MultipleLine Services Purchase Invoice] [Intra-State GST,Registered Vendor by Input Service Distributor(ISD) and Input Tax Credit is not available ]

        // [GIVEN] Created GST Setup for Registered Vendor and GST Credit adjustment is Not Available with GST group type as Service
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        UpdateInputServiceDistributer(true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [355650] Check if the system is calculating GST in case of Inter-State Purchase of Services from Registered Vendor by Input Service Distributor where Input Tax Credit is available
    // [FEATURE] [Services Purchase Invoice] [Inter-State GST,Registered Vendor by Input Service Distributor(ISD)]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchOrdRegVendorbyISDWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        UpdateInputServiceDistributer(true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [355651] Check if the system is calculating GST in case of Inter-State Purchase of Services from Registered Vendor with Multiple Lines by Input Service Distributor where Input Tax Credit is available
    // [FEATURE] [MultipleLine Services Purchase Order] [Inter-State GST,Registered Vendor by Input Service Distributor(ISD)]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchOrdMultipleLineRegVendorbyISDWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Purchase Document Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        UpdateInputServiceDistributer(true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [355652] Check if the system is calculating GST in case of Inter-State Purchase of Services from Registered Vendor by Input Service Distributor where Input Tax Credit is not available
    // [FEATURE] [Services Purchase Order] [Inter-State GST,Registered Vendor by Input Service Distributor(ISD) Input Tax Credit is not available  ]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchOrdRegVendorbyISDWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Purchase Document Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        UpdateInputServiceDistributer(true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [355653] Check if the system is calculating GST in case of Inter-State Purchase of Services from Registered Vendor with multiple lines by Input Service Distributor where Input Tax Credit is not available
    // [FEATURE] [MultipleLine Services Purchase Invoice] [Inter-State GST,Registered Vendor by Input Service Distributor(ISD) and Input Tax Credit is not available ]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchInvMultipleLineRegVendorbyISDWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Purchase Document Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        UpdateInputServiceDistributer(true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [354764] Check if the system is considering Discounts while calculating GST in case of Intra-State Purchase of Services from Registered vendor where ITC is available through Purchase Quote
    // [FEATURE] [Discounts Services Purchase Quote] [Intra-State GST,Registered Vendor Input Tax Credit is available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchaseServicesQuoteWithDiscRegVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        OrderNo: code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Purchase Document Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(true, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Quote);

        //Make Quote to Order
        OrderNo := LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
        LibraryGST.VerifyTaxTransactionForPurchase(OrderNo, DocumentType::Order);
    end;

    // [SCENARIO] [354765] Check if the system is considering Discounts while calculating GST in case of Intra-State Purchase of Services from Registered vendor where ITC is available through Purchase Order
    // [FEATURE] [Discounts Services Purchase Order] [Intra-State GST,Registered Vendor Input Tax Credit is not available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchaseServicesOrdereWithDiscRegVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Purchase Document Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(true, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    // [SCENARIO] [354766] Check if the system is considering Discounts while calculating GST in case of Intra-State Purchase of Services from Registered vendor where ITC is available through Purchase Invoice
    // [FEATURE] [Discounts Services Purchase Invoice] [Intra-State GST,Registered Vendor Input Tax Credit is not available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchaseServicesInvoiceWithDiscRegVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(true, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    // [SCENARIO] [354767] Check if the system is considering Discounts while calculating GST in case of Inter-State Purchase of Goods from Registered Vendor where ITC is avalable through Purchase Quote
    // [FEATURE] [Discounts Goods Purchase Quote] [Intra-State GST,Registered Vendor Input Tax Credit is available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchaseQuoteGoodsWithDiscRegVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        OrderNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Purchase Document Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            PurchaseHeader."Document Type"::Quote);

        //Make Quote to Order
        OrderNo := LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
        LibraryGST.VerifyTaxTransactionForPurchase(OrderNo, DocumentType::Order);
    end;
    // [SCENARIO] [354768] Check if the system is considering Discounts while calculating GST in case of Inter-State Purchase of Goods from Registered Vendor where ITC is avalable through Purchase order
    // [FEATURE] [Discounts Goods Purchase Order] [Intra-State GST,Registered Vendor Input Tax Credit is available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchOrdeGoodsWithDiscRegVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            PurchaseHeader."Document Type"::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354769] Check if the system is considering Discounts while calculating GST in case of Inter-State Purchase of Goods from Registered Vendor where ITC is avalable through Purchase Invoice
    // [FEATURE] [Discounts Goods Purchase Invoice] [Intra-State GST,Registered Vendor Input Tax Credit is not available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchaseInvoiceGoodsWithDiscRegVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            PurchaseHeader."Document Type"::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354852] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order.
    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchaseOrderWithITCWithMultipleHSNCodeWiseForIntraState()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);

        // [WHEN] Create and Post Purchase Order with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');

        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354861] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Invoice.
    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithITCWithMultipleHSNCodeWiseForIntraState()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Purchase Invoice with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354885] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchaseOrderWithITCWithMultipleHSNCode()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Purchase Order with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [354886] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Invoice.
    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchInvWithITCWithMultipleHSNCodeWise()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Purchase Invoice with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [354890] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Order.
    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchOrdWithoutITCWithMultipleHSNCode()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Purchase Order with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354891] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Invoice.
    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchInvWithoutITCWithMultipleHSNCode()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Purchase Invoice with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [353800] Intra-State/Intra-Union Territory Purchase of Services from Registered Vendor where Input Tax Credit is not available through Purchase Quote.
    // [FEATURE] [Service Purchase Quote] [Intra-State GST,Registered Vendor Input Tax Credit is not available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchaseServicesQuoteForRegVendorWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        OrderNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Purchase Document Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Created Purchase Quote with GST and Line Type as G/L Account for Intrastate Transactions.
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Quote);

        //Make Quote to Order
        OrderNo := LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
        LibraryGST.VerifyTaxTransactionForPurchase(OrderNo, DocumentType::Order);
    end;

    // [SCENARIO] [353803] Intra-State/Intra-Union Territory Purchase of Services from Registered Vendor where Input Tax Credit is not available through Purchase Order.
    // [FEATURE] [Service Purchase Order] [Intra-State GST,Registered Vendor Input Tax Credit is not available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchaseServicesOrderForRegVendorWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as GLAccount for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [353868] Check if the system is calculating GST in case of Inter-State Purchase of Services from Registered Vendor where Input Tax Credit is not available through Purchase Quote.
    // [FEATURE] [Service Purchase Quote] [Inter-State GST,Registered Vendor Input Tax Credit is not available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterstatePurchaseServicesQuoteForRegVendorWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Created Purchase Quote with GST and Line Type as GLAccount for Interstate Transactions.
        DocumentNo := CreatePurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Quote);

        // [THEN] Quote to Make Order
        LibraryGST.VerifyTaxTransactionForPurchase(DocumentNo, PurchaseLine."Document Type");
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [353869] Check if the system is calculating GST in case of Inter-State Purchase of Services from Registered Vendor where Input Tax Credit is not available through Purchase order.
    // [FEATURE] [Service Purchase Order] [Inter-State GST,Registered Vendor Input Tax Credit is not available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterstatePurchaseServicesOrderForRegVendorWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as GLAccount for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [353838] Check if the system is calculating GST in case of Inter-State Purchase of Goods from Registered Vendor where Input Tax Credit is not available through Purchase Quotes.
    // [FEATURE] [Goods Purchase Quote] [Inter-State GST,Registered Vendor Input Tax Credit is not available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterstatePurchaseGoodsQuoteForRegVendorWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Created Purchase Quote with GST and Line Type as GLAccount for Interstate Transactions.
        DocumentNo := CreatePurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Quote);

        // [THEN] Quote to Make Order
        LibraryGST.VerifyTaxTransactionForPurchase(DocumentNo, PurchaseLine."Document Type");
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [353839] Check if the system is calculating GST in case of Inter-State Purchase of Goods from Registered Vendor where Input Tax Credit is not available through Purchase Orders.
    // [FEATURE] [Goods Purchase Order] [Inter-State GST,Registered Vendor Input Tax Credit is not available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterstatePurchaseGoodsOrderForRegVendorWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as GLAccount for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [353804] Intra-State/Intra-Union Territory Purchase of Services from Registered Vendor where Input Tax Credit is not available through Purchase Invoice.
    // [FEATURE] [Service Purchase Invoice] [Intra-State GST,Registered Vendor Input Tax Credit is not available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchaseServicesInvoiceForRegVendorWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as GLAccount for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [353815] Check if the system is calculating GST in case of Inter-State Purchase of Goods from Registered Vendor where Input Tax Credit is available through Purchase Quote.
    // [FEATURE] [Goods Purchase Quote] [Intra-State GST,Registered Vendor Input Tax Credit is available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterstatePurchaseGoodsQuoteForRegVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Created Purchase Quote with GST and Line Type as Item for Interstate Transactions.
        DocumentNo := CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            PurchaseHeader."Document Type"::Quote);

        // [THEN] Quote to Make Order
        LibraryGST.VerifyTaxTransactionForPurchase(DocumentNo, PurchaseLine."Document Type");
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [353816] Check if the system is calculating GST in case of Inter-State Purchase of Goods from Registered Vendor where Input Tax Credit is available through Purchase Order.
    // [FEATURE] [Goods Purchase Order] [Inter-State GST,Registered Vendor Input Tax Credit is available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterstatePurchaseGoodsOrderForRegVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Item for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            PurchaseHeader."Document Type"::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [353817] Check if the system is calculating GST in case of Inter-State Purchase of Goods from Registered Vendor where Input Tax Credit is available through Purchase Invoice.
    // [FEATURE] [Goods Purchase Invoice] [Inter-State GST,Registered Vendor Input Tax Credit is available]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterstatePurchaseGoodsInvoiceForRegVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Item for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            PurchaseHeader."Document Type"::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    // [SCENARIO] [353781] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase of Goods from Registered Vendor where Input Tax Credit is not available through Purchase Quotes
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreatePurchaseOrderFromQuoteForGoodsRegisteredWithoutITCIntraState()
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
        InitializeShareStep(false, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);

        // [WHEN] Create Purchase Order from Purchase Quote
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Quote);

        //Make Quote to Order
        OrderNo := LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
        LibraryGST.VerifyTaxTransactionForPurchase(OrderNo, DocumentType::Order);
    end;

    // [SCENARIO] [353782] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase of Goods from Registered Vendor where Input Tax Credit is not available through Purchase Orders
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseOrderForRegisteredWithoutITCIntraSate()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);

        // [WHEN] Create Purchase Order
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    // [SCENARIO] [353755] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Goods from Registered Vendor where Input Tax Credit is available through Purchase Invoice Type-Debit Note
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseInvoiceForRegisteredWithDebitNoteAvailmentIntraSate()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
        InvoiceType: Enum "GST Invoice Type";
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        SetStorageLibraryPurchaseText(InvoiceTypeLbl, format(InvoiceType::"Debit Note"));

        // [WHEN] Create and Post Purchase Invoice
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
        SetStorageLibraryPurchaseText(InvoiceTypeLbl, '');
    end;

    // [SCENARIO] [353783] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase of Goods from Registered Vendor where Input Tax Credit is not available through Purchase Invoice
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchaseInvoiceForRegVendorWithoutITC()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Purchase Invoice
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    // [SCENARIO] [353774] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Service from Registered Vendor where Input Tax Credit is available through Purchase Invoice Type-Supplementary 
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchInvForRegisteredWithSupplementaryAvailment()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
        InvoiceType: Enum "GST Invoice Type";
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        SetStorageLibraryPurchaseText(InvoiceTypeLbl, format(InvoiceType::Supplementary));

        // [WHEN] Create and Post Purchase Invoice
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
        SetStorageLibraryPurchaseText(InvoiceTypeLbl, '');
    end;

    // [SCENARIO] [353786] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase of Services from Registered Vendor where Input Tax Credit is available through Purchase Order
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchOrdForRegVendorWithITC()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post Purchase Order
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    // [SCENARIO] [353789] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase of Services from Registered Vendor where Input Tax Credit is available through Purchase Quote
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreatePurchOrdFromQuoteForServiceRegVendorWithoutITCIntraSate()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);

        // [WHEN] Create Purchase Order From Quote
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Quote);

        //Make Quote to Order
        OrderNo := LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
        LibraryGST.VerifyTaxTransactionForPurchase(OrderNo, DocumentType::Order);
    end;

    // [SCENARIO] [353784] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase of Goods from Registered Vendor where Input Tax Credit is not available through Purchase Invoice Type-Debit Note
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchInvForRegVendorWithDebitNoteWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
        InvoiceType: Enum "GST Invoice Type";
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(false, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        SetStorageLibraryPurchaseText(InvoiceTypeLbl, format(InvoiceType::"Debit Note"));

        // [WHEN] Create and Post Purchase Journal
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
        SetStorageLibraryPurchaseText(InvoiceTypeLbl, '');
    end;

    // [SCENARIO] [353790] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase of Goods from Registered Vendor where Input Tax Credit is not available through Purchase Orders
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchInvForServiceRegisteredWithITC()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post Purchase Journal
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    // [SCENARIO] [353537] [Check After Change Pay to Vendor on Purchase Header]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ChangeVendor')]
    procedure CheckAfterChangePaytoVendorOnPurchaseHeader()
    var
        PurchaseHeader: Record "Purchase Header";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        PurchaseInvoiceType: enum "GST Invoice Type";
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create  Purchase Order
        DocumentType := DocumentType::Order;
        CreatePurchaseHeaderWithGST(
            PurchaseHeader,
            format(Storage.Get(VendorNoLbl)),
            DocumentType,
            format(Storage.Get(LocationCodeLbl)),
            PurchaseInvoiceType::" ");

        // [WHEN] Vendor is Changed in Purchase Order
        PurchaseHeader.Validate("Buy-from Vendor No.", LibraryGST.CreateVendorSetup());
        PurchaseHeader.Modify(true);
    end;

    // [SCENARIO] [357174]	[Check on purchase line, update type, no. and Qty]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckOnPurchaseLineUpdateTypeNumberandQty()
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

        // [WHEN] Create  Purchase Invoice
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);
        PurchaseLine.Validate(Quantity, LibraryRandom.RandInt(10));
        PurchaseLine.Modify(true);
    end;

    // [SCENARIO] [356402] [Check  after Change order Address on purchase header document]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckAfterChangeOrderAddressOnPurchaseHeaderDocument()
    var
        PurchaseHeader: Record "Purchase Header";
        OrderAddress: Record "Order Address";
        PurchaseLine, PurchaseLine2 : Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create  Purchase Order
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);
        LibraryPurchase.CreateOrderAddress(OrderAddress, PurchaseHeader."Buy-from Vendor No.");
        OrderAddress.Validate("ARN No.", Format(Random(20)));
        OrderAddress.Modify(true);
        PurchaseHeader.Validate("Order Address Code", OrderAddress.Code);
        PurchaseHeader.Modify(true);
        PurchaseLine2.Reset();
        PurchaseLine2.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine2.SetRange("Document Type", PurchaseLine2."Document Type"::"Invoice");
        PurchaseLine2.FindFirst();
        Assert.AreEqual(PurchaseHeader."Order Address Code", PurchaseLine2."Order Address Code", OrderAddressLbl);
    end;

    // [SCENARIO] [356418]	[Check after change Invoice type on header]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckAfterChangeInvoiceTypeOnHeader()
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

        // [WHEN] Create  Purchase Order with validation
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);
        PurchaseHeader.Validate("Invoice Type", PurchaseHeader."Invoice Type"::"Non-GST");
        PurchaseHeader.Validate("GST Invoice", false);
        PurchaseHeader.Modify(true);
    end;

    // [SCENARIO] [356419]	[Check after Change GST Group on line]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckAfterChangeGSTGroupOnLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LibraryAssert: Codeunit "Library Assert";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create  Purchase Order with validation
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);
        PurchaseLine.SetFilter("GST Group Code", '<>%1', '');
        LibraryAssert.RecordIsNotEmpty(PurchaseLine);
    end;

    // [SCENARIO] [356420] [Check Change Exempted on Purchase line]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckChangeExemptedOnPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LibraryAssert: Codeunit "Library Assert";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create  Purchase Order with validation
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);
        PurchaseLine.Validate(Exempted, true);
        PurchaseLine.Modify(true);
        LibraryAssert.IsTrue(PurchaseLine.Exempted, NotEqualLbl);
    end;

    // [SCENARIO] [356428] [Check Validation for Custom Duty Amount and Assessable Value on Purchase line.]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckValidationForCustomDutyAmountandAssessableValueOnPurchaseLine()
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
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);

        // [WHEN] Create  Purchase Order with validation
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);
        PurchaseLine.Validate("GST Assessable Value", 0.0);
        PurchaseLine.Modify(true);
    end;

    // [SCENARIO] [357173] [Check if change invoice type then document should be open and Invoice type - supplementary, updated on line also.]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckInvoiceTypeSupplementaryPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine, PurchaseLine2 : Record "Purchase Line";
        LibraryAssert: Codeunit "Library Assert";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Goods, false, false);

        // [WHEN] Create  Purchase Order with validation
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);
        PurchaseHeader.Validate("Invoice Type", PurchaseHeader."Invoice Type"::Supplementary);
        PurchaseHeader.Modify(true);
        PurchaseLine2.Reset();
        PurchaseLine2.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine2.SetRange("Document Type", PurchaseLine2."Document Type"::"Invoice");
        PurchaseLine2.FindFirst();
        LibraryAssert.IsTrue(PurchaseLine2.Supplementary, SupplementaryLbl);
    end;

    // [SCENARIO] [356400] [Check After change Location Code and POS on Purchase Header]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckAfterChangeLocationCodeAndPOSonPurchaseHeader()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LibraryAssert: Codeunit "Library Assert";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Create GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);

        // [WHEN] Create  Purchase Order with validation
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::"G/L Account", DocumentType::Invoice);
        PurchaseHeader.Validate("POS as Vendor State", true);
        PurchaseHeader.Modify(true);
        LibraryAssert.IsTrue(PurchaseHeader."POS as Vendor State", POSlbl);
    end;

    // [SCENARIO] [356317] [Check Vendor related validation as PAN No, Registration No. GST Vendor type, Vendor State Code etc.]
    [Test]
    procedure CheckVendorRelatedValidations()
    var
        Vendor: Record Vendor;
        LibraryAssert: Codeunit "Library Assert";
    begin
        Vendor.Reset();
        Vendor.Get(LibraryGST.CreateVendorSetup());
        asserterror Vendor.Validate("GST Registration No.", Format(Random(15)));
        LibraryAssert.ExpectedError(StrSubstNo(ErrorLbl, Vendor."No."));
        Vendor.Reset();
        Vendor.Get(LibraryGST.CreateVendorSetup());
        Vendor.Validate("State Code", LibraryGST.CreateGSTStateCode());
        Vendor.Modify(true);
        asserterror Vendor.Validate("GST Registration No.", Format(Random(15)));
        LibraryAssert.ExpectedError(PANNoErr);
    end;

    // [SCENARIO] [354996]	[Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with invoice discount/line discount and multiple HSN code wise. through Purchase order]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchaseOrderForFAWithITC()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Purchase Order with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    // [SCENARIO] [354999]	[Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with invoice discount/line discount and multiple HSN code wise through Purchase Invoice]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchInvForFAWithITCWithLineDisc()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Purchase Invoice with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    // [SCENARIO] [355004]	[Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is not available with invoice discount/line discount & multiple HSN code wise through Purchase order]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchOrdForFAWithLineDisc()
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
        InitializeShareStep(false, false, true);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Purchase Order with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 8);
    end;

    // [SCENARIO] [355005]	[Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is not available with invoice discount/line discount&multiple HSN code wise through Purchase Invoice]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchInvForFAWithLineDisc()
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
        InitializeShareStep(false, false, true);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Purchase Invoice with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 8);
    end;

    // [SCENARIO] [355008]	[Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with invoice discount/line discount and multiple HSN code wise through Purchase order]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchOrdForFAWithLineDiscWithITC()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Purchase Order with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [355009]	[Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with invoice discount/line discount and multiple HSN code wise through Purchase Invoice]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchInvForFAWithLineDiscWithITC()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Purchase Invoice with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [355036]	[Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is not available with invoice discount/line discount and multiple HSN code wise through Purchase order]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchOrdForFAWithLineDiscWithoutITC()
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
        InitializeShareStep(false, false, true);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Order Invoice with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    // [SCENARIO] [355037]	[Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is not available with invoice discount/line discount and multiple HSN code wise through Purchase Invoice]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchInvForFAWithLineDiscWithoutITC()
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
        InitializeShareStep(false, false, true);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Purchase Invoice with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    // [SCENARIO] [353747]	[Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Goods from Registered Vendor where Input Tax Credit is available through Purchase order]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchInvGoodsForRegVendor()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Purchase Order with Fixed Asset
        SetStorageLibraryPurchaseText(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [353749] [Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Goods from Registered Vendor where Input Tax Credit is available through Purchase Quote]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntrastatePurchaseGoodsQuoteForRegVendorWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Created Purchase Quote with GST and Line Type as GLAccount for Intrastate Transactions.
        DocumentNo := CreatePurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            PurchaseHeader."Document Type"::Quote);

        // [THEN] Quote to Make Order
        LibraryGST.VerifyTaxTransactionForPurchase(DocumentNo, PurchaseLine."Document Type");
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [353859] Check if the system is calculating GST in case of Inter-State Purchase of Services from Registered Vendor where Input Tax Credit is available through Purchase Quotes
    // [FEATURE] [Purchase Quote] [Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseQuoteRegisterdVendorWithoutITCForItem()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeShareStep(true, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Created Purchase Quote with GST and Line Type as G/L Account for Interstate Transactions.
        DocumentNo := CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForPurchase(DocumentNo, PurchaseLine."Document Type");
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [353840] Check if the system is calculating GST in case of Inter-State Purchase of Goods from Registered Vendor where Input Tax Credit is not available through Purchase Invoice
    // [FEATURE] [Purchase Invoice] [Without ITC Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseInvoiceRegisterdVendorWithoutITCForItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PostedInvoiceNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset for Interstate Transactions.
        PostedInvoiceNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        SetStorageLibraryPurchaseText(PostedDocumentNoLbl, PostedInvoiceNo);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, PostedInvoiceNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGSTPurchInvRegVendWithNonITCForServiceInterStateForDCA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [459354] Difference in DCA and Purchase Account Balance in case of GST Non-Availment
        // [FEATURE] [Goods, Purchase Invoice] [ITC Non-Availment, Registered Vendor, Inter-State]

        // [GIVEN] Created GST Setup and tax rates for Registered Vendor and GST Credit adjustment is Not Available with GST group type as Item
        CreateGeneralLedgerSetup();
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        SetStorageLibraryPurchaseText(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Item for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
        VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    local procedure CreateGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup."Inv. Rounding Precision (LCY)" := 1;
        GeneralLedgerSetup."Inv. Rounding Type (LCY)" := GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Nearest;
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
        SetStorageLibraryPurchaseText(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true)
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        SetStorageLibraryPurchaseText(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::"Bill-to Address", ReverseCharge);
        SetStorageLibraryPurchaseText(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        SetStorageLibraryPurchaseText(HSNSACCodeLbl, HSNSACCode);

        if IntraState then begin
            VendorNo := LibraryGST.CreateVendorSetup();
            LibraryGSTPurchase.UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, LocationStateCode, LocPANNo);
            InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
        end else begin
            VendorStateCode := LibraryGST.CreateGSTStateCode();
            VendorNo := LibraryGST.CreateVendorSetup();
            LibraryGSTPurchase.UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, VendorStateCode, LocPANNo);

            if GSTVendorType in [GSTVendorType::Import, GSTVendorType::SEZ] then
                InitializeTaxRateParameters(IntraState, '', LocationStateCode)
            else
                InitializeTaxRateParameters(IntraState, VendorStateCode, LocationStateCode);
        end;
        SetStorageLibraryPurchaseText(VendorNoLbl, VendorNo);

        CreateTaxRate();
        LibraryGSTPurchase.CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
    end;

    local procedure InitializeShareStep(InputCreditAvailment: Boolean; Exempted: Boolean; LineDiscount: Boolean)
    begin
        SetStorageBooleanLibraryPurchaseText(InputCreditAvailmentLbl, InputCreditAvailment);
        SetStorageBooleanLibraryPurchaseText(ExemptedLbl, Exempted);
        SetStorageBooleanLibraryPurchaseText(LineDiscountLbl, LineDiscount);
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
        NoOfLine: Integer;
    begin
        Evaluate(VendorNo, Storage.Get(VendorNoLbl));
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        Evaluate(NoOfLine, Storage.Get(NoOfLineLbl));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        CreatePurchaseLineWithGST(
            PurchaseHeader,
            PurchaseLine,
            LineType,
            StorageBoolean.Get(InputCreditAvailmentLbl),
            StorageBoolean.Get(ExemptedLbl),
            StorageBoolean.Get(LineDiscountLbl),
            NoOfLine);

        if not (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Quote) then begin
            DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
            SetStorageLibraryPurchaseText(PostedDocumentNoLbl, DocumentNo);
            exit(DocumentNo);
        end;
    end;

    local procedure CreatePurchaseDocument(var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type"): Code[20]
    var
        VendorNo: Code[20];
        LocationCode: Code[10];
        PurchaseInvoiceType: Enum "GST Invoice Type";
        NoOfLine: Integer;
    begin
        Evaluate(VendorNo, Storage.Get(VendorNoLbl));
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        Evaluate(NoOfLine, Storage.Get(NoOfLineLbl));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        CreatePurchaseLineWithGST(
            PurchaseHeader,
            PurchaseLine,
            LineType,
            StorageBoolean.Get(InputCreditAvailmentLbl),
            StorageBoolean.Get(ExemptedLbl),
            StorageBoolean.Get(LineDiscountLbl),
            NoOfLine);
        exit(PurchaseHeader."No.");
    end;

    local procedure UpdateInputServiceDistributer(InputServiceDistribute: Boolean)
    var
        LocationCod: Code[10];
    begin
        LocationCod := CopyStr(Storage.Get(LocationCodeLbl), 1, 10);
        LibraryGST.UpdateLocationWithISD(LocationCod, InputServiceDistribute);
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

    local procedure VerifyGSTEntries(DocumentNo: Code[20]; TableID: Integer)
    begin
        LibraryGSTPurchase.VerifyGSTEntries(DocumentNo, TableID, ComponentPerArray);
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
        LibraryGSTPurchase.UpdateReferenceInvoiceNoAndVerify(PurchaseHeader, (Storage.Get(PostedDocumentNoLbl)));

        ReverseDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        SetStorageLibraryPurchaseText(ReverseDocumentNoLbl, ReverseDocumentNo);
    end;

    procedure CreatePurchaseHeaderWithGST(
            VAR PurchaseHeader: Record "Purchase Header";
            VendorNo: Code[20];
            DocumentType: Enum "Purchase Document Type";
            LocationCode: Code[10];
            PurchaseInvoiceType: Enum "GST Invoice Type")
    var
        OrderAddress: Record "Order Address";
        LibraryUtility: Codeunit "Library - Utility";
        Overseas: Boolean;
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Location Code", LocationCode);

        if OrderAddr then
            PurchaseHeader.Validate("Order Address Code", LibraryGST.CreateOrderAddress(OrderAddress, VendorNo));

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

        if WithPaymentMethodCode then
            PurchaseHeader.Validate("Payment Method Code", PaymentMethodCode);

        PurchaseHeader.Modify(true);
    end;

    procedure CreatePurchaseLineWithGST(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
                      InputCreditAvailment: Boolean;
                      Exempted: Boolean;
                      LineDiscount: Boolean;
                      NoOfLine: Integer);
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LineTypeNo: Code[20];
        LineNo: Integer;
    begin
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

            LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, LineType, LineTypeno, LibraryRandom.RandDecInRange(2, 10, 0));

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

    [ConfirmHandler]
    procedure ChangeVendor(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
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
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]); //SGST
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]); //CGST
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[3]); //IGST
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[4]); //KFloodCess
        TaxRates.AttributeValue11.SetValue('');
        TaxRates.AttributeValue12.SetValue('');
        TaxRates.OK().Invoke();
    end;
}
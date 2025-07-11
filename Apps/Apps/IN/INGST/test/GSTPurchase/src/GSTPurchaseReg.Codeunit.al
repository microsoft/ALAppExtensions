codeunit 18139 "GST Purchase Reg"
{
    Subtype = Test;

    var
        LibraryGST: Codeunit "Library GST";
        LibraryPurchase: Codeunit "Library - Purchase";
        Storage: Dictionary of [Text, Text];
        ComponentPerArray: array[20] of Decimal;
        StorageBoolean: Dictionary of [Text, Boolean];
        ErrorLbl: Label 'State Code must have a value in Vendor: No.=%1.', Comment = '%1 = Vendor No.';
        OrderAddressLbl: Label 'Order Address are not Equal', Locked = true;
        PANNoErr: Label 'PAN No. must be entered.', Locked = true;
        POSLbl: Label 'POS as Vendor State is false';
        SupplementaryLbl: Label 'Supplementary if false', Locked = true;
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
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
        NotEqualLbl: Label 'Not Equal';
        InvoiceTypeLbl: Label 'InvoiceType';

    // [SCENARIO] [355068] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from SEZ Vendor where Input Tax Credit is not available with invoice discount/line discount multiple HSN code wise through Purchase Invoice
    // [FEATURE] [Fixed Assets Purchase Invoice] [invoice discount/line discount Not ITC,SEZ Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvSEZVendorWithoutITCWithLineDiscForFA()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            PurchaseLine.Type::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 7);
    end;

    // [SCENARIO] [354852] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order.
    // [FEATURE] [Fixed Assets Purchase Order] [Intra-State GST,Registered Vendor]
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
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            PurchaseLine.Type::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354852] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order.
    // [FEATURE] [Fixed Assets Purchase Order] [Intra-State GST,Registered Vendor]
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
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354852] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order.
    // [FEATURE] [Fixed Assets Purchase Order] [Intra-State GST,Registered Vendor]
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
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [354852] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order.
    // [FEATURE] [Fixed Assets Purchase Order] [Intra-State GST,Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineIntraStatePurchOrdWithITCForRegVendor()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354861] Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Invoice.
    // [FEATURE] [Fixed Assets Purchase Order] [Intra-State GST,Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineIntraStatePurchInvWithITCForRegVendor()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354885] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase order.
    // [FEATURE] [Fixed Assets Purchase Order] [InterState GST,Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineInterStatePurchOrdWithITCForRegVendor()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified 
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [354886] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with multiple HSN code wise through Purchase Invoice.
    // [FEATURE] [Fixed Assets Purchase Order] [InterState GST,Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineInterStatePurchInvWithITCForRegVendor()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [354890] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase order.
    // [FEATURE] [Fixed Assets Purchase Order] [InterState GST,Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineInterStatePurchOrdWithoutITCForRegVendor()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [WHEN] G.L Entries Verified
        LibraryGST.VerifyGLEntries(Enum::"Gen. Journal Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [354891] Check if the system is calculating GST in case of Inter-State Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is not available with multiple HSN code wise through Purchase Invoice.
    // [FEATURE] [Fixed Assets Purchase Invoice] [InterState GST,Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromMultiLineInterStatePurchInvWithoutITCRegVendor()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [355646] Check if the system is calculating GST in case of Intra-State Purchase of Services from Registered Vendor by Input Service Distributor where Input Tax Credit is available
    // [FEATURE] [Services Purchase Order] [Intra-State GST,Registered Vendor by Input Service Distributor(ISD)]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchOrdRegisteredVendorbyISDWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        GSTGroupType: Enum "GST Group Type";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type";
    Begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(true, false, false);
        UpdateInputServiceDistributer(true, true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [355647] Check if the system is calculating GST in case of Intra-State Purchase of Services from Registered Vendor with Multiple Lines by Input Service Distributor where Input Tax Credit is available
    // [FEATURE] [MultipleLine Services Purchase Order] [Intra-State GST,Registered Vendor by Input Service Distributor(ISD)]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchOrdMultipleLineRegVendorbyISDWithITC()
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
        InitializeShareStep(true, false, false);
        UpdateInputServiceDistributer(true, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [355648] Check if the system is calculating GST in case of Intra-State Purchase of Services from Registered Vendor by Input Service Distributor where Input Tax Credit is not available
    // [FEATURE] [Services Purchase Order] [Intra-State GST,Registered Vendor by Input Service Distributor(ISD) Input Tax Credit is not available  ]
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
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        UpdateInputServiceDistributer(true, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [355649] Check if the system is calculating GST in case of Intra-State Purchase of Services from Registered Vendor with Multiple lines by Input Service Distributor where Input Tax Credit is not available
    // [FEATURE] [MultipleLine Services Purchase Invoice] [Intra-State GST,Registered Vendor by Input Service Distributor(ISD) and Input Tax Credit is not available ]
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
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(false, false, false);
        UpdateInputServiceDistributer(true, false);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
    end;

    // [SCENARIO] [355650] Check if the system is calculating GST in case of Inter-State Purchase of Services from Registered Vendor by Input Service Distributor where Input Tax Credit is available
    // [FEATURE] [Services Purchase Invoice] [Inter-State GST,Registered Vendor by Input Service Distributor(ISD)]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchOrdRegisteredVendorbyISDWithITC()
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
        UpdateInputServiceDistributer(true, true);
        Storage.Set(NoOfLineLbl, '1');

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
    procedure PostFromMultiLineInterStatePurchOrdRegVendorbyISDWithITC()
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
        UpdateInputServiceDistributer(true, true);
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    // [SCENARIO] [355652] Check if the system is calculating GST in case of Inter-State Purchase of Services from Registered Vendor by Input Service Distributor where Input Tax Credit is not available
    // [FEATURE] [Services Purchase Order] [Inter-State GST,Registered Vendor by Input Service Distributor(ISD) Input Tax Credit is not available  ]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromInterStatePurchOrdRegisteredVendorbyISDWithoutITC()
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
        UpdateInputServiceDistributer(true, false);
        Storage.Set(NoOfLineLbl, '1');

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
    procedure PostFromMultiLineInterStatePurchInvRegVendorbyISDWithoutITC()
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
        UpdateInputServiceDistributer(true, false);
        Storage.Set(NoOfLineLbl, '2');

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
        OrderNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Purchase Document Type";
    begin
        // [GIVEN] Created GST Setup 
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeShareStep(true, false, true);
        Storage.Set(NoOfLineLbl, '2');

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
        Storage.Set(NoOfLineLbl, '2');

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
        Storage.Set(NoOfLineLbl, '2');

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
        Storage.Set(NoOfLineLbl, '2');

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
        Storage.Set(NoOfLineLbl, '2');

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
    procedure PostFromIntraStatePurchInvGoodsWithDiscRegVendorWithITC()
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
        Storage.Set(NoOfLineLbl, '2');

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
    procedure PostFromIntraStatePurchOrdWithITCWithMultipleHSNCodeWise()
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
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with Fixed Asset
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
    procedure PostFromIntraStatePurchInvWithITCWithMultipleHSNCodeWise()
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
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with Fixed Asset
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
    procedure PostFromInterStatePurchOrdWithITCWithMultipleHSNCodeWise()
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
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with Fixed Asset
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
    procedure PostFromInterStatePurchInvWithITCWithMultipleHSNCode()
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
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with Fixed Asset
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
    procedure PostFromInterStatePurchOrdWithoutITCWithMultipleHSNCodeWise()
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
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Order with Fixed Asset
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
    procedure PostFromInterStatePurchInvWithoutITCWithMultipleHSNCodeWise()
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
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create and Post Purchase Invoice with Fixed Asset
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
    procedure PostFromIntrastatePurchaseServicesQuoteForRegVendorWithoutITC()
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
        Storage.Set(NoOfLineLbl, '1');

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
    procedure PostFromIntrastatePurchaseServicesOrderForRegVendorWithoutITC()
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
        Storage.Set(NoOfLineLbl, '1');

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
        Storage.Set(NoOfLineLbl, '1');

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
        Storage.Set(NoOfLineLbl, '1');

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
        Storage.Set(NoOfLineLbl, '1');

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
        Storage.Set(NoOfLineLbl, '1');

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
    procedure PostFromIntrastatePurchaseServicesInvoiceForRegVendorWithoutITC()
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
        Storage.Set(NoOfLineLbl, '1');

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
        Storage.Set(NoOfLineLbl, '1');

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
        Storage.Set(NoOfLineLbl, '1');

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
        Storage.Set(NoOfLineLbl, '1');

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
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Purchase Order from Purchase Quote
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
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Purchase Order
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
    procedure PostFromIntraStatePurchInvForRegVendorWithDebitNoteAvailment()
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
        Storage.Set(InvoiceTypeLbl, format(InvoiceType::"Debit Note"));
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
        Storage.Set(InvoiceTypeLbl, '');
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
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice
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
        Storage.Set(InvoiceTypeLbl, format(InvoiceType::Supplementary));
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
        Storage.Set(InvoiceTypeLbl, '');
    end;

    // [SCENARIO] [353786] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase of Services from Registered Vendor where Input Tax Credit is available through Purchase Order
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseOrderForRegisteredWithITCIntraState()
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
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order
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
    procedure CreateIntraStatePurchaseOrderFromQuoteForServiceRegVendorWithoutITC()
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
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create Purchase Order From Quote
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
    procedure PostFromIntraStatePurchInvForRegisteredWithDebitNoteWithoutAvailment()
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
        Storage.Set(InvoiceTypeLbl, format(InvoiceType::"Debit Note"));
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Journal
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
        Storage.Set(InvoiceTypeLbl, '');
    end;

    // [SCENARIO] [353790] Check if the system is calculating GST in case of Intra-State/ Intra-Union Territory Purchase of Goods from Registered Vendor where Input Tax Credit is not available through Purchase Orders
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvForServiceRegisteredWithITCIntraSate()
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
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Journal
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    // [SCENARIO] [353537]	[Check After Change Pay to Vendor on Purchase Header]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ChangeVendor')]
    procedure CheckAfterChangePaytoVendoronPurchaseHeader()
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
        LibraryRandom: Codeunit "Library - Random";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create  Purchase Invoice
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        PurchaseLine.Validate(Quantity, LibraryRandom.RandInt(10));
        PurchaseLine.Modify(true);
    end;

    // [SCENARIO] [356402]	[Check  after Change order Address on purchase header document]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckAfterChangeOrderAddressOnPurchaseHeaderDocument()
    var
        PurchaseHeader: Record "Purchase Header";
        OrderAddress: Record "Order Address";
        PurchaseLine, PurchaseLine2 : Record "Purchase Line";
        Assert: Codeunit Assert;
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [GIVEN] Create GST Setup
        InitializeShareStep(true, false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create  Purchase Order
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
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
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create  Purchase Order with validation
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
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
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create  Purchase Order with validation
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        PurchaseLine.SetFilter("GST Group Code", '<>%1', '');
        LibraryAssert.RecordIsNotEmpty(PurchaseLine);
    end;

    // [SCENARIO] [356420] [Check Change Exempted on Purchase line]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckChangeExemptedonPurchaseLine()
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
        Storage.Set(NoOfLineLbl, '2');

        // [WHEN] Create  Purchase Order with validation
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        PurchaseLine.Validate(Exempted, true);
        PurchaseLine.Modify(true);
        LibraryAssert.IsTrue(PurchaseLine.Exempted, NotEqualLbl);
    end;
    // [SCENARIO] [356428] [Check Validation for Custom Duty Amount and Assessable Value on Purchase line.]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckValidationforCustomDutyAmountandAssessableValueonPurchaseline()
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
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create  Purchase Order with validation
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
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
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create  Purchase Order with validation
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
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
    procedure CheckAfterChangeLocationCodeAndPOSOnPurchaseHeader()
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
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create  Purchase Order with validation
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
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
    procedure PostFromPurchaseOrderForFixedAssetWithITCWithForIntraState()
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
        Storage.Set(NoOfLineLbl, '2');
        DocumentNo := CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseLine,
            LineType::"Fixed Asset",
            DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    // [SCENARIO] [354999]	[Check if the system is calculating GST in case of Intra-State/Intra-Union Territory Purchase of Fixed Assets from Registered Vendor where Input Tax Credit is available with invoice discount/line discount and multiple HSN code wise through Purchase Invoice]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromIntraStatePurchaseInvoiceForFAWithITCWithLineDisc()
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
        Storage.Set(NoOfLineLbl, '2');
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
    procedure PostFromIntraStatePurchaseOrderForFAWithLineDisc()
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
        Storage.Set(NoOfLineLbl, '2');
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
    procedure PostFromIntraStatePurchaseInvoiceForFixedAssetWithLineDiscount()
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
        Storage.Set(NoOfLineLbl, '2');
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
    procedure PostFromInterStatePurchaseOrderForFixedAssetWithLineDiscountWithITC()
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
        Storage.Set(NoOfLineLbl, '2');
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
    procedure PostFromInterStatePurchInvForFixedAssetWithLineDiscountWithITC()
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
        Storage.Set(NoOfLineLbl, '2');
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
    procedure PostFromInterStatePurchaseOrderForFAWithLineDiscWithoutITC()
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
        Storage.Set(NoOfLineLbl, '2');
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
    procedure PostFromInterStatePurchaseInvoiceForFixedAssetWithLineDisctWithoutITC()
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
        Storage.Set(NoOfLineLbl, '2');
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
    procedure PostFromPurchaseInvoiceRegisteredVendorForGoodsForIntraState()
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
        Storage.Set(NoOfLineLbl, '2');
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
    procedure PostFromIntrastatePurchaseGoodsQuoteForRegisteredVendorWithITC()
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
        Storage.Set(NoOfLineLbl, '1');

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
    procedure PostGSTPurchaseQuoteRegisterdVendorWithoutITCForItem()
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
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Fixed Asset for Interstate Transactions.
        DocumentNo := CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Quote);

        // [THEN] Make Order from Quote
        LibraryGST.VerifyTaxTransactionForPurchase(DocumentNo, PurchaseLine."Document Type");
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [353840] Check if the system is calculating GST in case of Inter-State Purchase of Goods from Registered Vendor where Input Tax Credit is not available through Purchase Invoice
    // [FEATURE] [Purchase Invoice] [Without ITC Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostGSTPurchaseInvoiceRegisterdVendorWithoutITCForItem()
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
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Fixed Asset for Interstate Transactions.
        PostedInvoiceNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, PostedInvoiceNo, 3);
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
        Storage.Set(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.MODIFY(TRUE);
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, FALSE);
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

    local procedure UpdateVendorSetupWithGST(VendorNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        AssociateEnterprise: boolean;
        StateCode: Code[10];
        PANNo: Code[20]);
    var
        Vendor: Record Vendor;
        State: Record State;
    begin
        Vendor.Get(VendorNo);
        if (GSTVendorType <> GSTVendorType::Import) then begin
            State.Get(StateCode);
            Vendor.Validate("State Code", StateCode);
            Vendor.Validate("P.A.N. No.", PANNo);
            if not ((GSTVendorType = GSTVendorType::" ") OR (GSTVendorType = GSTVendorType::Unregistered)) then
                Vendor.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo));
        end;
        Vendor.Validate("GST Vendor Type", GSTVendorType);
        if Vendor."GST Vendor Type" = vendor."GST Vendor Type"::Import then
            vendor.Validate("Associated Enterprises", AssociateEnterprise);
        Vendor.Modify(true);
    end;

    local procedure CreateAndPostPurchaseDocument(var PurchaseHeader: Record "Purchase Header";
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
            DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, TRUE, TRUE);
            exit(DocumentNo);
        end;
    end;

    local procedure CreatePurchaseDocument(var PurchaseHeader: Record "Purchase Header";
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

    local procedure CreatePurchaseHeaderWithGST(VAR PurchaseHeader: Record "Purchase Header";
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
        PurchaseHeader.VALIDATE("Location Code", LocationCode);
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
        PurchaseHeader.MODIFY(TRUE);
    end;

    local procedure CreatePurchaseLineWithGST(VAR PurchaseHeader: Record "Purchase Header"; VAR PurchaseLine: Record "Purchase Line"; LineType: Enum "Purchase Line Type"; Quantity: Decimal; InputCreditAvailment: Boolean; Exempted: Boolean; LineDiscount: Boolean);
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
                    LineTypeNo := LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, FALSE);
                LineType::"Fixed Asset":
                    LineTypeNo := LibraryGST.CreateFixedAssetWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
            end;

            LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, LineType, LineTypeno, Quantity);

            PurchaseLine.VALIDATE("VAT Prod. Posting Group", VATPostingsetup."VAT Prod. Posting Group");
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
            PurchaseLine.VALIDATE("Direct Unit Cost", LibraryRandom.RandInt(1000));
            PurchaseLine.MODIFY(TRUE);
        end;
    end;

    local procedure UpdateInputServiceDistributer(InputServiceDistribute: Boolean; InputCreditAvailment: Boolean)
    var
        LocationCod: Code[10];
    begin
        InputCreditAvailment := InputCreditAvailment;
        StorageBoolean.Set(InputCreditAvailmentLbl, InputCreditAvailment);
        LocationCod := CopyStr(Storage.Get(LocationCodeLbl), 1, 10);
        LibraryGST.UpdateLocationWithISD(LocationCod, InputServiceDistribute);
    end;

    local procedure CreateGSTComponentAndPostingSetup(IntraState: Boolean; LocationStateCode: Code[10]; TaxComponent: Record "Tax Component"; GSTComponentCode: Text[30]);
    begin
        IF IntraState THEN begin
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

    [ConfirmHandler]
    procedure ChangeVendor(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
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
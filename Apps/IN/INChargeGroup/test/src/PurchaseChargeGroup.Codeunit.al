codeunit 18990 "Purchase Charge Group"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryCharge: Codeunit "Library - Charge";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryGSTPurchase: Codeunit "Library - GST Purchase";
        LibraryRandom: Codeunit "Library - Random";
        Storage: Dictionary of [Text[20], Text[20]];
        ComponentPerArray: array[10] of Decimal;
        StorageBoolean: Dictionary of [Text[20], Boolean];
        StorageChargeGroupLineType: Dictionary of [Text[50], Enum "Charge Group Type"];
        StorageChargeGroupAssignment: Dictionary of [Text[50], Enum "Charge Assignment"];
        StorageChargeGroupComputationMethod: Dictionary of [Text[50], Enum "Charge Computation Method"];
        StorageGSTVendorType: Dictionary of [Text[50], Enum "GST Vendor Type"];
        OrderAddr: Boolean;
        GSTVendorTypeLbl: Label 'GSTVendorType';
        NoOfLineLbl: Label 'NoOfLine';
        LocationStateCodeLbl: Label 'LocationStateCode';
        LocationCodeLbl: Label 'LocationCode';
        GSTGroupCodeLbl: Label 'GSTGroupCode', Locked = true;
        HSNSACCodeLbl: Label 'HSNSACCode', Locked = true;
        VendorNoLbl: Label 'VendorNo';
        InputCreditAvailmentLbl: Label 'InputCreditAvailment', Locked = true;
        ExemptedLbl: Label 'Exempted', Locked = true;
        LineDiscountLbl: Label 'LineDiscount';
        FromStateCodeLbl: Label 'FromStateCode', Locked = true;
        ToStateCodeLbl: Label 'ToStateCode';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
        ChargeGroupCodeLbl: Label 'ChargeGroupCode';
        ChargeGroupTypeLbl: Label 'ChargeGroupType';
        ChargeAssignmentLbl: Label 'ChargeAssignment';
        ChargeComputationMethodLbl: Label 'ChargeComputationMethod';
        LocPANNoLbl: Label 'LocPANNo';
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo', Locked = true;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromPurchInvRegVendWithAvailmentChargeGroupIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Percentage with auto assignment-equally through Invoice to Registered Vendor Intrastate -availment]
        // [FEATURE] [Goods, Purchase Invoice] [ChargeItem Assignment,Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup, Charge Group Setup for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::"Separate Invoice");
        SetChargeGroupLineDetails(3, 0, ChargeAssignment::Equally, ComputationMethod::Percentage);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocumentWithChargeGroup(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 13);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromPurchInvRegVendWithNonAvailmentChargeGroupIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Percentage with auto assignment-equally, through Invoice to Registered Vendor Intrastate - Non-availment]
        // [FEATURE] [Goods, Purchase Invoice] [ChargeItem Assignment,Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup, Charge Group Setup for Registered Vendor and GST Credit adjustment is Non Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 0, ChargeAssignment::Equally, ComputationMethod::Percentage);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocumentWithChargeGroup(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 13);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromPurchInvRegVendWithAvailmentChargeGroupInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Fixed Value with auto assignment-By Amount through Invoice to Registered Vendor Interstate - availment.]
        // [FEATURE] [Goods, Purchase Invoice] [ChargeItem Assignment,Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup, Charge Group Setup with 3 Charges and 1 G/L for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 1, ChargeAssignment::"By Amount", ComputationMethod::"Fixed Value");
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocumentWithChargeGroup(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 11);
        //VerifyGSTEntries(DocumentNo, Database::"Purch. Inv. Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromPurchInvRegVendWithNonAvailmentChargeGroupInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Percentage with auto assignment-equally, through Invoice to Registered Vendor Interstate - Non-availment]
        // [FEATURE] [Goods, Purchase Invoice] [ChargeItem Assignment,Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup, Charge Group Setup with 3 Charges and 1 G/L for Registered Vendor and GST Credit adjustment is Non Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 1, ChargeAssignment::"By Amount", ComputationMethod::"Fixed Value");
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocumentWithChargeGroup(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 11);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromPurchInvCompositeVendWithAvailmentChargeGroupIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Percentage with auto assignment-equally through Invoice to Composite Vendor Intrastate - availment.]
        // [FEATURE] [Goods, Purchase Invoice] [ChargeItem Assignment,Composite Vendor, Intra-State]

        // [GIVEN] Created GST Setup, Charge Group Setup with 2 charge item and 2 G/L Account for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::Equally, ComputationMethod::Percentage);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocumentWithChargeGroup(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromPurchInvCompositeVendWithNonAvailmentChargeGroupIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Percentage with auto assignment-equally, through Invoice to Composite Vendor Intrastate - Non-availment]
        // [FEATURE] [Goods, Purchase Invoice] [ChargeItem Assignment,Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup, Charge Group Setup with 2 charge item and 2 G/L Account for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::Equally, ComputationMethod::Percentage);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocumentWithChargeGroup(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromPurchInvCompositeVendWithAvailmentFixValByAmtChargeGroupInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Fixed Value with auto assignment-By Amount through Invoice to Composite Vendor Interstate - availment.]
        // [FEATURE] [Goods, Purchase Invoice] [ChargeItem Assignment,Composite Vendor, Intra-State]

        // [GIVEN] Created GST Setup, Charge Group Setup with 2 charge item and 2 G/L Account for Composite Vendor and GST Credit adjustment is Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::"Fixed Value");
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocumentWithChargeGroup(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromPurchInvCompositeVendWithNonAvailmentFixValByAmtChargeGroupInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Fixed with auto assignment-By Amount, through Invoice to Composite Vendor Interstate - Non-availment]
        // [FEATURE] [Goods, Purchase Invoice] [ChargeItem Assignment,Composite Vendor, Intra-State]

        // [GIVEN] Created GST Setup, Charge Group Setup with 2 charge item and 2 G/L Account for Composite Vendor and GST Credit adjustment is Non Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Composite, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::"Fixed Value");
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocumentWithChargeGroup(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromPurchInvSezVendWithAvailmentChargeGroupIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Amount per Quantity  with auto assignment-By Amount through Invoice to SEZ Vendor Interstate - availment.]
        // [FEATURE] [Goods, Purchase Invoice] [ChargeItem Assignment,SEZ Vendor, Inter-State]

        // [GIVEN] Created GST Setup, Charge Group Setup for SEZ Vendor and GST Credit adjustment is Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::"Separate Invoice");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::"Amount Per Quantity");
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocumentWithChargeGroup(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 11);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromPurchInvSezVendWithNonAvailmentChargeGroupIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Amount per Quantity  with auto assignment-By Amount through Invoice to SEZ Vendor Interstate - Nonavailment.]
        // [FEATURE] [Goods, Purchase Invoice] [ChargeItem Assignment,SEZ Vendor, Inter-State]

        // [GIVEN] Created GST Setup, Charge Group Setup for SEZ Vendor and GST Credit adjustment is Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::SEZ, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::"Separate Invoice");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::"Amount Per Quantity");
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocumentWithChargeGroup(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 11);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromPurchInvImportVendWithAvailmentChargeGroupInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Amount per Quantity  with auto assignment-By Amount through Invoice to Import  Vendor Interstate - availment.]
        // [FEATURE] [Goods, Purchase Invoice] [ChargeItem Assignment,Registered Vendor, Inter-State]

        // [GIVEN] Created GST Setup, Charge Group Setup for Import Vendor and GST Credit adjustment is Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::"Separate Invoice");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::"Amount Per Quantity");
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocumentWithChargeGroup(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 14);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromPurchInvImportVendWithNonAvailmentChargeGroupInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        DocumentNo: Code[20];
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Amount per Quantity  with auto assignment-By Amount through Invoice to Import  Vendor Interstate -Non-availment.]
        // [FEATURE] [Goods, Purchase Invoice] [ChargeItem Assignment,Registered Vendor, Inter-State]

        // [GIVEN] Created GST Setup, Charge Group Setup for Import Vendor and GST Credit adjustment is Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::"Separate Invoice");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::"Amount Per Quantity");
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        DocumentNo := CreateAndPostPurchaseDocumentWithChargeGroup(PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 14);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler,ConfirmationHandler')]
    procedure PostFromPurchCrMemoRegVendWithAvailmentChargeGroupIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Percentage with auto assignment-equally, through Credit Memo to Registered Vendor Intrastate -availment]
        // [FEATURE] [Goods, Purchase Credit Memo] [ChargeItem Assignment,Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup, Charge Group Setup for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(true, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 0, ChargeAssignment::Equally, ComputationMethod::Percentage);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document created and Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 13);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler,ConfirmationHandler')]
    procedure PostFromPurchCrMemoRegVendWithNonAvailmentChargeGroupIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Percentage with auto assignment-equally, through Credit Memo to Registered Vendor Intrastate - Non-availment]
        // [FEATURE] [Goods, Purchase Credit Memo] [ChargeItem Assignment,Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup, Charge Group Setup for Registered Vendor and GST Credit adjustment is Non Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 0, ChargeAssignment::Equally, ComputationMethod::Percentage);
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document created and Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 13);
    End;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler,ConfirmationHandler')]
    procedure PostFromPurchCrMemoRegVendWithAvailmentChargeGroupInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Percentage with auto assignment-equally, through Credit Memo to Registered Vendor Interstate -availment]
        // [FEATURE] [Goods, Purchase Credit Memo] [ChargeItem Assignment,Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup, Charge Group Setup with 3 Charges and 1 G/L for Registered Vendor and GST Credit adjustment is Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(true, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 1, ChargeAssignment::"By Amount", ComputationMethod::"Fixed Value");
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document created and Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        LibraryCharge.VerifyGLEntries(PurchaseHeader."Document Type"::"Credit Memo", Storage.Get(ReverseDocumentNoLbl), 11);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferenceInvoiceNoPageHandler,ConfirmationHandler')]
    procedure PostFromPurchCrMemoRegVendWithNonAvailmentChargeGroupInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeGroupHeader: Record "Charge Group Header";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type enum";
        GSTVendorType: Enum "GST Vendor Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
    begin
        // [SCENARIO] [435451] [Check GST is calculating on based Charges if Charges are define in Percentage with auto assignment-equally, through Credit Memo to Registered Vendor Interstate - Non-availment]
        // [FEATURE] [Goods, Purchase Credit Memo] [ChargeItem Assignment,Registered Vendor, Intra-State]

        // [GIVEN] Created GST Setup, Charge Group Setup with 3 Charges and 1 G/L for Registered Vendor and GST Credit adjustment is Non Available with GST group type as Goods        
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeShareStep(false, false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 1, ChargeAssignment::"By Amount", ComputationMethod::"Fixed Value");
        SetStorageLibraryPurchaseText(NoOfLineLbl, Format(1));

        // [WHEN] Create and Post Purchase invoice with GST, Line Type as Item
        CreateAndPostPurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] Purchase Return Document created and Reference Invoice No. Updated
        CreateAndPostPurchaseReturnFromCopyDocument(PurchaseHeader, DocumentType::"Credit Memo");

        // [THEN] GST ledger entries are created and Verified
        VerifyValueEntries((Storage.Get(ReverseDocumentNoLbl)), Database::"Purch. Cr. Memo Hdr.");
    end;

    local procedure CreateGSTSetup(GSTVendorType: Enum "GST Vendor Type"; GSTGroupType: Enum "GST Group Type";
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
        StorageGSTVendorType.Set(GSTVendorTypeLbl, GSTVendorType);
        CompanyInformation.Get();

        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := LibraryCharge.CreatePANNos();
            CompanyInformation.Modify();
        end;

        LocPANNo := CompanyInformation."P.A.N. No.";
        Storage.Set(LocPANNoLbl, LocPANNo);
        LocationStateCode := LibraryCharge.CreateInitialSetup();
        SetStorageLibraryPurchaseText(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryCharge.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true)
        end;

        LocationCode := LibraryCharge.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        SetStorageLibraryPurchaseText(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryCharge.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::"Bill-to Address", ReverseCharge);
        SetStorageLibraryPurchaseText(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryCharge.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        SetStorageLibraryPurchaseText(HSNSACCodeLbl, HSNSACCode);

        if IntraState then begin
            VendorNo := LibraryCharge.CreateVendorSetup();
            LibraryGSTPurchase.UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, LocationStateCode, LocPANNo);
            InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
        end else begin
            VendorStateCode := LibraryCharge.CreateGSTStateCode();
            VendorNo := LibraryCharge.CreateVendorSetup();
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
        NoOfLine: Integer;
        PurchaseInvoiceType: Enum "GST Invoice Type";
    begin
        Evaluate(VendorNo, Storage.Get(VendorNoLbl));
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        Evaluate(NoOfLine, Storage.Get(NoOfLineLbl));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        UpdateChargeGroupOnPurchaseDocument(PurchaseHeader);
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, StorageBoolean.Get(InputCreditAvailmentLbl), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl), NoOfLine);
        InsertChargeGroupLinsOnPurchaseDocument(PurchaseHeader);
        if not (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Quote) then begin
            DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
            SetStorageGSTPurchaseText(PostedDocumentNoLbl, DocumentNo);
            exit(DocumentNo);
        end;
    end;

    local procedure SetStorageGSTPurchaseText(KeyValue: Text[20]; Value: Text[20])
    begin
        Storage.Set(KeyValue, Value);
        LibraryGSTPurchase.SetStorageLibraryPurchaseText(Storage);
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
        libraryGSTPurchase.UpdateReferenceInvoiceNoAndVerify(PurchaseHeader, (Storage.Get(PostedDocumentNoLbl)));

        ReverseDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(ReverseDocumentNoLbl, ReverseDocumentNo);
    end;

    local procedure VerifyValueEntries(DocumentNo: Code[20]; TableID: Integer)
    begin
        LibraryGSTPurchase.VerifyValueEntries(DocumentNo, TableID, ComponentPerArray);
    end;

    local procedure CreateAndPostPurchaseDocumentWithChargeGroup(
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
        UpdateChargeGroupOnPurchaseDocument(PurchaseHeader);
        CreatePurchaseLineWithGST(
            PurchaseHeader,
            PurchaseLine,
            LineType,
            StorageBoolean.Get(InputCreditAvailmentLbl),
            StorageBoolean.Get(ExemptedLbl),
            StorageBoolean.Get(LineDiscountLbl),
            NoOfLine);
        InsertChargeGroupLinsOnPurchaseDocument(PurchaseHeader);

        if not (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Quote) then begin
            DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
            SetStorageLibraryPurchaseText(PostedDocumentNoLbl, DocumentNo);
            exit(DocumentNo);
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

    local procedure UpdateChargeGroupOnPurchaseDocument(var PurchaseHeader: Record "Purchase Header")
    var
        ChargeGroupHeader: Record "Charge Group Header";
    begin
        if not ChargeGroupHeader.Get(Storage.Get(ChargeGroupCodeLbl)) then
            exit;

        PurchaseHeader.Validate(PurchaseHeader."Charge Group Code", ChargeGroupHeader.Code);
        PurchaseHeader.Modify(true);
    end;

    local procedure InsertChargeGroupLinsOnPurchaseDocument(PurchaseHeader: Record "Purchase Header")
    begin
        case PurchaseHeader."Document Type" of
            "Purchase Document Type"::"Blanket Order":
                InsertChargeGroupLinsOnPurchaseBlanketOrderDocument(PurchaseHeader);
            "Purchase Document Type"::"Credit Memo":
                InsertChargeGroupLinsOnPurchaseCreditMemoDocument(PurchaseHeader);
            "Purchase Document Type"::Invoice:
                InsertChargeGroupLinsOnPurchaseInvoiceDocument(PurchaseHeader);
            "Purchase Document Type"::Order:
                InsertChargeGroupLinsOnPurchaseOrderDocument(PurchaseHeader);
            "Purchase Document Type"::Quote:
                InsertChargeGroupLinsOnPurchaseQuoteDocument(PurchaseHeader);
            "Purchase Document Type"::"Return Order":
                InsertChargeGroupLinsOnPurchaseReturnOrderDocument(PurchaseHeader);
            else
                InsertChargeGroupLinsOnPurchaseDocuments(PurchaseHeader);
        end;

        if (PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ]) then
            UpdateGSTAssessableValueonPurchaseDocument(PurchaseHeader);
    end;

    local procedure InsertChargeGroupLinsOnPurchaseDocuments(PurchaseHeader: Record "Purchase Header")
    var
        ChargeGroupManagement: Codeunit "Charge Group Management";
    begin
        ChargeGroupManagement.InsertChargeItemOnLine(PurchaseHeader);
    end;

    local procedure InsertChargeGroupLinsOnPurchaseBlanketOrderDocument(PurchaseHeader: Record "Purchase Header")
    var
        BlanketPurchaseOrder: TestPage "Blanket Purchase Order";
    begin
        BlanketPurchaseOrder.OpenEdit();
        BlanketPurchaseOrder.GoToRecord(PurchaseHeader);
        BlanketPurchaseOrder.PurchLines."Explode Charge Group".Invoke();
    end;

    local procedure InsertChargeGroupLinsOnPurchaseCreditMemoDocument(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseCreditMemo: TestPage "Purchase Credit Memo";
    begin
        PurchaseCreditMemo.OpenEdit();
        PurchaseCreditMemo.GoToRecord(PurchaseHeader);
        PurchaseCreditMemo.PurchLines."Explode Charge Group".Invoke();
    end;

    local procedure InsertChargeGroupLinsOnPurchaseInvoiceDocument(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseInvoice: TestPage "Purchase Invoice";
    begin
        PurchaseInvoice.OpenEdit();
        PurchaseInvoice.GoToRecord(PurchaseHeader);
        PurchaseInvoice.PurchLines."Explode Charge Group".Invoke();
    end;

    local procedure InsertChargeGroupLinsOnPurchaseOrderDocument(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseOrder: TestPage "Purchase Order";
    begin
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchaseHeader);
        PurchaseOrder.PurchLines."Explode Charge Group".Invoke();
    end;

    local procedure InsertChargeGroupLinsOnPurchaseQuoteDocument(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseQuote: TestPage "Purchase Quote";
    begin
        PurchaseQuote.OpenEdit();
        PurchaseQuote.GoToRecord(PurchaseHeader);
        PurchaseQuote.PurchLines."Explode Charge Group".Invoke();
    end;

    local procedure InsertChargeGroupLinsOnPurchaseReturnOrderDocument(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseReturnOrder: TestPage "Purchase Return Order";
    begin
        PurchaseReturnOrder.OpenEdit();
        PurchaseReturnOrder.GoToRecord(PurchaseHeader);
        PurchaseReturnOrder.PurchLines."Explode Charge Group".Invoke();
    end;

    local procedure UpdateGSTAssessableValueonPurchaseDocument(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                if (not (PurchaseLine.Type in [PurchaseLine.Type::" ", PurchaseLine.Type::"Charge (Item)"])) then begin
                    PurchaseLine.Validate("GST Assessable Value", LibraryRandom.RandInt(1000));
                    if PurchaseLine.Type in [PurchaseLine.Type::Item, PurchaseLine.Type::"G/L Account"] then
                        PurchaseLine.Validate("Custom Duty Amount", LibraryRandom.RandInt(1000));
                    PurchaseLine.Modify(true);
                end;
            until PurchaseLine.Next() = 0;
    end;

    procedure CreatePurchaseHeaderWithGST(
            VAR PurchaseHeader: Record "Purchase Header";
            VendorNo: Code[20];
            DocumentType: Enum "Purchase Document Type";
                              LocationCode: Code[10];
                              PurchaseInvoiceType: Enum "GST Invoice Type")
    var
        OrderAddress: Record "Order Address";
        Overseas: Boolean;
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Location Code", LocationCode);

        if OrderAddr then
            PurchaseHeader.Validate("Order Address Code", LibraryCharge.CreateOrderAddress(OrderAddress, VendorNo));

        if Overseas then
            PurchaseHeader.Validate("POS Out Of India", true);

        if PurchaseInvoiceType in [PurchaseInvoiceType::"Debit Note", PurchaseInvoiceType::Supplementary] then
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.fieldno("Vendor Invoice No."), Database::"Purchase Header"))
        else
            PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.fieldno("Vendor Cr. Memo No."), Database::"Purchase Header"));
        if PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ] then begin
            PurchaseHeader."Bill of Entry No." := LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Bill of Entry No."), Database::"Purchase Header");
            PurchaseHeader."Bill of Entry Date" := WorkDate();
            PurchaseHeader."Bill of Entry Value" := LibraryRandom.RandInt(1000);
        end;
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
                    LineTypeNo := LibraryCharge.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
                LineType::"G/L Account":
                    LineTypeNo := LibraryCharge.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
                LineType::"Fixed Asset":
                    LineTypeNo := LibraryCharge.CreateFixedAssetWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
                LineType::"Charge (Item)":
                    LineTypeNo := LibraryCharge.CreateChargeItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
            end;

            LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, LineType, LineTypeno, LibraryRandom.RandDecInRange(2, 10, 0));

            PurchaseLine.Validate("VAT Prod. Posting Group", VATPostingsetup."VAT Prod. Posting Group");
            if InputCreditAvailment then
                PurchaseLine."GST Credit" := PurchaseLine."GST Credit"::Availment
            else
                PurchaseLine."GST Credit" := PurchaseLine."GST Credit"::"Non-Availment";

            if LineDiscount then begin
                PurchaseLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
                LibraryCharge.UpdateLineDiscAccInGeneralPostingSetup(PurchaseLine."Gen. Bus. Posting Group", PurchaseLine."Gen. Prod. Posting Group");
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

    local procedure CreateChargeGroupHeader(var ChargeGroupHeader: Record "Charge Group Header"; InvoiceCombination: Enum "Charge Group Invoice Comb.")
    var
        ChargeGroupCode: Code[20];
    begin
        ChargeGroupCode := LibraryUtility.GenerateRandomCode(ChargeGroupHeader.FieldNo(Code), Database::"Charge Group Header");

        ChargeGroupHeader.Reset();
        ChargeGroupHeader.SetCurrentKey("Code");
        ChargeGroupHeader.SetRange("Code", ChargeGroupCode);
        if not ChargeGroupHeader.FindFirst() then begin
            ChargeGroupHeader.Init();
            ChargeGroupHeader.Validate("Code", ChargeGroupCode);
            ChargeGroupHeader.Validate(Name, LibraryRandom.RandText(50));
            ChargeGroupHeader.Validate("Invoice Combination", InvoiceCombination);
            ChargeGroupHeader.Insert(true);
        end;
        SetStorageLibraryPurchaseText(ChargeGroupCodeLbl, ChargeGroupHeader.Code);
    end;

    local procedure SetChargeGroupLineDetails(
        NoOfChargeLine: Integer; NoOfGlLine: Integer;
        ChargeAssignment: Enum "Charge Assignment";
                              ComputationMethod: Enum "Charge Computation Method");
    var
        LineNo: Integer;
        ChargeGroupType: Enum "Charge Group Type";
    begin
        if NoOfChargeLine <> 0 then
            for LineNo := 1 to NoOfChargeLine do
                SetChargeItem(ChargeAssignment, ComputationMethod, ChargeGroupType::"Charge (Item)");

        if NoOfGlLine <> 0 then
            for LineNo := 1 to NoOfGlLine do
                SetChargeItem(ChargeAssignment, ComputationMethod, ChargeGroupType::"G/L Account");
    end;

    local procedure SetChargeItem(
        ChargeAssignment: Enum "Charge Assignment";
                              ComputationMethod: Enum "Charge Computation Method";
                              ChargeGroupType: Enum "Charge Group Type")
    begin
        StorageChargeGroupLineType.Set(ChargeGroupTypeLbl, ChargeGroupType);
        StorageChargeGroupAssignment.Set(ChargeAssignmentLbl, ChargeAssignment);
        StorageChargeGroupComputationMethod.Set(ChargeComputationMethodLbl, ComputationMethod);
        CreateChargeGroupLineSetup();
    end;

    local procedure CreateChargeGroupLineSetup()
    var
        ChargeGroupLine: Record "Charge Group Line";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        ChargeGroupLine.Init();
        ChargeGroupLine."Charge Group Code" := Storage.Get(ChargeGroupCodeLbl);
        ChargeGroupLine."Line No." := GetChargeGroupLineNextLineNo(ChargeGroupLine."Charge Group Code");

        if StorageChargeGroupLineType.Get(ChargeGroupTypeLbl) = StorageChargeGroupLineType.Get(ChargeGroupTypeLbl) ::"Charge (Item)" then begin
            ChargeGroupLine.Validate(Type, ChargeGroupLine.Type::"Charge (Item)");
            ChargeGroupLine."No." := LibraryCharge.CreateChargeItemWithGSTDetailsForChargeGroup(
                VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)),
                (Storage.Get(HSNSACCodeLbl)),
                (StorageBoolean.Get(InputCreditAvailmentLbl)),
                (StorageBoolean.Get(ExemptedLbl)));
        end else begin
            ChargeGroupLine.Validate(Type, ChargeGroupLine.Type::"G/L Account");
            ChargeGroupLine."No." := LibraryCharge.CreateChargeItemWithGSTDetailsForChargeGroup(
                VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)),
                (Storage.Get(HSNSACCodeLbl)),
                (StorageBoolean.Get(InputCreditAvailmentLbl)),
                (StorageBoolean.Get(ExemptedLbl)));
        end;

        ChargeGroupLine.Assignment := StorageChargeGroupAssignment.Get(ChargeAssignmentLbl);
        ChargeGroupLine."Computation Method" := StorageChargeGroupComputationMethod.Get(ChargeComputationMethodLbl);
        ChargeGroupLine.Value := LibraryRandom.RandDecInRange(10, 20, 0);
        ChargeGroupLine.Insert(true);
    end;

    local procedure GetChargeGroupLineNextLineNo(ChargeGroupCode: Code[20]): Integer
    var
        ChargeGroupLine: Record "Charge Group Line";
    begin
        ChargeGroupLine.SetRange("Charge Group Code", ChargeGroupCode);
        If ChargeGroupLine.FindLast() then
            exit(ChargeGroupLine."Line No." + 10000)
        else
            exit(10000);
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

    [PageHandler]
    procedure ChargeGroupLinePageHandler(var ChargeGroupLines: TestPage "Charge Group SubPage")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        ChargeNo: Code[20];
        ChargeGroupType: Enum "Charge Group Type";
    begin
        ChargeGroupLines.New();
        if StorageChargeGroupLineType.Get(ChargeGroupTypeLbl) = StorageChargeGroupLineType.Get(ChargeGroupTypeLbl) ::"Charge (Item)" then begin
            ChargeGroupLines.Type.SetValue(ChargeGroupType::"Charge (Item)");
            ChargeNo := LibraryCharge.CreateChargeItemWithGSTDetailsForChargeGroup(
                VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)),
                (Storage.Get(HSNSACCodeLbl)),
                (StorageBoolean.Get(InputCreditAvailmentLbl)),
                (StorageBoolean.Get(ExemptedLbl)))
        end
        else begin
            ChargeGroupLines.Type.SetValue(ChargeGroupType::"G/L Account");
            ChargeNo := LibraryCharge.CreateGLAccWithGSTDetailsForChargeGroup(
                VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)),
                (Storage.Get(HSNSACCodeLbl)),
                (StorageBoolean.Get(InputCreditAvailmentLbl)),
                (StorageBoolean.Get(ExemptedLbl)));
        end;
        ChargeGroupLines."No.".SetValue(ChargeNo);
        ChargeGroupLines.Assignment.SetValue(StorageChargeGroupAssignment.Get(ChargeAssignmentLbl));
        ChargeGroupLines."Computation Method".SetValue(StorageChargeGroupComputationMethod.Get(ChargeComputationMethodLbl));
        ChargeGroupLines.Value.SetValue(LibraryRandom.RandDecInRange(10, 20, 0));
        ChargeGroupLines.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmationHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;
}
codeunit 18991 "Sales Charge Group"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryCharge: Codeunit "Library - Charge";
        LibraryRandom: Codeunit "Library - Random";
        Storage: Dictionary of [Text, Code[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
        StorageChargeGroupLineType: Dictionary of [Text[50], Enum "Charge Group Type"];
        StorageChargeGroupAssignment: Dictionary of [Text[50], Enum "Charge Assignment"];
        StorageChargeGroupComputationMethod: Dictionary of [Text[50], Enum "Charge Computation Method"];
        ComponentPerArray: array[20] of Decimal;
        LocationStateCodeLbl: Label 'LocationStateCode';
        KeralaCESSLbl: Label 'KeralaCESS';
        PartialShipLbl: Label 'PartialShip';
        WithoutPaymentofDutyLbl: Label 'WithoutPaymentofDuty';
        PostGSTtoCustomerLbl: Label 'PostGSTtoCustomer';
        LocationCodeLbl: Label 'LocationCode';
        POSLbl: Label 'POS';
        NoOfLineLbl: Label 'NoOfLine';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        ExemptedLbl: Label 'Exempted';
        LineDiscountLbl: Label 'LineDiscount';
        FromStateCodeLbl: Label 'FromStateCode';
        CustomerNoLbl: Label 'CustomerNo';
        ToStateCodeLbl: Label 'ToStateCode';
        SuccessMsg: Label 'GST Payment Lines Posted Successfully.', Locked = true;
        NotPostedErr: Label 'The entries were not posted.', locked = true;
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo';
        PriceInclusiveOfTaxLbl: Label 'WithPIT';
        ChargeGroupCodeLbl: Label 'ChargeGroupCode';
        ChargeGroupTypeLbl: Label 'ChargeGroupType';
        ChargeAssignmentLbl: Label 'ChargeAssignment';
        ChargeComputationMethodLbl: Label 'ChargeComputationMethod';

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromSalesInvRegCustIntraStateWithChargeGroup()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [01]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Fixed Value with auto assignment-equally through Invoice to Registered Customer  Intrastate.
        // [FEATURE] [Goods Sales Invoice] [Intra-State GST,Registered Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::"Separate Invoice");
        SetChargeGroupLineDetails(3, 0, ChargeAssignment::Equally, ComputationMethod::"Fixed Value");
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 13);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries,ConfirmationHandler')]
    procedure PostFromSalesCrMemoRegCustIntraStateWithChargeGroupCopyDoc()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [02]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Fixed Value with auto assignment-equally, through Credit Memo with copy document to Registered Customer Intrastate.
        // [FEATURE] [Goods Sales Cr. Memo] [Intra-State GST,Registered Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 0, ChargeAssignment::Equally, ComputationMethod::"Fixed Value");
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Cr. Memo with GST and Line Type as Goods and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Sales Return Document created and Reference Invoice No. Updated
        CreateAndPostSalesDocumentFromCopyDocument(SalesHeader, DocumentType::"Credit Memo");

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 13);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries,GetPostedSalesDocumentLines,ConfirmationHandler')]
    procedure PostFromSalesCrMemoRegCustIntraStateWithChargeGroupGetPostedDoctoReverse()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [03]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Fixed Value with auto assignment-equally, through Credit Memo with Get Posted Document line to reverse to Registered Customer Interstate.
        // [FEATURE] [Goods Sales Cr. Memo] [Intra-State GST,Registered Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 0, ChargeAssignment::Equally, ComputationMethod::"Fixed Value");
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Cr. Memo with GST and Line Type as Services and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Sales Return Document created and Reference Invoice No. Updated
        CreateAndPostSalesDocumentFromGetPostedDocToReverse(SalesHeader, DocumentType::"Credit Memo");

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 13);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure CorrectCancelFromPostedSalesInvRegCustIntraStateWithChargeGroup()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [04]
        // [SCENARIO] [435451] Check Correct/Cancellation feature for Posted Sales Invoice when GST is calculating on the basis of  Charges Group if Charges are define in Fixed Value with auto assignment-equally through Invoice to Registered Customer  Interstate
        // [FEATURE] [Goods Sales Invoice] [Intra-State GST,Registered Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::"Separate Invoice");
        SetChargeGroupLineDetails(3, 0, ChargeAssignment::Equally, ComputationMethod::"Fixed Value");
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 13);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromSalesInvRegCustIntraStateWithChargeGroupandGL()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [05]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Percentage with auto assignment-equally through Invoice to Registered Customer  Intrastate.
        // [FEATURE] [Goods Sales Invoice] [Intra-State GST,Registered Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 1, ChargeAssignment::Equally, ComputationMethod::Percentage);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Goods and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 14);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries,ConfirmationHandler')]
    procedure PostFromSalesCrMemoRegCustIntraStateChargeGroupAndGlWithCopyDoc()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [06]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Percentage with auto assignment-equally, through Credit Memo with copy document to Registered Customer  Intrastate.
        // [FEATURE] [Goods Sales Cr. Memo] [Intra-State GST,Registered Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 1, ChargeAssignment::Equally, ComputationMethod::"Fixed Value");
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Cr. Memo with GST and Line Type as Goods and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Purchase Return Document created and Reference Invoice No. Updated
        CreateAndPostSalesDocumentFromCopyDocument(SalesHeader, DocumentType::"Credit Memo");

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 14);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries,GetPostedSalesDocumentLines,ConfirmationHandler')]
    procedure PostFromSalesCrMemoRegCustIntraStateWithChargeGroupPerGetPostedDoctoReverse()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [07]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Percentage with auto assignment-equally, through Credit Memo with Get Posted document line to reverse to Registered Customer  Intrastate.
        // [FEATURE] [Goods Sales Cr. Memo] [Intra-State GST,Registered Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 1, ChargeAssignment::Equally, ComputationMethod::Percentage);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Cr. Memo with GST and Line Type as Services and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Sales Return Document created and Reference Invoice No. Updated
        CreateAndPostSalesDocumentFromGetPostedDocToReverse(SalesHeader, DocumentType::"Credit Memo");

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 14);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromSalesInvRegCustInterStateChargeItemAndGlWithChargeGroup()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [09]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Fixed Value with auto assignment-By Amount through Invoice to Registered Customer  Interstate ..
        // [FEATURE] [Goods Sales Invoice] [Inter-State GST,Registered Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 1, ChargeAssignment::"By Amount", ComputationMethod::"Fixed Value");
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 10);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries,ConfirmationHandler')]
    procedure PostFromSalesCrMemoRegCustInterStateWithChargeGroupAndGlCopyDoc()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [10]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Fixed Value with auto assignment-By Amount, through Credit Memo with copy document to Registered Customer  Interstate
        // [FEATURE] [Goods Sales Cr. Memo] [Inter-State GST,Registered Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 0, ChargeAssignment::"By Amount", ComputationMethod::"Fixed Value");
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Cr. Memo with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Sales Return Document created and Reference Invoice No. Updated
        CreateAndPostSalesDocumentFromCopyDocument(SalesHeader, DocumentType::"Credit Memo");

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 9);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries,GetPostedSalesDocumentLines,ConfirmationHandler')]
    procedure PostFromSalesCrMemoRegCustInterStateWithChargeGroupGetPostedDoctoReverse()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [11]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Fixed Value with auto assignment-By Amount, through Credit Memo with Get posted document line to reverse to Registered Customer  Interstate
        // [FEATURE] [Goods Sales Cr. Memo] [Inter-State GST,Registered Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(3, 1, ChargeAssignment::"By Amount", ComputationMethod::"Fixed Value");
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Cr. Memo with GST and Line Type as Services and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Sales Return Document created and Reference Invoice No. Updated
        CreateAndPostSalesDocumentFromGetPostedDocToReverse(SalesHeader, DocumentType::"Credit Memo");

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 10);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromSalesInvExemptedCustIntraStateWithChargeGroup()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [13]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Percentage with auto assignment-equally through Invoice to Exempted Customer  Intrastate
        // [FEATURE] [Goods Sales Invoice] [Intra-State GST,Exempted Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Exempted, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::Equally, ComputationMethod::Percentage);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries,ConfirmationHandler')]
    procedure PostFromSalesCrMemoExemptedCustIntraStateWithChargeGroupAndGLCopyDoc()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [14]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Percentage with auto assignment-equally, through Credit Memo with copy document to Exempted Customer  Intrastate
        // [FEATURE] [Goods Sales Cr. Memo] [Intra-State GST,Exempted Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Exempted, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::Equally, ComputationMethod::Percentage);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Cr. Memo with GST and Line Type as Goods and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Sales Return Document created and Reference Invoice No. Updated
        CreateAndPostSalesDocumentFromCopyDocument(SalesHeader, DocumentType::"Credit Memo");

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries,GetPostedSalesDocumentLines,ConfirmationHandler')]
    procedure PostFromSalesCrMemoExemptedCustIntraStateWithChargeGroupGetPostedDoctoReverse()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [15]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Percentage with auto assignment-equally, through Credit Memo with Get posted document line to reverse to Exempted  Intrastate
        // [FEATURE] [Goods Sales Cr. Memo] [Intra-State GST,Exempted Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Exempted, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::Equally, ComputationMethod::Percentage);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Cr. Memo with GST and Line Type as Services and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Sales Return Document created and Reference Invoice No. Updated
        CreateAndPostSalesDocumentFromGetPostedDocToReverse(SalesHeader, DocumentType::"Credit Memo");

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromSalesInvExemptedCustInterStateWithChargeGroup()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [17]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Fixed Value with auto assignment-By Amount through Invoice to Exempted Customer  Interstate
        // [FEATURE] [Goods Sales Invoice] [Inter-State GST,Exempted Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Exempted, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::"Fixed Value");
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item and InterState Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries,ConfirmationHandler')]
    procedure PostFromSalesCrMemoExemptedCustInterStateWithChargeGroupAndGLCopyDoc()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [18]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Fixed Value with auto assignment-By Amount, through Credit Memo to Exempted Customer  Interstate
        // [FEATURE] [Goods Sales Cr. Memo] [Inter-State GST,Exempted Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Exempted, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::"Fixed Value");
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Cr. Memo with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Sales Return Document created and Reference Invoice No. Updated
        CreateAndPostSalesDocumentFromCopyDocument(SalesHeader, DocumentType::"Credit Memo");

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromSalesInvSezDevCustInterStateWithChargeGroup()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [19]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Amount per Quantity  with auto assignment-By Amount through Invoice to SEZ Customer  Interstate
        // [FEATURE] [Goods Sales Invoice] [Inter-State GST,SEZ\Development Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::"Amount Per Quantity");
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item and InterState Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 12);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries,ConfirmationHandler')]
    procedure PostFromSalesCrMemoSEZDevCustInterStateWithChargeGroupAndGLCopyDoc()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [20]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Percentage with auto assignment-By Amount, through Credit Memo with copy document to SEZ Customer  Interstate
        // [FEATURE] [Goods Sales Cr. Memo] [Inter-State GST,SEZ\Development Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::Percentage);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Cr. Memo with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Sales Return Document created and Reference Invoice No. Updated
        CreateAndPostSalesDocumentFromCopyDocument(SalesHeader, DocumentType::"Credit Memo");

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 12);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromSalesInvSezDevCustInterStateWithChargeGroupWithOutPaymentodDuty()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [23]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Amount per Quantity  with auto assignment-By Amount through Invoice to SEZ Customer  Interstate
        // [FEATURE] [Goods Sales Invoice] [Inter-State GST,SEZ\Development Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::"Amount Per Quantity");
        Storage.Set(NoOfLineLbl, '1');
        SalesWithoutPaymentofDuty(true);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item and InterState Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries,ConfirmationHandler')]
    procedure PostFromSalesCrMemoSEZDevCustInterStateWithChargeGroupAndGLCopyDocWithoutPayofDuty()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [24]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Percentage with auto assignment-By Amount, through Credit Memo with copy document to SEZ Customer  Interstate
        // [FEATURE] [Goods Sales Cr. Memo] [Inter-State GST,SEZ\Development Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::Percentage);
        Storage.Set(NoOfLineLbl, '1');
        SalesWithoutPaymentofDuty(true);

        // [WHEN] Create and Post Sales Cr. Memo with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Sales Return Document created and Reference Invoice No. Updated
        CreateAndPostSalesDocumentFromCopyDocument(SalesHeader, DocumentType::"Credit Memo");

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromSalesInvSezDevCustInterStateWithChargeGroupPostGSTtoCustomer()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [27]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Amount per Quantity  with auto assignment-By Amount through Invoice to SEZ Customer  Interstate
        // [FEATURE] [Goods Sales Invoice] [Inter-State GST,SEZ\Development Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::"Amount Per Quantity");
        Storage.Set(NoOfLineLbl, '1');
        PostGSTtoCustomer(true);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item and InterState Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries,ConfirmationHandler')]
    procedure PostFromSalesCrMemoSEZDevCustInterStateWithChargeGroupAndGLCopyDocPostGSTtoCustomer()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [28]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Percentage with auto assignment-By Amount, through Credit Memo with copy document to SEZ Customer  Interstate
        // [FEATURE] [Goods Sales Cr. Memo] [Inter-State GST,SEZ\Development Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"SEZ Development", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::Percentage);
        Storage.Set(NoOfLineLbl, '1');
        PostGSTtoCustomer(true);

        // [WHEN] Create and Post Sales Cr. Memo with GST and Line Type as Goods and Interstate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Sales Return Document created and Reference Invoice No. Updated
        CreateAndPostSalesDocumentFromCopyDocument(SalesHeader, DocumentType::"Credit Memo");

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ReferencePageHandler,CustomerLedgerEntries,GetPostedSalesDocumentLines,ConfirmationHandler')]
    procedure PostFromSalesCrMemoExportCustInterStateWithChargeGroupGetPostedDoctoReversePostGSTtoCustomer()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [41]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Amount per Quantity  with auto assignment-By Amount through Credit Memo with Get posted document line to reverse to Export  Customer  Interstate ..
        // [FEATURE] [Goods Sales Cr. Memo] [Interstate GST,Expot Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::Export, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::Equally, ComputationMethod::Percentage);
        Storage.Set(NoOfLineLbl, '1');
        PostGSTtoCustomer(true);

        // [WHEN] Create and Post Sales Cr. Memo with GST and Line Type as Services and Intrastate Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] Sales Return Document created and Reference Invoice No. Updated
        CreateAndPostSalesDocumentFromGetPostedDocToReverse(SalesHeader, DocumentType::"Credit Memo");

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromSalesInvDeemedExportCustInterStateWithChargeGroup()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [55]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Amount per Quantity  with auto assignment-By Amount through Invoice to Deemed Export  Customer  Interstate ..
        // [FEATURE] [Goods Sales Invoice] [Inter-State GST,DeemedExport Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"Deemed Export", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::"Amount Per Quantity");
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item and InterState Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6);//Change from 12 to 6
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromSalesInvDeemedExportCustInterStateWithChargeGroupWithOutPaymentodDuty()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [59]
        // [SCENARIO] [435451] Check GST is calculating on the basis of  Charges Group if Charges are define in Amount per Quantity  with auto assignment-By Amount through Invoice to SEZ Customer  Interstate
        // [FEATURE] [Goods Sales Invoice] [Inter-State GST,SEZ\Development Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"Deemed Export", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::"Amount Per Quantity");
        Storage.Set(NoOfLineLbl, '1');
        SalesWithoutPaymentofDuty(true);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item and InterState Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmationHandler')]
    procedure PostFromSalesInvDeemedExportCustInterStateWithChargeGroupPostGSTtoCustomer()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ChargeGroupHeader: Record "Charge Group Header";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        InvoiceCombination: Enum "Charge Group Invoice Comb.";
        LineType: Enum "Sales Line Type";
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method";
        PostedDocumentNo: Code[20];
    begin
        // [Test Case] [63]
        // [SCENARIO] [435451]  Check GST is calculating on the basis of  Charges Group if Charges are define in Amount per Quantity  with auto assignment-By Amount through Invoice to Deemed Export  Customer  Interstate ..
        // [FEATURE] [Goods Sales Invoice] [Inter-State GST,Deemed Export Customer]
        // [GIVEN] Created GST Setup
        CreateGSTSetup(GSTCustomeType::"Deemed Export", GSTGroupType::Goods, false);
        InitializeShareStep(false, false);
        CreateChargeGroupHeader(ChargeGroupHeader, InvoiceCombination::" ");
        SetChargeGroupLineDetails(2, 2, ChargeAssignment::"By Amount", ComputationMethod::"Amount Per Quantity");
        Storage.Set(NoOfLineLbl, '1');
        PostGSTtoCustomer(true);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item and InterState Juridisction
        PostedDocumentNo := CreateAndPostSalesDocumentWithChargeGroup(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        // [THEN] G/L Entries verified
        LibraryCharge.VerifyGLEntries(DocumentType::Invoice, PostedDocumentNo, 6);
    end;

    local procedure SalesWithoutPaymentofDuty(WithOutPayofDuty: Boolean)
    begin
        StorageBoolean.Set(WithoutPaymentofDutyLbl, WithOutPayofDuty);
    end;

    local procedure PostGSTtoCustomer(PostGSTCust: Boolean)
    begin
        StorageBoolean.Set(PostGSTtoCustomerlbl, PostGSTCust);
    end;

    local procedure CreateAndPostSalesDocumentFromCopyDocument(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type")
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        ReverseDocumentNo: Code[20];
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, Storage.Get(CustomerNoLbl));
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Validate("Location Code", Storage.Get(LocationCodeLbl));
        SalesHeader.Modify(true);
        CopyDocumentMgt.SetProperties(true, false, false, false, true, false, false);
        CopyDocumentMgt.CopySalesDocForInvoiceCancelling(Storage.Get(PostedDocumentNoLbl), SalesHeader);
        UpdateReferenceInvoiceNoAndVerify(SalesHeader);

        ReverseDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Storage.Set(ReverseDocumentNoLbl, ReverseDocumentNo);
    end;

    local procedure CreateAndPostSalesDocumentFromGetPostedDocToReverse(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type")
    var
        ReverseDocumentNo: Code[20];
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, Storage.Get(CustomerNoLbl));
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Validate("Location Code", Storage.Get(LocationCodeLbl));
        SalesHeader.Modify(true);
        GetPostedDocumentToReverse(SalesHeader);
        UpdateReferenceInvoiceNoAndVerify(SalesHeader);

        ReverseDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Storage.Set(ReverseDocumentNoLbl, ReverseDocumentNo);
    end;

    local procedure UpdateReferenceInvoiceNoAndVerify(SalesHeader: Record "Sales Header")
    var
        SalesReturnOrder: TestPage "Sales Return Order";
        SalesCreditMemo: TestPage "Sales Credit Memo";
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then begin
            SalesReturnOrder.OpenEdit();
            SalesReturnOrder.Filter.SetFilter("No.", SalesHeader."No.");
            SalesReturnOrder."Update Reference Invoice No.".Invoke();
        end else begin
            SalesCreditMemo.OpenEdit();
            SalesCreditMemo.Filter.SetFilter("No.", SalesHeader."No.");
            SalesCreditMemo."Update Reference Invoice No.".Invoke();
        end;
    end;

    local procedure GetPostedDocumentToReverse(SalesHeader: Record "Sales Header")
    begin
        SalesHeader.GetPstdDocLinesToReverse();
    end;

    local procedure UpdateCustomerSetupWithGST(
        CustomerNo: Code[20];
        GSTCustomerType: Enum "GST Customer Type";
        StateCode: Code[10];
        PANNo: Code[20])
    var
        Customer: Record Customer;
        State: Record State;
    begin
        Customer.Get(CustomerNo);
        if GSTCustomerType <> GSTCustomerType::Export then begin
            State.Get(StateCode);
            Customer.Validate("State Code", StateCode);
            Customer.Validate("P.A.N. No.", PANNo);
            if not ((GSTCustomerType = GSTCustomerType::" ") or (GSTCustomerType = GSTCustomerType::Unregistered)) then
                Customer.Validate("GST Registration No.", LibraryCharge.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo));
        end;

        Customer.Validate(Address, CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(Customer.Address)));
        Customer.Validate("GST Customer Type", GSTCustomerType);
        if GSTCustomerType = GSTCustomerType::Export then
            Customer.Validate("Currency Code", LibraryCharge.CreateCurrencyCode());
        Customer.Modify(true);
    end;

    local procedure CreateGSTSetup(
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        IntraState: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        TaxComponent: Record "Tax Component";
        CompanyInformation: Record "Company information";
        LocationStateCode: Code[10];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        CustomerStateCode: Code[10];
        LocPANNo: Code[20];
        HSNSACCode: Code[10];
        GSTGroupCode: Code[20];
        LocationGSTRegNo: Code[15];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTComponentCode: Text[30];
    begin
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := LibraryCharge.CreatePANNos();
            CompanyInformation.Modify();
        end else
            LocPANNo := CompanyInformation."P.A.N. No.";

        LocPANNo := CompanyInformation."P.A.N. No.";
        LocationStateCode := LibraryCharge.CreateInitialSetup();
        Storage.Set(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryCharge.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true);
        end;

        LocationCode := LibraryCharge.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        Storage.Set(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryCharge.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::" ", false);
        Storage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryCharge.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        Storage.Set(HSNSACCodeLbl, HSNSACCode);

        if IntraState then begin
            CustomerNo := LibraryCharge.CreateCustomerSetup();
            UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, LocationStateCode, LocPANNo);
            InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
        end else begin
            CustomerStateCode := LibraryCharge.CreateGSTStateCode();
            CustomerNo := LibraryCharge.CreateCustomerSetup();
            UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, CustomerStateCode, LocPANNo);
            if GSTCustomerType in [GSTCustomerType::Export, GSTCustomerType::"SEZ Unit", GSTCustomerType::"SEZ Development"] then
                InitializeTaxRateParameters(IntraState, '', LocationStateCode)
            else
                InitializeTaxRateParameters(IntraState, CustomerStateCode, LocationStateCode);
        end;
        Storage.Set(CustomerNoLbl, CustomerNo);

        CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);

        CreateTaxRate();
    end;

    local procedure InitializeShareStep(Exempted: Boolean; LineDiscount: Boolean)
    begin
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
    end;

    local procedure CreateGSTComponentAndPostingSetup(
        IntraState: Boolean;
        LocationStateCode: Code[10];
        TaxComponent: Record "Tax Component";
        GSTComponentCode: Text[30])
    var
        POS: Boolean;
    begin
        if StorageBoolean.ContainsKey(POSLbl) then
            POS := StorageBoolean.Get(POSLbl);

        if IntraState then begin
            if POS then begin
                GSTComponentCode := IGSTLbl;
                LibraryCharge.CreateGSTComponent(TaxComponent, GSTComponentCode);
                LibraryCharge.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
            end else begin
                GSTComponentCode := CGSTLbl;
                LibraryCharge.CreateGSTComponent(TaxComponent, GSTComponentCode);
                LibraryCharge.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

                GSTComponentCode := SGSTLbl;
                LibraryCharge.CreateGSTComponent(TaxComponent, GSTComponentCode);
                LibraryCharge.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
            end;
        end else begin
            GSTComponentCode := IGSTLbl;
            LibraryCharge.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryCharge.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end;
    end;

    local procedure InitializeTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10])
    var
        GSTTaxPercent: Decimal;
        KFCCESS: Boolean;
        POS: Boolean;
    begin
        Storage.Set(FromStateCodeLbl, FromState);
        Storage.Set(ToStateCodeLbl, ToState);

        if StorageBoolean.ContainsKey(KeralaCESSLbl) then
            KFCCESS := StorageBoolean.Get(KeralaCESSLbl);

        if StorageBoolean.ContainsKey(POSLbl) then
            POS := StorageBoolean.Get(POSLbl);

        GSTTaxPercent := LibraryRandom.RandDecInRange(10, 18, 0);
        if IntraState then begin
            if POS then
                ComponentPerArray[4] := GSTTaxPercent
            else begin
                ComponentPerArray[1] := (GSTTaxPercent / 2);
                ComponentPerArray[2] := (GSTTaxPercent / 2);
                if KFCCESS then
                    ComponentPerArray[3] := LibraryRandom.RandDecInRange(1, 4, 0);
            end;
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

    local procedure CreateSalesHeaderWithGST(
        var SalesHeader: Record "Sales Header";
        CustomerNo: Code[20];
        DocumentType: Enum "Sales Document Type";
        LocationCode: Code[10])
    var
        WithoutPaymentofDuty: Boolean;
        PostGSTtoCustomer: Boolean;
        POS: Boolean;
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Validate("Location Code", LocationCode);

        if StorageBoolean.ContainsKey(WithoutPaymentofDutyLbl) then begin
            WithoutPaymentofDuty := StorageBoolean.Get(WithoutPaymentofDutyLbl);
            if WithoutPaymentofDuty then
                SalesHeader.Validate("GST Without Payment of Duty", true);
        end;

        if StorageBoolean.ContainsKey(POSLbl) then begin
            POS := StorageBoolean.Get(POSLbl);
            if POS then begin
                SalesHeader.Validate("GST Invoice", true);
                SalesHeader.Validate("POS Out Of India", true);
            end
        end;

        if StorageBoolean.ContainsKey(PostGSTtoCustomerlbl) then begin
            PostGSTtoCustomer := StorageBoolean.Get(PostGSTtoCustomerlbl);
            if PostGSTtoCustomer then
                SalesHeader.Validate("Post GST to Customer", true);
        end;

        SalesHeader.Modify(true);
    end;

    local procedure CreateSalesLineWithGST(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
        Quantity: Decimal;
        Exempted: Boolean;
        LineDiscount: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LineTypeNo: Code[20];
        LineNo: Integer;
        NoOfLine: Integer;
    begin
        if not Storage.ContainsKey(NoOfLineLbl) then
            NoOfLine := 1
        else
            Evaluate(NoOfLine, Storage.Get(NoOfLineLbl));

        for LineNo := 1 to NoOfLine do begin
            case LineType of
                LineType::Item:
                    LineTypeNo := LibraryCharge.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
                LineType::"G/L Account":
                    LineTypeNo := LibraryCharge.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
                LineType::"Fixed Asset":
                    LineTypeNo := LibraryCharge.CreateFixedAssetWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
            end;

            LibrarySales.CreateSalesLine(SalesLine, SalesHeader, LineType, LineTypeno, Quantity);
            SalesLine.Validate("VAT Prod. Posting Group", VATPostingsetup."VAT Prod. Posting Group");
            if StorageBoolean.ContainsKey(PartialShipLbl) then begin
                if StorageBoolean.Get(PartialShipLbl) then
                    SalesLine.Validate(SalesLine."Qty. to Ship", Quantity / 2);
                SalesLine.Validate(SalesLine."Qty. to Invoice", Quantity / 2);
                StorageBoolean.Remove(PartialShipLbl);
            end;
            if LineDiscount then begin
                SalesLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
                LibraryCharge.UpdateLineDiscAccInGeneralPostingSetup(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
            end;

            if StorageBoolean.ContainsKey(PriceInclusiveOfTaxLbl) then
                if StorageBoolean.Get(PriceInclusiveOfTaxLbl) = true then
                    SalesLine.Validate("Price Inclusive of Tax", true);
            SalesLine.Validate("Unit Price Incl. of Tax", LibraryRandom.RandInt(10000));

            SalesLine.Validate("Unit Price", LibraryRandom.RandInt(10000));
            SalesLine.Modify(true);
            CalculateGSTOnSalesLine(SalesLine);
        end;
    end;

    local procedure CalculateGSTOnSalesLine(SalesLine: Record "Sales Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnSalesLine(SalesLine, SalesLine);
    end;

    procedure CreateChargeGroupHeader(var ChargeGroupHeader: Record "Charge Group Header"; InvoiceCombination: Enum "Charge Group Invoice Comb.")
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
        SetStorageLibrarySalesText(ChargeGroupCodeLbl, ChargeGroupHeader.Code);
    end;

    local procedure SetStorageLibrarySalesText(KeyValue: Text[20]; Value: Text[20])
    begin
        Storage.Set(KeyValue, Value);
    end;

    local procedure SetChargeGroupLineDetails(
        NoOfChargeLine: Integer;
        NoOfGlLine: Integer;
        ChargeAssignment: Enum "Charge Assignment";
        ComputationMethod: Enum "Charge Computation Method")
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

    local procedure SetChargeItem(ChargeAssignment: Enum "Charge Assignment";
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
            ChargeGroupLine."No." := LibraryCharge.CreateChargeItemWithGSTDetailsForChargeGroup(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true,
               (StorageBoolean.Get(ExemptedLbl)))
        end else begin
            ChargeGroupLine.Validate(Type, ChargeGroupLine.Type::"G/L Account");
            ChargeGroupLine."No." := LibraryCharge.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true,
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

    local procedure CreateAndPostSalesDocumentWithChargeGroup(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
        DocumentType: Enum "Sales Document Type"): Code[20];
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CustomerNo: Code[20];
        LocationCode: Code[10];
        PostedDocumentNo: Code[20];
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Generate E-Inv. on Sales Post" = false then begin
            GeneralLedgerSetup."Generate E-Inv. on Sales Post" := true;
            GeneralLedgerSetup.Modify();
        end;

        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));

        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        UpdateChargeGroupOnSalesDocument(SalesHeader);

        CreateSalesLineWithGST(SalesHeader, SalesLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        InsertChargeGroupLinsOnSalesDocument(SalesHeader);
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, PostedDocumentNo);
        exit(PostedDocumentNo);
    end;

    local procedure UpdateChargeGroupOnSalesDocument(var SalesHeader: Record "Sales Header")
    var
        ChargeGroupHeader: Record "Charge Group Header";
    begin
        if not ChargeGroupHeader.Get(Storage.Get(ChargeGroupCodeLbl)) then
            exit;

        SalesHeader.Validate("Charge Group Code", ChargeGroupHeader.Code);
        SalesHeader.Modify(true);
    end;

    local procedure InsertChargeGroupLinsOnSalesDocument(SalesHeader: Record "Sales Header")
    begin
        case SalesHeader."Document Type" of
            "Sales Document Type"::"Blanket Order":
                InsertChargeGroupLinsOnSalesBlanketOrderDocument(SalesHeader);
            "Sales Document Type"::"Credit Memo":
                InsertChargeGroupLinsOnSalesCreditMemoDocument(SalesHeader);
            "Sales Document Type"::Invoice:
                InsertChargeGroupLinsOnSalesInvoiceDocument(SalesHeader);
            "Sales Document Type"::Order:
                InsertChargeGroupLinsOnSalesOrderDocument(SalesHeader);
            "Sales Document Type"::Quote:
                InsertChargeGroupLinsOnSalesQuoteDocument(SalesHeader);
            "Sales Document Type"::"Return Order":
                InsertChargeGroupLinsOnSalesReturnOrderDocument(SalesHeader);
            else
                InsertChargeGroupLinsOnSalesDocuments(SalesHeader);
        end;
    end;

    local procedure InsertChargeGroupLinsOnSalesDocuments(SalesHeader: Record "Sales Header")
    var
        ChargeGroupManagement: Codeunit "Charge Group Management";
    begin
        ChargeGroupManagement.InsertChargeItemOnLine(SalesHeader);
    end;

    local procedure InsertChargeGroupLinsOnSalesBlanketOrderDocument(SalesHeader: Record "Sales Header")
    var
        BlanketSalesOrder: TestPage "Blanket Sales Order";
    begin
        BlanketSalesOrder.OpenEdit();
        BlanketSalesOrder.GoToRecord(SalesHeader);
        BlanketSalesOrder.SalesLines."Explode Charge Group".Invoke();
    end;

    local procedure InsertChargeGroupLinsOnSalesCreditMemoDocument(SalesHeader: Record "Sales Header")
    var
        SalesCreditMemo: TestPage "Sales Credit Memo";
    begin
        SalesCreditMemo.OpenEdit();
        SalesCreditMemo.GoToRecord(SalesHeader);
        SalesCreditMemo.SalesLines."Explode Charge Group".Invoke();
    end;

    local procedure InsertChargeGroupLinsOnSalesInvoiceDocument(SalesHeader: Record "Sales Header")
    var
        SalesInvoice: TestPage "Sales Invoice";
    begin
        SalesInvoice.OpenEdit();
        SalesInvoice.GoToRecord(SalesHeader);
        SalesInvoice.SalesLines."Explode Charge Group".Invoke();
    end;

    local procedure InsertChargeGroupLinsOnSalesOrderDocument(SalesHeader: Record "Sales Header")
    var
        SalesOrder: TestPage "Sales Order";
    begin
        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);
        SalesOrder.SalesLines."Explode Charge Group".Invoke();
    end;

    local procedure InsertChargeGroupLinsOnSalesQuoteDocument(SalesHeader: Record "Sales Header")
    var
        SalesQuote: TestPage "Sales Quote";
    begin
        SalesQuote.OpenEdit();
        SalesQuote.GoToRecord(SalesHeader);
        SalesQuote.SalesLines."Explode Charge Group".Invoke();
    end;

    local procedure InsertChargeGroupLinsOnSalesReturnOrderDocument(SalesHeader: Record "Sales Header")
    var
        SalesReturnOrder: TestPage "Sales Return Order";
    begin
        SalesReturnOrder.OpenEdit();
        SalesReturnOrder.GoToRecord(SalesHeader);
        SalesReturnOrder.SalesLines."Explode Charge Group".Invoke();
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    var
        POS: Boolean;
    begin
        if StorageBoolean.ContainsKey(POSLbl) then
            POS := StorageBoolean.Get(POSLbl);
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(GSTGroupCodeLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(HSNSACCodeLbl));
        TaxRates.AttributeValue3.SetValue(Storage.Get(FromStateCodeLbl));
        TaxRates.AttributeValue4.SetValue(Storage.Get(ToStateCodeLbl));
        TaxRates.AttributeValue5.SetValue(Today);
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', Today));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]);
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]);
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]);
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[3]);
        if POS then
            TaxRates.AttributeValue11.SetValue(POS)
        else
            TaxRates.AttributeValue11.SetValue(POS);
        TaxRates.OK().Invoke();
        POS := false;
    end;

    [PageHandler]
    procedure ReferencePageHandler(var UpdateReferenceInvoiceNo: TestPage "Update Reference Invoice No")
    begin
        UpdateReferenceInvoiceNo."Reference Invoice Nos.".Lookup();
        UpdateReferenceInvoiceNo."Reference Invoice Nos.".SetValue(Storage.Get(PostedDocumentNoLbl));
        UpdateReferenceInvoiceNo.Verify.Invoke();
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
            ChargeNo := LibraryCharge.CreateChargeItemWithGSTDetailsForChargeGroup(VATPostingSetup,
            (Storage.Get(GSTGroupCodeLbl)),
            (Storage.Get(HSNSACCodeLbl)),
            true,
            (StorageBoolean.Get(ExemptedLbl)))
        end
        else begin
            ChargeGroupLines.Type.SetValue(ChargeGroupType::"G/L Account");
            ChargeNo := LibraryCharge.CreateGLAccWithGSTDetails(VATPostingSetup,
            (Storage.Get(GSTGroupCodeLbl)),
            (Storage.Get(HSNSACCodeLbl)),
            true,
            (StorageBoolean.Get(ExemptedLbl)));
        end;
        ChargeGroupLines."No.".SetValue(ChargeNo);
        ChargeGroupLines.Assignment.SetValue(StorageChargeGroupAssignment.Get(ChargeAssignmentLbl));

        ChargeGroupLines."Computation Method".SetValue(StorageChargeGroupComputationMethod.Get(ChargeComputationMethodLbl));
        ChargeGroupLines.Value.SetValue(LibraryRandom.RandDecInRange(10, 20, 0));
        ChargeGroupLines.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure GetPostedSalesDocumentLines(var PostedSalesDocumentLines: TestPage "Posted Sales Document Lines")
    begin
        PostedSalesDocumentLines.PostedInvoices.Filter.SetFilter("Document No.", Storage.Get(PostedDocumentNoLbl));
        PostedSalesDocumentLines.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CustomerLedgerEntries(var CustomerLedgerEntries: TestPage "Customer Ledger Entries")
    begin
        CustomerLedgerEntries.Filter.SetFilter("Document No.", Storage.Get(PostedDocumentNoLbl));
        CustomerLedgerEntries.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ApplyAdjustmentEntries(var PayGST: TestPage "Pay GST")
    begin
        PayGST.Post.Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmationHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure PostMessageHandler(Message: Text[1024])
    begin
        if Message <> SuccessMsg then
            Error(NotPostedErr);
    end;
}
codeunit 18272 "GST On Journals For Vendor"
{
    Subtype = Test;

    var
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryRandom: Codeunit "Library - Random";
        LibraryGST: Codeunit "Library GST";
        LibraryERM: Codeunit "Library - ERM";
        LibraryJournals: Codeunit "Library - Journals";
        ComponentPerArray: array[20] of Decimal;
        Storage: Dictionary of [Text, Text[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
        LocationCodeLbl: Label 'LocationCode';
        POSoutOfIndiaLbl: Label 'POSoutOfIndia';
        LocationStateCodeLbl: Label 'LocationStateCode';
        ExemptedLbl: Label 'Exempted';
        AssociateEnterpriseLbl: Label 'AssociateEnterprise';
        POSLbl: Label 'POS';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        FromStateCodeLbl: Label 'FromStateCode';
        InputCreditAvailmentLbl: Label 'InputCreditAvailment';
        VendorNoLbl: Label 'VendorNo';
        ToStateCodeLbl: Label 'ToStateCode';
        TemplateNameLbl: Label 'TemplateName';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
        GSTLEVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
        VendGSTTypeErr: Label 'You can select POS Out Of India field on header only if GST Vendor Type is Registered.';
        POSAsVednorStateErr: Label 'POS Out Of India must be equal to ''No''  in Gen. Journal Line: Journal Template Name=%1, Journal Batch Name=%2, Line No.=%3. Current value is ''Yes''.', Comment = '%1 = Journal Template Name,%2 = Journal Batch Name,%3= Line No.';

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckGSTTDSTCSGSTJurisdictionType()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] Check If system is assigning GST Jurisdiction Type, from Purchase Journals for Registered Vendor for GST TDS/TCS.

        // [GIVEN] Gen Journal Line for Account Type Vendor and GST TDS/GST TCS.
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Payment, GenJournalLine, TemplateType::Purchases);
        ProvideGSTTDSTCValue(GenJournalLine);

        // [WHEN] The function GSTTDSTCS is called.
        GSTJournalLineValidations.OnValidateGSTTDSTCS(GenJournalLine);

        //[THEN] Verify GST Jurisdiction Type
        Assert.AreNotEqual('', GenJournalLine."GST Jurisdiction Type",
            StrSubstNo(GSTLEVerifyErr, GenJournalLine.FieldName("GST Jurisdiction Type"), GenJournalLine.TableCaption));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckPosOutofIndiaImportVendor()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] Check If system is only allowing POS out of India for Registered Vendor.

        // [GIVEN] Gen Journal Line for Account Type Vendor and POS out of India.
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, true, false);
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases);
        ProvidePOSOutofIndiaValue(GenJournalLine);

        // [WHEN] The function Pos out of India is called.
        asserterror GSTJournalLineValidations.POSOutOfIndia(GenJournalLine);

        //[THEN] Verify error message for Vendor Type.
        Assert.ExpectedError(VendGSTTypeErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckAccountNoPartyTypeVendor()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
    begin
        // [SCENARIO] Check if system assigning same value in account no. as party code for party type Vendor .

        // [GIVEN] Gen journal line for party type vendor.
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        CreateGenJnlLineFromPartyTypeVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases);

        // [WHEN] The function PartyCode is called.
        GSTJournalLineValidations.PartyCode(GenJournalLine);

        //[THEN] Verify the account no. is same as party code.
        Assert.Compare(GenJournalLine."Party Code", GenJournalLine."Account No.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckPosAsVendorStateWithPOSoutOfIndia()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] Check if system is allowing POS as vendor state, when POS out of India is false.

        // [GIVEN] Gen Journal Line for Account Type Vendor and POS as vendor state.
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases);
        ProvidePOSAsVendorStateValue(GenJournalLine);

        // [WHEN] The function Pos as vendor state is called.
        asserterror GSTJournalLineValidations.POSasVendorState(GenJournalLine);

        //[THEN] Verify error message for Pos out of India.
        Assert.AreEqual(StrSubstNo(POSAsVednorStateErr,
                        GenJournalLine."Journal Template Name",
                        GenJournalLine."Journal Batch Name",
                        GenJournalLine."Line No."),
                        GetLastErrorText,
                        '');
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckBalVendNo()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        PartyCode: Code[20];
    begin
        // [SCENARIO] Check if system assigning GST vendor type same as bal vendor, when party type vendor.

        // [GIVEN] Gen journal line for party type vendor.
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        PartyCode := LibraryGST.CreateVendorParties(GSTVendorType::Registered);
        CreateGenJnlLineFromPartyTypeVendorInvoice(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases, PartyCode);
        Vendor.Get(GenJournalLine."Account No.");

        // [WHEN] The function BalVendNo is called.
        GSTJournalLineValidations.BalVendNo(GenJournalLine, Vendor);

        //[THEN] Verify the gst vendor type same in gen. journal line.
        Assert.Compare(GenJournalLine."GST Vendor Type", Vendor."GST Vendor Type");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckABSValueGSTAssessableValue()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] Check if system assign abs value in GST Assessable Value.

        // [GIVEN] Gen Journal Line for Account Type Vendor and GST Assessable Value.
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases);
        AssignNegativeGSTAssessableValue(GenJournalLine);

        // [WHEN] The function GSTAssessableValue is called.
        GSTJournalLineValidations.GSTAssessableValue(GenJournalLine);

        //[THEN] Verify GST Assessable Value is positive.
        Assert.AreNearlyEqual(GenJournalLine.Amount,
        GenJournalLine."GST Assessable Value",
        GenJournalLine.Amount - GenJournalLine."GST Assessable Value",
        StrSubstNo(GSTLEVerifyErr,
            GenJournalLine.FieldName("GST Assessable Value"),
            GenJournalLine.TableCaption)
            );
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckABSValueGSTCustomDutyAmount()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] Check if system assign abs value in GST Custom Duty Amount.

        // [GIVEN] Gen Journal Line for Account Type Vendor and GST Custom Duty Amount.
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases);
        AssignNegativeGSTCustomDutyAmount(GenJournalLine);

        // [WHEN] The function CustomDutyAmount is called.
        GSTJournalLineValidations.CustomDutyAmount(GenJournalLine);

        //[THEN] Verify GST Custom Duty is positive.
        Assert.AreNearlyEqual(GenJournalLine.Amount,
        GenJournalLine."Custom Duty Amount",
        GenJournalLine.Amount - GenJournalLine."Custom Duty Amount",
        StrSubstNo(GSTLEVerifyErr,
            GenJournalLine.FieldName("Custom Duty Amount"),
            GenJournalLine.TableCaption)
            );
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseJournalWithITCForRegisetredVendor()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355324] Check If system is calculating GST when Invoice created from Purchase Journals for Registered Vendor.

        // [GIVEN] Created GST Setup and tax rates for registered customer
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post Purchase Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseJournalWithITCForUnregisetredVendor()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355325] Check If system is calculating GST when Invoice created from Purchase Journals for Unregistered Vendor.

        // [GIVEN] Created GST Setup Customer type is Unregistered and GST Group type is Service
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);

        // [WHEN] Create and Post Purchase Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseJournalWithITCForImportVendor()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355326] Check If system is calculating GST when Invoice created from Purchase Journals for Import Vendor.

        // [GIVEN] Created GST Setup customer type is import and gst group type is service
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);

        // [WHEN] Create and Post Purchase Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseJournalWithITCForAssociateVendor()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355327] Check If system is calculating GST when Invoice created from Purchase Journals for Associate Import Vendor.

        // [GIVEN] Created GST Setup with Customer type is Import and GST group type is Srvice and Jurisdiction is Interstate
        InitializeShareStep(true, false);
        InitializeAssociateVendor(true);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);

        // [WHEN] Create and Post Purchase Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalWithReverseChargeWithoutInputCreditAvailmentForUnregisetredVendor()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [357299] Intra-State Purchase of Services from an Unregistered Vendor where Input Tax Credit is not available (Reverse Charge) through General Journal

        // [GIVEN] Created GST Setup Customer type is unregistered and gts group type is services
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, true);

        // [WHEN] Create and Post General Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::General);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseJournalWithReverseChargeWithAvailment()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [357303] Intra-State Purchase of Services from an Registered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Journal

        // [GIVEN] Created GST Setup Customer is Registered and jurisdiction is Intrastate
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);

        // [WHEN] Create and Post Purchase Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseJournalWithReverseChargeWithoutInputCreditAvailment()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [357444] Intra-State Purchase of Services from an Registered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Journal

        // [GIVEN] Created GST Setup with GST Customer type is Registered and GST group type is Service
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, true);

        // [WHEN] Create and Post Purchase Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromFAGLournalForRegisteredWithAvailmentForIntraState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355329] Check If system is calculating GST when Invoice created from FA G/L Journals for Registered Vendor 

        // [GIVEN] Created GST Setup and Customer is Registred with GST group type Service and Jusrisdiction is Intrastate
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post FA G/L Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Assets);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromFAGLournalForImportWithAvailmentForInterState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355331] Check If system is calculating GST when Invoice created from FA G/L Journals for Import Vendor 

        // [GIVEN] Created GST Setup with Customer type is Import and GSt goup type is Service
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, false);

        // [WHEN] Create and Post FA G/L Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Assets);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromFAGLournalCreditMemoForRegisteredWithAvailmentForIntraState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355374] Check If system is calculating GST when Credit Memo created from FA G/L Journals for Registered Vendor 

        // [GIVEN] Created GST Setup with Customer is Registered and GST Group type is Service with Intrastate Jurisdiction
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post FA G/L Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::"Credit Memo", GenJournalLine, TemplateType::Assets);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromFAGLournalCreditMemoForUnregisteredWithAvailmentForIntraState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355376] Check If system is calculating GST when Credit Memo created from FA G/L Journals for Unregistered Vendor 

        // [GIVEN] Created GST Setup where Customer type is Registered and Jurisdiction is Interstate and GST group type is Goods
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Unregistered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post FA G/L Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::"Credit Memo", GenJournalLine, TemplateType::Assets);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseJournalForGoodsRegisteredWithoutAvailmentInterState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [357249] Inter-State Purchase of Goods from Registered Vendor where Input Tax Credit is not available through Purchase Journal

        // [GIVEN] Created GST Setup where Customer type is Registered and Jurisdiction is Interstate and GST group type is Goods
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Purchase Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalForServiceRegisteredWithAvailmentInterState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [357253] Inter-State Purchase of Services from Registered Vendor where Input Tax Credit is available through General journal

        // [GIVEN] Created GST Setup where Customer type is Registered and Jurisdiction is Interstate
        InitializeShareStep(true, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);

        // [WHEN] Create and Post General Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::General);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalForServiceRegisteredWithoutAvailmentInterState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [357263] Inter-State Purchase of Services from Registered Vendor where Input Tax Credit is not available through General journal

        // [GIVEN] Created GST Setup where Customer type is Registered and Jurisdiction is Interstate and GST group type is Service
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);

        // [WHEN] Create and Post General Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::General);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchaseJournalForRegisteredReverseInterState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [358518] Inter-State Purchase of Services from an Registered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Journal

        // [GIVEN] Created GST Setup where Customer type is Registered and Jurisdiction is Interstate
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, true);
        InitializeShareStep(true, false);

        // [WHEN] Create and Post Sales Journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,JournalTemplateHandler,ReferencePageHandler,VendorLedgerEntries')]
    procedure PostFromPurchaseJournalForRegisteredReverseInterStateCreditMemo()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        TemplateType: Enum "Gen. Journal Template Type";
        GenJnlDocType: Enum "Gen. Journal Document Type";
    begin
        // [SCENARIO] Inter-State Purchase Return of Services from an Registered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Journal

        // [GIVEN] Created GST Setup and tax rates for registred vendor with interstate jurisdiction
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, true);
        InitializeShareStep(true, false);

        // [WHEN] Create and Post Sales Journal from purchase journal
        CreateGenJnlLineFromVendorToGL(GenJnlDocType::Invoice, GenJournalLine, TemplateType::Purchases);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] create and post Credit Memo with reference invoice number
        CreateGenJnlLineforVendorToGLCreditMemo(GenJournalLine, TemplateType::Purchases);
    end;

    local procedure CreateGenJnlLineforVendorToGLCreditMemo(var GenJournalLine: Record "Gen. Journal Line"; TemplateType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VendorNo: Code[20];
        LocationCode: Code[10];
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);
        Storage.Set(TemplateNameLbl, GenJournalTemplate.Name);
        VendorNo := CopyStr(Storage.Get(VendorNoLbl), 1, 20);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));

        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::"Credit Memo",
            GenJournalLine."Account Type"::Vendor, VendorNo,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, CopyStr(Storage.Get(GSTGroupCodeLbl), 1, 20), CopyStr(Storage.Get(HSNSACCodeLbl), 1, 10), true, StorageBoolean.Get(ExemptedLbl)),
            LibraryRandom.RandIntInRange(1, 100000));

        GenJournalLine.Validate("Location Code", LocationCode);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::Purchase);
        CalculateGST(GenJournalLine);
        GenJournalLine.Modify(true);
        CalculateGST(GenJournalLine);

        UpdateReferenceInvoiceNoAndVerify();
    end;

    local procedure UpdateReferenceInvoiceNoAndVerify()
    var
        PurchaseJournal: TestPage "Purchase Journal";
    begin
        PurchaseJournal.OpenEdit();
        PurchaseJournal."Update Reference Invoice No.".Invoke();
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

    local procedure CreateGenJournalTemplateBatch(
        var GenJournalTemplate: Record "Gen. Journal Template";
        var GenJournalBatch: Record "Gen. Journal Batch";
        TemplateType: Enum "Gen. Journal Template Type")
    var
        LocationCode: Code[10];
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, TemplateType);
        GenJournalTemplate.Modify(true);

        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Location Code", LocationCode);
        GenJournalBatch.Modify(true);
    end;

    local procedure CreateGenJnlLineFromVendorToGL(
        GenJnlDocType: Enum "Gen. Journal Document Type";
        var GenJournalLine: Record "Gen. Journal Line";
        TemplateType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VendorNo: Code[20];
        LocationCode: Code[10];
        POSoutOfIndia: Boolean;
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);
        VendorNo := Storage.Get(VendorNoLbl);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJnlDocType,
            GenJournalLine."Account Type"::Vendor, VendorNo,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, CopyStr(Storage.Get(GSTGroupCodeLbl), 1, 20), CopyStr(Storage.Get(HSNSACCodeLbl), 1, 10), StorageBoolean.Get(InputCreditAvailmentLbl), StorageBoolean.Get(ExemptedLbl)),
            -LibraryRandom.RandIntInRange(1, 10000));

        GenJournalLine.Validate("Location Code", LocationCode);
        GenJournalLine.Validate("GST Group Code");
        GenJournalLine.Validate("HSN/SAC Code");
        if StorageBoolean.ContainsKey(POSoutOfIndiaLbl) then begin
            Evaluate(POSoutOfIndia, Format(StorageBoolean.Get(POSoutOfIndiaLbl)));
            GenJournalLine.Validate("POS Out Of India", POSoutOfIndia);
            POSoutOfIndia := false;
        end;

        if GenJournalLine."Document Type" in [GenJournalLine."Document Type"::"Credit Memo"] then
            GenJournalLine.Validate(Amount, -GenJournalLine.Amount)
        else
            GenJournalLine.Validate(Amount);

        CalculateGST(GenJournalLine);
        Storage.Set(PostedDocumentNoLbl, GenJournalLine."Document No.");
        GenJournalLine.Modify(true);
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

    local procedure CalculateGST(GenJournalLine: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnGenJnlLine(GenJournalLine, GenJournalLine)
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
        LocationCode: Code[10];
        VendorStateCode: Code[10];
        LocPANNo: Code[20];
        LocationGSTRegNo: Code[15];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTComponentCode: Text[30];
        GSTGroupCode: Code[20];
        HSNSACCode: Code[10];
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
        end else begin
            VendorStateCode := LibraryGST.CreateGSTStateCode();
            VendorNo := LibraryGST.CreateVendorSetup();
            if StorageBoolean.ContainsKey(AssociateEnterpriseLbl) then begin
                UpdateVendorSetupWithGST(VendorNo, GSTVendorType, StorageBoolean.Get(AssociateEnterpriseLbl), VendorStateCode, LocPANNo);
                StorageBoolean.Remove(AssociateEnterpriseLbl)
            end else
                UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, VendorStateCode, LocPANNo);
            if GSTVendorType in [GSTVendorType::Import, GSTVendorType::SEZ] then
                InitializeTaxRateParameters(IntraState, '', LocationStateCode)
            else
                InitializeTaxRateParameters(IntraState, VendorStateCode, LocationStateCode);
        end;
        Storage.Set(VendorNoLbl, VendorNo);
        CreateTaxRate();
        LibraryGST.CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
    end;

    local procedure InitializeShareStep(InputCreditAvailment: Boolean; Exempted: Boolean)
    begin
        StorageBoolean.Set(InputCreditAvailmentLbl, InputCreditAvailment);
        StorageBoolean.Set(ExemptedLbl, Exempted);
    end;

    local procedure InitializeAssociateVendor(AssociateEnterprise: Boolean)
    begin
        StorageBoolean.Set(AssociateEnterpriseLbl, AssociateEnterprise);
    end;

    local procedure InitializeTaxRateParameters(
        IntraState: Boolean;
        FromState: Code[10];
        ToState: Code[10]) GSTTaxPercent: Decimal;
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

    local procedure ProvideGSTTDSTCValue(var GenJournalLine: record "Gen. Journal Line")
    begin
        GenJournalLine."GST TCS State Code" := GenJournalLine."Location State Code";
        GenJournalLine."GST TDS/GST TCS" := GenJournalLine."GST TDS/GST TCS"::TDS;
        GenJournalLine."GST TDS/TCS Base Amount" := GenJournalLine.Amount;
        GenJournalLine.Modify(true);
    end;

    local procedure ProvidePOSOutofIndiaValue(var GenJournalLine: record "Gen. Journal Line")
    begin
        GenJournalLine."POS Out Of India" := true;
        GenJournalLine."Location State Code" := GenJournalLine."GST Ship-to State Code";
        GenJournalLine.Modify(true);
    end;

    local procedure ProvidePOSAsVendorStateValue(var GenJournalLine: record "Gen. Journal Line")
    begin
        GenJournalLine."POS Out Of India" := true;
        GenJournalLine."POS as Vendor State" := false;
        GenJournalLine."Location State Code" := GenJournalLine."GST Ship-to State Code";
        GenJournalLine.Modify(true);
    end;

    local procedure AssignNegativeGSTAssessableValue(var GenJournalLine: record "Gen. Journal Line")
    begin
        GenJournalLine."GST Assessable Value" := -Abs(GenJournalLine.Amount);
        GenJournalLine.Modify(true);
    end;

    local procedure AssignNegativeGSTCustomDutyAmount(var GenJournalLine: record "Gen. Journal Line")
    begin
        GenJournalLine."Custom Duty Amount" := -Abs(GenJournalLine.Amount);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateGenJnlLineFromPartyTypeVendorToGL(
            GenJnlDocType: Enum "Gen. Journal Document Type";
            var GenJournalLine: Record "Gen. Journal Line";
            TemplateType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VendorNo: Code[20];
        LocationCode: Code[10];
        POSoutOfIndia: Boolean;
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);
        VendorNo := Storage.Get(VendorNoLbl);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        LibraryJournals.CreateGenJournalLine(
            GenJournalLine,
            GenJournalTemplate.Name,
            GenJournalBatch.Name,
            GenJnlDocType,
            GenJournalLine."Account Type"::"G/L Account",
            '',
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryGST.CreateGLAccWithGSTDetails(
                VATPostingSetup,
                CopyStr(Storage.Get(GSTGroupCodeLbl), 1, 20),
                CopyStr(Storage.Get(HSNSACCodeLbl), 1, 10),
                StorageBoolean.Get(InputCreditAvailmentLbl),
                StorageBoolean.Get(ExemptedLbl)
            ),
            -LibraryRandom.RandIntInRange(1, 10000));
        GenJournalLine.Validate("Location Code", LocationCode);
        GenJournalLine.Validate("GST Group Code");
        GenJournalLine.Validate("HSN/SAC Code");
        GenJournalLine.Validate(GenJournalLine."Party Type", GenJournalLine."Party Type"::Vendor);
        GenJournalLine.Validate("Party Code", VendorNo);
        if StorageBoolean.ContainsKey(POSoutOfIndiaLbl) then begin
            Evaluate(POSoutOfIndia, Format(StorageBoolean.Get(POSoutOfIndiaLbl)));
            GenJournalLine.Validate("POS Out Of India", POSoutOfIndia);
            POSoutOfIndia := false;
        end;
        if GenJournalLine."Document Type" in [GenJournalLine."Document Type"::"Credit Memo"] then
            GenJournalLine.Validate(Amount, -GenJournalLine.Amount)
        else
            GenJournalLine.Validate(Amount);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateGenJnlLineFromPartyTypeVendorInvoice(
             GenJnlDocType: Enum "Gen. Journal Document Type";
             var GenJournalLine: Record "Gen. Journal Line";
             TemplateType: Enum "Gen. Journal Template Type";
             PartyCode: code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VendorNo: Code[20];
        LocationCode: Code[10];
        POSoutOfIndia: Boolean;
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);
        VendorNo := Storage.Get(VendorNoLbl);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        LibraryJournals.CreateGenJournalLine(
            GenJournalLine,
            GenJournalTemplate.Name,
            GenJournalBatch.Name,
            GenJnlDocType,
            GenJournalLine."Account Type"::Vendor,
            VendorNo,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryGST.CreateGLAccWithGSTDetails(
                VATPostingSetup,
                CopyStr(Storage.Get(GSTGroupCodeLbl), 1, 20),
                CopyStr(Storage.Get(HSNSACCodeLbl), 1, 10),
                StorageBoolean.Get(InputCreditAvailmentLbl),
                StorageBoolean.Get(ExemptedLbl)
            ),
            -LibraryRandom.RandIntInRange(1, 10000));
        GenJournalLine.Validate("Location Code", LocationCode);
        GenJournalLine.Validate("GST Group Code");
        GenJournalLine.Validate("HSN/SAC Code");
        GenJournalLine.Validate(GenJournalLine."Party Type", GenJournalLine."Party Type"::Vendor);
        GenJournalLine.Validate("Party Code", VendorNo);
        if StorageBoolean.ContainsKey(POSoutOfIndiaLbl) then begin
            Evaluate(POSoutOfIndia, Format(StorageBoolean.Get(POSoutOfIndiaLbl)));
            GenJournalLine.Validate("POS Out Of India", POSoutOfIndia);
            POSoutOfIndia := false;
        end;
        if GenJournalLine."Document Type" in [GenJournalLine."Document Type"::"Credit Memo"] then
            GenJournalLine.Validate(Amount, -GenJournalLine.Amount)
        else
            GenJournalLine.Validate(Amount);
        GenJournalLine."Bal. Account No." := VendorNo;
        GenJournalLine.Validate("Party Type", GenJournalLine."Party Type"::Party);
        GenJournalLine.Validate("Party Code", PartyCode);
        GenJournalLine.Modify(true);
    end;

    [ModalPageHandler]
    procedure JournalTemplateHandler(var GeneralJournalTemplateList: TestPage "General Journal Template List")
    begin
        GeneralJournalTemplateList.Filter.SetFilter(Name, Storage.Get(TemplateNameLbl));
        GeneralJournalTemplateList.OK().Invoke();
    end;

    [PageHandler]
    procedure ReferencePageHandler(var UpdateReferenceInvJournals: TestPage "Update Reference Inv. Journals")
    begin
        UpdateReferenceInvJournals."Reference Invoice Nos.".Lookup();
        UpdateReferenceInvJournals."Reference Invoice Nos.".SetValue(Storage.Get(PostedDocumentNoLbl));
        UpdateReferenceInvJournals.Verify.Invoke();
    end;

    [ModalPageHandler]
    procedure VendorLedgerEntries(var VendorLedgerEntries: TestPage "Vendor Ledger Entries")
    begin
        VendorLedgerEntries.Filter.SetFilter("Document No.", Storage.Get(PostedDocumentNoLbl));
        VendorLedgerEntries.OK().Invoke();
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
        TaxRates.AttributeValue5.SetValue(WorkDate());
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', WorkDate()));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]); // SGST
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]); // CGST
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[3]); // IGST
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[4]); // KFloodCess
        if POS then
            TaxRates.AttributeValue11.SetValue(POS)
        else
            TaxRates.AttributeValue11.SetValue(POS);
        TaxRates.OK().Invoke();
        POS := false;
    end;
}
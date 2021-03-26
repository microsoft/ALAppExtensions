codeunit 18136 "GST Purchase Reverse Charge"
{
    Subtype = Test;

    var
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryGST: Codeunit "Library GST";
        ComponentPerArray: array[20] of Decimal;
        PostedDocumentNo: Code[20];
        Storage: Dictionary of [Text, Text[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
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

    // [SCENARIO] [354131] Check if the system is calculating GST in case of Intra-State Purchase of Services from an Registered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Quote
    // [FEATURE] [Service Purchase Quote] [Intra-State Reverse Charge,Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromPurchaseServiceQuoteReverseChargeWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        Initialize(GSTVendorType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(true, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Quote);

        // [THEN] Create Purchase Quote To Purchase Order
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [354132] Check if the system is calculating GST in case of Intra-State Purchase of Services from an Registered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Orders
    // [FEATURE] [Service Purchase Orders] // [FEATURE] [Service Purchase Quote] [Intra-State Reverse Charge , Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromPurchaseServiceOrdersReverseChargeWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        Initialize(GSTVendorType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(true, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354133] Check if the system is calculating GST in case of Intra-State Purchase of Services from an Registered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Invoice
    // [FEATURE] [Service Purchase Invoice] [FEATURE] [Service Purchase Quote] [Intra-State Reverse Charge , Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromPurchaseServiceInvoiceReverseChargeWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        Initialize(GSTVendorType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(true, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Invoice with GST and Line Type as Services for Intrastate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 2);
    end;

    // [SCENARIO] [354136] Check if the system is calculating GST in case of Intra-State Purchase of Services from an Registered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Quote
    // [FEATURE] [Service Purchase Quote] [Intra-State Reverse Charge Without ITC ,Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromPurchaseServiceQuoteReverseChargeWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        Initialize(GSTVendorType::Registered, GSTGroupType::Service, true);
        InitializeShareStep(false, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Quote with GST and Line Type as Services for Intrastate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Quote);

        // [THEN] GST ledger entries are created and Verified
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [354141] Check if the system is calculating GST in case of Inter-State Purchase of Services from an Registered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Quotes
    // [FEATURE] [Service Purchase Quotes] [Inter-State Reverse Charge With ITC Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromInterStatePurchaseServiceQuoteReverseChargeWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        Initialize(GSTVendorType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(true, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Quote);

        // [THEN] Create Purchase Quote To Purchase Order
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [354142] Check if the system is calculating GST in case of Inter-State Purchase of Services from an Registered Vendor where Input Tax Credit is available (Reverse Charge) through Purchase Orders
    // [FEATURE] [Service Purchase Order] [Inter-State Reverse Charge With ITC Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromInterStatePurchaseServiceOrderReverseChargeWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup
        Initialize(GSTVendorType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(true, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as GLAccount for Interstate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine, LineType::"G/L Account",
            PurchaseHeader."Document Type"::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 1);
    end;

    // [SCENARIO] [354150] Check if the system is calculating GST in case of Inter-State Purchase of Services from an Registered Vendor where Input Tax Credit is available (Reverse Charge) through purchase Invoices
    // [FEATURE] [Service Purchase Invoice] [Inter-State Reverse Charge With ITC Registered Vendor] 
    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromInterStatePurchaseServiceInvoiceReverseChargeWithITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        Initialize(GSTVendorType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(true, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 1);
    end;

    // [SCENARIO] [354154] Check if the system is calculating GST in case of Inter-State Purchase of Services from an Registered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Quotes
    // [FEATURE] [Service Purchase Quotes] [Inter-State Reverse Charge Without ITC Registered Vendor]
    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromInterStatePurchaseServiceQuoteReverseChargeWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        Initialize(GSTVendorType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Quote);

        // [THEN] Create Purchase Quote To Purchase Order
        LibraryPurchase.QuoteMakeOrder(PurchaseHeader);
    end;

    // [SCENARIO] [354155] Check if the system is calculating GST in case of Inter-State Purchase of Services from an Registered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Orders
    // [FEATURE] [Service Purchase Order] [Input Tax Credit is not available] 
    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromInterStatePurchaseServiceOrderReverseChargeWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        Initialize(GSTVendorType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::"G/L Account",
            PurchaseHeader."Document Type"::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 1);
    end;

    // [SCENARIO] [354156] Check if the system is calculating GST in case of Inter-State Purchase of Services from an Registered Vendor where Input Tax Credit is not available (Reverse Charge) through Purchase Invoices
    // [FEATURE] [Service Purchase Invoice] [Input Tax Credit is not available] 
    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromInterStatePurchaseServiceInvoiceReverseChargeWithoutITC()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GSTVendorType: Enum "GST Vendor Type";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
    begin
        // [GIVEN] Created GST Setup 
        Initialize(GSTVendorType::Registered, GSTGroupType::Service, false);
        InitializeShareStep(false, false, false);
        LibraryGST.UpdateGSTGroupCodeWithReversCharge((Storage.Get(GSTGroupCodeLbl)), true);
        Storage.Set(NoOfLineLbl, '1');

        // [WHEN] Create and Post Purchase Order with GST and Line Type as Services for Intrastate Transactions.
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine, LineType::"G/L Account",
            PurchaseHeader."Document Type"::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.GSTLedgerEntryCount(PostedDocumentNo, 1);
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

    local procedure CreatePurchaseHeaderWithGST(
        var PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        DocumentType: Enum "Purchase Document Type";
        LocationCode: Code[10])
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Location Code", LocationCode);

        PurchaseHeader."Vendor Invoice No." := LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Vendor Invoice No."), Database::"Purchase Header");
        if PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::SEZ then begin
            PurchaseHeader."Bill of Entry No." := LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Bill of Entry No."), Database::"Purchase Header");
            PurchaseHeader."Bill of Entry Date" := WorkDate();
            PurchaseHeader."Bill of Entry Value" := 1001;
        end;
        PurchaseHeader.Modify(true);
    end;

    local procedure CreatePurchaseDocument(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type")
    var
        VendorNo2: Code[20];
        LocationCode2: Code[10];
        Exempted: Boolean;
    begin
        VendorNo2 := Storage.Get(VendorNoLbl);
        Evaluate(LocationCode2, Storage.Get(LocationCodeLbl));
        Exempted := false;

        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo2, DocumentType, LocationCode2);
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(InputCreditAvailmentLbl), Exempted, StorageBoolean.Get(LineDiscountLbl));
        if not (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Quote) then
            PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
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
        Evaluate(NoOfLine, Storage.Get(NoOfLineLbl));
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
            PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandInt(1000));
            if InputCreditAvailment then
                PurchaseLine."GST Credit" := PurchaseLine."GST Credit"::Availment
            else
                PurchaseLine."GST Credit" := PurchaseLine."GST Credit"::"Non-Availment";

            if LineDiscount then begin
                PurchaseLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
                LibraryGST.UpdateLineDiscAccInGeneralPostingSetup(PurchaseLine."Gen. Bus. Posting Group", PurchaseLine."Gen. Prod. Posting Group");
            end;

            if (PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ]) and (PurchaseLine.Type = PurchaseLine.Type::Item) then begin
                PurchaseLine.Validate("GST Assessable Value", PurchaseLine."Line Amount");
                PurchaseLine.Validate("Custom Duty Amount", PurchaseLine."Line Amount");
            end;
            PurchaseLine.Modify(true);
        end;
    end;

    local procedure Initialize(
        GSTVendorType: Enum "GST Vendor Type";
        GSTGroupType: Enum "GST Group Type";
        IntraState: Boolean)
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
        HSNSACCode: Code[10];
        GSTGroupCode: Code[20];
        LocationGSTRegNo: Code[15];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTComponentCode: Text[30];
        isInitialized: Boolean;
    begin
        LibrarySetupStorage.Restore();
        if isInitialized then
            exit;
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

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::" ", false);
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
                CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
            end;
        end;
        Storage.Set(VendorNoLbl, VendorNo);

        CreateTaxRate();
        isInitialized := true;
    end;

    local procedure InitializeShareStep(InputCreditAvailment: Boolean; Exempted: Boolean; LineDiscount: Boolean)
    begin
        StorageBoolean.Set(InputCreditAvailmentLbl, InputCreditAvailment);
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
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

    [PageHandler]
    procedure TaxRatesPage(var TaxRates: TestPage "Tax Rates")
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
codeunit 18127 "GST Purch RCM Charge Item"
{
    Subtype = Test;

    var
        LibraryGST: Codeunit "Library GST";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryGSTPurchase: Codeunit "Library - GST Purchase";
        Assert: Codeunit Assert;
        Storage: Dictionary of [Text[20], Text[20]];
        ComponentPerArray: array[10] of Decimal;
        StorageBoolean: Dictionary of [Text[20], Boolean];
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
        AssociatedVendorLbl: Label 'AssociatedVendor';
        GSTLEVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvToRegVendorWithRCMChargeItemITCIntrState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        //[SCENARIO] [399688] Check if the system is calculating GST for Charge (Item) on Purchase Invoice for a Registered Vendor with Intrastate and ITC is Availment with Reverse Charge.
        //[GIVEN] Created GST Setup with GST Credit Availment
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeSharedStep(true, false, false);

        // [WHEN] Create Purchase Invoice with GST and Line type as Item for Intrastate Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] New Purchase Line Created With Charge Item and assigned with Item
        DocumentNo := CreateAndPostPurchaseDocWithChargeItem(PurchaseHeader);

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries are created and Verified
        VerifyGSTEntries(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvToRegVendorWithRCMChargeItemNonITCIntraState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        //[SCENARIO] [399700] Check if the system is calculating GST for Charge (Item) on Purchase Invoice for a Registered Vendor with Intrastate and ITC is Non-Availment with Reverse Charge.
        //[GIVEN] Created GST Setup with GST Credit Non-Availment
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, true, false);
        InitializeSharedStep(false, false, false);

        // [WHEN] Create Purchase Invoice with GST and Line type as Item for Intrastate Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] New Purchase Line Created With Charge Item and assigned with Item
        DocumentNo := CreateAndPostPurchaseDocWithChargeItem(PurchaseHeader);

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries are created and Verified
        VerifyGSTEntries(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdToRegVendorWithRCMChargeItemITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        //[SCENARIO] [399750] Check if the system is calculating GST for Charge (Item) on Purchase Order for a Registered Vendor with Interstate and ITC is Availment with Reverse Charge.
        //[GIVEN] Created GST Setup with GST Credit Availment
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeSharedStep(true, false, false);

        // [WHEN] Create Purchase Invoice with GST and Line type as Item for InterState Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] New Purchase Line Created With Charge Item and assigned with Item
        DocumentNo := CreateAndPostPurchaseDocWithChargeItem(PurchaseHeader);

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries are created and Verified
        VerifyGSTEntries(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdToRegVendorWithRCMChargeItemNonITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        //[SCENARIO] [399820] Check if the system is calculating GST for Charge (Item) on Purchase Order for a Registered Vendor with Interstate and ITC is Non-Availment with Reverse Charge.
        //[GIVEN] Created GST Setup with GST Credit Availment
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeSharedStep(false, false, false);

        // [WHEN] Create Purchase Invoice with GST and Line type as Item for InterState Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Order);

        // [THEN] New Purchase Line Created With Charge Item and assigned with Item
        DocumentNo := CreateAndPostPurchaseDocWithChargeItem(PurchaseHeader);

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries are created and Verified
        VerifyGSTEntries(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvToRegVendorWithRCMChargeItemNonITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        //[SCENARIO] [399820] Check if the system is calculating GST for Charge (Item) on Purchase Invoice for a Registered Vendor with Interstate and ITC is Non-Availment with Reverse Charge.
        //[GIVEN] Created GST Setup with GST Credit Availment
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeSharedStep(false, false, false);

        // [WHEN] Create Purchase Invoice with GST and Line type as Item for InterState Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] New Purchase Line Created With Charge Item and assigned with Item
        DocumentNo := CreateAndPostPurchaseDocWithChargeItem(PurchaseHeader);

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries are created and Verified
        VerifyGSTEntries(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvToRegVendorWithRCMChargeItemITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        //[SCENARIO] [399750] Check if the system is calculating GST for Charge (Item) on Purchase Invoice for a Registered Vendor with Interstate and ITC is Availment with Reverse Charge.
        //[GIVEN] Created GST Setup with GST Credit Availment
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeSharedStep(true, false, false);

        // [WHEN] Create Purchase Invoice with GST and Line type as Item for InterState Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] New Purchase Line Created With Charge Item and assigned with Item
        DocumentNo := CreateAndPostPurchaseDocWithChargeItem(PurchaseHeader);

        //[THEN] GST Ledger Entries and Detailed GST Ledger Entries are created and Verified
        VerifyGSTEntries(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvToRegVendorWithoutRCMChargeItemNonITCInterState()
    var
        PurchaseHeader: Record "Purchase Header";
        InventorySetup: Record "Inventory Setup";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        //[SCENARIO] Check if the system is adding GST for Charge (Item) on Purchase Invoice for a Registered Vendor In Costing Entries with Interstate and ITC is Non-Availment with Automatic Cost Posting True.
        //[GIVEN] Created GST Setup with GST Credit Non Availment and Set Inventory Setup value
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Service, false, false);
        InitializeSharedStep(false, false, false);
        InventorySetup."Automatic Cost Posting" := true;
        InventorySetup."Automatic Cost Adjustment" := InventorySetup."Automatic Cost Adjustment"::Always;

        // [WHEN] Create Purchase Invoice with GST and Line type as Item for InterState Transactions.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, LineType::Item, DocumentType::Invoice);

        // [THEN] New Purchase Line Created With Charge Item and assigned with Item
        DocumentNo := CreateAndPostPurchaseDocWithChargeItem(PurchaseHeader);

        //[THEN] GL Entries, GST Ledger Entries and Detailed GST Ledger Entries are created and Verified
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 5);
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
    begin
        Exempted := StorageBoolean.Get(ExemptedLbl);
        InputCreditAvailment := StorageBoolean.Get(InputCreditAvailmentLbl);

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

        PurchaseLine.Validate("GST Reverse Charge", true);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandInt(1000));
        PurchaseLine.Modify(true);
    end;

    local procedure VerifyGSTEntries(DocumentNo: Code[20])
    var
        PurchInvLine: Record "Purch. Inv. Line";
        ComponentList: List of [Code[30]];
    begin
        PurchInvLine.SetRange("Document No.", DocumentNo);
        PurchInvLine.SetRange(Type, PurchInvLine.Type::"Charge (Item)");
        PurchInvLine.SetFilter("No.", '<>%1', '');
        if PurchInvLine.FindSet() then
            VerifyGSTEntriesForPurchase(PurchInvLine, DocumentNo);
        repeat
            FillComponentList(PurchInvLine."GST Jurisdiction Type", ComponentList, PurchInvLine."GST Group Code");
            VerifyDetailedGSTEntriesForPurchase(PurchInvLine, DocumentNo, ComponentList);
        until PurchInvLine.Next() = 0;
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
            ComponentList.Add(CESSLbl);
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

        if GSTVendorType IN [GSTVendorType::Import, GSTVendorType::SEZ] then
            InitializeTaxRateParameters(IntraState, '', LocationStateCode)
        else
            InitializeTaxRateParameters(IntraState, VendorStateCode, LocationStateCode);
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
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(InputCreditAvailmentLbl), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        exit(PurchaseHeader."No.")
    end;

    local procedure InitializeSharedStep(InputCreditAvailment: Boolean; LineDiscount: Boolean; Exempted: Boolean)
    begin
        StorageBoolean.Set(InputCreditAvailmentLbl, InputCreditAvailment);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
        StorageBoolean.Set(ExemptedLbl, Exempted);
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
        if PurchaseInvoiceType IN [PurchaseInvoiceType::"Debit Note", PurchaseInvoiceType::Supplementary] then
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Vendor Invoice No."), Database::"Purchase Header"))
        else
            PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Vendor Cr. Memo No."), Database::"Purchase Header"));
        if (PurchaseHeader."GST Vendor Type" IN [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ]) then begin
            PurchaseHeader."Bill of Entry No." := LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Bill of Entry No."), Database::"Purchase Header");
            PurchaseHeader."Bill of Entry Date" := WorkDate();
            PurchaseHeader."Bill of Entry Value" := LibraryRandom.RandInt(1000);
        end;
        PurchaseHeader.Modify(true);
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
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        PurchInvHeader.SetRange("No.", DocumentNo);
        if PurchInvHeader.FindFirst() then
            exit(PurchInvHeader."Currency Factor");
    end;

    local procedure GetPurchGSTAmount(
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line"): Decimal
    begin
        if PurchInvHeader."GST Vendor Type" IN [PurchInvHeader."GST Vendor Type"::Registered,
             PurchInvHeader."GST Vendor Type"::Unregistered,
             PurchInvHeader."GST Vendor Type"::Import,
             PurchInvHeader."GST Vendor Type"::SEZ] then
            if PurchInvLine."GST Jurisdiction Type" = PurchInvLine."GST Jurisdiction Type"::Interstate then
                exit(PurchInvLine.Amount * ComponentPerArray[4] / 100)
            else
                exit(PurchInvLine.Amount * ComponentPerArray[1] / 100)
        else
            if PurchInvHeader."GST Vendor Type" IN [PurchInvHeader."GST Vendor Type"::Composite,
           PurchInvHeader."GST Vendor Type"::Exempted] then
                exit(0.00);
    end;

    local procedure GetPurchResEligibilityForITC(
       PurchInvHeader: Record "Purch. Inv. Header";
       PurchInvLine: Record "Purch. Inv. Line"): Enum "Eligibility for ITC"
    var
        EligibilityForITC: Enum "Eligibility for ITC";
    begin
        if PurchInvHeader."GST Vendor Type" IN [PurchInvHeader."GST Vendor Type"::Registered,
             PurchInvHeader."GST Vendor Type"::Unregistered,
             PurchInvHeader."GST Vendor Type"::Import,
             PurchInvHeader."GST Vendor Type"::Exempted,
             PurchInvHeader."GST Vendor Type"::SEZ] then
            exit(LibraryGSTPurchase.GetEligibilityforITC(PurchInvLine."GST Credit", PurchInvLine."GST Group Type", PurchInvLine.Type))
        else
            exit(EligibilityForITC::"Input Services");
    end;

    local procedure VerifyGSTEntriesForPurchase(
        var PurchInvLine: Record "Purch. Inv. Line";
        DocumentNo: Code[20])
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        SourceCodeSetup: Record "Source Code Setup";
        GSTAmount: Decimal;
        CurrencyFactor: Decimal;
        TransactionNo: Decimal;
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        PurchInvHeader.Get(DocumentNo);

        CurrencyFactor := GetCurrencyFactorForPurchase(DocumentNo);
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        SourceCodeSetup.Get();

        TransactionNo := LibraryGSTPurchase.GetTransactionNo(DocumentNo, PurchInvHeader."Posting Date", DocumentType::Invoice);

        GSTLedgerEntry.SetRange("Document No.", DocumentNo);
        GSTLedgerEntry.FindFirst();

        GSTAmount := GetPurchGSTAmount(PurchInvHeader, PurchInvLine);

        Assert.AreEqual(PurchInvLine."Gen. Bus. Posting Group", GSTLedgerEntry."Gen. Bus. Posting Group",
           StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldName("Gen. Bus. Posting Group"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvLine."Gen. Prod. Posting Group", GSTLedgerEntry."Gen. Prod. Posting Group",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Gen. Prod. Posting Group"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvHeader."Posting Date", GSTLedgerEntry."Posting Date",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Posting Date"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Document Type"::Invoice, GSTLedgerEntry."Document Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Document Type"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Transaction Type"::Purchase, GSTLedgerEntry."Transaction Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction Type"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Source Type"::Vendor, GSTLedgerEntry."Source Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Type"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvHeader."Pay-to Vendor No.", GSTLedgerEntry."Source No.",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source No."), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(UserId, GSTLedgerEntry."User ID",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("User ID"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(SourceCodeSetup.Purchases, GSTLedgerEntry."Source Code",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Code"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvLine.Amount / CurrencyFactor, GSTLedgerEntry."GST Base Amount",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Base Amount"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(TransactionNo, GSTLedgerEntry."Transaction No.",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction No."), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvHeader."Vendor Invoice No.", GSTLedgerEntry."External Document No.",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("External Document No."), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvLine."GST Reverse Charge", GSTLedgerEntry."Reverse Charge",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Reverse Charge"), GSTLedgerEntry.TableCaption));

        Assert.AreNearlyEqual(GSTAmount / CurrencyFactor, GSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Amount"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Entry Type"::"Initial Entry", GSTLedgerEntry."Entry Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Entry Type"), GSTLedgerEntry.TableCaption));
    end;

    local procedure VerifyDetailedGSTEntriesForPurchase(
        var PurchInvLine: Record "Purch. Inv. Line";
        DocumentNo: Code[20];
        var ComponentList: List of [Code[30]])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        PurchInvHeader: Record "Purch. Inv. Header";
        SourceCodeSetup: Record "Source Code Setup";
        Vendor: Record Vendor;
        GSTAmount: Decimal;
        CurrencyFactor: Decimal;
        EligibilityforITC: Enum "Eligibility for ITC";
        ComponentCode: Code[30];
        TransactionNo: Decimal;
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        PurchInvHeader.Get(DocumentNo);

        CurrencyFactor := GetCurrencyFactorForPurchase(DocumentNo);
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        Vendor.Get(PurchInvHeader."Pay-to Vendor No.");
        SourceCodeSetup.Get();

        TransactionNo := LibraryGSTPurchase.GetTransactionNo(DocumentNo, PurchInvHeader."Posting Date", DocumentType::Invoice);

        EligibilityforITC := GetPurchResEligibilityForITC(PurchInvHeader, PurchInvLine);

        GSTAmount := GetPurchGSTAmount(PurchInvHeader, PurchInvLine);

        foreach ComponentCode IN ComponentList do begin
            DetailedGSTLedgerEntry.Reset();
            DetailedGSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Document Line No.", PurchInvLine."Line No.");
            DetailedGSTLedgerEntry.SetRange("Posting Date", PurchInvLine."Posting Date");
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
            DetailedGSTLedgerEntry.FindFirst();
        end;

        DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");

        Assert.AreEqual(DetailedGSTLedgerEntry."Entry Type"::"Initial Entry", DetailedGSTLedgerEntry."Entry Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Entry Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Transaction Type"::Purchase, DetailedGSTLedgerEntry."Transaction Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Document Type"::Invoice, DetailedGSTLedgerEntry."Document Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Document Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvHeader."Posting Date", DetailedGSTLedgerEntry."Posting Date",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Posting Date"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvLine.Type, DetailedGSTLedgerEntry.Type,
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption(Type), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvLine."No.", DetailedGSTLedgerEntry."No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ComponentCode, DetailedGSTLedgerEntry."GST Component Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Component Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Product Type"::Item, DetailedGSTLedgerEntry."Product Type",
        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Product Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Source Type"::Vendor, DetailedGSTLedgerEntry."Source Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvHeader."Pay-to Vendor No.", DetailedGSTLedgerEntry."Source No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvLine."HSN/SAC Code", DetailedGSTLedgerEntry."HSN/SAC Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("HSN/SAC Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvLine."GST Group Code", DetailedGSTLedgerEntry."GST Group Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Group Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvLine."GST Jurisdiction Type", DetailedGSTLedgerEntry."GST Jurisdiction Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Jurisdiction Type"), DetailedGSTLedgerEntry.TableCaption));

        if PurchInvHeader."GST Vendor Type" IN [PurchInvHeader."GST Vendor Type"::Registered,
            PurchInvHeader."GST Vendor Type"::Unregistered,
            PurchInvHeader."GST Vendor Type"::Import,
            PurchInvHeader."GST Vendor Type"::SEZ] then
            if DetailedGSTLedgerEntry."GST Jurisdiction Type" = DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate then
                Assert.AreEqual(ComponentPerArray[4], DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
            else
                Assert.AreEqual(ComponentPerArray[1], DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
        else
            if PurchInvHeader."GST Vendor Type" IN [PurchInvHeader."GST Vendor Type"::Composite,
                PurchInvHeader."GST Vendor Type"::Exempted] then
                Assert.AreEqual(0.0, DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreNearlyEqual(GSTAmount / CurrencyFactor, DetailedGSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Amount"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvLine.Amount / CurrencyFactor, DetailedGSTLedgerEntry."GST Base Amount",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Base Amount"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvHeader."Vendor Invoice No.", DetailedGSTLedgerEntry."External Document No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("External Document No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvLine.Quantity, DetailedGSTLedgerEntry.Quantity,
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName(Quantity), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(UserId, DetailedGSTLedgerEntryInfo."User ID",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("User ID"), DetailedGSTLedgerEntryInfo.TableCaption));

        if PurchInvHeader."GST Vendor Type" IN [PurchInvHeader."GST Vendor Type"::Registered,
            PurchInvHeader."GST Vendor Type"::Unregistered,
            PurchInvHeader."GST Vendor Type"::Import,
            PurchInvHeader."GST Vendor Type"::SEZ] then
            Assert.AreEqual(true, DetailedGSTLedgerEntryInfo.Positive,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(Positive), DetailedGSTLedgerEntryInfo.TableCaption))
        else
            if PurchInvHeader."GST Vendor Type" = PurchInvHeader."GST Vendor Type"::Composite then
                Assert.AreEqual(false, DetailedGSTLedgerEntryInfo.Positive,
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(Positive), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(PurchInvLine."Line No.", DetailedGSTLedgerEntry."Document Line No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Reverse Charge"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvLine."GST Reverse Charge", DetailedGSTLedgerEntry."Reverse Charge",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Reverse Charge"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvHeader."Nature of Supply", DetailedGSTLedgerEntryInfo."Nature of Supply",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Nature of Supply"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(PurchInvHeader."Location State Code", DetailedGSTLedgerEntryInfo."Location State Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Location State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(Vendor."State Code", DetailedGSTLedgerEntryInfo."Buyer/Seller State Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Buyer/Seller State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(PurchInvHeader."Location GST Reg. No.", DetailedGSTLedgerEntry."Location  Reg. No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Location  Reg. No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvHeader."Vendor GST Reg. No.", DetailedGSTLedgerEntry."Buyer/Seller Reg. No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Buyer/Seller Reg. No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvLine."GST Group Type", DetailedGSTLedgerEntry."GST Group Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Group Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvLine."GST Credit", DetailedGSTLedgerEntry."GST Credit",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Credit"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(TransactionNo, DetailedGSTLedgerEntry."Transaction No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntryInfo."Original Doc. Type"::Invoice, DetailedGSTLedgerEntryInfo."Original Doc. Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. Type"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(DocumentNo, DetailedGSTLedgerEntryInfo."Original Doc. No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. No."), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(PurchInvHeader."Location Code", DetailedGSTLedgerEntry."Location Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Location Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvHeader."GST Vendor Type", DetailedGSTLedgerEntry."GST Vendor Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Vendor Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(PurchInvLine."Gen. Bus. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Bus. Posting Group",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldName("Gen. Bus. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(PurchInvLine."Gen. Prod. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Prod. Posting Group",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Gen. Prod. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(PurchInvLine."Unit of Measure Code", DetailedGSTLedgerEntryInfo.UOM,
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(UOM), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(true, DetailedGSTLedgerEntry."Item Charge Entry",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(UOM), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(EligibilityforITC, DetailedGSTLedgerEntry."Eligibility for ITC",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Eligibility for ITC"), DetailedGSTLedgerEntry.TableCaption));
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

codeunit 18428 "GST Bonded Warehouse Tests"
{

    Subtype = Test;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromTransferOrderwithBondedWarehouseInterStateITC()
    var
        FromLocation, ToLocation, InTransitLocation : Record Location;
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [354827] Check if the system is calculating GST in case of Transfer from Bonded Warehouse to Normal Warehouse - Transfer Shipment and Receipt with ITC Available.
        // [GIVEN] Created GST Setup ,Transfer Locations with ITC for Bonded Warehouse
        CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Goods, false, true);

        // [WHEN] Create and Post Interstate Transfer Order with ITC for Bonded Warehouse
        PostedDocumentNo := CreateandPostTransferOrder(
            TransferHeader,
            TransferLine);

        // [THEN] Posted Entries Verified for InterState Transactions
        VerifyPostedEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure VerifyGSTAssesableValuewithBondedWarehouseInterStateITC()
    var
        FromLocation, ToLocation, InTransitLocation : Record Location;
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] Check GST Assessable Value is Zero for GST Group Type Service while transferring from Bonded Warehouse location.
        // [GIVEN] Created GST Setup ,Transfer Locations with ITC for GSTGroupType Service
        CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);

        // [WHEN] Create Interstate Transfer Order with ITC for Bonded Warehouse
        DocumentNo := CreateTransferOrder(
            TransferHeader,
            TransferLine);

        // [THEN] Assert Error Verified for GST Assessable Value for InterState Transactions
        asserterror TransferLine.Validate(TransferLine."GST Assessable Value", LibraryRandom.RandDecInRange(100, 1000, 0));
        Assert.ExpectedError(GSTAssessableErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure VerifyCustomDutyAmountwithBondedWarehouseInterStateITC()
    var
        FromLocation, ToLocation, InTransitLocation : Record Location;
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] Check Custom Duty Amount must be 0 if GST Group Type is Service while transferring from Bonded Warehouse location.
        // [GIVEN] Created GST Setup ,Transfer Locations with ITC for GSTGroupType Service
        CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        CreateGSTSetup(GSTVendorType::Import, GSTGroupType::Service, false, true);

        // [WHEN] Create Interstate Transfer Order with ITC for Bonded Warehouse
        DocumentNo := CreateTransferOrder(
            TransferHeader,
            TransferLine);

        // [THEN] Assert Error Verified for CustomDutyAmount for InterState Transactions
        asserterror TransferLine.Validate(TransferLine."Custom Duty Amount", LibraryRandom.RandDecInRange(100, 1000, 0));
        Assert.ExpectedError(GSTCustomDutyErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostTransferOrderwithInterStateBondedWarehouseWithoutITC()
    var
        FromLocation, ToLocation, InTransitLocation : Record Location;
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [385430] Check if the system is calculating GST in case of Inter-State Stock Transfer Shipment and Receipt with ITC Non-Availment.
        // [GIVEN] Created GST Setup ,Transfer Locations without ITC for GSTGroupType Goods
        CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        CreateGSTSetup(GSTVendorType, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Interstate Transfer Order without ITC for Bonded Warehouse
        PostedDocumentNo := CreateandPostTransferOrder(
            TransferHeader,
            TransferLine);

        // [THEN] Posted Entries Verified for without ITC InterState Transactions
        VerifyPostedEntries(PostedDocumentNo);
    end;

    local procedure CreateItemWithInventory(): Code[20]
    var
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        InputCreditAvailment: Boolean;
        ItemNo: Code[20];
    begin
        InputCreditAvailment := StorageBoolean.Get(AvailmentLbl);

        ItemNo := LibraryGST.CreateItemWithGSTDetails(
              VATPostingSetup,
              (LibraryStorage.Get(GSTGroupCodeLbl)),
              (LibraryStorage.Get(HSNSACCodeLbl)),
              InputCreditAvailment, false);

        Item.Get(ItemNo);
        UpdateInventoryPostingSetup((LibraryStorage.Get(InTransitLocationLbl)), Item."Inventory Posting Group");
        UpdateInventoryPostingSetup((LibraryStorage.Get(FromLocationLbl)), Item."Inventory Posting Group");
        UpdateInventoryPostingSetup((LibraryStorage.Get(ToLocationLbl)), Item."Inventory Posting Group");
        LibraryGST.CreateGeneralPostingSetup('', Item."Gen. Prod. Posting Group");

        LibraryInventory.CreateItemJournalLineInItemTemplate(
            ItemJournalLine, Item."No.",
            (LibraryStorage.Get(FromLocationLbl)),
            '', LibraryRandom.RandInt(100));
        Codeunit.Run(Codeunit::"Item Jnl.-Post Batch", ItemJournalLine);
        exit(Item."No.");
    end;

    local procedure CreateandPostTransferOrder(var TransferHeader: Record "Transfer Header";
        var TransferLine: Record "Transfer Line"): Code[20]
    var
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        LibraryWarehouse.CreateTransferHeader(
            TransferHeader,
            (LibraryStorage.Get(FromLocationLbl)),
            (LibraryStorage.Get(ToLocationLbl)),
            (LibraryStorage.Get(InTransitLocationLbl)));

        TransferHeader.Validate("Vendor No.", LibraryStorage.Get(VendorNoLbl));
        TransferHeader."Bill of Entry No." := LibraryUtility.GenerateRandomCode(TransferHeader.FieldNo("Bill of Entry No."), Database::"Transfer Header");
        TransferHeader."Bill of Entry Date" := WorkDate();
        TransferHeader.Modify(true);

        CreateTransferLineWithGST(TransferHeader, TransferLine, StorageBoolean.Get(AvailmentLbl));
        TransferLine.Validate(TransferLine."GST Assessable Value", LibraryRandom.RandDecInRange(100, 1000, 0));
        TransferLine.Validate(TransferLine."Custom Duty Amount", LibraryRandom.RandDecInRange(100, 1000, 0));
        TransferLine.Modify(true);

        DocumentNo := TransferHeader."No.";
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, true);
        PostedDocumentNo := GetPostedTransferShipmentNo(DocumentNo);
        exit(PostedDocumentNo);
    end;

    local procedure CreateTransferOrder(var TransferHeader: Record "Transfer Header";
        var TransferLine: Record "Transfer Line"): Code[20]
    begin
        LibraryWarehouse.CreateTransferHeader(
            TransferHeader,
            (LibraryStorage.Get(FromLocationLbl)),
            (LibraryStorage.Get(ToLocationLbl)),
            (LibraryStorage.Get(InTransitLocationLbl)));

        TransferHeader.Validate("Vendor No.", LibraryStorage.Get(VendorNoLbl));
        TransferHeader."Bill of Entry No." := LibraryUtility.GenerateRandomCode(TransferHeader.FieldNo("Bill of Entry No."), Database::"Transfer Header");
        TransferHeader."Bill of Entry Date" := WorkDate();
        TransferHeader.Modify(true);

        CreateTransferLineWithGST(TransferHeader, TransferLine, StorageBoolean.Get(AvailmentLbl));
        exit(TransferHeader."No.");
    end;

    local procedure CreateTransferLineWithGST(var TransferHeader: Record "Transfer Header";
        var TransferLine: Record "Transfer Line";
        Availment: Boolean)
    begin
        LibraryWarehouse.CreateTransferLine(
             TransferHeader,
             Transferline,
             CreateItemWithInventory(),
             LibraryRandom.RandIntInRange(1, 5));
        TransferLine.Validate("Transfer Price", LibraryRandom.RandDecInRange(100, 1000, 0));
        if Availment then
            Transferline.Validate("GST Credit", Transferline."GST Credit"::Availment)
        else
            TransferLine.Validate("GST Credit", TransferLine."GST Credit"::"Non-Availment");
    end;

    local procedure GetPostedTransferShipmentNo(DocumentNo: Code[20]): Code[20]
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        TransferShipmentHeader.SetRange("Transfer Order No.", DocumentNo);
        if TransferShipmentHeader.FindFirst() then
            exit(TransferShipmentHeader."No.")
    end;

    local procedure VerifyPostedEntries(PostedDocumentNo: Code[20])
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        TransferShipmentHeader.SetRange("No.", PostedDocumentNo);
        TransferShipmentHeader.FindFirst();
        Assert.RecordIsNotEmpty(TransferShipmentHeader);

        TransferShipmentLine.SetRange(TransferShipmentLine."Document No.", TransferShipmentHeader."No.");
        TransferShipmentLine.FindFirst();
        Assert.RecordIsNotEmpty(TransferShipmentLine);
    end;

    local procedure FillCompanyInformation()
    var
        CompanyInformation: Record "Company information";
        LocationStateCode: Code[10];
        LocationGSTRegNo: Code[15];
        LocPan: Code[20];
    begin
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := LibraryGST.CreatePANNos();
            CompanyInformation.Modify();
        end else
            LocPan := CompanyInformation."P.A.N. No.";
        LocPan := CompanyInformation."P.A.N. No.";
        LibraryStorage.Set(LocPANLbl, LocPan);

        LocationStateCode := LibraryGST.CreateInitialSetup();
        LibraryStorage.Set(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPan);
        LibraryStorage.Set(LocGSTRegNoLbl, LocationGSTRegNo);

        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true);
        end;
    end;

    local procedure CreateTransferLocations(var FromLocation: Record Location; var ToLocation: Record Location; var InTransitLocation: Record Location)
    begin
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        LibraryStorage.Set(FromLocationLbl, FromLocation.Code);
        LibraryStorage.Set(ToLocationLbl, ToLocation.Code);
        LibraryStorage.Set(InTransitLocationLbl, InTransitLocation.Code);
    end;

    local procedure CreateGSTSetup(
        GSTVendorType: Enum "GST Vendor Type";
        GSTGroupType: Enum "GST Group Type";
        IntraState: Boolean;
        Availment: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        HSNSACCode: Code[10];
        GSTGroupCode: Code[20];
        HsnSacType: Enum "GST Goods And Services Type";
    begin
        LibraryGST.CreateInitialSetup();
        FillCompanyInformation();

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::" ", false);
        LibraryStorage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        LibraryStorage.Set(HSNSACCodeLbl, HSNSACCode);

        LibraryGST.CreateNoVatSetup();

        if IntraState then
            IntraStateSetup()
        else
            InterStateSetup(GSTVendorType::Import);

        StorageBoolean.Set(AvailmentLbl, Availment);
        CreateTaxRate();
    end;

    local procedure IntraStateSetup()
    var
        TaxComponent: Record "Tax Component";
        Location: Record Location;
        GSTComponentCode: Text[30];
    begin
        Location.Reset();
        Location.Get(LibraryStorage.Get(FromLocationLbl));
        Location."State Code" := (LibraryStorage.Get(LocationStateCodeLbl));
        Location."GST Registration No." := (LibraryStorage.Get(LocGSTRegNoLbl));
        Location."Location ARN No." := Format(LibraryRandom.RandIntInRange(1000, 9999));
        Location.Modify(true);

        Location.Reset();
        Location.Get(LibraryStorage.Get(ToLocationLbl));
        Location."Bonded warehouse" := true;
        Location.Modify(true);

        CreateGSTSetupTaxRateParameters(true, Location."State Code", Location."State Code");
        CreateGSTComponentAndPostingSetup(true, Location."State Code", TaxComponent, GSTComponentCode);
    end;

    local procedure InterStateSetup(GSTVendorType: Enum "GST Vendor Type")
    var
        TaxComponent: Record "Tax Component";
        Location: Record Location;
        State: Record State;
        GSTComponentCode: Text[30];
        VendorNo: Code[20];
        VendorStateCode: Code[10];
        ToStateCode: Code[10];
    begin
        Location.Reset();
        Location.Get(LibraryStorage.Get(FromLocationLbl));
        Location.Validate("Bonded warehouse", true);
        Location.Modify(true);

        Location.Reset();
        Location.Get(LibraryStorage.Get(ToLocationLbl));
        LibraryGST.CreateState(State);
        Location."State Code" := State.Code;
        ToStateCode := Location."State Code";
        Location."GST Registration No." := (LibraryStorage.Get(LocGSTRegNoLbl));
        Location."Location ARN No." := Format(LibraryRandom.RandIntInRange(1000, 9999));
        Location.Modify(true);

        VendorNo := LibraryGST.CreateVendorSetup();
        VendorStateCode := LibraryGST.CreateGSTStateCode();
        UpdateVendorSetupWithGST(VendorNo, GSTVendorType, VendorStateCode, (LibraryStorage.Get(LocPANLbl)));
        if GSTVendorType in [GSTVendorType::Import, GSTVendorType::SEZ] then
            CreateGSTSetupTaxRateParameters(false, '', ToStateCode)
        else begin
            CreateGSTSetupTaxRateParameters(false, VendorStateCode, ToStateCode);
            CreateGSTComponentAndPostingSetup(false, VendorStateCode, TaxComponent, GSTComponentCode);
        end;

        LibraryStorage.Set(VendorNoLbl, VendorNo);

        CreateGSTComponentAndPostingSetup(false, ToStateCode, TaxComponent, GSTComponentCode);
    end;

    local procedure UpdateVendorSetupWithGST(VendorNo: Code[20];
       GSTVendorType: Enum "GST Vendor Type";
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
        Vendor.Validate(Vendor."Gen. Bus. Posting Group", '');
        Vendor.Modify(true);
    end;

    local procedure CreateGSTSetupTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10])
    var
        GSTTaxPercent: Decimal;
    begin
        LibraryStorage.Set(FromStateCodeLbl, FromState);
        LibraryStorage.Set(ToStateCodeLbl, ToState);

        GSTTaxPercent := LibraryRandom.RandDecInRange(10, 18, 0);

        if IntraState then begin
            ComponentPerArray[1] := (GSTTaxPercent / 2);
            ComponentPerArray[2] := (GSTTaxPercent / 2);
            ComponentPerArray[3] := 0.00;
        end else
            ComponentPerArray[4] := GSTTaxPercent;
    end;

    local procedure CreateGSTComponentAndPostingSetup(IntraState: Boolean; LocationStateCode: Code[10]; TaxComponent: Record "Tax Component"; GSTcomponentcode: Text[30]);
    begin
        IF IntraState then begin
            GSTcomponentcode := CGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentcode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTcomponentcode := SGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentcode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTcomponentcode := IGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentcode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end;
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

    local procedure UpdateInventoryPostingSetup(Location: Code[20]; InventoryPostingGroup: Code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
    begin
        InventoryPostingSetup.SetRange("Location Code", Location);
        InventoryPostingSetup.SetRange("Invt. Posting Group Code", InventoryPostingGroup);
        if InventoryPostingSetup.FindFirst() then
            InventoryPostingSetup.Validate("Unrealized Profit Account", LibraryERM.CreateGLAccountNo());
        InventoryPostingSetup.Modify(true);
    end;

    [PageHandler]
    procedure TaxRatesPage(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(LibraryStorage.Get(GSTGroupCodeLbl));
        TaxRates.AttributeValue2.SetValue(LibraryStorage.Get(HSNSACCodeLbl));
        TaxRates.AttributeValue3.SetValue(LibraryStorage.Get(FromStateCodeLbl));
        TaxRates.AttributeValue4.SetValue(LibraryStorage.Get(ToStateCodeLbl));
        TaxRates.AttributeValue5.SetValue(Today);
        TaxRates.AttributeValue6.SetValue(CALCDATE('<10Y>', Today));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]);
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]);
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]);
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[3]);
        TaxRates.OK().Invoke();
    end;

    var
        LibraryGST: Codeunit "Library GST";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryStorage: Dictionary of [Text, Text];
        StorageBoolean: Dictionary of [Text, Boolean];
        ComponentPerArray: array[20] of Decimal;
        LocationStateCodeLbl: Label 'LocationStateCode';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        FromStateCodeLbl: Label 'FromStateCode';
        ToStateCodeLbl: Label 'ToStateCode';
        AvailmentLbl: Label 'Availment';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        FromLocationLbl: Label 'FromLocation';
        LocPANLbl: Label 'LocPAN';
        ToLocationLbl: Label 'ToLocation';
        VendorNoLbl: Label 'VendorNo';
        GSTCustomDutyErr: Label 'Custom Duty Amount must be 0 if GST Group Type is Service while transferring from Bonded Warehouse location.';
        GSTAssessableErr: Label 'GST Assessable Value must be 0 if GST Group Type is Service while transferring from Bonded Warehouse location.';
        LocGSTRegNoLbl: Label 'LocGSTRegNo';
        InTransitLocationLbl: Label 'InTransitLocation';
}
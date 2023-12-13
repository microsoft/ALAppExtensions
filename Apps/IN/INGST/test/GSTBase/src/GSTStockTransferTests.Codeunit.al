codeunit 18427 "GST Stock Transfer Tests"
{

    Subtype = Test;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostTransferOrderwithInterStateStockTransferITC()
    var
        FromLocation, ToLocation, InTransitLocation : Record Location;
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        GSTGroupType: Enum "GST Group Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [354811] Check if the system is calculating GST in case of Inter-State Stock Transfer Shipment and Receipt.
        // [GIVEN] Created GST Setup ,Transfer Locations with ITC
        CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        CreateGSTSetup(GSTGroupType::Goods, false, true);

        // [WHEN] Create and Post Interstate Transfer Order with ITC
        PostedDocumentNo := CreateandPostTransferOrder(
            TransferHeader,
            TransferLine);

        // [THEN] GLEntries Verified 
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromTransferOrderwithIntraStateStockTransferITC()
    var
        FromLocation, ToLocation, InTransitLocation : Record Location;
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        GSTGroupType: Enum "GST Group Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [354826] Check if the system is calculating GST in case of Intra-State Stock Transfer Shipment and Receipt.
        // [GIVEN] Created GST Setup ,SharedSetps Location ,Inventory Setup
        CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        CreateGSTSetup(GSTGroupType::Goods, true, true);

        // [WHEN] Create and Post Intrastate Transfer Order with ITC
        PostedDocumentNo := CreateandPostTransferOrder(
            TransferHeader,
            TransferLine);

        // [THEN] GLEntries Verified 
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromTransferOrderwithInterStateStockTransferWithoutITC()
    var
        FromLocation, ToLocation, InTransitLocation : Record Location;
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        GSTGroupType: Enum "GST Group Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [385430] Check if the system is calculating GST in case of Inter-State Stock Transfer Shipment and Receipt with ITC Non-Availment.
        // [GIVEN] Created GST Setup ,Transfer Locations with ITC
        CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        CreateGSTSetup(GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Interstate Transfer Order without ITC
        PostedDocumentNo := CreateandPostTransferOrder(
            TransferHeader,
            TransferLine);

        // [THEN] GLEntries Verified 
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromTransferOrderwithInterStateStockTransfer()
    var
        FromLocation, ToLocation, InTransitLocation : Record Location;
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        GSTGroupType: Enum "GST Group Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [453739] Check if the system is able to Post with GST in case of Inter-State Stock Transfer Shipment and Receipt.
        // [GIVEN] Created GST Setup ,Transfer Locations
        CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        CreateGSTSetup(GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Interstate Transfer Order
        PostedDocumentNo := CreateandPostTransferOrder(
            TransferHeader,
            TransferLine);

        // [THEN] GLEntries Verified 
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostRevaluationFromTransferOrderwithInterStateStockTransfer()
    var
        FromLocation, ToLocation, InTransitLocation : Record Location;
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        GSTGroupType: Enum "GST Group Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [460400] Check if the system is able to Post with GST in case of Inter-State Stock Transfer Shipment and Receipt.
        // [GIVEN] Created GST Setup ,Transfer Locations
        CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        CreateGSTSetup(GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Interstate Transfer Order
        PostedDocumentNo := CreateandPostTransferOrderWithLoadUnRealizedProfitAmt(
            TransferHeader,
            TransferLine);

        // [THEN] Value Entry Verified 
        VerifyValueEntryForRevaluationEntryType(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPageHandler')]
    procedure PostTransferOrderwithInterStateAndGSTCessStockTransfer()
    var
        FromLocation, ToLocation, InTransitLocation : Record Location;
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        CompCalcType: Enum "Component Calc Type";
        GSTGroupType: Enum "GST Group Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [460400] Check if the system is able to Post with GST in case of Inter-State Stock Transfer Shipment and Receipt.
        // [GIVEN] Created GST Setup ,Transfer Locations
        CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        CreateGSTSetupWithGSTCess(GSTGroupType::Goods, false, CompCalcType::Threshold, false);

        // [WHEN] Create and Post Interstate Transfer Order
        PostedDocumentNo := CreateandPostTransferOrder(
            TransferHeader,
            TransferLine);

        // [THEN] Value Entry Verified 
        VerifyGSTEntries(PostedDocumentNo);
    end;

    local procedure CreateItemWithInventory(): Code[20]
    var
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        InputCreditAvailment: Boolean;
    begin
        InputCreditAvailment := StorageBoolean.Get(AvailmentLbl);

        CreateNoVatSetup();

        LibraryInventory.CreateItem(Item);
        Item.Validate("GST Group Code", LibraryStorage.Get(GSTGroupCodeLbl));
        Item.Validate("HSN/SAC Code", LibraryStorage.Get(HSNSACCodeLbl));
        if InputCreditAvailment then
            Item.Validate("GST Credit", Item."GST Credit"::Availment)
        else
            Item.Validate("GST Credit", Item."GST Credit"::"Non-Availment");
        Item.Modify(true);

        UpdateInventoryPostingSetup((LibraryStorage.Get(InTransitLocationLbl)), Item."Inventory Posting Group");
        UpdateInventoryPostingSetup((LibraryStorage.Get(FromLocationLbl)), Item."Inventory Posting Group");
        UpdateInventoryPostingSetup((LibraryStorage.Get(ToLocationLbl)), Item."Inventory Posting Group");
        LibraryInventory.CreateItemJournalLineInItemTemplate(
            ItemJournalLine, Item."No.",
            (LibraryStorage.Get(FromLocationLbl)),
            '', LibraryRandom.RandInt(100));
        Codeunit.Run(Codeunit::"Item Jnl.-Post Batch", ItemJournalLine);
        exit(Item."No.");
    end;

    local procedure CreateLotItemWithInventory(var Item: Record Item; var LotNo: Code[50])
    var
        ItemJournalLine: Record "Item Journal Line";
        ReservationEntry: Record "Reservation Entry";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        InputCreditAvailment: Boolean;
    begin
        InputCreditAvailment := StorageBoolean.Get(AvailmentLbl);

        CreateNoVatSetup();
        LibraryItemTracking.CreateLotItem(Item);

        Item.Validate("GST Group Code", LibraryStorage.Get(GSTGroupCodeLbl));
        Item.Validate("HSN/SAC Code", LibraryStorage.Get(HSNSACCodeLbl));
        if InputCreditAvailment then
            Item.Validate("GST Credit", Item."GST Credit"::Availment)
        else
            Item.Validate("GST Credit", Item."GST Credit"::"Non-Availment");
        Item.Modify(true);

        UpdateInventoryPostingSetup((LibraryStorage.Get(InTransitLocationLbl)), Item."Inventory Posting Group");
        UpdateInventoryPostingSetup((LibraryStorage.Get(FromLocationLbl)), Item."Inventory Posting Group");
        UpdateInventoryPostingSetup((LibraryStorage.Get(ToLocationLbl)), Item."Inventory Posting Group");
        LibraryInventory.CreateItemJournalLineInItemTemplate(
            ItemJournalLine, Item."No.",
            (LibraryStorage.Get(FromLocationLbl)),
            '', LibraryRandom.RandInt(100));
        LotNo := NoSeriesManagement.GetNextNo(Item."Lot Nos.", WorkDate(), true);
        LibraryItemTracking.CreateItemJournalLineItemTracking(ReservationEntry, ItemJournalLine, '', LotNo, ItemJournalLine.Quantity);
        Codeunit.Run(Codeunit::"Item Jnl.-Post Batch", ItemJournalLine);
    end;

    local procedure CreateNoVatSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.Reset();
        VATPostingSetup.SetRange("VAT Bus. Posting Group", '');
        VATPostingSetup.SetRange("VAT Prod. Posting Group", '');
        if VATPostingSetup.IsEmpty() then begin
            VATPostingSetup.Init();
            VATPostingSetup.Validate("VAT Bus. Posting Group", '');
            VATPostingSetup.Validate("VAT Prod. Posting Group", '');
            VATPostingSetup.Validate("VAT Identifier", LibraryRandom.RandText(10));
            VATPostingSetup.Insert(true);
        end;
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
        CreateTransferLineWithGST(TransferHeader, TransferLine, StorageBoolean.Get(AvailmentLbl));
        DocumentNo := TransferHeader."No.";
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, true);
        PostedDocumentNo := GetPostedTransferShipmentNo(DocumentNo);
        exit(PostedDocumentNo);
    end;

    local procedure CreateandPostTransferOrderWithLoadUnRealizedProfitAmt(var TransferHeader: Record "Transfer Header";
        var TransferLine: Record "Transfer Line"): Code[20]
    var
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
    begin
        LibraryWarehouse.CreateTransferHeader(
            TransferHeader,
            (LibraryStorage.Get(FromLocationLbl)),
            (LibraryStorage.Get(ToLocationLbl)),
            '');

        TransferHeader.Validate("Direct Transfer", true);
        TransferHeader.Validate("Load Unreal Prof Amt on Invt.", true);
        TransferHeader.Modify();

        CreateTransferLineWithLotItemAndGST(TransferHeader, TransferLine, StorageBoolean.Get(AvailmentLbl));
        DocumentNo := TransferHeader."No.";

        LibraryWarehouse.PostTransferOrder(TransferHeader, true, true);
        PostedDocumentNo := GetPostedTransferReceiptNo(DocumentNo);
        exit(PostedDocumentNo);
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
        TransferLine.Modify(true);
    end;

    local procedure CreateTransferLineWithLotItemAndGST(var TransferHeader: Record "Transfer Header";
        var TransferLine: Record "Transfer Line";
        Availment: Boolean)
    var
        Item: Record Item;
        ReservationEntry: Record "Reservation Entry";
        LotNo: Code[50];
    begin
        CreateLotItemWithInventory(Item, LotNo);
        LibraryWarehouse.CreateTransferLine(
             TransferHeader,
             Transferline,
             Item."No.",
             LibraryRandom.RandIntInRange(1, 5));
        TransferLine.Validate("Transfer Price", LibraryRandom.RandDecInRange(100, 1000, 0));
        if Availment then
            Transferline.Validate("GST Credit", Transferline."GST Credit"::Availment)
        else
            TransferLine.Validate("GST Credit", TransferLine."GST Credit"::"Non-Availment");
        TransferLine.Modify(true);
        LibraryItemTracking.CreateTransferOrderItemTracking(ReservationEntry, TransferLine, '', LotNo, TransferLine.Quantity);
    end;

    local procedure GetPostedTransferShipmentNo(DocumentNo: Code[20]): Code[20]
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        TransferShipmentHeader.SetRange("Transfer Order No.", DocumentNo);
        if TransferShipmentHeader.FindFirst() then
            exit(TransferShipmentHeader."No.")
    end;

    local procedure GetPostedTransferReceiptNo(DocumentNo: Code[20]): Code[20]
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
    begin
        TransferReceiptHeader.SetRange("Transfer Order No.", DocumentNo);
        if TransferReceiptHeader.FindFirst() then
            exit(TransferReceiptHeader."No.")
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
            InterStateSetup();

        StorageBoolean.Set(AvailmentLbl, Availment);
        CreateTaxRate();
    end;

    local procedure CreateGSTSetupWithGSTCess(
        GSTGroupType: Enum "GST Group Type";
        IntraState: Boolean;
        CompCalcType: Enum "Component Calc Type";
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

        GSTGroupCode := LibraryGST.CreateCessGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::" ", CompCalcType, false);
        LibraryStorage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        LibraryStorage.Set(HSNSACCodeLbl, HSNSACCode);

        LibraryGST.CreateNoVatSetup();

        if IntraState then
            IntraStateSetupForCess()
        else
            InterStateSetupForCess();

        StorageBoolean.Set(AvailmentLbl, Availment);
        CreateTaxRateWithGSTCess();
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
        Location."State Code" := (LibraryStorage.Get(LocationStateCodeLbl));
        Location."GST Registration No." := (LibraryStorage.Get(LocGSTRegNoLbl));
        Location."Location ARN No." := Format(LibraryRandom.RandIntInRange(1000, 9999));
        Location.Modify(true);

        CreateGSTSetupTaxRateParameters(true, Location."State Code", Location."State Code");
        CreateGSTComponentAndPostingSetup(true, Location."State Code", TaxComponent, GSTComponentCode);
    end;

    local procedure InterStateSetup()
    var
        TaxComponent: Record "Tax Component";
        Location: Record Location;
        State: Record State;
        GSTComponentCode: Text[30];
        FromStateCode, ToStateCode : Code[10];
    begin
        Location.Reset();
        Location.Get(LibraryStorage.Get(FromLocationLbl));
        Location."State Code" := (LibraryStorage.Get(LocationStateCodeLbl));
        FromStateCode := Location."State Code";
        Location."GST Registration No." := (LibraryStorage.Get(LocGSTRegNoLbl));
        Location."Location ARN No." := Format(LibraryRandom.RandIntInRange(1000, 9999));
        Location.Modify(true);

        Location.Reset();
        Location.Get(LibraryStorage.Get(ToLocationLbl));
        LibraryGST.CreateState(State);
        Location."State Code" := State.Code;
        ToStateCode := Location."State Code";
        Location."GST Registration No." := (LibraryStorage.Get(LocGSTRegNoLbl));
        Location."Location ARN No." := Format(LibraryRandom.RandIntInRange(1000, 9999));
        Location.Modify(true);

        CreateGSTSetupTaxRateParameters(false, FromStateCode, ToStateCode);
        CreateGSTComponentAndPostingSetup(false, FromStateCode, TaxComponent, GSTComponentCode);
        CreateGSTComponentAndPostingSetup(false, ToStateCode, TaxComponent, GSTComponentCode);
    end;

    local procedure IntraStateSetupForCess()
    var
        CompanyInformation: Record "Company Information";
        TaxComponent: Record "Tax Component";
        Location: Record Location;
        GSTComponentCode: Text[30];
    begin
        CompanyInformation.Get();

        Location.Reset();
        Location.Get(LibraryStorage.Get(FromLocationLbl));
        Location."State Code" := (LibraryStorage.Get(LocationStateCodeLbl));
        Location."GST Registration No." := (LibraryStorage.Get(LocGSTRegNoLbl));
        Location."Location ARN No." := Format(LibraryRandom.RandIntInRange(1000, 9999));
        Location.Modify(true);

        Location.Reset();
        Location.Get(LibraryStorage.Get(ToLocationLbl));
        Location."State Code" := (LibraryStorage.Get(LocationStateCodeLbl));
        Location."GST Registration No." := LibraryGST.CreateGSTRegistrationNos(Location."State Code", CompanyInformation."P.A.N. No.");
        Location."Location ARN No." := Format(LibraryRandom.RandIntInRange(1000, 9999));
        Location.Modify(true);

        CreateGSTSetupWithCessTaxRateParameters(true, Location."State Code", Location."State Code");
        CreateGSTComponentAndPostingSetup(true, Location."State Code", TaxComponent, GSTComponentCode);
    end;

    local procedure InterStateSetupForCess()
    var
        CompanyInformation: Record "Company Information";
        TaxComponent: Record "Tax Component";
        Location: Record Location;
        GSTComponentCode: Text[30];
        FromStateCode, ToStateCode : Code[10];
    begin
        CompanyInformation.Get();

        Location.Reset();
        Location.Get(LibraryStorage.Get(FromLocationLbl));
        Location."State Code" := (LibraryStorage.Get(LocationStateCodeLbl));
        FromStateCode := Location."State Code";
        Location."GST Registration No." := (LibraryStorage.Get(LocGSTRegNoLbl));
        Location."Location ARN No." := Format(LibraryRandom.RandIntInRange(1000, 9999));
        Location.Modify(true);

        Location.Reset();
        Location.Get(LibraryStorage.Get(ToLocationLbl));
        Location."State Code" := LibraryGST.CreateGSTStateCode();
        ToStateCode := Location."State Code";
        Location."GST Registration No." := LibraryGST.CreateGSTRegistrationNos(ToStateCode, CompanyInformation."P.A.N. No.");
        Location."Location ARN No." := Format(LibraryRandom.RandIntInRange(1000, 9999));
        Location.Modify(true);

        CreateGSTSetupWithCessTaxRateParameters(false, FromStateCode, ToStateCode);
        CreateGSTComponentAndPostingSetup(false, FromStateCode, TaxComponent, GSTComponentCode);
        CreateGSTComponentAndPostingSetup(false, ToStateCode, TaxComponent, GSTComponentCode);
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

    local procedure CreateGSTSetupWithCessTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10])
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
            ComponentPerArray[5] := LibraryRandom.RandDecInRange(8, 10, 0);
            ComponentPerArray[6] := LibraryRandom.RandDecInRange(4, 6, 0);
            ComponentPerArray[7] := LibraryRandom.RandDecInRange(900, 1100, 0);
            ComponentPerArray[8] := LibraryRandom.RandDecInRange(900, 100, 0);
            ComponentPerArray[9] := LibraryRandom.RandDecInRange(1, 2, 0);
        end else begin
            ComponentPerArray[4] := GSTTaxPercent;
            ComponentPerArray[5] := LibraryRandom.RandDecInRange(8, 10, 0);
            ComponentPerArray[6] := LibraryRandom.RandDecInRange(4, 6, 0);
            ComponentPerArray[7] := LibraryRandom.RandDecInRange(900, 1100, 0);
            ComponentPerArray[8] := LibraryRandom.RandDecInRange(900, 100, 0);
            ComponentPerArray[9] := LibraryRandom.RandDecInRange(1, 2, 0);
        end;
    end;

    local procedure CreateGSTComponentAndPostingSetup(IntraState: Boolean; LocationStateCode: Code[10]; TaxComponent: Record "Tax Component"; GSTcomponentcode: Text[30]);
    begin
        IF IntraState then begin
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
        GSTComponentCode := CessLbl;
        LibraryGST.CreateGSTCessPostingSetup(GSTComponentCode, LocationStateCode);
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

    local procedure CreateTaxRateWithGSTCess()
    var
        GSTSetup: Record "GST Setup";
        TaxTypes: TestPage "Tax Types";
    begin
        GSTSetup.Get();
        TaxTypes.OpenEdit();
        LibraryStorage.Set(TaxTypeLbl, GSTSetup."GST Tax Type");
        TaxTypes.Filter.SetFilter(Code, GSTSetup."GST Tax Type");
        TaxTypes.TaxRates.Invoke();

        LibraryStorage.Set(TaxTypeLbl, GSTSetup."Cess Tax Type");
        TaxTypes.Filter.SetFilter(Code, GSTSetup."Cess Tax Type");
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

    local procedure VerifyGSTEntries(DocumentNo: Code[20])
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        ComponentList: List of [Code[30]];
    begin
        TransferShipmentLine.SetRange("Document No.", DocumentNo);
        TransferShipmentLine.SetFilter("Item No.", '<>%1', '');
        TransferShipmentLine.FindSet();
        repeat
            FillComponentList(ComponentList, TransferShipmentLine."GST Group Code");
            VerifyGSTEntriesForTransfer(TransferShipmentLine, DocumentNo, ComponentList);
            VerifyDetailedGSTEntriesForTransfer(TransferShipmentLine, DocumentNo, ComponentList);
        until TransferShipmentLine.Next() = 0;
    end;

    local procedure GetCessAmountForTransferShipmentLine(TransferShipmentLine: Record "Transfer Shipment Line"; GSTBaseAmount: Decimal; var CessAmount: Decimal; var CessPercent: Decimal)
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        GSTGroup: Record "GST Group";
        CompareAmount, CurrencyFactor : Decimal;
        CessAmountByCessPercent, CessAmountByUnitFactor : Decimal;
    begin
        Clear(CessAmount);

        TransferShipmentHeader.Get(TransferShipmentLine."Document No.");
        GSTGroup.Get(TransferShipmentLine."GST Group Code");

        CurrencyFactor := 1;

        CompareAmount := TransferShipmentLine.Amount / CurrencyFactor;

        case GSTGroup."Component Calc. Type" of
            "Component Calc Type"::"Cess %":
                begin
                    CessAmount := ((GSTBaseAmount * ComponentPerArray[5]) / 100) / CurrencyFactor;
                    CessPercent := ComponentPerArray[5];
                end;

            "Component Calc Type"::Threshold:
                if CompareAmount <= ComponentPerArray[7] then begin
                    CessAmount := ((GSTBaseAmount * ComponentPerArray[6]) / 100) / CurrencyFactor;
                    CessPercent := ComponentPerArray[6];
                end else begin
                    CessAmount := ((GSTBaseAmount * ComponentPerArray[5]) / 100) / CurrencyFactor;
                    CessPercent := ComponentPerArray[5];
                end;

            "Component Calc Type"::"Amount / Unit Factor":
                begin
                    CessAmount := (((CurrencyFactor * ComponentPerArray[8]) / ComponentPerArray[9]) * TransferShipmentLine.Quantity);
                    CessAmount := CessAmount / CurrencyFactor;
                    CessPercent := 0;
                end;

            "Component Calc Type"::"Cess % + Amount / Unit Factor":
                begin
                    CessAmount := ((GSTBaseAmount * ComponentPerArray[5]) / 100) / CurrencyFactor;
                    CessAmount += (((CurrencyFactor * ComponentPerArray[8]) / ComponentPerArray[9]) * TransferShipmentLine.Quantity) / CurrencyFactor;
                    CessPercent := 0;
                end;

            "Component Calc Type"::"Cess % Or Amount / Unit Factor Whichever Higher":
                begin
                    CessAmountByCessPercent := ((GSTBaseAmount * ComponentPerArray[5]) / 100) / CurrencyFactor;
                    CessAmountByUnitFactor := (((CurrencyFactor * ComponentPerArray[8]) / ComponentPerArray[9]) * TransferShipmentLine.Quantity) / CurrencyFactor;
                    if CessAmountByCessPercent >= CessAmountByUnitFactor then begin
                        CessAmount := CessAmountByCessPercent;
                        CessPercent := ComponentPerArray[5];
                    end else begin
                        CessAmount := CessAmountByUnitFactor;
                        CessPercent := 0;
                    end;
                end;
        end;
    end;

    local procedure FillComponentList(
       var ComponentList: List of [Code[30]];
       GSTGroupCode: Code[20])
    var
        GSTGroup: Record "GST Group";
    begin
        GSTGroup.Get(GSTGroupCode);
        Clear(ComponentList);
        if LibraryStorage.Get(FromStateCodeLbl) = LibraryStorage.Get(ToStateCodeLbl) then begin
            ComponentList.Add(CGSTLbl);
            ComponentList.Add(SGSTLbl);
        end else
            ComponentList.Add(IGSTLbl);

        if GSTGroup."Component Calc. Type" <> GSTGroup."Component Calc. Type"::General then
            ComponentList.Add(CessLbl);
    end;

    local procedure GetTransactionNo(DocumentNo: Code[20]; PostingDate: Date; DocumentType: Enum "Gen. Journal Document Type"): Integer
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Posting Date", PostingDate);
        GLEntry.SetRange("Document Type", DocumentType);
        GLEntry.FindFirst();

        exit(GLEntry."Transaction No.");
    end;

    local procedure VerifyGSTEntriesForTransfer(
        TransferShipmentLine: Record "Transfer Shipment Line";
        DocumentNo: Code[20];
        ComponentList: List of [Code[30]])
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        GSTGroup: Record "GST Group";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        SourceCodeSetup: Record "Source Code Setup";
        GSTAmount: Decimal;
        CessAmount, CessPercent : Decimal;
        ComponentCode: Code[30];
        TransactionNo: Integer;
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        TransferShipmentHeader.Get(DocumentNo);

        TransferShipmentLine.SetRange("Document No.", DocumentNo);
        TransferShipmentLine.SetFilter("Item No.", '<>%1', '');
        TransferShipmentLine.FindFirst();

        SourceCodeSetup.Get();

        GSTGroup.Get(TransferShipmentLine."GST Group Code");

        TransactionNo := GetTransactionNo(DocumentNo, TransferShipmentHeader."Posting Date", DocumentType::Invoice);

        foreach ComponentCode in ComponentList do begin
            GSTLedgerEntry.Reset();
            GSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            GSTLedgerEntry.SetRange("Document No.", DocumentNo);
            GSTLedgerEntry.SetRange("Posting Date", TransferShipmentHeader."Posting Date");
            GSTLedgerEntry.SetRange("Document Type", GSTLedgerEntry."Document Type"::Invoice);
            GSTLedgerEntry.FindFirst();

            if LibraryStorage.Get(FromStateCodeLbl) <> LibraryStorage.Get(ToStateCodeLbl) then
                GSTAmount := (TransferShipmentLine.Amount * ComponentPerArray[4]) / 100
            else
                GSTAmount := TransferShipmentLine.Amount * ComponentPerArray[1] / 100;

            if GSTGroup."Component Calc. Type" <> GSTGroup."Component Calc. Type"::General then
                GetCessAmountForTransferShipmentLine(TransferShipmentLine, TransferShipmentLine.Amount, CessAmount, CessPercent);

            Assert.AreEqual(TransferShipmentLine."Gen. Prod. Posting Group", GSTLedgerEntry."Gen. Prod. Posting Group",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Gen. Prod. Posting Group"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransferShipmentHeader."Posting Date", GSTLedgerEntry."Posting Date",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Posting Date"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(DocumentNo, GSTLedgerEntry."Document No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Posting Date"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Document Type"::Invoice, GSTLedgerEntry."Document Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Document Type"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Transaction Type"::Sales, GSTLedgerEntry."Transaction Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction Type"), GSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(-TransferShipmentLine.Amount, GSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Base Amount"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(UserId, GSTLedgerEntry."User ID",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("User ID"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(SourceCodeSetup.Transfer, GSTLedgerEntry."Source Code",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Code"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransferShipmentHeader."Transfer Order No.", GSTLedgerEntry."External Document No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("External Document No."), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(ComponentCode, GSTLedgerEntry."GST Component Code",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Component Code"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransactionNo, GSTLedgerEntry."Transaction No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction No."), GSTLedgerEntry.TableCaption));

            if ComponentCode <> CessLbl then
                Assert.AreNearlyEqual(-GSTAmount, GSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                    StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Amount"), GSTLedgerEntry.TableCaption))
            else
                Assert.AreNearlyEqual(CessAmount, GSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                    StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Amount"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Entry Type"::"Initial Entry", GSTLedgerEntry."Entry Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Entry Type"), GSTLedgerEntry.TableCaption));
        end;
    end;

    local procedure VerifyDetailedGSTEntriesForTransfer(TransferShipmentLine: Record "Transfer Shipment Line";
        DocumentNo: Code[20];
        ComponentList: List of [Code[30]])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTGroup: Record "GST Group";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        SourceCodeSetup: Record "Source Code Setup";
        FromLocation: Record Location;
        ToLocation: Record Location;
        GSTAmount: Decimal;
        CessAmount, CessPercent : Decimal;
        TransactionNo: Integer;
        DocumentType: Enum "Gen. Journal Document Type";
        ComponentCode: Code[30];
    begin
        TransferShipmentHeader.Get(DocumentNo);

        TransferShipmentLine.SetRange("Document No.", DocumentNo);
        TransferShipmentLine.SetFilter("Item No.", '<>%1', '');
        TransferShipmentLine.FindFirst();

        SourceCodeSetup.Get();
        FromLocation.Get(LibraryStorage.Get(FromLocationLbl));
        ToLocation.Get(LibraryStorage.Get(ToLocationLbl));

        GSTGroup.Get(TransferShipmentLine."GST Group Code");

        TransactionNo := GetTransactionNo(DocumentNo, TransferShipmentHeader."Posting Date", DocumentType::Invoice);

        foreach ComponentCode in ComponentList do begin
            DetailedGSTLedgerEntry.Reset();
            DetailedGSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Posting Date", TransferShipmentHeader."Posting Date");
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
            DetailedGSTLedgerEntry.FindFirst();

            DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");

            if LibraryStorage.Get(FromStateCodeLbl) <> LibraryStorage.Get(ToStateCodeLbl) then
                GSTAmount := (TransferShipmentLine.Amount * ComponentPerArray[4]) / 100
            else
                GSTAmount := TransferShipmentLine.Amount * ComponentPerArray[1] / 100;

            if GSTGroup."Component Calc. Type" <> GSTGroup."Component Calc. Type"::General then
                GetCessAmountForTransferShipmentLine(TransferShipmentLine, TransferShipmentLine.Amount, CessAmount, CessPercent);

            Assert.AreEqual(DetailedGSTLedgerEntry."Entry Type"::"Initial Entry", DetailedGSTLedgerEntry."Entry Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Entry Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Transaction Type"::Sales, DetailedGSTLedgerEntry."Transaction Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Document Type"::Invoice, DetailedGSTLedgerEntry."Document Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Document Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransferShipmentHeader."Posting Date", DetailedGSTLedgerEntry."Posting Date",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Posting Date"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry.Type::Item, DetailedGSTLedgerEntry.Type,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption(Type), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransferShipmentLine."Item No.", DetailedGSTLedgerEntry."No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(LibraryGST.GetGSTPayableAccountNo((LibraryStorage.Get(FromStateCodeLbl)), DetailedGSTLedgerEntry."GST Component Code"), DetailedGSTLedgerEntry."G/L Account No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("G/L Account No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Product Type"::Item, DetailedGSTLedgerEntry."Product Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Product Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Source Type"::" ", DetailedGSTLedgerEntry."Source Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual('', DetailedGSTLedgerEntry."Source No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransferShipmentLine."HSN/SAC Code", DetailedGSTLedgerEntry."HSN/SAC Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("HSN/SAC Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransferShipmentLine."GST Group Code", DetailedGSTLedgerEntry."GST Group Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Group Code"), DetailedGSTLedgerEntry.TableCaption));

            if LibraryStorage.Get(FromStateCodeLbl) <> LibraryStorage.Get(ToStateCodeLbl) then
                Assert.AreEqual(DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate, DetailedGSTLedgerEntry."GST Jurisdiction Type",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Jurisdiction Type"), DetailedGSTLedgerEntry.TableCaption))
            else
                Assert.AreEqual(DetailedGSTLedgerEntry."GST Jurisdiction Type"::Intrastate, DetailedGSTLedgerEntry."GST Jurisdiction Type",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Jurisdiction Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(-TransferShipmentLine.Amount, DetailedGSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Base Amount"), DetailedGSTLedgerEntry.TableCaption));

            if ComponentCode <> CessLbl then begin
                if DetailedGSTLedgerEntry."GST Jurisdiction Type" = DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate then
                    Assert.AreEqual(ComponentPerArray[4], DetailedGSTLedgerEntry."GST %",
                        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
                else
                    Assert.AreEqual(ComponentPerArray[1], DetailedGSTLedgerEntry."GST %",
                        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption));

                Assert.AreNearlyEqual(-GSTAmount, DetailedGSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Amount"), DetailedGSTLedgerEntry.TableCaption));
            end else begin
                Assert.AreEqual(CessPercent, DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption));

                Assert.AreNearlyEqual(-CessAmount, DetailedGSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Amount"), DetailedGSTLedgerEntry.TableCaption));
            end;

            Assert.AreEqual(TransferShipmentHeader."Transfer Order No.", DetailedGSTLedgerEntry."External Document No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("External Document No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransferShipmentHeader."Transfer Order No.", DetailedGSTLedgerEntryInfo."Original Doc. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. No."), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(-TransferShipmentLine.Quantity, DetailedGSTLedgerEntry.Quantity,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName(Quantity), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransferShipmentLine."Line No.", DetailedGSTLedgerEntry."Document Line No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Reverse Charge"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(LibraryStorage.Get(FromStateCodeLbl), DetailedGSTLedgerEntryInfo."Location State Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Location State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(LibraryStorage.Get(ToStateCodeLbl), DetailedGSTLedgerEntryInfo."Buyer/Seller State Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Buyer/Seller State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(FromLocation."GST Registration No.", DetailedGSTLedgerEntry."Location  Reg. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Location  Reg. No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(ToLocation."GST Registration No.", DetailedGSTLedgerEntry."Buyer/Seller Reg. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Buyer/Seller Reg. No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."GST Group Type"::Goods, DetailedGSTLedgerEntry."GST Group Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Group Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransferShipmentLine."GST Credit"::" ", DetailedGSTLedgerEntry."GST Credit",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Credit"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransactionNo, DetailedGSTLedgerEntry."Transaction No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntryInfo."Original Doc. Type"::"Transfer Shipment", DetailedGSTLedgerEntryInfo."Original Doc. Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. Type"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(LibraryStorage.Get(FromLocationLbl), DetailedGSTLedgerEntry."Location Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Location Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(UserId, DetailedGSTLedgerEntryInfo."User ID",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("User ID"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(TransferShipmentLine."Unit of Measure Code", DetailedGSTLedgerEntryInfo.UOM,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(UOM), DetailedGSTLedgerEntry.TableCaption));
        end;
    end;

    local procedure VerifyValueEntryForRevaluationEntryType(DocumentNo: Code[20])
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferReceiptLine: Record "Transfer Receipt Line";
        ValueEntry: Record "Value Entry";
    begin
        TransferReceiptHeader.Get(DocumentNo);

        TransferReceiptLine.SetRange("Document No.", DocumentNo);
        TransferReceiptLine.FindFirst();

        ValueEntry.SetRange("Document No.", DocumentNo);
        ValueEntry.SetRange("Posting Date", TransferReceiptHeader."Posting Date");
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Transfer);
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::Revaluation);
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::" ");
        ValueEntry.FindLast();

        Assert.AreEqual(TransferReceiptLine.Amount, ValueEntry."Cost Amount (Actual)",
            StrSubstNo(ValueEntryVerifyErr, ValueEntry.FieldCaption("Cost Amount (Actual)"), ValueEntry.TableCaption));
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

    [PageHandler]
    procedure TaxRatesPageHandler(var TaxRates: TestPage "Tax Rates")
    var
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        if LibraryStorage.Get(TaxTypeLbl) = GSTSetup."GST Tax Type" then begin
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
        end else
            if LibraryStorage.Get(TaxTypeLbl) = GSTSetup."Cess Tax Type" then begin
                TaxRates.New();
                TaxRates.AttributeValue1.SetValue(LibraryStorage.Get(GSTGroupCodeLbl));
                TaxRates.AttributeValue2.SetValue(LibraryStorage.Get(HSNSACCodeLbl));
                TaxRates.AttributeValue3.SetValue(LibraryStorage.Get(FromStateCodeLbl));
                TaxRates.AttributeValue4.SetValue(LibraryStorage.Get(ToStateCodeLbl));
                TaxRates.AttributeValue5.SetValue(Today);
                TaxRates.AttributeValue6.SetValue(CALCDATE('<10Y>', Today));
                TaxRates.AttributeValue7.SetValue(ComponentPerArray[5]); //Cess
                TaxRates.AttributeValue8.SetValue(ComponentPerArray[6]); //Before Threshold Cess
                TaxRates.AttributeValue9.SetValue(ComponentPerArray[7]); //Threshold Amount
                TaxRates.AttributeValue10.SetValue(ComponentPerArray[8]); //Cess Amount Per Unit Factor
                TaxRates.AttributeValue11.SetValue(ComponentPerArray[9]); //Cess Factor Quantity
                TaxRates.OK().Invoke();
            end;
    end;

    var
        LibraryGST: Codeunit "Library GST";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
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
        CessLbl: Label 'CESS', Locked = true;
        FromLocationLbl: Label 'FromLocation';
        ToLocationLbl: Label 'ToLocation';
        LocGSTRegNoLbl: Label 'LocGSTRegNo';
        InTransitLocationLbl: Label 'InTransitLocation';
        TaxTypeLbl: Label 'TaxType', Locked = true;
        GSTLEVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
        ValueEntryVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
}
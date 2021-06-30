codeunit 147108 "CD WMS"
{
    // // [FEATURE] [Custom Declaration]

    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryCDTracking: Codeunit "Library - CD Tracking";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        DoYouWantPostRcptQst: Label 'Do you want to post the receipt?';
        DoYouWantRegDocQst: Label 'Do you want to register the %1 Document?';
        DoYouWantPostJnlLinesQst: Label 'Do you want to post the journal lines?';
        IncorrConfirmDialogOpenedErr: Label 'Incorrect confirm dialog opened: ';
        NumberOfPutAwayActivitiesCreatedMsg: Label 'Number of put-away activities created';
        JnlLinesSuccessPostedMsg: Label 'The journal lines were successfully posted.';
        WhseRcptHdrCreatedMsg: Label '1 Warehouse Receipt Header has been created.';
        WhseShptHdrCreatedMsg: Label '1 Warehouse Shipment Header has been created.';
        NumOfSrcDocsPostedMsg: Label 'Number of source documents posted: 1 out of a total of 1.';
        UnexpMsgErr: Label 'Unexpected message: ';

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        if IsInitialized then
            exit;

        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateVATPostingSetup();
        LibraryERMCountryData.UpdateLocalData();

        IsInitialized := true;
        Commit();
    end;

    [Test]
    [HandlerFunctions('HndlConfirm,MessageHandler')]
    [Scope('OnPrem')]
    procedure NoTracking()
    var
        Location: Record Location;
        Vendor: Record Vendor;
        Customer: Record Customer;
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        Counter: Integer;
        Qty: array[2] of Integer;
        BinArray: array[3] of Code[20];
    begin
        // Check that simple scenario without CD Tracking works correctly

        Initialize();
        LibraryCDTracking.CreateWMSLocation(Location);
        LibraryPurchase.CreateVendor(Vendor);
        LibrarySales.CreateCustomer(Customer);
        LibraryInventory.CreateItem(Item);
        for Counter := 1 to ArrayLen(BinArray) do
            BinArray[Counter] := LibraryCDTracking.CreateBin(Location, Counter);
        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", Location.Code);
        Qty[1] := 10;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, Item."No.", LibraryRandom.RandDec(100, 2), Qty[1]);
        LibraryPurchase.ReleasePurchaseDocument(PurchaseHeader);

        PostWhseRcptFromPurchOrder(PurchaseHeader, Item, Location, BinArray[2], BinArray[1], 5);
        LibraryCDTracking.ValidateBinContentQty(Location, BinArray[1], 5);
        LibrarySales.CreateSalesOrderWithLocation(SalesHeader, Customer."No.", Location.Code);
        Qty[2] := 5;
        LibrarySales.CreateSalesLineWithUnitPrice(SalesLine, SalesHeader, Item."No.", LibraryRandom.RandDec(100, 2), Qty[2]);
        SalesLine.AutoReserve();
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        PostWhseShptFromSalesOrder(WarehouseShipmentHeader, WarehouseShipmentLine, SalesHeader, Item, BinArray[2]);
        PostShptAfterRegPick(WarehouseShipmentLine, WarehouseShipmentHeader, Location, BinArray[2], 0, Qty[2]);
    end;

    [Test]
    [HandlerFunctions('HndlConfirm,MessageHandler')]
    [Scope('OnPrem')]
    procedure SerialLotTracking()
    var
        Location: Record Location;
        Vendor: Record Vendor;
        Customer: Record Customer;
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ReservationEntry: Record "Reservation Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        BinArray: array[3] of Code[20];
        SerialNo: array[10] of Code[20];
        LotNo: array[10] of Code[20];
        i: Integer;
        Qty: array[2] of Integer;
    begin
        // Check that tracking with serial and lot nos. works correctly

        Initialize();
        WMSInitialSetup(Location, ItemTrackingCode, Vendor, Customer, Item, true);

        for i := 1 to ArrayLen(BinArray) do
            BinArray[i] := LibraryCDTracking.CreateBin(Location, i);
        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", Location.Code);
        Qty[1] := 10;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(
          PurchaseLine, PurchaseHeader, Item."No.", LibraryRandom.RandDec(100, 2), Qty[1]);
        PurchaseLine.Validate(Quantity, Qty[1]);
        PurchaseLine.Modify();
        for i := 1 to Qty[1] do begin
            SerialNo[i] := LibraryUtility.GenerateGUID();
            LotNo[i] := LibraryUtility.GenerateGUID();
            ItemTrackingSetup."Serial No." := SerialNo[i];
            ItemTrackingSetup."Lot No." := LotNo[i];
            ItemTrackingSetup."Package No." := '';
            LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, ItemTrackingSetup, 1);
        end;
        LibraryPurchase.ReleasePurchaseDocument(PurchaseHeader);

        PostWhseRcptFromPurchOrder(PurchaseHeader, Item, Location, BinArray[2], BinArray[1], 5);
        LibraryCDTracking.ValidateBinContentQty(Location, BinArray[1], 5);
        LibrarySales.CreateSalesOrderWithLocation(SalesHeader, Customer."No.", Location.Code);
        Qty[2] := 5;
        LibrarySales.CreateSalesLineWithUnitPrice(SalesLine, SalesHeader, Item."No.", LibraryRandom.RandDec(100, 2), Qty[2]);
        SalesLine.AutoReserve();
        LibraryItemTracking.CreateSalesTrackingFromReservation(SalesHeader, true);
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        PostWhseShptFromSalesOrder(WarehouseShipmentHeader, WarehouseShipmentLine, SalesHeader, Item, BinArray[2]);
        PostShptAfterRegPick(WarehouseShipmentLine, WarehouseShipmentHeader, Location, BinArray[2], 0, Qty[2]);
        for i := 1 to Qty[2] do begin
            ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
            LibraryItemTracking.CheckLastItemLedgerEntry(
              ItemLedgerEntry, Item."No.", Location.Code, SerialNo[i], LotNo[i], '', -1);
        end;
    end;

    [Test]
    [HandlerFunctions('HndlConfirm,MessageHandler')]
    [Scope('OnPrem')]
    procedure CDTracking()
    var
        Location: Record Location;
        Vendor: Record Vendor;
        Customer: Record Customer;
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ReservationEntry: Record "Reservation Entry";
        PackageNoInformation: Record "Package No. Information";
        ItemLedgerEntry: Record "Item Ledger Entry";
        PackageNo: Code[50];
        BinArray: array[3] of Code[20];
        Counter: Integer;
        Qty: array[2] of Integer;
    begin
        // Check that tracking with CD nos. works correctly

        Initialize();
        WMSInitialSetup(Location, ItemTrackingCode, Vendor, Customer, Item, false);
        PackageNo := LibraryUtility.GenerateGUID();
        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", PackageNo);
        for Counter := 1 to ArrayLen(BinArray) do
            BinArray[Counter] := LibraryCDTracking.CreateBin(Location, Counter);

        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", Location.Code);
        Qty[1] := 10;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(
          PurchaseLine, PurchaseHeader, Item."No.", LibraryRandom.RandDec(100, 2), Qty[1]);
        ItemTrackingSetup."Package No." := PackageNo;
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, ItemTrackingSetup, Qty[1]);
        LibraryPurchase.ReleasePurchaseDocument(PurchaseHeader);

        PostWhseRcptFromPurchOrder(PurchaseHeader, Item, Location, BinArray[2], BinArray[1], 5);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, '', '', PackageNo, Qty[1]);
        LibraryCDTracking.ValidateBinContentQty(Location, BinArray[1], 5);

        LibrarySales.CreateSalesOrderWithLocation(SalesHeader, Customer."No.", Location.Code);
        Qty[2] := 5;
        LibrarySales.CreateSalesLineWithUnitPrice(
          SalesLine, SalesHeader, Item."No.", LibraryRandom.RandDec(100, 2), Qty[2]);
        LibraryItemTracking.CreateSalesOrderItemTracking(ReservationEntry, SalesLine, '', '', PackageNo, Qty[2]);

        SalesLine.AutoReserve();
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        PostWhseShptFromSalesOrder(WarehouseShipmentHeader, WarehouseShipmentLine, SalesHeader, Item, BinArray[2]);
        PostShptAfterRegPick(WarehouseShipmentLine, WarehouseShipmentHeader, Location, BinArray[2], 0, Qty[2]);
        CheckLastItemLedgEntryByType(ItemLedgerEntry."Entry Type"::Sale, Item."No.", Location.Code, PackageNo, -Qty[2]);
    end;

    [Test]
    [HandlerFunctions('HndlConfirm,MessageHandler')]
    [Scope('OnPrem')]
    procedure CDTrackingTransfer()
    var
        Location: Record Location;
        Vendor: Record Vendor;
        Customer: Record Customer;
        PurchaseHeader: Record "Purchase Header";
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
        CDLocationSetup: Record "CD Location Setup";
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ReservationEntry: Record "Reservation Entry";
        PackageNoInformation: Record "Package No. Information";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemJournalLine: Record "Item Journal Line";
        Zone: Record Zone;
        Zone2: Record Zone;
        PackageNo: Code[50];
        NewPackageNo: Code[50];
        BinArray: array[5] of Code[20];
        Counter: Integer;
        Qty: Integer;
    begin
        // Check that tracking with CD Nos. work correctly on trasfering

        Initialize();
        LibraryCDTracking.CreateWMSLocation(Location);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, Location.Code);
        LibraryPurchase.CreateVendor(Vendor);
        LibrarySales.CreateCustomer(Customer);
        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);
        PackageNo := LibraryUtility.GenerateGUID();
        NewPackageNo := LibraryUtility.GenerateGUID();
        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", PackageNo);
        InsertZone(Zone, Location.Code, 'RECEIVE');
        InsertZone(Zone2, Location.Code, 'SHIP');

        for Counter := 1 to ArrayLen(BinArray) do
            BinArray[Counter] := LibraryCDTracking.CreateBin(Location, Counter);

        UpdateBin(BinArray[1], Zone2.Code, 'Ship');
        UpdateBin(BinArray[2], Zone.Code, 'Receive');
        UpdateBin(BinArray[3], Zone.Code, 'QC');
        UpdateBin(BinArray[4], Zone.Code, 'Put Away');
        UpdateBin(BinArray[5], Zone.Code, 'Pick');

        Location.Validate("Adjustment Bin Code", BinArray[3]);
        Location.Validate("Receipt Bin Code", BinArray[2]);
        Location.Validate("Shipment Bin Code", BinArray[1]);
        Location.Modify();

        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", Location.Code);
        Qty := 10;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, Item."No.", LibraryRandom.RandDec(100, 2), Qty);
        ItemTrackingSetup."Package No." := PackageNo;
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, ItemTrackingSetup, Qty);
        LibraryPurchase.ReleasePurchaseDocument(PurchaseHeader);

        LibraryWarehouse.CreateWhseReceiptFromPO(PurchaseHeader);
        PostWhseRcptLineWithZone(Item."No.", Zone.Code);
        PostWhseActLineWithZoneAndBin(Location.Code, BinArray[2], Zone.Code, Qty);

        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, '', '', PackageNo, Qty);
        LibraryCDTracking.ValidateBinContentQty(Location, BinArray[2], 10);

        LibraryCDTracking.CreateItemRecLine(ItemJournalLine, ItemJournalLine."Entry Type"::Transfer, WorkDate(), Item."No.", Qty, Location.Code);
        ItemJournalLine.Validate("Bin Code", BinArray[2]);
        ItemJournalLine.Validate("New Location Code", Location.Code);
        ItemJournalLine.Validate("New Bin Code", BinArray[1]);
        ItemJournalLine.Modify();
        CreateTransItemJnlLineTracking(ItemJournalLine, PackageNo, NewPackageNo);
        LibraryInventory.PostItemJnlLineWithCheck(ItemJournalLine);

        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, '', '', NewPackageNo, 10);
        LibraryCDTracking.ValidateBinContentQty(Location, BinArray[2], Qty);
    end;

    [Test]
    [HandlerFunctions('HndlConfirm,MessageHandler')]
    [Scope('OnPrem')]
    procedure ComplexUOMWithCDTracking()
    var
        Location: Record Location;
        Vendor: Record Vendor;
        Customer: Record Customer;
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Array[2] of Record "Item Tracking Setup";
        ReservationEntry: Record "Reservation Entry";
        PackageNoInformation: Record "Package No. Information";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Counter: Integer;
        Qty: array[2] of Integer;
        BinArray: array[3] of Code[20];
        PackageNo: array[2] of Code[50];
        i: Integer;
    begin
        // Check that tracking with CD nos. works correctly with specific unit of measure

        Initialize();
        WMSInitialSetup(Location, ItemTrackingCode, Vendor, Customer, Item, false);

        for i := 1 to ArrayLen(PackageNo) do
            ItemTrackingSetup[i]."Package No." := LibraryUtility.GenerateGUID();

        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", ItemTrackingSetup[1]."Package No.");
        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", ItemTrackingSetup[2]."Package No.");
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 15);

        for Counter := 1 to ArrayLen(BinArray) do
            BinArray[Counter] := LibraryCDTracking.CreateBin(Location, Counter);

        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", Location.Code);
        Qty[1] := 2;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, Item."No.", LibraryRandom.RandDec(100, 2), Qty[1]);
        PurchaseLine.Validate("Unit of Measure Code", UnitOfMeasure.Code);
        PurchaseLine.Modify();

        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, ItemTrackingSetup[1], 15);
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, ItemTrackingSetup[2], 15);
        LibraryPurchase.ReleasePurchaseDocument(PurchaseHeader);

        PostWhseRcptFromPurchOrder(PurchaseHeader, Item, Location, BinArray[2], BinArray[1], 2);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, ItemTrackingSetup[1], 15);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, ItemTrackingSetup[2], 15);
        LibraryCDTracking.ValidateBinContentQty(Location, BinArray[1], 30);

        LibrarySales.CreateSalesOrderWithLocation(SalesHeader, Customer."No.", Location.Code);
        Qty[2] := 20;
        LibrarySales.CreateSalesLineWithUnitPrice(SalesLine, SalesHeader, Item."No.", LibraryRandom.RandDec(100, 2), Qty[2]);

        LibraryItemTracking.CreateSalesOrderItemTracking(ReservationEntry, SalesLine, ItemTrackingSetup[1], 15);
        LibraryItemTracking.CreateSalesOrderItemTracking(ReservationEntry, SalesLine, ItemTrackingSetup[2], 5);
        SalesLine.AutoReserve();
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        PostWhseShptFromSalesOrder(WarehouseShipmentHeader, WarehouseShipmentLine, SalesHeader, Item, BinArray[3]);
        PostShptAfterRegPick(WarehouseShipmentLine, WarehouseShipmentHeader, Location, BinArray[1], 10, Qty[2]);
        CheckLastItemLedgEntryByType(
            ItemLedgerEntry."Entry Type"::Sale, Item."No.", Location.Code, ItemTrackingSetup[1]."Package No.", -15);
        CheckLastItemLedgEntryByType(
            ItemLedgerEntry."Entry Type"::Sale, Item."No.", Location.Code, ItemTrackingSetup[2]."Package No.", -5);
    end;


    [Test]
    [HandlerFunctions('ItemTrackingCDNoPageHandler,ReservationPageHandler,ConfirmYesHandler,ItemTrackingListPageHandler')]
    [Scope('OnPrem')]
    procedure ReserveSpecificCDNoVerifyAvailTrackingLines()
    var
        ItemTrackingCode: Record "Item Tracking Code";
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReservationEntry: Record "Reservation Entry";
        CD: array[2] of Code[20];
        I: Integer;
    begin

        // [FEATURE] [Item Tracking] [Avail. - Item Tracking Lines]
        // [SCENARIO 155298] Specific CD No. can be reserved from "Avail. - Item Tracking Lines"

        Initialize();

        // [GIVEN] Item "I" with CD No. tracking.
        CreateItemTrackingCodeCDTracking(ItemTrackingCode);

        LibraryInventory.CreateItem(Item);
        Item.Validate("Item Tracking Code", ItemTrackingCode.Code);
        Item.Modify(true);

        // [GIVEN] Create purchase order with 2 pcs of item "I", assign 2 CD nos. "CD1" and "CD2"
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, '');
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", 2);
        for I := 1 to 2 do
            CD[I] := LibraryUtility.GenerateGUID();
        OpenPurchaseItemTrackingLines(PurchaseLine, CD);

        // [GIVEN] Create sales order with 2 pcs of item "I", assign CD nos. "CD1" and "CD2"
        CreateSalesOrder(SalesHeader, SalesLine, Item."No.", 2);
        OpenSalesItemTrackingLines(SalesLine, CD);

        // [WHEN] Run "Reserve" action and choose to reserve specific CD number "CD2"
        PurchaseLine.ShowReservation();

        // [THEN] CD No. "CD2" is reserved
        ReservationEntry.SetRange("Package No.", CD[2]);
        ReservationEntry.SetRange("Reservation Status", ReservationEntry."Reservation Status"::Reservation);
        Assert.RecordIsNotEmpty(ReservationEntry);
    end;

    local procedure CreateSalesOrder(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ItemNo: Code[20]; Quantity: Decimal)
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        ManufacturingSetup.Get();
        SalesHeader.Validate("Shipment Date", CalcDate(ManufacturingSetup."Default Safety Lead Time", SalesHeader."Shipment Date"));
        SalesHeader.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, Quantity);
    end;

    local procedure CreateItemTrackingCodeCDTracking(var ItemTrackingCode: Record "Item Tracking Code")
    var
        CDLocationSetup: Record "CD Location Setup";
    begin
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false);
        ItemTrackingCode.Validate("Package Specific Tracking", true);
        ItemTrackingCode.Modify(true);
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, '');
    end;

    local procedure CreateTransItemJnlLineTracking(ItemJournalLine: Record "Item Journal Line"; PackageNo: Code[50]; NewPackageNo: Code[50])
    var
        ReservationEntry: Record "Reservation Entry";
        LastEntryNo: Integer;
    begin
        with ReservationEntry do begin
            if FindLast() then
                LastEntryNo := "Entry No." + 1
            else
                LastEntryNo := 1;
            Init();
            "Entry No." := LastEntryNo;
            Positive := true;
            Validate("Reservation Status", "Reservation Status"::Prospect);
            Validate("Item No.", ItemJournalLine."Item No.");
            Validate("Location Code", ItemJournalLine."Location Code");
            Validate("Qty. per Unit of Measure", ItemJournalLine."Qty. per Unit of Measure");
            Validate("Quantity (Base)", -ItemJournalLine."Quantity (Base)");
            Validate("Source Type", DATABASE::"Item Journal Line");
            Validate("Source Subtype", ItemJournalLine."Entry Type");
            Validate("Source ID", ItemJournalLine."Journal Template Name");
            Validate("Source Batch Name", ItemJournalLine."Journal Batch Name");
            Validate("Source Ref. No.", ItemJournalLine."Line No.");
            Validate("Package No.", PackageNo);
            Validate("New Package No.", NewPackageNo);
            Insert(true);
        end;
    end;

    local procedure EnqueueTrackingNumbers(SN: array[2] of Code[20])
    var
        I: Integer;
    begin
        LibraryVariableStorage.Enqueue(ArrayLen(SN));
        for I := 1 to 2 do
            LibraryVariableStorage.Enqueue(SN[I]);
    end;

    local procedure InsertZone(var Zone: Record Zone; LocationCode: Code[10]; BinTypeCode: Code[10])
    begin
        Zone.Init();
        Zone."Location Code" := LocationCode;
        Zone.Code := BinTypeCode;
        Zone."Bin Type Code" := BinTypeCode;
        Zone.Insert();
    end;

    local procedure OpenPurchaseItemTrackingLines(PurchaseLine: Record "Purchase Line"; TrackingNo: array[2] of Code[20])
    begin
        EnqueueTrackingNumbers(TrackingNo);
        PurchaseLine.OpenItemTrackingLines();
    end;

    local procedure OpenSalesItemTrackingLines(SalesLine: Record "Sales Line"; TrackingNo: array[2] of Code[20])
    begin
        EnqueueTrackingNumbers(TrackingNo);
        SalesLine.OpenItemTrackingLines();
    end;

    local procedure UpdateBin(BinCode: Code[20]; ZoneCode: Code[10]; BinTypeCode: Code[10])
    var
        Bin: Record Bin;
    begin
        with Bin do begin
            SetRange(Code, BinCode);
            FindFirst();
            Validate("Zone Code", ZoneCode);
            Validate("Bin Type Code", BinTypeCode);
            Modify();
        end;
    end;

    local procedure PostShptAfterRegPick(WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; Location: Record Location; BinCode: Code[20]; QtyToValidate: Decimal; QtyToRegister: Decimal)
    var
        WhsePostShipment: Codeunit "Whse.-Post Shipment";
    begin
        LibraryCDTracking.CreatePickFromWhseShpt(WarehouseShipmentLine, WarehouseShipmentHeader);
        LibraryCDTracking.ValidateBinContentQty(Location, BinCode, QtyToValidate);
        LibraryCDTracking.RegisterPick(Location, QtyToRegister);
        WhsePostShipment.SetPostingSettings(true);
        WhsePostShipment.Run(WarehouseShipmentLine);
    end;

    local procedure PostWhseRcptFromPurchOrder(PurchaseHeader: Record "Purchase Header"; Item: Record Item; Location: Record Location; WhseRcptBinCode: Code[20]; WhseActBinCode: Code[20]; Qty: Decimal)
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WhsePostReceiptYesNo: Codeunit "Whse.-Post Receipt (Yes/No)";
    begin
        LibraryWarehouse.CreateWhseReceiptFromPO(PurchaseHeader);
        LibraryCDTracking.WhseRcptSetBinCode(WarehouseReceiptLine, Item, WhseRcptBinCode);
        WhsePostReceiptYesNo.Run(WarehouseReceiptLine);
        LibraryCDTracking.PostWarehouseActivityLine(Location, WhseActBinCode, Qty);
    end;

    local procedure PostWhseShptFromSalesOrder(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var WarehouseShipmentLine: Record "Warehouse Shipment Line"; SalesHeader: Record "Sales Header"; Item: Record Item; BinCode: Code[20])
    var
        WhseShipmentRelease: Codeunit "Whse.-Shipment Release";
    begin
        LibraryWarehouse.CreateWhseShipmentFromSO(SalesHeader);
        LibraryCDTracking.WhseShptSetBinCode(WarehouseShipmentLine, Item, BinCode);
        WarehouseShipmentHeader.Get(WarehouseShipmentLine."No.");
        WhseShipmentRelease.Release(WarehouseShipmentHeader);
    end;

    local procedure PostWhseRcptLineWithZone(ItemNo: Code[20]; ZoneCode: Code[10])
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WhsePostReceiptYesNo: Codeunit "Whse.-Post Receipt (Yes/No)";
    begin
        with WarehouseReceiptLine do begin
            SetFilter("Item No.", ItemNo);
            FindFirst();
            "Zone Code" := ZoneCode;
            Modify();
            WhsePostReceiptYesNo.Run(WarehouseReceiptLine);
        end;
    end;

    local procedure PostWhseActLineWithZoneAndBin(LocationCode: Code[10]; BinCode: Code[20]; ZoneCode: Code[10]; Qty: Decimal)
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
        WhseActRegisterYesNo: Codeunit "Whse.-Act.-Register (Yes/No)";
    begin
        with WarehouseActivityLine do begin
            Reset();
            SetCurrentKey("Location Code");
            SetFilter("Location Code", LocationCode);
            FindSet();
            repeat
                "Bin Code" := BinCode;
                "Zone Code" := ZoneCode;
                Validate("Qty. to Handle", Qty);
                Modify();
            until Next() = 0;
            WhseActRegisterYesNo.Run(WarehouseActivityLine);
        end;
    end;

    local procedure CheckLastItemLedgEntryByType(EntryType: Enum "Item Ledger Entry Type"; ItemNo: Code[20];
                                                                LocationCode: Code[10];
                                                                PackageNo: Code[50];
                                                                Qty: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Entry Type", EntryType);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, ItemNo, LocationCode, '', '', PackageNo, Qty);
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure HndlConfirm(Question: Text[1024]; var Reply: Boolean)
    begin
        Assert.IsTrue(
          (StrPos(Question, DoYouWantPostRcptQst) <> 0) or
          (StrPos(Question, DoYouWantRegDocQst) <> 0) or
          (StrPos(Question, DoYouWantPostJnlLinesQst) <> 0), IncorrConfirmDialogOpenedErr + Question);
        Reply := true;
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmYesHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    local procedure WMSInitialSetup(var Location: Record Location; var ItemTrackingCode: Record "Item Tracking Code"; var Vendor: Record Vendor; var Customer: Record Customer; var Item: Record Item; UseLotSerial: Boolean)
    var
        CDLocationSetup: Record "CD Location Setup";
    begin
        LibraryCDTracking.CreateWMSLocation(Location);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, UseLotSerial, UseLotSerial, not UseLotSerial);

        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, Location.Code);
        LibraryPurchase.CreateVendor(Vendor);
        LibrarySales.CreateCustomer(Customer);
        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(msg: Text)
    var
        temp: Text;
    begin
        if StrPos(msg, NumberOfPutAwayActivitiesCreatedMsg) <> 0 then
            temp := msg;
        if StrPos(msg, JnlLinesSuccessPostedMsg) <> 0 then
            temp := msg;
        Assert.IsTrue(msg in [WhseRcptHdrCreatedMsg, WhseShptHdrCreatedMsg, NumOfSrcDocsPostedMsg, temp], UnexpMsgErr + msg);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ItemTrackingCDNoPageHandler(var ItemTrackingLines: TestPage "Item Tracking Lines")
    var
        I: Integer;
    begin
        for I := 1 to LibraryVariableStorage.DequeueInteger() do begin
            ItemTrackingLines."Package No.".SetValue(LibraryVariableStorage.DequeueText());
            ItemTrackingLines."Quantity (Base)".SetValue(1);
            ItemTrackingLines.Next();
        end;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ReservationPageHandler(var Reservation: TestPage Reservation)
    begin
        Reservation."Reserve from Current Line".Invoke();
        Reservation.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ItemTrackingListPageHandler(var ItemTrackingList: TestPage "Item Tracking List")
    begin
        ItemTrackingList.Last();
        ItemTrackingList.OK().Invoke();
    end;
}


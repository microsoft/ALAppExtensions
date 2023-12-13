codeunit 147103 "CD Transfer"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        isInitialized := false;
    end;

    var
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryCDTracking: Codeunit "Library - CD Tracking";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ReservationManagement: Codeunit "Reservation Management";
        Assert: Codeunit Assert;
        isInitialized: Boolean;
        WrongInventoryErr: Label 'Wrong inventory.';
        SerTxt: Label 'SER';
        QtyToHandleMessageErr: Label 'Qty. to Handle (Base) in the item tracking assigned to the document line for item %1 is currently 3. It must be 4.\\Check the assignment for serial number %2, lot number .';
        PackageInfoNotExistErr: Label 'The Package No. Information does not exist.';
        TearDownErr: Label 'Error in TearDown';
        TemporaryPackageNoIsNotEqualErr: Label 'Temporary CD Number must be equal to ''No''  in Package No. Information';
        DoYouWantPostDirectTransferMsg: Label 'Do you want to post the Direct Transfer?';
        IncorrectConfirmDialogOpenedMsg: Label 'Incorrect confirm dialog opened: %1', Comment = '%1 is the question shown in the confirm dialog';
        HasBeenDeletedMsg: Label 'is now deleted';
        UnexpectedMsg: Label 'Unexpected message: %1', Comment = '%1 is the message shown in the message dialog';

    local procedure Initialize()
    var
        InventorySetup: Record "Inventory Setup";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        if isInitialized then
            exit;

        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateVATPostingSetup();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateLocalData();

        InventorySetup.Get();
        InventorySetup.Validate("Posted Direct Trans. Nos.", CreateNoSeries());
        InventorySetup.Modify();

        isInitialized := true;
        Commit();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CheckManualCDinTOInbError()
    var
        LocationFrom: Record Location;
        LocationTo: Record Location;
        LocationTransit: Record Location;
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        ItemTrackingCode: Record "Item Tracking Code";
        ReservationEntry: Record "Reservation Entry";
        InventorySetup: Record "Inventory Setup";
        PackageNo: Code[50];
    begin
        Initialize();
        InventorySetup.Get();
        InventorySetup.Validate("Check CD Number Format", true);
        InventorySetup.Modify();

        LibraryWarehouse.CreateTransferLocations(LocationFrom, LocationTo, LocationTransit);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        CreateCDTrackingWithAllowTempNo(ItemTrackingCode.Code, LocationTo.Code, false);
        CreateCDTrackingWithAllowTempNo(ItemTrackingCode.Code, LocationFrom.Code, true);
        CreateCDTrackingWithAllowTempNo(ItemTrackingCode.Code, LocationTransit.Code, true);
        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);
        PackageNo := LibraryUtility.GenerateGUID();

        LibraryInventory.CreateItemJnlLine(ItemJournalLine, "Item Ledger Entry Type"::"Positive Adjmt.", WorkDate(), Item."No.", 5, LocationFrom.Code);
        LibraryItemTracking.CreateItemJournalLineItemTracking(ReservationEntry, ItemJournalLine, '', '', PackageNo, 5);
        LibraryInventory.PostItemJnlLineWithCheck(ItemJournalLine);

        LibraryInventory.CreateTransferHeader(TransferHeader, LocationFrom.Code, LocationTo.Code, LocationTransit.Code);
        LibraryInventory.CreateTransferLine(TransferHeader, TransferLine, Item."No.", 5);
        LibraryItemTracking.CreateTransferOrderItemTracking(ReservationEntry, TransferLine, '', '', PackageNo, 5);

        // TODO asserterror LibraryInventory.PostTransferHeader(TransferHeader, true, true);
        // Assert.ExpectedError(TemporaryPackageNoIsNotEqualErr);

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CheckTOwithSN()
    var
        LocationFrom: Record Location;
        LocationTo: Record Location;
        LocationTransit: Record Location;
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        ItemTrackingCode: Record "Item Tracking Code";
        ReservationEntry: Record "Reservation Entry";
        InventorySetup: Record "Inventory Setup";
        i: Integer;
    begin
        Initialize();
        InventorySetup.Get();
        InventorySetup.Validate("Check CD Number Format", true);
        InventorySetup.Modify();
        LibraryWarehouse.CreateTransferLocations(LocationFrom, LocationTo, LocationTransit);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, true, false, false);
        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);

        LibraryInventory.CreateItemJnlLine(ItemJournalLine, "Item Ledger Entry Type"::"Positive Adjmt.", WorkDate(), Item."No.", 9, LocationFrom.Code);
        CreateJnlLineSNTracking(ReservationEntry, ItemJournalLine, SerTxt, '', 9);
        LibraryInventory.PostItemJnlLineWithCheck(ItemJournalLine);

        LibraryInventory.CreateTransferHeader(TransferHeader, LocationFrom.Code, LocationTo.Code, LocationTransit.Code);
        LibraryInventory.CreateTransferLine(TransferHeader, TransferLine, Item."No.", 4);
        CreateTransferSNTracking(ReservationEntry, TransferLine, SerTxt, '', 4);
        LibraryInventory.PostTransferHeader(TransferHeader, true, false);

        for i := 1 to 4 do
            LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", LocationTransit.Code, SerTxt + '0' + Format(i), '', '', 1);
        LibraryInventory.PostTransferHeader(TransferHeader, false, true);
        for i := 1 to 4 do
            LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", LocationTo.Code, SerTxt + '0' + Format(i), '', '', 1);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", LocationFrom.Code, SerTxt + '0' + Format(7), '', '', 1);

        TearDown();
    end;


    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure CheckDTwithReserve()
    var
        LocationFrom: Record Location;
        LocationTo: Record Location;
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemJournalLine: Record "Item Journal Line";
        TransferHeader: array[2] of Record "Transfer Header";
        TransferLine: array[2] of Record "Transfer Line";
        ItemTrackingCode: Record "Item Tracking Code";
        ReservationEntry: Record "Reservation Entry";
        InventorySetup: Record "Inventory Setup";
        PackageNoInformation: array[3] of Record "Package No. Information";
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PackageNo: array[3] of Code[50];
        CostingMethod: Option FIFO,LIFO,Specific,"Average",Standard;
        i: Integer;
    begin
        Initialize();

        InventorySetup.Get();
        InventorySetup.Validate("Check CD Number Format", false);
        InventorySetup.Modify();

        CreateDTLocations(LocationFrom, LocationTo);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);
        Item.Validate("Costing Method", CostingMethod::LIFO);
        Item.Modify();

        for i := 1 to ArrayLen(PackageNo) do begin
            PackageNo[i] := LibraryUtility.GenerateGUID();
            LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation[i], Item."No.", PackageNo[i]);
        end;

        LibraryInventory.CreateItemJnlLine(ItemJournalLine, "Item Ledger Entry Type"::"Positive Adjmt.", WorkDate(), Item."No.", 3, LocationFrom.Code);
        LibraryItemTracking.CreateItemJournalLineItemTracking(ReservationEntry, ItemJournalLine, '', '', PackageNo[1], 3);
        LibraryInventory.PostItemJnlLineWithCheck(ItemJournalLine);

        LibraryInventory.CreateItemJnlLine(ItemJournalLine, "Item Ledger Entry Type"::"Positive Adjmt.", WorkDate(), Item."No.", 4, LocationFrom.Code);
        LibraryItemTracking.CreateItemJournalLineItemTracking(ReservationEntry, ItemJournalLine, '', '', PackageNo[3], 4);
        LibraryInventory.PostItemJnlLineWithCheck(ItemJournalLine);

        LibraryCDTracking.CreateForeignVendor(Vendor);
        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", LocationFrom.Code);
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, Item."No.", 200, 10);
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, '', '', PackageNo[1], 5);
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, '', '', PackageNo[2], 5);

        CreateDirectTrHeader(TransferHeader[1], LocationTo.Code, LocationFrom.Code);
        LibraryInventory.CreateTransferLine(TransferHeader[1], TransferLine[1], Item."No.", 12);
        ReserveDTFromPO(TransferHeader[1], PurchaseHeader, Item, LocationFrom, '', '', PackageNo[1], 5);
        SetNewPackageNo(Item."No.", PackageNo[1], PackageNo[1]);
        ReserveDTFromPO(TransferHeader[1], PurchaseHeader, Item, LocationFrom, '', '', PackageNo[2], 4);
        SetNewPackageNo(Item."No.", PackageNo[2], PackageNo[2]);
        ReserveDTFromInv(TransferLine[1], 3);
        SetNewPackageNo(Item."No.", PackageNo[3], PackageNo[3]);

        CreateDirectTrHeader(TransferHeader[2], LocationTo.Code, LocationFrom.Code);
        LibraryInventory.CreateTransferLine(TransferHeader[2], TransferLine[2], Item."No.", 1);
        ReserveDTFromPO(TransferHeader[2], PurchaseHeader, Item, LocationFrom, '', '', PackageNo[2], 1);
        SetNewPackageNo(Item."No.", PackageNo[2], PackageNo[2]);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PostTransferDocument(TransferHeader[1]);

        CheckQuantityLocationPackage(Item, LocationFrom.Code, PackageNo[3], 1);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", LocationTo.Code, '', '', PackageNo[2], 4);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", LocationTo.Code, '', '', PackageNo[1], 5);

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CheckITLinDT()
    var
        LocationFrom: Record Location;
        LocationTo: Record Location;
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        ItemTrackingCode: Record "Item Tracking Code";
        CDLocationSetup: Record "CD Location Setup";
        ReservationEntry: Record "Reservation Entry";
        PackageNoInformation: Record "Package No. Information";
        PackageNo: Code[50];
        NewPackageNo: Code[50];
        Serial: Code[20];
        i: Integer;
    begin
        Initialize();
        CreateDTLocations(LocationFrom, LocationTo);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, true, false, true);

        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, LocationTo.Code);
        CDLocationSetup.Validate("Allow Temporary CD Number", true);
        CDLocationSetup.Modify();

        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, LocationFrom.Code);
        CDLocationSetup.Validate("Allow Temporary CD Number", true);
        CDLocationSetup.Modify();

        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);
        LibraryInventory.CreateItemJnlLine(ItemJournalLine, "Item Ledger Entry Type"::"Positive Adjmt.", WorkDate(), Item."No.", 5, LocationFrom.Code);
        PackageNo := LibraryUtility.GenerateGUID();
        for i := 1 to 5 do begin
            Serial := 'SER0' + Format(i);
            LibraryItemTracking.CreateItemJournalLineItemTracking(ReservationEntry, ItemJournalLine, Serial, '', PackageNo, 1);
        end;
        LibraryInventory.PostItemJnlLineWithCheck(ItemJournalLine);

        NewPackageNo := LibraryUtility.GenerateGUID();
        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", NewPackageNo);

        CreateDirectTrHeader(TransferHeader, LocationTo.Code, LocationFrom.Code);
        LibraryInventory.CreateTransferLine(TransferHeader, TransferLine, Item."No.", 4);
        for i := 1 to 3 do begin
            Serial := 'SER0' + Format(i);
            CreateDirectTracking(ReservationEntry, TransferLine, Serial, '', PackageNo, NewPackageNo, Serial, '', 1);
        end;

        asserterror PostTransferDocument(TransferHeader);
        Assert.ExpectedError(StrSubstNo(QtyToHandleMessageErr, Item."No.", 'SER01'));

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CheckCDInfoDT()
    var
        LocationFrom: Record Location;
        LocationTo: Record Location;
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        ItemTrackingCode: Record "Item Tracking Code";
        ReservationEntry: Record "Reservation Entry";
        InventorySetup: Record "Inventory Setup";
        PackageNo: Code[50];
        NewPackageNo: Code[50];
    begin
        Initialize();
        InventorySetup.Get();
        InventorySetup.Validate("Check CD Number Format", false);
        InventorySetup.Modify();

        CreateDTLocations(LocationFrom, LocationTo);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        CreateCDTrackingWithCDInfoMustExist(ItemTrackingCode.Code, LocationTo.Code, true);
        CreateCDTrackingWithCDInfoMustExist(ItemTrackingCode.Code, LocationFrom.Code, false);
        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);
        PackageNo := LibraryUtility.GenerateGUID();
        NewPackageNo := LibraryUtility.GenerateGUID();
        LibraryInventory.CreateItemJnlLine(ItemJournalLine, "Item Ledger Entry Type"::"Positive Adjmt.", WorkDate(), Item."No.", 2, LocationFrom.Code);
        LibraryItemTracking.CreateItemJournalLineItemTracking(ReservationEntry, ItemJournalLine, '', '', PackageNo, 2);
        LibraryInventory.PostItemJnlLineWithCheck(ItemJournalLine);

        CreateDirectTrHeader(TransferHeader, LocationTo.Code, LocationFrom.Code);
        LibraryInventory.CreateTransferLine(TransferHeader, TransferLine, Item."No.", 2);
        CreateDirectTracking(ReservationEntry, TransferLine, '', '', PackageNo, NewPackageNo, '', '', 2);
        asserterror PostTransferDocument(TransferHeader);
        Assert.ExpectedError(PackageInfoNotExistErr);

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestTemporaryCDNoDT()
    var
        LocationFrom: Record Location;
        LocationTo: Record Location;
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        ItemTrackingCode: Record "Item Tracking Code";
        ReservationEntry: Record "Reservation Entry";
        CDNumberHeader: Record "CD Number Header";
        InventorySetup: Record "Inventory Setup";
        PackageNoInformation: Record "Package No. Information";
        PackageNo: Code[50];
    begin
        Initialize();
        InventorySetup.Get();
        InventorySetup.Validate("Check CD Number Format", true);
        InventorySetup.Modify();

        CreateDTLocations(LocationFrom, LocationTo);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        CreateCDTrackingWithAllowTempNo(ItemTrackingCode.Code, LocationTo.Code, false);
        CreateCDTrackingWithAllowTempNo(ItemTrackingCode.Code, LocationFrom.Code, true);
        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);

        LibraryCDTracking.CreateCDNumberHeaderWithCountryRegion(CDNumberHeader);
        PackageNo := LibraryUtility.GenerateGUID();
        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", PackageNo);
        PackageNoInformation.Validate("Country/Region Code", CDNumberHeader."Country/Region of Origin Code");
        PackageNoInformation.Validate("Temporary CD Number", true);
        PackageNoInformation.Modify();

        LibraryInventory.CreateItemJnlLine(ItemJournalLine, "Item Ledger Entry Type"::"Positive Adjmt.", WorkDate(), Item."No.", 2, LocationFrom.Code);
        LibraryItemTracking.CreateItemJournalLineItemTracking(ReservationEntry, ItemJournalLine, '', '', PackageNo, 2);
        LibraryInventory.PostItemJnlLineWithCheck(ItemJournalLine);

        CreateDirectTrHeader(TransferHeader, LocationTo.Code, LocationFrom.Code);
        LibraryInventory.CreateTransferLine(TransferHeader, TransferLine, Item."No.", 2);
        CreateDirectTracking(ReservationEntry, TransferLine, '', '', PackageNo, PackageNo, '', '', 2);
        asserterror PostTransferDocument(TransferHeader);
        Assert.ExpectedError(TemporaryPackageNoIsNotEqualErr);

        TearDown();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure CheckCDFormatInDT()
    var
        LocationFrom: Record Location;
        LocationTo: Record Location;
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        ItemTrackingCode: Record "Item Tracking Code";
        ReservationEntry: Record "Reservation Entry";
        CDNumberHeader: Record "CD Number Header";
        PackageNoInformation: Record "Package No. Information";
        PackageNo: Code[50];
        NewPackageNo: Code[50];
    begin
        Initialize();
        UpdateCDNumberFormat();
        CreateDTLocations(LocationFrom, LocationTo);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        CreateCDTrackingWithAllowTempNo(ItemTrackingCode.Code, LocationTo.Code, false);
        CreateCDTrackingWithAllowTempNo(ItemTrackingCode.Code, LocationFrom.Code, true);
        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);

        LibraryCDTracking.CreateCDNumberHeaderWithCountryRegion(CDNumberHeader);
        PackageNo := LibraryUtility.GenerateGUID();
        NewPackageNo := 'CD1/' + Item."No." + '/000';
        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", NewPackageNo);
        PackageNoInformation.Validate("Country/Region Code", CDNumberHeader."Country/Region of Origin Code");
        PackageNoInformation.Validate("Temporary CD Number", false);
        PackageNoInformation.Modify();

        LibraryInventory.CreateItemJnlLine(ItemJournalLine, "Item Ledger Entry Type"::"Positive Adjmt.", WorkDate(), Item."No.", 2, LocationFrom.Code);
        LibraryItemTracking.CreateItemJournalLineItemTracking(ReservationEntry, ItemJournalLine, '', '', PackageNo, 2);
        LibraryInventory.PostItemJnlLineWithCheck(ItemJournalLine);

        CreateDirectTrHeader(TransferHeader, LocationTo.Code, LocationFrom.Code);
        LibraryInventory.CreateTransferLine(TransferHeader, TransferLine, Item."No.", 2);
        CreateDirectTracking(ReservationEntry, TransferLine, '', '', PackageNo, NewPackageNo, '', '', 2);
        PostTransferDocument(TransferHeader);

        TearDown();
    end;

    local procedure CheckQuantityLocationPackage(var Item: Record Item; LocationCode: Code[10]; PackageNo: Code[50]; Qty: Decimal): Boolean
    begin
        Item.SetRange("Location Filter", LocationCode);
        Item.SetRange("Package No. Filter", PackageNo);
        Item.CalcFields(Inventory);
        Assert.AreEqual(Qty, Item.Inventory, WrongInventoryErr);
    end;

    local procedure CreateTransferSNTracking(var ReservationEntry: Record "Reservation Entry"; TransferLine: Record "Transfer Line"; SerialNo: Code[10]; LotNo: Code[20]; Quantity: Integer)
    var
        i: Integer;
        Serial: Code[20];
    begin
        for i := 1 to Quantity do begin
            Serial := SerialNo + '0' + Format(i);
            LibraryItemTracking.CreateTransferOrderItemTracking(ReservationEntry, TransferLine, Serial, LotNo, 1);
        end;
    end;

    local procedure CreateJnlLineSNTracking(var ReservationEntry: Record "Reservation Entry"; ItemJournalLine: Record "Item Journal Line"; SerialNo: Code[10]; LotNo: Code[20]; Quantity: Decimal)
    var
        i: Integer;
        Serial: Code[20];
    begin
        for i := 1 to Quantity do begin
            Serial := SerialNo + '0' + Format(i);
            LibraryItemTracking.CreateItemJournalLineItemTracking(ReservationEntry, ItemJournalLine, Serial, LotNo, 1);
        end;
    end;

    local procedure CreateDirectTrHeader(var TransferHeader: Record "Transfer Header"; LocationTo: Text[10]; LocationFrom: Text[10])
    begin
        LibraryInventory.CreateTransferHeader(TransferHeader, LocationFrom, LocationTo, '');
        TransferHeader.Validate("Direct Transfer", true);
        TransferHeader.Modify();
    end;

    local procedure CreateDirectTracking(var ReservationEntry: Record "Reservation Entry"; TransferLine: Record "Transfer Line"; SerialNo: Code[20]; LotNo: Code[20]; PackageNo: Code[50]; NewPackageNo: Code[50]; NewSN: Code[20]; NewLot: Code[20]; QtyBase: Integer)
    begin
        LibraryItemTracking.CreateTransferOrderItemTracking(ReservationEntry, TransferLine, SerialNo, LotNo, QtyBase);
        ReservationEntry.Validate("Package No.", PackageNo);
        ReservationEntry.Validate("New Package No.", NewPackageNo);
        ReservationEntry.Validate("New Serial No.", NewSN);
        ReservationEntry.Validate("New Lot No.", NewLot);
        ReservationEntry.Modify(true);
    end;

    local procedure ReserveDTFromPO(var TransferHeader: Record "Transfer Header"; var PurchaseHeader: Record "Purchase Header"; var Item: Record Item; var Location: Record Location; SerialNo: Code[20]; LotNo: Code[20]; PackageNo: Code[50]; Qty: Integer)
    var
        TrackingSpecification: Record "Tracking Specification";
        ReservEntryFor: Record "Reservation Entry";
    begin
        TrackingSpecification.InitTrackingSpecification(5741, 0, TransferHeader."No.", '', 0, 10000, '', '', 1);
        TrackingSpecification."Serial No." := SerialNo;
        TrackingSpecification."Lot No." := LotNo;
        TrackingSpecification."Package No." := PackageNo;
        CreateReservEntry.CreateReservEntryFrom(TrackingSpecification);
        CreateReservEntry.CreateEntry(
            Item."No.", '', Location.Code, '', CalcDate('<+1D>', WorkDate()), CalcDate('<+5D>', WorkDate()), 0, "Reservation Status"::Reservation);
        ReservEntryFor.CopyTrackingFromSpec(TrackingSpecification);
        CreateReservEntry.CreateReservEntryFor(39, 1, PurchaseHeader."No.", '', 0, 10000, 1, Qty, Qty, ReservEntryFor);
        CreateReservEntry.CreateEntry(
            Item."No.", '', Location.Code, '', CalcDate('<+1D>', WorkDate()), CalcDate('<+5D>', WorkDate()), 0, "Reservation Status"::Reservation);
    end;

    local procedure ReserveDTFromInv(var TransferLine: Record "Transfer Line"; Quantity: Integer)
    var
        AutoReserve: Boolean;
    begin
        ReservationManagement.SetReservSource(TransferLine, "Transfer Direction"::Outbound);
        TransferLine.TestField("Shipment Date");
        ReservationManagement.AutoReserveToShip(AutoReserve, '', TransferLine."Shipment Date", Quantity, Quantity);
    end;

    local procedure CreateDTLocations(var LocationFrom: Record Location; var LocationTo: Record Location)
    begin
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(LocationFrom);
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(LocationTo);
    end;

    local procedure CreateNoSeries(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, '', '');
        exit(NoSeries.Code);
    end;

    local procedure CreateCDTrackingWithAllowTempNo(ItemTrackingCode: Code[10]; LocationCode: Code[10]; AllowTemporaryPackageNo: Boolean)
    var
        CDLocationSetup: Record "CD Location Setup";
    begin
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode, LocationCode);
        CDLocationSetup.Validate("Allow Temporary CD Number", AllowTemporaryPackageNo);
        CDLocationSetup.Modify();
    end;

    local procedure CreateCDTrackingWithCDInfoMustExist(ItemTrackingCode: Code[10]; LocationCode: Code[10]; PackageNoInfoMustExist: Boolean)
    var
        CDLocationSetup: Record "CD Location Setup";
    begin
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode, LocationCode);
        CDLocationSetup.Validate("CD Info. Must Exist", PackageNoInfoMustExist);
        CDLocationSetup.Modify();
    end;

    local procedure SetNewPackageNo(ItemNo: Code[20]; PackageNo: Code[50]; NewPackageNo: Code[50])
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.Reset();
        ReservationEntry.SetFilter("Item No.", ItemNo);
        ReservationEntry.SetRange("Source Type", DATABASE::"Transfer Line");
        ReservationEntry.FindLast();
        ReservationEntry.Validate("Package No.", PackageNo);
        ReservationEntry.Validate("New Package No.", NewPackageNo);
        ReservationEntry.Validate("Item Tracking", "Item Tracking Entry Type"::"Package No.");
        ReservationEntry.Modify();
    end;

    local procedure PostTransferDocument(var TransferHeader: Record "Transfer Header")
    var
        TransferOrderPostTransfer: Codeunit "TransferOrder-Post Transfer";
    begin
        TransferOrderPostTransfer.Run(TransferHeader);
    end;

    local procedure UpdateCDNumberFormat()
    var
        CDNumberFormat: Record "CD Number Format";
    begin
        if CDNumberFormat.FindLast() then begin
            CDNumberFormat.Validate(Format, '@@#/@@########/###');
            CDNumberFormat.Modify();
        end else begin
            CDNumberFormat.Init();
            CDNumberFormat.Validate(Format, '@@#/@@########/###');
            CDNumberFormat.Insert();
        end;
    end;

    local procedure TearDown()
    begin
        asserterror Error(TearDownErr);
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure HndlConfirm(Question: Text[1024]; var Reply: Boolean)
    begin
        if StrPos(Question, DoYouWantPostDirectTransferMsg) <> 0 then
            Reply := true
        else
            Error(IncorrectConfirmDialogOpenedMsg, Question);
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(msg: Text[1024])
    var
        temp: Text[100];
    begin
        if StrPos(msg, HasBeenDeletedMsg) <> 0 then
            temp := msg;
        case msg of
            temp:
                ;
            else
                Error(UnexpectedMsg, msg);
        end;
    end;
}


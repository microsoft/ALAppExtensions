codeunit 147101 "CD Sales Red Storno"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibrarySales: Codeunit "Library - Sales";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        ItemEntryType: Option " ",Receipt,Shipment;
        isInitialized: Boolean;
        TestSerialTxt: Label 'TestSerialNo0';

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryVariableStorage.Clear();

        if isInitialized then
            exit;

        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateVATPostingSetup();
        LibraryERMCountryData.UpdateLocalData();

        SetupInvtDocNosInInvSetup();

        isInitialized := true;
        Commit();
    end;

    local procedure SetupInvtDocNosInInvSetup()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        with InventorySetup do begin
            Get();
            if "Invt. Receipt Nos." = '' then
                Validate("Invt. Receipt Nos.", CreateNoSeries());
            if "Posted Invt. Receipt Nos." = '' then
                Validate("Posted Invt. Receipt Nos.", CreateNoSeries());
            if "Invt. Shipment Nos." = '' then
                Validate("Invt. Shipment Nos.", CreateNoSeries());
            if "Posted Invt. Shipment Nos." = '' then
                Validate("Posted Invt. Shipment Nos.", CreateNoSeries());
            Modify(true);
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ItemTrackingDeleteConfirmHandler')]
    procedure "1ItemCD_IRRedStorno"()
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
        Item: Record Item;
        Location: Record Location;
        ReservationEntry: Record "Reservation Entry";
        PackageNoInformation: Record "Package No. Information";
        InvtDocumentHeader: Record "Invt. Document Header";
        InvtDocumentLine: Record "Invt. Document Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        InvtReceiptHeader: Record "Invt. Receipt Header";
        CopyInvtDocumentMgt: Codeunit "Copy Invt. Document Mgt.";
        PackageNo: array[3] of Code[50];
        SerialNo: array[10] of Code[50];
        ItemReceiptNo: Code[20];
        Qty: Decimal;
    begin
        Initialize();

        InitScenario(Vendor, Customer, Item, Location, false, false, true);
        WarehouseSetup();

        Qty := 6;
        PackageNo[1] := LibraryUtility.GenerateGUID();
        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", PackageNo[1]);

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Receipt, Location.Code);
        ItemReceiptNo := InvtDocumentHeader."No.";
        LibraryInventory.CreateInvtDocumentLine(
          InvtDocumentHeader, InvtDocumentLine, Item."No.", LibraryRandom.RandDec(100, 2), Qty);
        CreateItemReceiptLineTracking(InvtDocumentLine, ReservationEntry, false, Qty, SerialNo, '', PackageNo, 1);
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, '', '', PackageNo[1], Qty);

        InvtReceiptHeader.SetRange("Receipt No.", ItemReceiptNo);
        InvtReceiptHeader.FindFirst();

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Receipt, Location.Code);
        CopyInvtDocumentMgt.CopyItemDoc("Invt. Doc. Document Type From"::"Posted Receipt", InvtReceiptHeader."No.",
          InvtDocumentHeader);
        InvtDocumentHeader.Validate(Correction, true);
        InvtDocumentHeader.Modify();
        CreateItemReceiptLineTracking(InvtDocumentLine, ReservationEntry, false, Qty, SerialNo, '', PackageNo, -1);
        ReservationEntry.Validate("Appl.-to Item Entry", ItemLedgerEntry."Entry No.");
        ReservationEntry.Modify();
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, '', '', PackageNo[1], -Qty);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ItemTrackingDeleteConfirmHandler')]
    procedure "1ItemCDLot_IRRedStorno"()
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
        Item: Record Item;
        Location: Record Location;
        ReservationEntry: Record "Reservation Entry";
        PackageNoInformation: Record "Package No. Information";
        InvtDocumentHeader: Record "Invt. Document Header";
        InvtDocumentLine: Record "Invt. Document Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        InvtReceiptHeader: Record "Invt. Receipt Header";
        CopyInvtDocumentMgt: Codeunit "Copy Invt. Document Mgt.";
        PackageNo: array[3] of Code[50];
        SerialNo: array[10] of Code[50];
        LotNo: Code[50];
        ItemReceiptNo: Code[20];
        Qty: Decimal;
    begin
        Initialize();

        InitScenario(Vendor, Customer, Item, Location, false, true, true);
        WarehouseSetup();

        Qty := 6;
        LotNo := LibraryUtility.GenerateGUID();
        PackageNo[1] := LibraryUtility.GenerateGUID();
        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", PackageNo[1]);

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Receipt, Location.Code);
        ItemReceiptNo := InvtDocumentHeader."No.";
        LibraryInventory.CreateInvtDocumentLine(
          InvtDocumentHeader, InvtDocumentLine, Item."No.", LibraryRandom.RandDec(100, 2), Qty);
        CreateItemReceiptLineTracking(InvtDocumentLine, ReservationEntry, false, Qty, SerialNo, LotNo, PackageNo, 1);
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, '', LotNo, PackageNo[1], Qty);

        InvtReceiptHeader.SetRange("Receipt No.", ItemReceiptNo);
        InvtReceiptHeader.FindFirst();

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Receipt, Location.Code);
        CopyInvtDocumentMgt.CopyItemDoc("Invt. Doc. Document Type From"::"Posted Receipt", InvtReceiptHeader."No.",
          InvtDocumentHeader);
        InvtDocumentHeader.Validate(Correction, true);
        InvtDocumentHeader.Modify();
        CreateItemReceiptLineTracking(InvtDocumentLine, ReservationEntry, false, Qty, SerialNo, LotNo, PackageNo, -1);
        ReservationEntry.Validate("Appl.-to Item Entry", ItemLedgerEntry."Entry No.");
        ReservationEntry.Modify();
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, '', LotNo, PackageNo[1], -Qty);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ItemTrackingDeleteConfirmHandler')]
    procedure "1ItemCDLotSerial_IRRedStorno"()
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
        Item: Record Item;
        Location: Record Location;
        ReservationEntry: Record "Reservation Entry";
        PackageNoInformation: Record "Package No. Information";
        InvtDocumentHeader: Record "Invt. Document Header";
        InvtDocumentLine: Record "Invt. Document Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        InvtReceiptHeader: Record "Invt. Receipt Header";
        CopyInvtDocumentMgt: Codeunit "Copy Invt. Document Mgt.";
        PackageNo: array[3] of Code[50];
        SerialNo: array[10] of Code[50];
        LotNo: Code[50];
        ItemReceiptNo: Code[20];
        Qty: Decimal;
        j: Integer;
    begin
        Initialize();

        InitScenario(Vendor, Customer, Item, Location, true, true, true);
        WarehouseSetup();

        Qty := 6;
        LotNo := LibraryUtility.GenerateGUID();
        PackageNo[1] := LibraryUtility.GenerateGUID();
        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", PackageNo[1]);

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Receipt, Location.Code);
        ItemReceiptNo := InvtDocumentHeader."No.";
        LibraryInventory.CreateInvtDocumentLine(
          InvtDocumentHeader, InvtDocumentLine, Item."No.", LibraryRandom.RandDec(100, 2), Qty);
        CreateItemReceiptLineTracking(InvtDocumentLine, ReservationEntry, true, Qty, SerialNo, LotNo, PackageNo, 1);
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);

        for j := 1 to Qty do begin
            ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Positive Adjmt.");
            LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, SerialNo[j], LotNo, PackageNo[1], 1);
        end;

        InvtReceiptHeader.SetRange("Receipt No.", ItemReceiptNo);
        InvtReceiptHeader.FindFirst();

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Receipt, Location.Code);
        CopyInvtDocumentMgt.CopyItemDoc(
            "Invt. Doc. Document Type From"::"Posted Receipt", InvtReceiptHeader."No.", InvtDocumentHeader);
        InvtDocumentHeader.Validate(Correction, true);
        InvtDocumentHeader.Modify();
        CreateItemReceiptLineTracking(InvtDocumentLine, ReservationEntry, true, Qty, SerialNo, LotNo, PackageNo, -1);
        ReservationEntry.Validate("Appl.-to Item Entry", ItemLedgerEntry."Entry No.");
        ReservationEntry.Modify();
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);

        for j := 1 to Qty do begin
            ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Positive Adjmt.");
            LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, SerialNo[j], LotNo, PackageNo[1], -1);
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ItemTrackingDeleteConfirmHandler')]
    procedure "1ItemCD_ISRedStorno"()
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
        Item: Record Item;
        Location: Record Location;
        ReservationEntry: Record "Reservation Entry";
        PackageNoInformation: Record "Package No. Information";
        InvtDocumentHeader: Record "Invt. Document Header";
        InvtDocumentLine: Record "Invt. Document Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        InvtShipmentHeader: Record "Invt. Shipment Header";
        ItemTrackingSetup: Record "Item Tracking Setup";
        CopyInvtDocumentMgt: Codeunit "Copy Invt. Document Mgt.";
        PackageNo: array[3] of Code[50];
        SerialNo: array[10] of Code[50];
        InvtShipmentNo: Code[20];
        Qty: array[2] of Decimal;
    begin
        Initialize();

        InitScenario(Vendor, Customer, Item, Location, false, false, true);
        WarehouseSetup();

        Qty[ItemEntryType::Receipt] := 10 * LibraryRandom.RandInt(10);
        Qty[ItemEntryType::Shipment] := Round(Qty[ItemEntryType::Receipt] / 3, 1);

        PackageNo[1] := LibraryUtility.GenerateGUID();
        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", PackageNo[1]);

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Receipt, Location.Code);
        LibraryInventory.CreateInvtDocumentLine(
          InvtDocumentHeader, InvtDocumentLine, Item."No.", LibraryRandom.RandDec(100, 2), Qty[ItemEntryType::Receipt]);
        CreateItemReceiptLineTracking(InvtDocumentLine, ReservationEntry, false, Qty[ItemEntryType::Receipt], SerialNo, '', PackageNo, 1);
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);

        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, '', '', PackageNo[1], Qty[ItemEntryType::Receipt]);

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Shipment, Location.Code);
        InvtShipmentNo := InvtDocumentHeader."No.";
        LibraryInventory.CreateInvtDocumentLine(
          InvtDocumentHeader, InvtDocumentLine, Item."No.", LibraryRandom.RandDec(100, 2), Qty[ItemEntryType::Shipment]);

        ItemTrackingSetup."Package No." := PackageNo[1];
        LibraryItemTracking.CreateItemReceiptItemTracking(ReservationEntry, InvtDocumentLine, ItemTrackingSetup, Qty[ItemEntryType::Shipment]);
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);

        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Negative Adjmt.");
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, '', '', PackageNo[1], -Qty[ItemEntryType::Shipment]);

        InvtShipmentHeader.SetRange("Shipment No.", InvtShipmentNo);
        InvtShipmentHeader.FindFirst();

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Shipment, Location.Code);
        CopyInvtDocumentMgt.CopyItemDoc("Invt. Doc. Document Type From"::"Posted Shipment", InvtShipmentHeader."No.", InvtDocumentHeader);

        InvtDocumentHeader.Validate(Correction, true);
        InvtDocumentHeader.Modify();

        LibraryItemTracking.CreateItemReceiptItemTracking(ReservationEntry, InvtDocumentLine, ItemTrackingSetup, Qty[ItemEntryType::Shipment]);
        ReservationEntry.Validate("Appl.-from Item Entry", ItemLedgerEntry."Entry No.");
        ReservationEntry.Modify();
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);

        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Negative Adjmt.");
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, '', '', PackageNo[1], Qty[ItemEntryType::Shipment]);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ItemTrackingDeleteConfirmHandler')]
    procedure "1ItemCDLot_ISRedStorno"()
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
        Item: Record Item;
        Location: Record Location;
        PackageNoInformation: Record "Package No. Information";
        InvtShipmentHeader: Record "Invt. Shipment Header";
        InvtDocumentHeader: Record "Invt. Document Header";
        InvtDocumentLine: Record "Invt. Document Line";
        ReservationEntry: Record "Reservation Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemTrackingSetup: Record "Item Tracking Setup";
        CopyInvtDocumentMgt: Codeunit "Copy Invt. Document Mgt.";
        PackageNo: array[3] of Code[50];
        SerialNo: array[10] of Code[50];
        LotNo: Code[50];
        InvtShipmentNo: Code[20];
        Qty: array[2] of Decimal;
    begin
        Initialize();

        InitScenario(Vendor, Customer, Item, Location, false, true, true);
        WarehouseSetup();

        Qty[ItemEntryType::Receipt] := 10 * LibraryRandom.RandInt(10);
        Qty[ItemEntryType::Shipment] := Round(Qty[ItemEntryType::Receipt] / 3, 1);

        LotNo := LibraryUtility.GenerateGUID();
        PackageNo[1] := LibraryUtility.GenerateGUID();
        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", PackageNo[1]);

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Receipt, Location.Code);
        LibraryInventory.CreateInvtDocumentLine(
          InvtDocumentHeader, InvtDocumentLine, Item."No.", LibraryRandom.RandDec(100, 2), Qty[ItemEntryType::Receipt]);
        CreateItemReceiptLineTracking(InvtDocumentLine, ReservationEntry, false, Qty[ItemEntryType::Receipt], SerialNo, LotNo, PackageNo, 1);

        LibraryInventory.PostInvtDocument(InvtDocumentHeader);
        LibraryItemTracking.CheckLastItemLedgerEntry(
          ItemLedgerEntry, Item."No.", Location.Code, '', LotNo, PackageNo[1], Qty[ItemEntryType::Receipt]);

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Shipment, Location.Code);
        InvtShipmentNo := InvtDocumentHeader."No.";
        LibraryInventory.CreateInvtDocumentLine(
          InvtDocumentHeader, InvtDocumentLine, Item."No.", LibraryRandom.RandDec(100, 2), Qty[ItemEntryType::Shipment]);
        ItemTrackingSetup."Lot No." := LotNo;
        ItemTrackingSetup."Package No." := PackageNo[1];
        LibraryItemTracking.CreateItemReceiptItemTracking(
            ReservationEntry, InvtDocumentLine, ItemTrackingSetup, Qty[ItemEntryType::Shipment]);

        LibraryInventory.PostInvtDocument(InvtDocumentHeader);
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Negative Adjmt.");
        LibraryItemTracking.CheckLastItemLedgerEntry(
          ItemLedgerEntry, Item."No.", Location.Code, ItemTrackingSetup, -Qty[ItemEntryType::Shipment]);

        InvtShipmentHeader.SetRange("Shipment No.", InvtShipmentNo);
        InvtShipmentHeader.FindFirst();

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Shipment, Location.Code);
        CopyInvtDocumentMgt.CopyItemDoc(
          "Invt. Doc. Document Type From"::"Posted Shipment", InvtShipmentHeader."No.", InvtDocumentHeader);

        InvtDocumentHeader.Validate(Correction, true);
        InvtDocumentHeader.Modify();

        LibraryItemTracking.CreateItemReceiptItemTracking(
          ReservationEntry, InvtDocumentLine, ItemTrackingSetup, Qty[ItemEntryType::Shipment]);
        ReservationEntry.Validate("Appl.-from Item Entry", ItemLedgerEntry."Entry No.");
        ReservationEntry.Modify();
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);

        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Negative Adjmt.");
        LibraryItemTracking.CheckLastItemLedgerEntry(
          ItemLedgerEntry, Item."No.", Location.Code, '', LotNo, PackageNo[1], Qty[ItemEntryType::Shipment]);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure "1ItemCDLotSerial_ISRedStorno"()
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
        Item: Record Item;
        Location: Record Location;
        ReservationEntry: Record "Reservation Entry";
        PackageNoInformation: Record "Package No. Information";
        InvtDocumentHeader: Record "Invt. Document Header";
        InvtDocumentLine: Record "Invt. Document Line";
        InvtShipmentHeader: Record "Invt. Shipment Header";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemTrackingSetup: Record "Item Tracking Setup";
        CopyInvtDocumentMgt: Codeunit "Copy Invt. Document Mgt.";
        PackageNo: array[3] of Code[50];
        SerialNo: array[10] of Code[50];
        LotNo: Code[50];
        Qty: array[2] of Decimal;
        InvtShipmentNo: Code[20];
        j: Integer;
    begin
        Initialize();

        InitScenario(Vendor, Customer, Item, Location, true, true, true);
        WarehouseSetup();
        Qty[ItemEntryType::Receipt] := 10 * LibraryRandom.RandInt(10);
        Qty[ItemEntryType::Shipment] := Round(Qty[ItemEntryType::Receipt] / 3, 1);

        LotNo := LibraryUtility.GenerateGUID();
        PackageNo[1] := LibraryUtility.GenerateGUID();
        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", PackageNo[1]);

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Receipt, Location.Code);
        LibraryInventory.CreateInvtDocumentLine(
          InvtDocumentHeader, InvtDocumentLine, Item."No.", LibraryRandom.RandDec(100, 2), Qty[ItemEntryType::Receipt]);
        CreateItemReceiptLineTracking(InvtDocumentLine, ReservationEntry, true, Qty[ItemEntryType::Receipt], SerialNo, LotNo, PackageNo, 1);
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);

        for j := 1 to Qty[ItemEntryType::Receipt] do begin
            ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Positive Adjmt.");
            LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, SerialNo[j], LotNo, PackageNo[1], 1);
        end;

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Shipment, Location.Code);
        InvtShipmentNo := InvtDocumentHeader."No.";
        LibraryInventory.CreateInvtDocumentLine(
          InvtDocumentHeader, InvtDocumentLine, Item."No.", LibraryRandom.RandDec(100, 2), Qty[ItemEntryType::Shipment]);

        for j := 1 to Qty[ItemEntryType::Shipment] do begin
            ItemTrackingSetup."Serial No." := SerialNo[j];
            ItemTrackingSetup."Lot No." := LotNo;
            ItemTrackingSetup."Package No." := PackageNo[1];
            LibraryItemTracking.CreateItemReceiptItemTracking(ReservationEntry, InvtDocumentLine, ItemTrackingSetup, 1);
        end;
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);

        for j := 1 to Qty[ItemEntryType::Shipment] do begin
            ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Negative Adjmt.");
            LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, SerialNo[j], LotNo, PackageNo[1], -1);
        end;

        InvtShipmentHeader.SetRange("Shipment No.", InvtShipmentNo);
        InvtShipmentHeader.FindFirst();

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Shipment, Location.Code);
        CopyInvtDocumentMgt.CopyItemDoc(
            "Invt. Doc. Document Type From"::"Posted Shipment", InvtShipmentHeader."No.", InvtDocumentHeader);

        InvtDocumentHeader.Validate(Correction, true);
        InvtDocumentHeader.Modify();

        for j := 1 to Qty[ItemEntryType::Shipment] do begin
            ItemTrackingSetup."Serial No." := SerialNo[j];
            ItemTrackingSetup."Lot No." := LotNo;
            ItemTrackingSetup."Package No." := PackageNo[1];
            LibraryItemTracking.CreateItemReceiptItemTracking(ReservationEntry, InvtDocumentLine, ItemTrackingSetup, -1);
        end;

        ReservationEntry.Validate("Appl.-from Item Entry", ItemLedgerEntry."Entry No.");
        ReservationEntry.Modify();
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);

        for j := 1 to Qty[ItemEntryType::Shipment] do begin
            ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Negative Adjmt.");
            ItemTrackingSetup."Serial No." := SerialNo[j];
            ItemTrackingSetup."Lot No." := LotNo;
            ItemTrackingSetup."Package No." := PackageNo[1];
            LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, ItemTrackingSetup, 1);
        end;
    end;

    local procedure InitScenario(var Vendor: Record Vendor; var Customer: Record Customer; var Item: Record Item; var Location: Record Location; NewSerialTracking: Boolean; NewLotTracking: Boolean; NewPackageTracking: Boolean)
    var
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        LibraryPurchase.CreateVendor(Vendor);
        LibrarySales.CreateCustomer(Customer);
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        ItemTrackingSetup."Serial No. Required" := NewSerialTracking;
        ItemTrackingSetup."Lot No. Required" := NewLotTracking;
        ItemTrackingSetup."Package No. Required" := NewPackageTracking;
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, ItemTrackingSetup);
        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 20);
    end;

    local procedure UpdateSerialNos(var SerialNo: array[10] of Code[50]; i: Integer)
    begin
        if i = 1 then
            SerialNo[i] := TestSerialTxt
        else
            SerialNo[i] := IncStr(SerialNo[i - 1]);
    end;

    local procedure WarehouseSetup()
    var
        InvSetup: Record "Inventory Setup";
    begin
        InvSetup.Get();
        if not InvSetup."Enable Red Storno" then
            InvSetup."Enable Red Storno" := true;
        InvSetup.Modify();
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

    local procedure CreateItemReceiptLineTracking(var InvtDocumentLine: Record "Invt. Document Line"; var ReservationEntry: Record "Reservation Entry"; NewSerialTracking: Boolean; Qty: Decimal; var SerialNo: array[10] of Code[50]; LotNo: Code[50]; PackageNo: array[3] of Code[50]; Sign: Integer)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
        j: Integer;
    begin
        if not NewSerialTracking then begin
            ItemTrackingSetup."Serial No." := '';
            ItemTrackingSetup."Lot No." := LotNo;
            ItemTrackingSetup."Package No." := PackageNo[1];
            LibraryItemTracking.CreateItemReceiptItemTracking(ReservationEntry, InvtDocumentLine, ItemTrackingSetup, Sign * Qty);
        end else
            for j := 1 to Qty do begin
                UpdateSerialNos(SerialNo, j);
                ItemTrackingSetup."Serial No." := SerialNo[j];
                ItemTrackingSetup."Lot No." := LotNo;
                ItemTrackingSetup."Package No." := PackageNo[1];
                LibraryItemTracking.CreateItemReceiptItemTracking(ReservationEntry, InvtDocumentLine, ItemTrackingSetup, Sign * 1);
            end;
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ItemTrackingDeleteConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}


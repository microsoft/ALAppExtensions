codeunit 147102 "CD Purchase"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        isInitialized := false;
    end;

    var
        Assert: Codeunit Assert;
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryCDTracking: Codeunit "Library - CD Tracking";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryUtility: Codeunit "Library - Utility";
        isInitialized: Boolean;
        ItemTrackingDoesNotMatchErr: Label 'Item Tracking does not match for line 10000, Item %1, Qty. to Receive 4';

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        if isInitialized then
            exit;

        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateVATPostingSetup();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateLocalData();

        isInitialized := true;
        Commit();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPurchaseOrder2CDInfoMustExist()
    var
        Location: Record Location;
        Item: array[2] of Record Item;
        CDLocationSetup: Record "CD Location Setup";
        ItemTrackingCode: Record "Item Tracking Code";
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        ReservationEntry: Record "Reservation Entry";
        PurchaseLine: Record "Purchase Line";
        PackageNo: array[2] of Code[20];
        Qty: Decimal;
        i: Integer;
    begin
        // scenario for purchase order (1.2 PO > CD)
        // Trying to set ITL without CD card and post purchase

        Initialize();
        CreateForeignVendorAndLocation(Vendor, Location, false);

        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, Location.Code);
        CDLocationSetup.Validate("CD Info. Must Exist", true);
        CDLocationSetup.Modify();

        for i := 1 to ArrayLen(Item) do begin
            LibraryItemTracking.CreateItemWithItemTrackingCode(Item[i], ItemTrackingCode);
            PackageNo[i] := LibraryUtility.GenerateGUID();
        end;

        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", Location.Code);
        Qty := 4;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, Item[1]."No.", 20, Qty);
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, '', '', PackageNo[1], Qty);
        Qty := 5;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, Item[2]."No.", 15, Qty);
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, '', '', PackageNo[2], Qty);

        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Assert.ExpectedErrorCannotFind(Database::"Package No. Information");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPurchaseOrderSpecialCDSet()
    var
        Location: Record Location;
        Item: array[2] of Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        CDLocationSetup: Record "CD Location Setup";
        ItemTrackingCode: Record "Item Tracking Code";
        Vendor: Record Vendor;
        PurchaseHeader: array[2] of Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Qty: Decimal;
        i: Integer;
    begin
        // Scenario for purchase order with special CD tracking:

        Initialize();
        CreateForeignVendorAndLocation(Vendor, Location, false);

        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, false);
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, Location.Code);
        CDLocationSetup.Validate("CD Info. Must Exist", true);
        CDLocationSetup.Modify();

        for i := 1 to ArrayLen(Item) do
            LibraryItemTracking.CreateItemWithItemTrackingCode(Item[i], ItemTrackingCode);

        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader[1], Vendor."No.", Location.Code);
        Qty := 40;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader[1], Item[1]."No.", 20, Qty);
        Qty := 50;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader[1], Item[2]."No.", 15, Qty);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader[1], true, true);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item[1]."No.", Location.Code, '', '', '', 40);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item[2]."No.", Location.Code, '', '', '', 50);

        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item[1]."No.", Location.Code, '', '', '', 40);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item[2]."No.", Location.Code, '', '', '', 50);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPOCheckerrITLRelease()
    var
        Location: Record Location;
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        CDLocationSetup: Record "CD Location Setup";
        ItemTrackingCode: Record "Item Tracking Code";
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        // Trying to Release purchase order without tracking information in ITL.

        Initialize();
        CreateForeignVendorAndLocation(Vendor, Location, false);

        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, Location.Code);
        CDLocationSetup.Validate("CD Purchase Check on Release", true);
        CDLocationSetup.Modify();

        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 6);

        CreatePurchOrder(PurchaseHeader, Vendor."No.", Location.Code, PurchaseLine, Item."No.", UnitOfMeasure.Code, 4);
        // Must be error because ITL are not filled
        asserterror LibraryPurchase.ReleasePurchaseDocument(PurchaseHeader);
        Assert.ExpectedError(StrSubstNo(ItemTrackingDoesNotMatchErr, Item."No."));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPurOrdCDCheckFormAndSale()
    var
        Location: Record Location;
        Item: array[2] of Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ReservationEntry: Record "Reservation Entry";
        CDLocationSetup: Record "CD Location Setup";
        Customer: Record Customer;
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        CDNumberHeader: Record "CD Number Header";
        PackageNoInfo: array[2] of Record "Package No. Information";
        PackageNo: array[2] of Code[30];
        Qty: Decimal;
        i: Integer;
    begin
        // Scenario for purchase order, check CD No. format

        Initialize();
        UpdateCDNumberFormat();
        CreateForeignVendorAndLocation(Vendor, Location, false);

        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, Location.Code);
        CDLocationSetup.Validate("Allow Temporary CD Number", true);
        CDLocationSetup.Modify();

        LibraryCDTracking.CreateCDNumberHeaderWithCountryRegion(CDNumberHeader);
        for i := 1 to ArrayLen(Item) do begin
            LibraryItemTracking.CreateItemWithItemTrackingCode(Item[i], ItemTrackingCode);
            PackageNo[i] := LibraryUtility.GenerateGUID();
            LibraryCDTracking.UpdatePackageInfo(CDNumberHeader, PackageNoInfo[i], Item[i]."No.", PackageNo[i]);
            PackageNoInfo[i].Validate("Temporary CD Number", true);
            PackageNoInfo[i].Modify();
        end;

        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", Location.Code);
        Qty := 4;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, Item[1]."No.", 20, Qty);
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, '', '', PackageNo[1], Qty);

        Qty := 5;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, Item[2]."No.", 15, Qty);
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, '', '', PackageNo[2], Qty);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesOrderWithLocation(SalesHeader, Customer."No.", Location.Code);
        LibrarySales.CreateSalesLineWithUnitPrice(SalesLine, SalesHeader, Item[1]."No.", 40, 2);
        LibraryItemTracking.CreateSalesOrderItemTracking(ReservationEntry, SalesLine, '', '', PackageNo[1], 2);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPurOrdCDCheckFormY()
    var
        Location: Record Location;
        Item: array[2] of Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ReservationEntry: Record "Reservation Entry";
        CDLocationSetup: Record "CD Location Setup";
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        CDNumberHeader: Record "CD Number Header";
        PackageNoInfo: array[2] of Record "Package No. Information";
        PackageNo: array[2] of Code[30];
        Qty: Decimal;
        i: Integer;
    begin
        // scenario for purchase order, check CD No. format

        Initialize();
        UpdateCDNumberFormat();
        CreateForeignVendorAndLocation(Vendor, Location, false);

        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, Location.Code);
        CDLocationSetup.Validate("Allow Temporary CD Number", false);
        CDLocationSetup.Modify();

        LibraryCDTracking.CreateCDNumberHeaderWithCountryRegion(CDNumberHeader);
        for i := 1 to ArrayLen(Item) do begin
            LibraryItemTracking.CreateItemWithItemTrackingCode(Item[i], ItemTrackingCode);
            PackageNo[i] := LibraryUtility.GenerateGUID();
            LibraryItemTracking.CreatePackageNoInformation(PackageNoInfo[i], Item[i]."No.", PackageNo[i]);
            PackageNoInfo[i].Validate("Temporary CD Number", true);
            PackageNoInfo[i].Modify();
        end;

        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", Location.Code);
        Qty := 4;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, Item[1]."No.", 20, Qty);
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, '', '', PackageNo[1], Qty);

        Qty := 5;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, Item[2]."No.", 15, Qty);
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, '', '', PackageNo[2], Qty);

        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Assert.ExpectedTestFieldError(PackageNoInfo[i].FieldCaption("Temporary CD Number"), 'No');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPurOrdCDCheckFormAndSales()
    var
        Location: Record Location;
        Item: array[2] of Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ReservationEntry: Record "Reservation Entry";
        CDLocationSetup: Record "CD Location Setup";
        Customer: Record Customer;
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        PackageNoInfo: array[2] of Record "Package No. Information";
        PackageNo: array[2] of Code[30];
        Qty: Decimal;
        i: Integer;
    begin
        // Scenario for purchase order, check CD No. format

        Initialize();
        UpdateCDNumberFormat();
        CreateForeignVendorAndLocation(Vendor, Location, true);

        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, Location.Code);
        CDLocationSetup.Validate("Allow Temporary CD Number", true);
        CDLocationSetup.Validate("CD Sales Check on Release", true);
        CDLocationSetup.Validate("CD Info. Must Exist", true);
        CDLocationSetup.Modify();

        for i := 1 to ArrayLen(Item) do begin
            LibraryItemTracking.CreateItemWithItemTrackingCode(Item[i], ItemTrackingCode);
            PackageNo[i] := LibraryUtility.GenerateGUID();
            LibraryItemTracking.CreatePackageNoInformation(PackageNoInfo[i], Item[i]."No.", PackageNo[i]);
            PackageNoInfo[i].Validate("Temporary CD Number", true);
            PackageNoInfo[i].Modify();
        end;

        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", Location.Code);
        Qty := 4;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, Item[1]."No.", 20, Qty);
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, '', '', PackageNo[1], Qty);

        Qty := 5;
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, Item[2]."No.", 15, Qty);
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, '', '', PackageNo[2], Qty);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesOrderWithLocation(SalesHeader, Customer."No.", Location.Code);
        LibrarySales.CreateSalesLineWithUnitPrice(SalesLine, SalesHeader, Item[1]."No.", 40, 2);
        LibraryItemTracking.CreateSalesOrderItemTracking(ReservationEntry, SalesLine, '', '', PackageNo[1], 2);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    local procedure UpdateInvtSetup(CheckCDFormat: Boolean)
    var
        InventorySetup: Record "Inventory Setup";
        InvtSetupUpdated: Boolean;
    begin
        InventorySetup.Get();
        InvtSetupUpdated := false;
        if InventorySetup."Check CD Number Format" <> CheckCDFormat then begin
            InventorySetup.Validate("Check CD Number Format", CheckCDFormat);
            InvtSetupUpdated := true;
        end;
        if InvtSetupUpdated then
            InventorySetup.Modify();
    end;

    local procedure UpdateCDNumberFormat()
    var
        CDNumberFormat: Record "CD Number Format";
    begin
        if CDNumberFormat.FindLast() then begin
            CDNumberFormat.Validate(Format, '####/##/####');
            CDNumberFormat.Modify();
        end else begin
            CDNumberFormat.Init();
            CDNumberFormat.Validate(Format, '####/##/####');
            CDNumberFormat.Insert();
        end;
    end;

    local procedure CreateForeignVendorAndLocation(var Vendor: Record Vendor; var Location: Record Location; CheckCDFormat: Boolean)
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Currency Code", 'EUR');
        Vendor.Modify(true);
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        UpdateInvtSetup(CheckCDFormat);
    end;

    [Normal]
    local procedure CreatePurchOrder(var PurchaseHeader: Record "Purchase Header"; VendorNo: Code[20]; Locationcode: Code[10]; var PurchaseLine: Record "Purchase Line"; ItemNo: Code[20]; UnitOfMeasureCode: Code[10]; Qty: Decimal)
    begin
        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, VendorNo, LocationCode);
        PurchaseHeader.Validate("Prices Including VAT", true);

        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, ItemNo, 20, Qty);
        PurchaseLine.Validate("Unit of Measure Code", UnitOfMeasureCode);
        PurchaseLine.Modify(true);
    end;
}


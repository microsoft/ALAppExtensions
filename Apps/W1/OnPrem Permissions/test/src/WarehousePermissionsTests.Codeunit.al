codeunit 139872 "Warehouse Permissions Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;
    
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        LocationWhite: Record Location;
        LocationBlue: Record Location;
        LocationOrange: Record Location;
        LocationYellow: Record Location;
        LocationGreen: Record Location;
        LocationRed: Record Location;
        LocationInTransit: Record Location;
        LocationSilver: Record Location;
        LocationBlack: Record Location;
        Assert: Codeunit Assert;
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySmallBusiness: Codeunit "Library - Small Business";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        InvtPickCreatedTxt: Label 'Number of Invt. Pick activities created';
        ItemTrackingMode: Option " ",AssignLotNo,SelectEntries,AssignSerialNo,ApplyFromItemEntry,AssignAutoSerialNo,AssignAutoLotAndSerialNo,AssignManualLotNo,AssignManualTwoLotNo,AssignTwoLotNo,SelectEntriesForMultipleLines,UpdateQty,PartialAssignManualTwoLotNo;
        ReservationMode: Option " ",ReserveFromCurrentLine,AutoReserve;
        isInitialized: Boolean;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [TestPermissions(TestPermissions::NonRestrictive)]
    [Scope('OnPrem')]
    procedure CreateInvtPickDoesNotRequireWhsePermission()
    var
        Location: Record Location;
        WarehouseEmployee: Record "Warehouse Employee";
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        SalesHeader: Record "Sales Header";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        WarehouseActivityHeader: Record "Warehouse Activity Header";
    begin
        // [FEATURE] [Inventory Pick]
        // [SCENARIO 263236] A user does not require permissions for warehouse documents to create inventory pick.
        LibraryLowerPermissions.SetOutsideO365Scope();
        Initialize();

        // [GIVEN] Location "L" set up for required pick.
        LibraryInventory.CreateItem(Item);
        LibraryWarehouse.CreateLocationWMS(Location, false, false, true, false, false);
        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, Location.Code, false);

        // [GIVEN] Item "I" is in inventory on "L".
        LibraryInventory.CreateItemJournalLineInItemTemplate(
          ItemJournalLine, Item."No.", Location.Code, '', LibraryRandom.RandIntInRange(20, 40));
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");

        // [GIVEN] Sales order on location "L".
        CreateAndReleaseSalesOrder(
          SalesHeader, '', Item."No.", LibraryRandom.RandInt(10), Location.Code, '', false, ReservationMode::" ");

        // [GIVEN] Lower permissions of a user, so they have access only to inventory documents (invt. pick, put-away, etc.), not warehouse documents (whse. shipment, receipt).
        LibraryLowerPermissions.SetO365Basic();
        LibraryLowerPermissions.AddInvtPickPutawayMovement();
        LibraryLowerPermissions.AddWhseMgtActivities();

        // [WHEN] Create inventory pick from the sales order.
        LibraryVariableStorage.Enqueue(InvtPickCreatedTxt);
        LibraryWarehouse.CreateInvtPutPickMovement(
          WarehouseActivityHeader."Source Document"::"Sales Order", SalesHeader."No.", false, true, false);

        // [THEN] Inventory pick is created.
        FindWarehouseActivityLine(
          WarehouseActivityLine, WarehouseActivityLine."Source Document"::"Sales Order", SalesHeader."No.",
          WarehouseActivityLine."Activity Type"::"Invt. Pick");

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CalcAvailQtyToInvtPickDoesNotRequireWhsePermission()
    var
        Location: Record Location;
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        WhseAvailMgt: Codeunit "Warehouse Availability Mgt.";
        QtyInStock: Decimal;
        QtyAvailToPick: Decimal;
    begin
        // [FEATURE] [UT]
        // [SCENARIO 263236] A user does not require permissions for warehouse documents to run CalcInvtAvailQty function, that calculates available quantity to pick/put-away/move with inventory documents.
        LibraryLowerPermissions.SetOutsideO365Scope();
        Initialize();

        // [GIVEN] Location "L" set up for required pick.
        LibraryInventory.CreateItem(Item);
        LibraryWarehouse.CreateLocationWMS(Location, false, false, true, false, false);

        // [GIVEN] "Q" pcs of item "I" are in stock on location "L".
        QtyInStock := LibraryRandom.RandIntInRange(20, 40);
        LibraryInventory.CreateItemJournalLineInItemTemplate(
          ItemJournalLine, Item."No.", Location.Code, '', QtyInStock);
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");

        // [GIVEN] Lower permissions of a user, so they have access only to inventory documents (invt. pick, put-away, etc.), not warehouse documents (whse. shipment, receipt).
        LibraryLowerPermissions.SetO365Basic();
        LibraryLowerPermissions.AddInvtPickPutawayMovement();

        // [WHEN] Invoke "CalcInvtAvailQty" function in codeunit Warehouse Availability Mgt., in order to calculate available quantity to pick.
        QtyAvailToPick := WhseAvailMgt.CalcInvtAvailQty(Item, Location, '', WarehouseActivityLine);

        // [THEN] No permission issues. Available quantity to pick = "Q".
        Assert.AreEqual(QtyInStock, QtyAvailToPick, 'Available quantity to pick is wrong.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostDirectTransferReceiptErrorShipmentRollBack()
    var
        Item: Record Item;
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
    begin
        // [FEATURE] [Direct Transfer]
        // [SCENARIO 270430] If posting of the receipt side of a direct transfer order fails, posted shipment is rolled back
        Initialize();

        // [GIVEN] Two locations: BLUE with no warehouse settings, and SILVER with bin mandatory
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(LocationBlue);
        LibraryWarehouse.CreateLocationWMS(LocationSilver, true, false, false, false, false);

        // [GIVEN] Item "I" with stock on BLUE location
        CreateAndPostItem(Item, LocationBlue.Code, LibraryRandom.RandIntInRange(100, 200));

        LibraryLowerPermissions.SetO365INVCreate();
        LibraryLowerPermissions.AddO365INVPost();
        LibraryLowerPermissions.AddWhseMgtActivities();
        LibraryLowerPermissions.AddInvtPickPutawayMovement();

        // [GIVEN] Direct transfer order for item "I" from BLUE to SILVER location. Bin code for the transfer receipt is not filled
        CreateDirectTransferHeader(TransferHeader, LocationBlue.Code, LocationSilver.Code);
        LibraryInventory.CreateTransferLine(TransferHeader, TransferLine, Item."No.", LibraryRandom.RandDec(100, 2));

        // [WHEN] Post the transfer order
        asserterror LibraryInventory.PostDirectTransferOrder(TransferHeader);

        // [THEN] Posting fails
        // [THEN] Shipped quantity on the transfer line is 0
        TransferLine.Find();
        TransferLine.TestField("Qty. Shipped (Base)", 0);
    end;

    local procedure CreateAndPostItem(var Item: Record Item; LocationCode: Code[10]; Quantity: Decimal)
    begin
        LibrarySmallBusiness.CreateItem(Item);
        CreateAndPostItemJournalLine(Item."No.", LocationCode, Quantity);
    end;

    local procedure CreateAndPostItemJournalLine(ItemNo: Code[20]; LocationCode: Code[10]; Quantity: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, ItemNo, LocationCode, '', Quantity);
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
    end;

    [Scope('OnPrem')]
    local procedure CreateDirectTransferHeader(var TransferHeader: Record "Transfer Header"; FromLocation: Text[10]; ToLocation: Text[10])
    begin
        Clear(TransferHeader);
        TransferHeader.Init();
        TransferHeader.Insert(true);
        TransferHeader.Validate("Transfer-from Code", FromLocation);
        TransferHeader.Validate("Transfer-to Code", ToLocation);
        TransferHeader.Validate("Direct Transfer", true);
        TransferHeader.Modify(true);
    end;

    local procedure CreateAndReleaseSalesOrder(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal; LocationCode: Code[10]; VariantCode: Code[10]; ItemTracking: Boolean; ReservationMode: Option)
    begin
        CreateSalesDocument(
          SalesHeader, SalesHeader."Document Type"::Order, CustomerNo, ItemNo, Quantity, LocationCode, VariantCode, ItemTracking,
          ReservationMode);
        LibrarySales.ReleaseSalesDocument(SalesHeader);
    end;

    local procedure CreateSalesDocument(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type"; CustomerNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal; LocationCode: Code[10]; VariantCode: Code[10]; UseTracking: Boolean; ReservationMode: Option)
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, Quantity);
        SalesLine.Validate("Location Code", LocationCode);
        SalesLine.Validate("Variant Code", VariantCode);
        SalesLine.Modify(true);
        if UseTracking then
            SalesLine.OpenItemTrackingLines();
        if ReservationMode <> 0 then
            CreateReservation(SalesLine, ReservationMode);
    end;

    local procedure CreateReservation(SalesLine: Record "Sales Line"; ReservationMode: Option " ",ReserveFromCurrentLine,AutoReserve)
    begin
        if ReservationMode = ReservationMode::ReserveFromCurrentLine then
            LibraryVariableStorage.Enqueue(LibraryInventory.GetReservConfirmText());  // Enqueue for ConfirmHandler.
        LibraryVariableStorage.Enqueue(ReservationMode);  // Enqueue for ReservationPageHandler.
        SalesLine.ShowReservation();
    end;

    local procedure FindWarehouseActivityLine(var WarehouseActivityLine: Record "Warehouse Activity Line"; SourceDocument: Enum "Warehouse Activity Source Document"; SourceNo: Code[20]; ActivityType: Option)
    begin
        FilterWarehouseActivityLine(WarehouseActivityLine, SourceDocument, SourceNo, ActivityType);
        WarehouseActivityLine.FindFirst();
    end;

    local procedure FilterWarehouseActivityLine(var WarehouseActivityLine: Record "Warehouse Activity Line"; SourceDocument: Enum "Warehouse Activity Source Document"; SourceNo: Code[20]; ActivityType: Option)
    begin
        WarehouseActivityLine.SetRange("Source Document", SourceDocument);
        WarehouseActivityLine.SetRange("Source No.", SourceNo);
        WarehouseActivityLine.SetRange("Activity Type", ActivityType);
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Warehouse Permissions Tests");
        LibraryVariableStorage.Clear();
        LibrarySetupStorage.Restore();
        Clear(ItemTrackingMode);

        // Lazy Setup.
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Warehouse Permissions Tests");

        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        CreateLocationSetup();
        CreateTransferRoute();
        NoSeriesSetup();
        ItemJournalSetup();

        LibrarySetupStorage.Save(DATABASE::"General Ledger Setup");

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Warehouse Permissions Tests");
    end;

    local procedure NoSeriesSetup()
    var
        WarehouseSetup: Record "Warehouse Setup";
    begin
        LibraryWarehouse.NoSeriesSetup(WarehouseSetup);
        LibrarySales.SetOrderNoSeriesInSetup();
        LibraryPurchase.SetOrderNoSeriesInSetup();
    end;

    local procedure ItemJournalSetup()
    begin
        LibraryInventory.SelectItemJournalTemplateName(ItemJournalTemplate, ItemJournalTemplate.Type::Item);
        ItemJournalTemplate.Validate("No. Series", LibraryUtility.GetGlobalNoSeriesCode());
        ItemJournalTemplate.Modify(true);

        LibraryInventory.SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type, ItemJournalTemplate.Name);
        UpdateNoSeriesOnItemJournalBatch(ItemJournalBatch, LibraryUtility.GetGlobalNoSeriesCode());
    end;

    local procedure UpdateNoSeriesOnItemJournalBatch(var ItemJournalBatch: Record "Item Journal Batch"; NoSeries: Code[20])
    begin
        ItemJournalBatch.Validate("No. Series", NoSeries);
        ItemJournalBatch.Modify(true);
    end;

    local procedure CreateTransferRoute()
    var
        TransferRoute: Record "Transfer Route";
    begin
        LibraryWarehouse.CreateTransferRoute(TransferRoute, LocationGreen.Code, LocationYellow.Code);
        TransferRoute.Validate("In-Transit Code", LocationInTransit.Code);
        TransferRoute.Modify(true);
    end;

    local procedure CreateLocationSetup()
    var
        WarehouseEmployee: Record "Warehouse Employee";
    begin
        WarehouseEmployee.DeleteAll(true);
        CreateFullWarehouseSetup(LocationWhite);
        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, LocationWhite.Code, true);
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(LocationBlue);
        LibraryWarehouse.CreateInTransitLocation(LocationInTransit);
        LibraryWarehouse.CreateLocationWMS(LocationOrange, true, true, true, true, true);  // With Require Put Away, Require Pick, Require Receive, Require Shipment and Bin Mandatory.
        LibraryWarehouse.CreateLocationWMS(LocationSilver, true, false, true, false, false);  // With Require Pick and Bin Mandatory.
        LibraryWarehouse.CreateLocationWMS(LocationBlack, true, false, true, false, true);  // With Require Pick, Require Shipment and Bin Mandatory.
        LibraryWarehouse.CreateLocationWMS(LocationYellow, false, true, true, true, true);  // With Require Receive, Require Put Away, Require Shipment and Require Pick.
        LibraryWarehouse.CreateLocationWMS(LocationGreen, false, true, false, true, false);  // With Required Receive and Require Put Away.
        LibraryWarehouse.CreateLocationWMS(LocationRed, false, true, false, false, false);  // With Require Put Away.
        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, LocationOrange.Code, false);
        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, LocationSilver.Code, false);
        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, LocationBlack.Code, false);
        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, LocationYellow.Code, false);
        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, LocationGreen.Code, false);
        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, LocationRed.Code, false);
        LibraryWarehouse.CreateNumberOfBins(LocationOrange.Code, '', '', 2, false);  // Value required for No. of Bins.
    end;

    local procedure CreateFullWarehouseSetup(var Location: Record Location)
    begin
        LibraryWarehouse.CreateFullWMSLocation(Location, 2);  // Value used for number of bin per zone.
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    var
        DequeueVariable: Variant;
        LocalMessage: Text[1024];
    begin
        LibraryVariableStorage.Dequeue(DequeueVariable);
        LocalMessage := DequeueVariable;
        Assert.IsTrue(StrPos(Message, LocalMessage) > 0, Message);
    end;

}
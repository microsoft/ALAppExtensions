codeunit 139852 "APIV2 - Purch. Order Lines E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Purchase] [Order]
    end;

    var
        Assert: Codeunit "Assert";
        APIV2SalesInvLinesE2E: Codeunit "APIV2 - Sales Inv. Lines E2E";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryGraphDocumentTools: Codeunit "Library - Graph Document Tools";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySmallBusiness: Codeunit "Library - Small Business";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        LibraryERM: Codeunit "Library - ERM";
        IsInitialized: Boolean;
        OrderServiceNameTxt: Label 'purchaseOrders';
        OrderServiceLinesNameTxt: Label 'purchaseOrderLines';
        LineTypeFieldNameTxt: Label 'lineType';

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        LibraryApplicationArea.EnableFoundationSetup();

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestFailsOnIDAbsense()
    var
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Call GET on the lines without providing a parent order ID.
        // [GIVEN] the order API exposed
        Initialize();

        // [WHEN] we GET all the lines without an ID from the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage('',
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        asserterror LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the response text should be empty
        Assert.AreEqual('', ResponseText, 'Response JSON should be blank');
    end;

    [Test]
    procedure TestGetOrderLineDirectly()
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        TargetURL: Text;
        OrderId: Text;
        LineNo: Integer;
        SequenceValue: Text;
    begin
        // [SCENARIO] Call GET on the Line of an order
        // [GIVEN] An order with a line.
        Initialize();
        OrderId := CreatePurchaseOrderWithLines(PurchaseHeader);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineNo := PurchaseLine."Line No.";

        // [WHEN] we GET all the lines with the order ID from the web service
        TargetURL := APIV2SalesInvLinesE2E.GetLinesURL(PurchaseLine.SystemId, Page::"APIV2 - Purchase Orders", OrderServiceNameTxt, OrderServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the line returned should be valid (numbers and integration id)
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'documentId');
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'sequence', SequenceValue);
        Assert.AreEqual(SequenceValue, Format(LineNo), 'The sequence value is wrong.');
    end;

    [Test]
    procedure TestGetOrderLines()
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        TargetURL: Text;
        OrderId: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of a  order 
        // [GIVEN] An order with lines.
        Initialize();
        OrderId := CreatePurchaseOrderWithLines(PurchaseHeader);

        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseLine.FindFirst();
        LineNo1 := Format(PurchaseLine."Line No.");
        PurchaseLine.FindLast();
        LineNo2 := Format(PurchaseLine."Line No.");

        // [WHEN] we GET all the lines with the  order ID from the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the lines returned should be valid (numbers and integration ids)
        VerifyOrderLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestGetOrderLinesDirectlyWithDocumentIdFilter()
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        TargetURL: Text;
        OrderId: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of an order
        // [GIVEN] An order with lines.
        Initialize();
        OrderId := CreatePurchaseOrderWithLines(PurchaseHeader);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineNo1 := Format(PurchaseLine."Line No.");
        PurchaseLine.FindLast();
        LineNo2 := Format(PurchaseLine."Line No.");

        // [WHEN] we GET all the lines with the order ID from the web service
        TargetURL := APIV2SalesInvLinesE2E.GetLinesURLWithDocumentIdFilter(OrderId, Page::"APIV2 - Purchase Orders", OrderServiceNameTxt, OrderServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the lines returned should be valid (numbers and integration ids)
        VerifyOrderLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestPostOrderLines()
    var
        Item: Record "Item";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        TargetURL: Text;
        OrderLineJSON: Text;
        LineNoFromJSON: Text;
        OrderId: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] POST a new line to an  order
        // [GIVEN] An existing  order and a valid JSON describing the new order line
        Initialize();
        OrderId := CreatePurchaseOrderWithLines(PurchaseHeader);
        LibraryInventory.CreateItem(Item);

        OrderLineJSON := CreateOrderLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] the response text should contain the order ID and the change should exist in the database
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        Evaluate(LineNo, LineNoFromJSON);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseLine.SetRange("Line No.", LineNo);
        Assert.IsFalse(PurchaseLine.IsEmpty(), 'The order line should exist');
    end;

    [Test]
    procedure TestModifyOrderLines()
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        TargetURL: Text;
        OrderLineJSON: Text;
        LineNo: Integer;
        OrderId: Text;
        PurchaseQuantity: Integer;
    begin
        // [SCENARIO] PATCH a line of an  order
        // [GIVEN] An  order with lines and a valid JSON describing the fields that we want to change
        Initialize();
        OrderId := CreatePurchaseOrderWithLines(PurchaseHeader);
        Assert.AreNotEqual('', OrderId, 'ID should not be empty');
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseLine.FindFirst();
        LineNo := PurchaseLine."Line No.";

        PurchaseQuantity := 4;
        OrderLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', Format(PurchaseQuantity));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(PurchaseLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] the line should be changed in the table and the response JSON text should contain our changed field
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');

        PurchaseLine.Reset();
        PurchaseLine.SetRange("Line No.", LineNo);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        Assert.IsTrue(PurchaseLine.FindFirst(), 'The  order line should exist after modification');
        Assert.AreEqual(PurchaseLine.Quantity, PurchaseQuantity, 'The patch of Sales line quantity was unsuccessful');
    end;

    [Test]
    procedure TestModifyOrderLineFailsOnSequenceIdOrDocumentIdChange()
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        TargetURL: Text;
        OrderLineJSON: Array[2] of Text;
        OrderId: Text;
        NewSequence: Integer;
    begin
        // [SCENARIO] PATCH a line of an order will fail if sequence is modified
        // [GIVEN] An order with lines and a valid JSON describing the fields that we want to change
        Initialize();
        OrderId := CreatePurchaseOrderWithLines(PurchaseHeader);
        Assert.AreNotEqual('', OrderId, 'ID should not be empty');
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();

        NewSequence := PurchaseLine."Line No." + 1;
        OrderLineJSON[1] := LibraryGraphMgt.AddPropertytoJSON('', 'sequence', NewSequence);
        OrderLineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', 'documentId', LibraryGraphMgt.StripBrackets(CreateGuid()));

        // [WHEN] we PATCH the line
        // [THEN] the request will fail
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(PurchaseLine.SystemId, OrderServiceLinesNameTxt));
        asserterror LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON[1], ResponseText);

        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(PurchaseLine.SystemId, OrderServiceLinesNameTxt));
        asserterror LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON[2], ResponseText);
    end;

    [Test]
    procedure TestDeleteOrderLine()
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        TargetURL: Text;
        OrderId: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] DELETE a line from an  order
        // [GIVEN] An  order with lines
        Initialize();
        OrderId := CreatePurchaseOrderWithLines(PurchaseHeader);

        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseLine.FindFirst();
        LineNo := PurchaseLine."Line No.";

        Commit();

        // [WHEN] we DELETE the first line of that order
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(PurchaseLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the line should no longer exist in the database
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseLine.SetRange("Line No.", LineNo);
        Assert.IsTrue(PurchaseLine.IsEmpty(), 'The order line should not exist');
    end;

    [Test]
    procedure TestCreateLineThroughPageAndAPI()
    var
        PurchaseHeader: Record "Purchase Header";
        Item: Record "Item";
        PagePurchaseLine: Record "Purchase Line";
        ApiPurchaseLine: Record "Purchase Line";
        Vendor: Record "Vendor";
        TempIgnoredFieldsForComparison: Record 2000000041 temporary;
        PageRecordRef: RecordRef;
        ApiRecordRef: RecordRef;
        PurchaseOrder: TestPage "Purchase Order";
        ResponseText: Text;
        TargetURL: Text;
        OrderLineJSON: Text;
        LineNoFromJSON: Text;
        OrderId: Text;
        LineNo: Integer;
        ItemQuantity: Integer;
        ItemNo: Code[20];
        VendorNo: Code[20];
    begin
        // [SCENARIO] Create an order both through the client UI and through the API and compare their final values.
        // [GIVEN] An  order and a JSON describing the line we want to create
        Initialize();
        LibraryPurchase.CreateVendor(Vendor);
        VendorNo := Vendor."No.";
        ItemNo := LibraryInventory.CreateItem(Item);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, VendorNo);
        OrderId := PurchaseHeader.SystemId;
        ItemQuantity := LibraryRandom.RandIntInRange(1, 100);
        OrderLineJSON := CreateOrderLineJSON(Item.SystemId, ItemQuantity);
        Commit();

        // [WHEN] we POST the JSON to the web service and when we create an order through the client UI
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] the response text should be valid, the order line should exist in the tables and the two Orders have the same field values.
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        Evaluate(LineNo, LineNoFromJSON);
        ApiPurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        ApiPurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        ApiPurchaseLine.SetRange("Line No.", LineNo);
        Assert.IsTrue(ApiPurchaseLine.FindFirst(), 'The  order line should exist');

        CreateOrderAndLinesThroughPage(PurchaseOrder, VendorNo, ItemNo, ItemQuantity);
        PagePurchaseLine.SetRange("Document No.", PurchaseOrder."No.".Value());
        PagePurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        Assert.IsTrue(PagePurchaseLine.FindFirst(), 'The  order line should exist');

        ApiRecordRef.GetTable(ApiPurchaseLine);
        PageRecordRef.GetTable(PagePurchaseLine);

        // Ignore these fields when comparing Page and API Orders
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiPurchaseLine.FieldNo("Line No."), Database::"Purchase Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiPurchaseLine.FieldNo("Document No."), Database::"Purchase Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiPurchaseLine.FieldNo("No."), Database::"Purchase Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiPurchaseLine.FieldNo(Subtype), Database::"Purchase Line");
        LibraryUtility.AddTempField(
          TempIgnoredFieldsForComparison, ApiPurchaseLine.FieldNo("Recalculate Invoice Disc."), Database::"Purchase Line"); // TODO: remove once other changes are checked in

        Assert.RecordsAreEqualExceptCertainFields(ApiRecordRef, PageRecordRef, TempIgnoredFieldsForComparison,
          'Page and API order lines do not match');
        RecallNotifications();
    end;

    [Test]
    procedure TestInsertingLineUpdatesOrderDiscountPct()
    var
        PurchaseHeader: Record "Purchase Header";
        Item: Record "Item";
        TargetURL: Text;
        OrderLineJSON: Text;
        ResponseText: Text;
        DiscountPct: Decimal;
        MinAmount: Decimal;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Creating a line through API should update Discount Pct
        // [GIVEN] An  order for Vendor with order discount pct
        Initialize();

        DiscountPct := LibraryRandom.RandDecInDecimalRange(1, 90, 2);
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInDecimalRange(1, 100, 2), LibraryRandom.RandDecInDecimalRange(1, 100, 2));
        MinAmount := PurchaseHeader.Amount + Item."Unit Price" / 2;

        CreateDocumentWithItemAndDiscountPctPending(Item, PurchaseHeader, DiscountPct, MinAmount, PurchaseHeader."Document Type"::Order);
        PurchaseHeader.CALCFIELDS(Amount);
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInDecimalRange(1, 100, 2), LibraryRandom.RandDecInDecimalRange(1, 100, 2));
        OrderLineJSON := CreateOrderLineWithCostJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100), Item."Unit Cost");
        Commit();

        // [WHEN] We create a line through API
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            PurchaseHeader.SystemId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] order discount is applied
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'itemId');
        VerifyTotals(PurchaseHeader, DiscountPct, PurchaseHeader."Invoice Discount Calculation"::"%");
    end;

    [Test]
    procedure TestModifyingLineUpdatesOrderDiscountPct()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        TargetURL: Text;
        OrderLineJSON: Text;
        ResponseText: Text;
        DiscountPct: Decimal;
        MinAmount: Decimal;
        PurchaseQuantity: Integer;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Modifying a line through API should update Discount Pct
        // [GIVEN] An  order for vendor with order discount pct
        Initialize();

        DiscountPct := LibraryRandom.RandDecInDecimalRange(1, 90, 2);
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInDecimalRange(1, 100, 2), LibraryRandom.RandDecInDecimalRange(1, 100, 2));
        MinAmount := PurchaseHeader.Amount + Item."Unit Price" / 2;

        CreateDocumentWithItemAndDiscountPctPending(Item, PurchaseHeader, DiscountPct, MinAmount, PurchaseHeader."Document Type"::Order);
        PurchaseHeader.CALCFIELDS(Amount);

        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);
        PurchaseQuantity := PurchaseLine.Quantity * 2;

        Commit();

        OrderLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', Format(PurchaseQuantity));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            PurchaseHeader.SystemId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(PurchaseLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] order discount is applied
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'itemId');
        VerifyTotals(PurchaseHeader, DiscountPct, PurchaseHeader."Invoice Discount Calculation"::"%");
    end;

    [Test]
    procedure TestDeletingLineMovesOrderDiscountPct()
    var
        PurchaseHeader: Record "Purchase Header";
        Item: Record "Item";
        Vendor: Record Vendor;
        PurchaseLine: Record "Purchase Line";
        TargetURL: Text;
        ResponseText: Text;
        MinAmount1: Decimal;
        DiscountPct1: Decimal;
        MinAmount2: Decimal;
        DiscountPct2: Decimal;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Deleting a line through API should update Discount Pct
        // [GIVEN] An  order for vendor with order discount pct
        Initialize();

        CreateOrderWithTwoLines(PurchaseHeader, Vendor, Item);
        PurchaseHeader.CALCFIELDS(Amount);
        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);

        MinAmount1 := PurchaseHeader.Amount - 2 * PurchaseLine."Line Amount";
        DiscountPct1 := LibraryRandom.RandDecInDecimalRange(1, 20, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToVendor(Vendor, DiscountPct1, MinAmount1, PurchaseHeader."Currency Code");

        MinAmount2 := PurchaseHeader.Amount - PurchaseLine."Line Amount" / 2;
        DiscountPct2 := LibraryRandom.RandDecInDecimalRange(30, 50, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToVendor(Vendor, DiscountPct2, MinAmount2, PurchaseHeader."Currency Code");

        CODEUNIT.RUN(CODEUNIT::"Purch - Calc Disc. By Type", PurchaseLine);
        PurchaseHeader.Find();
        Assert.AreEqual(PurchaseHeader."Invoice Discount Value", DiscountPct2, 'Discount Pct was not assigned');
        Commit();

        // [WHEN] we DELETE the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            PurchaseHeader.SystemId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(PurchaseLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] Lower order discount is applied
        VerifyTotals(PurchaseHeader, DiscountPct1, PurchaseHeader."Invoice Discount Calculation"::"%");
        RecallNotifications();
    end;

    [Test]
    procedure TestDeletingLineRemovesOrderDiscountPct()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        Item: Record "Item";
        TargetURL: Text;
        ResponseText: Text;
        MinAmount: Decimal;
        DiscountPct: Decimal;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Deleting a line through API should update Discount Pct
        // [GIVEN] An  order for vendor with order discount pct
        Initialize();
        CreateOrderWithTwoLines(PurchaseHeader, Vendor, Item);
        PurchaseHeader.CALCFIELDS(Amount);
        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);

        MinAmount := PurchaseHeader.Amount - PurchaseLine."Line Amount" / 2;
        DiscountPct := LibraryRandom.RandDecInDecimalRange(30, 50, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToVendor(Vendor, DiscountPct, MinAmount, PurchaseHeader."Currency Code");

        CODEUNIT.RUN(CODEUNIT::"Purch - Calc Disc. By Type", PurchaseLine);
        PurchaseHeader.Find();
        Assert.AreEqual(PurchaseHeader."Invoice Discount Value", DiscountPct, 'Discount Pct was not assigned');
        Commit();

        // [WHEN] we DELETE the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            PurchaseHeader.SystemId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(PurchaseLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] Lower order discount is applied
        VerifyTotals(PurchaseHeader, 0, PurchaseHeader."Invoice Discount Calculation"::"%");
        RecallNotifications();
    end;

    [Test]
    procedure TestInsertingLineKeepsOrderDiscountAmt()
    var
        PurchaseHeader: Record "Purchase Header";
        Item: Record "Item";
        TargetURL: Text;
        ResponseText: Text;
        OrderLineJSON: Text;
        DiscountAmount: Decimal;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Adding an order through API will keep Discount Amount
        // [GIVEN] An  order for customer with order discount amount
        Initialize();
        LibraryInventory.CreateItem(Item);
        SetupAmountDiscountTest(PurchaseHeader, DiscountAmount);
        OrderLineJSON := CreateOrderLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));

        Commit();

        // [WHEN] We create a line through API
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            PurchaseHeader.SystemId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Discount Amount is Kept
        VerifyTotals(PurchaseHeader, DiscountAmount, PurchaseHeader."Invoice Discount Calculation"::Amount);
        RecallNotifications();
    end;

    [Test]
    procedure TestModifyingLineKeepsOrderDiscountAmt()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record "Item";
        DiscountAmount: Decimal;
        TargetURL: Text;
        OrderLineJSON: Text;
        ResponseText: Text;
        Quantity: Integer;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Modifying a line through API should keep existing Discount Amount
        // [GIVEN] An  order for customer with order discount amt
        Initialize();
        SetupAmountDiscountTest(PurchaseHeader, DiscountAmount);
        OrderLineJSON := CreateOrderLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));

        Quantity := 0;
        OrderLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', Format(Quantity));
        Commit();

        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            PurchaseHeader.SystemId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(PurchaseLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] order discount is kept
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'itemId');
        VerifyTotals(PurchaseHeader, DiscountAmount, PurchaseHeader."Invoice Discount Calculation"::Amount);
        RecallNotifications();
    end;

    [Test]
    procedure TestDeletingLineKeepsOrderDiscountAmt()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DiscountAmount: Decimal;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Deleting a line through API should update Discount Pct
        // [GIVEN] An  order for vendor with order discount pct
        Initialize();
        SetupAmountDiscountTest(PurchaseHeader, DiscountAmount);
        Commit();

        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);

        // [WHEN] we DELETE the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            PurchaseHeader.SystemId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(PurchaseLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] Lower order discount is applied
        VerifyTotals(PurchaseHeader, DiscountAmount, PurchaseHeader."Invoice Discount Calculation"::Amount);
        RecallNotifications();
    end;

    [Test]
    procedure TestGettingLinesWithDifferentTypes()
    var
        PurchaseHeader: Record "Purchase Header";
        ExpectedNumberOfLines: Integer;
        TargetURL: Text;
        ResponseText: Text;
        LinesJSON: Text;
    begin
        // [SCENARIO] Getting a line through API lists all possible types
        // [GIVEN] An order with lines of different types
        Initialize();
        CreateOrderWithAllPossibleLineTypes(PurchaseHeader, ExpectedNumberOfLines);

        Commit();

        // [WHEN] we GET the lines
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(PurchaseHeader.SystemId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] All lines are shown in the response
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'value', LinesJSON);
        Assert.AreEqual(ExpectedNumberOfLines, LibraryGraphMgt.GetCollectionCountFromJSON(LinesJSON), 'Four lines should be returned');
        VerifyPurchaseOrderLinesForPurchaseHeader(PurchaseHeader, LinesJSON);
    end;

    [Test]
    procedure TestPostingBlankLineDefaultsToCommentType()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TargetURL: Text;
        ResponseText: Text;
        OrderLineJSON: Text;
    begin
        // [SCENARIO] Posting a line with description only will get a type item
        // [GIVEN] A post request with description only
        Initialize();
        CreatePurchaseOrderWithLines(PurchaseHeader);

        Commit();

        OrderLineJSON := '{"description":"test"}';

        // [WHEN] we just POST a blank line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            PurchaseHeader.SystemId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Line of type Item is created
        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);
        PurchaseLine.FindLast();
        Assert.AreEqual('', PurchaseLine."No.", 'No should be blank');
        Assert.AreEqual(PurchaseLine.Type, PurchaseLine.Type::" ", 'Wrong type is set');

        VerifyIdsAreBlank(ResponseText);
    end;

    [Test]
    procedure TestPostingCommentLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TargetURL: Text;
        ResponseText: Text;
        OrderLineJSON: Text;
    begin
        // [FEATURE] [Comment]
        // [SCENARIO] Posting a line with Type Comment and description will make a comment line
        // [GIVEN] A post request with type and description
        Initialize();
        CreatePurchaseOrderWithLines(PurchaseHeader);

        OrderLineJSON := '{"' + LineTypeFieldNameTxt + '":"Comment","description":"test"}';

        Commit();

        // [WHEN] we just POST a blank line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            PurchaseHeader.SystemId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Line of type Item is created
        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);
        PurchaseLine.FindLast();
        Assert.AreEqual(PurchaseLine.Type, PurchaseLine.Type::" ", 'Wrong type is set');
        Assert.AreEqual('test', PurchaseLine.Description, 'Wrong description is set');

        LibraryGraphDocumentTools.VerifyPurchaseObjectTxtDescriptionWithoutComplexType(PurchaseLine, ResponseText);
        VerifyIdsAreBlank(ResponseText);
    end;

    [Test]
    procedure TestPatchingTheIdToAccountChangesLineType()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
        TargetURL: Text;
        ResponseText: Text;
        OrderLineJSON: Text;
        OrderId: Text;
    begin
        // [SCENARIO] PATCH a Type on a line of an unposted Order
        // [GIVEN] An unposted Order with lines and a valid JSON describing the fields that we want to change
        Initialize();
        OrderId := CreatePurchaseOrderWithLines(PurchaseHeader);
        Assert.AreNotEqual('', OrderId, 'ID should not be empty');
        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);

        CreateVATPostingSetup(VATPostingSetup, PurchaseLine."VAT Bus. Posting Group", PurchaseLine."VAT Prod. Posting Group");
        GetGLAccountWithVATPostingGroup(GLAccount, PurchaseLine."VAT Bus. Posting Group", PurchaseLine."VAT Prod. Posting Group");

        OrderLineJSON := StrSubstNo('{"accountId":"%1"}', LibraryGraphMgt.StripBrackets(GLAccount.SystemId));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(PurchaseLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Line type is changed to Account
        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);
        Assert.AreEqual(PurchaseLine.Type::"G/L Account", PurchaseLine.Type, 'Type was not changed');
        Assert.AreEqual(GLAccount."No.", PurchaseLine."No.", 'G/L Account No was not set');

        VerifyPurchaseLineResponseWithPurchaseLine(PurchaseLine, ResponseText);
    end;

    [Test]
    procedure TestPatchingTheIdToItemChangesLineType()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record "Item";
        ExpectedNumberOfLines: Integer;
        TargetURL: Text;
        ResponseText: Text;
        OrderLineJSON: Text;
        OrderId: Text;
    begin
        // [SCENARIO] PATCH a Type on a line of an unposted Order
        // [GIVEN] An unposted Order with lines and a valid JSON describing the fields that we want to change
        Initialize();
        CreateOrderWithAllPossibleLineTypes(PurchaseHeader, ExpectedNumberOfLines);
        OrderId := LibraryGraphMgt.StripBrackets(PurchaseHeader.SystemId);
        PurchaseLine.SetRange(Type, PurchaseLine.Type::"G/L Account");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.FindFirst();
        PurchaseLine.SetRange(Type);

        Assert.AreNotEqual('', OrderId, 'ID should not be empty');
        LibraryInventory.CreateItem(Item);

        OrderLineJSON := StrSubstNo('{"itemId":"%1"}', LibraryGraphMgt.StripBrackets(Item.SystemId));
        Commit();

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            PurchaseHeader.SystemId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(PurchaseLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Line type is changed to Item and other fields are updated
        PurchaseLine.Find();
        Assert.AreEqual(PurchaseLine.Type::Item, PurchaseLine.Type, 'Type was not changed');
        Assert.AreEqual(Item."No.", PurchaseLine."No.", 'Item No was not set');

        VerifyPurchaseLineResponseWithPurchaseLine(PurchaseLine, ResponseText);
    end;

    [Test]
    procedure TestPatchingTheTypeBlanksIds()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvLineAggregate: Record "Purch. Inv. Line Aggregate";
        TargetURL: Text;
        ResponseText: Text;
        OrderLineJSON: Text;
        OrderId: Text;
    begin
        // [SCENARIO] PATCH a Type on a line of an unposted Order
        // [GIVEN] An unposted Order with lines and a valid JSON describing the fields that we want to change
        Initialize();
        OrderId := CreatePurchaseOrderWithLines(PurchaseHeader);
        Assert.AreNotEqual('', OrderId, 'ID should not be empty');
        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);

        OrderLineJSON := StrSubstNo('{"%1":"%2"}', LineTypeFieldNameTxt, Format(PurchInvLineAggregate."API Type"::Account));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(PurchaseLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Line type is changed to Account
        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);
        Assert.AreEqual(PurchaseLine.Type::"G/L Account", PurchaseLine.Type, 'Type was not changed');
        Assert.AreEqual('', PurchaseLine."No.", 'No should be blank');

        VerifyIdsAreBlank(ResponseText);
    end;

    [Test]
    procedure TestPostOrderLineWithItemVariant()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record "Item";
        ItemVariant: Record "Item Variant";
        ItemNo: Code[20];
        ItemVariantCode: Code[10];
        ResponseText: Text;
        TargetURL: Text;
        OrderLineJSON: Text;
        LineNoFromJSON: Text;
        OrderId: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] POST a new line to an order with item variant
        // [GIVEN] An existing order and a valid JSON describing the new order line with item variant
        Initialize();
        OrderId := CreatePurchaseOrderWithLines(PurchaseHeader);
        ItemNo := LibraryInventory.CreateItem(Item);
        ItemVariantCode := LibraryInventory.CreateItemVariant(ItemVariant, ItemNo);
        Commit();

        // [WHEN] we POST the JSON to the web service
        OrderLineJSON := CreateOrderLineJSONWithItemVariantId(Item.SystemId, LibraryRandom.RandIntInRange(1, 100), ItemVariant.SystemId);
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Purchase Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] the response text should contain the order ID and the change should exist in the database
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        Evaluate(LineNo, LineNoFromJSON);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseLine.SetRange("Line No.", LineNo);
        PurchaseLine.SetRange("Variant Code", ItemVariantCode);
        Assert.IsFalse(PurchaseLine.IsEmpty(), 'The order line should exist');
    end;

    [Test]
    procedure TestPostOrderLineWithWrongItemVariant()
    var
        Item1: Record "Item";
        Item2: Record "Item";
        ItemVariant: Record "Item Variant";
        PurchaseHeader: Record "Purchase Header";
        ItemNo2: Code[20];
        ResponseText: Text;
        TargetURL: Text;
        OrderLineJSON: Text;
        OrderId: Text;
    begin
        // [SCENARIO] POST a new line to an order with wrong item variant
        // [GIVEN] An existing order and a valid JSON describing the new order line with item variant
        Initialize();
        OrderId := CreatePurchaseOrderWithLines(PurchaseHeader);
        LibraryInventory.CreateItem(Item1);
        ItemNo2 := LibraryInventory.CreateItem(Item2);
        LibraryInventory.CreateItemVariant(ItemVariant, ItemNo2);
        Commit();

        // [WHEN] we POST the JSON to the web service
        OrderLineJSON := CreateOrderLineJSONWithItemVariantId(Item1.SystemId, LibraryRandom.RandIntInRange(1, 100), ItemVariant.SystemId);
        TargetURL := LibraryGraphMgt
                  .CreateTargetURLWithSubpage(
                    OrderId,
                    Page::"APIV2 - Purchase Orders",
                    OrderServiceNameTxt,
                    OrderServiceLinesNameTxt);

        // [THEN] the request will fail
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);
    end;

    local procedure VerifyOrderLines(ResponseText: Text; LineNo1: Text; LineNo2: Text)
    var
        LineJSON1: Text;
        LineJSON2: Text;
        ItemId1: Text;
        ItemId2: Text;
    begin
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, 'sequence', LineNo1, LineNo2, LineJSON1, LineJSON2),
          'Could not find the order lines in JSON');
        LibraryGraphMgt.VerifyIDFieldInJson(LineJSON1, 'documentId');
        LibraryGraphMgt.VerifyIDFieldInJson(LineJSON2, 'documentId');
        LibraryGraphMgt.GetObjectIDFromJSON(LineJSON1, 'itemId', ItemId1);
        LibraryGraphMgt.GetObjectIDFromJSON(LineJSON2, 'itemId', ItemId2);
        Assert.AreNotEqual(ItemId1, ItemId2, 'Item Ids should be different for different items');
    end;

    local procedure VerifyTotals(var PurchaseHeader: Record "Purchase Header"; ExpectedInvDiscValue: Decimal; ExpectedInvDiscType: Option)
    var
        PurchaseOrderEntityBuffer: Record "Purchase Order Entity Buffer";
    begin
        PurchaseHeader.Find();
        PurchaseHeader.CALCFIELDS(Amount, "Amount Including VAT", "Invoice Discount Amount", "Recalculate Invoice Disc.");
        Assert.AreEqual(ExpectedInvDiscType, PurchaseHeader."Invoice Discount Calculation", 'Wrong order discount type');
        Assert.AreEqual(ExpectedInvDiscValue, PurchaseHeader."Invoice Discount Value", 'Wrong order discount value');
        Assert.IsFalse(PurchaseHeader."Recalculate Invoice Disc.", 'Recalculate inv. discount should be false');

        if ExpectedInvDiscValue = 0 then
            Assert.AreEqual(0, PurchaseHeader."Invoice Discount Amount", 'Wrong sales order discount amount')
        else
            Assert.IsTrue(PurchaseHeader."Invoice Discount Amount" > 0, 'order discount amount value is wrong');

        // Verify Aggregate table
        PurchaseOrderEntityBuffer.Get(PurchaseHeader."No.");
        Assert.AreEqual(PurchaseHeader.Amount, PurchaseOrderEntityBuffer.Amount, 'Amount was not updated on Aggregate Table');
        Assert.AreEqual(
          PurchaseHeader."Amount Including VAT", PurchaseOrderEntityBuffer."Amount Including VAT",
          'Amount Including VAT was not updated on Aggregate Table');
        Assert.AreEqual(
          PurchaseHeader."Amount Including VAT" - PurchaseHeader.Amount, PurchaseOrderEntityBuffer."Total Tax Amount",
          'Total Tax Amount was not updated on Aggregate Table');
        Assert.AreEqual(
          PurchaseHeader."Invoice Discount Amount", PurchaseOrderEntityBuffer."Invoice Discount Amount",
          'Amount was not updated on Aggregate Table');
    end;

    local procedure VerifyPurchaseOrderLinesForPurchaseHeader(var PurchaseHeader: Record "Purchase Header"; JsonObjectTxt: Text)
    var
        PurchaseLine: Record "Purchase Line";
        CurrentIndex: Integer;
    begin
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.FindSet();
        CurrentIndex := 0;

        repeat
            VerifyPurchaseLineResponseWithPurchaseLine(PurchaseLine, LibraryGraphMgt.GetObjectFromCollectionByIndex(JsonObjectTxt, CurrentIndex));
            CurrentIndex += 1;
        until PurchaseLine.next() = 0;
    end;

    local procedure VerifyPurchaseLineResponseWithPurchaseLine(var PurchaseLine: Record "Purchase Line"; JsonObjectTxt: Text)
    begin
        LibraryGraphDocumentTools.VerifyPurchaseObjectTxtDescriptionWithoutComplexType(PurchaseLine, JsonObjectTxt);
        VerifyPurchaseIdsSetFromTxt(PurchaseLine, JsonObjectTxt);
    end;

    local procedure VerifyPurchaseIdsSetFromTxt(PurchaseLine: Record "Purchase Line"; JObjectTxt: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        "Newtonsoft.Json.Linq.JObject": DotNet JObject;
    begin
        JSONManagement.InitializeObject(JObjectTxt);
        JSONManagement.GetJSONObject("Newtonsoft.Json.Linq.JObject");
        LibraryGraphDocumentTools.VerifyPurchaseIdsSet(PurchaseLine, "Newtonsoft.Json.Linq.JObject");
    end;

    local procedure VerifyIdsAreBlank(JsonObjectTxt: Text)
    var
        itemId: Text;
        accountId: Text;
        ExpectedId: Text;
        BlankGuid: Guid;
    begin
        ExpectedId := LibraryGraphMgt.StripBrackets(BlankGuid);

        Assert.IsTrue(LibraryGraphMgt.GetPropertyValueFromJSON(JsonObjectTxt, 'itemId', itemId), 'Could not find itemId');
        Assert.IsTrue(LibraryGraphMgt.GetPropertyValueFromJSON(JsonObjectTxt, 'accountId', accountId), 'Could not find accountId');

        Assert.AreEqual(UPPERCASE(ExpectedId), UPPERCASE(accountId), 'Account id should be blank');
        Assert.AreEqual(UPPERCASE(ExpectedId), UPPERCASE(itemId), 'Item id should be blank');
    end;

    local procedure FindFirstPurchaseLine(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
    end;

    local procedure SetupAmountDiscountTest(var PurchaseHeader: Record "Purchase Header"; var DiscountAmount: Decimal)
    var
        Vendor: Record Vendor;
        Item: Record "Item";
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
    begin
        CreateOrderWithTwoLines(PurchaseHeader, Vendor, Item);
        PurchaseHeader.CALCFIELDS(Amount);
        DiscountAmount := LibraryRandom.RandDecInDecimalRange(1, PurchaseHeader.Amount / 2, 2);
        PurchCalcDiscByType.ApplyInvDiscBasedOnAmt(DiscountAmount, PurchaseHeader);
    end;

    local procedure CreatePurchaseOrderWithLines(var PurchaseHeader: Record "Purchase Header"): Text
    var
        PurchaseLine: Record "Purchase Line";
        Item: Record "Item";
    begin
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        LibraryInventory.CreateItem(Item);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", 2);
        Commit();
        exit(PurchaseHeader.SystemId);
    end;

    [Normal]
    local procedure CreateOrderLineJSON(ItemId: Guid; Quantity: Integer): Text
    var
        LineJSONTxt: Text;
    begin
        LineJSONTxt := LibraryGraphMgt.AddPropertytoJSON('', 'itemId', LibraryGraphMgt.StripBrackets(ItemId));
        LineJSONTxt := LibraryGraphMgt.AddComplexTypetoJSON(LineJSONTxt, 'quantity', Format(Quantity));
        exit(LineJSONTxt);
    end;

    [Normal]
    local procedure CreateOrderLineWithCostJSON(ItemId: Guid; Quantity: Integer; DirectUnitCost: Decimal): Text
    var
        LineJSONTxt: Text;
    begin
        LineJSONTxt := LibraryGraphMgt.AddPropertytoJSON('', 'itemId', LibraryGraphMgt.StripBrackets(ItemId));
        LineJSONTxt := LibraryGraphMgt.AddComplexTypetoJSON(LineJSONTxt, 'quantity', Format(Quantity));
        LineJSONTxt := LibraryGraphMgt.AddComplexTypetoJSON(LineJSONTxt, 'directUnitCost', Format(DirectUnitCost));
        exit(LineJSONTxt);
    end;

    local procedure CreateOrderLineJSONWithItemVariantId(ItemId: Guid; Quantity: Integer; ItemVariantId: Guid): Text
    var
        LineJsonText: Text;
    begin
        LineJsonText := CreateOrderLineJSON(ItemId, Quantity);
        LineJsonText := LibraryGraphMgt.AddPropertytoJSON(LineJsonText, 'itemVariantId', LibraryGraphMgt.StripBrackets(ItemVariantId));
        exit(LineJsonText);
    end;

    local procedure CreateOrderAndLinesThroughPage(var PurchaseOrder: TestPage "Purchase Order"; VendorNo: Text; ItemNo: Text; ItemQuantity: Integer)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseOrder.OpenNew();
        PurchaseOrder."Buy-from Vendor No.".SetValue(VendorNo);

        PurchaseOrder.PurchLines.LAST();
        PurchaseOrder.PurchLines.next();
        PurchaseOrder.PurchLines.FilteredTypeField.SetValue(PurchaseLine.Type::Item);
        PurchaseOrder.PurchLines."No.".SetValue(ItemNo);

        PurchaseOrder.PurchLines.Quantity.SetValue(ItemQuantity);

        // Trigger Save
        PurchaseOrder.PurchLines.next();
        PurchaseOrder.PurchLines.Previous();
    end;

    local procedure CreateDocumentWithItemAndDiscountPctPending(var Item: Record Item; var PurchaseHeader: Record "Purchase Header"; var DiscountPct: Decimal; MinAmount: Decimal; DocumentType: Enum "Purchase Document Type")
    var
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin

        LibraryPurchase.CreateVendor(Vendor);
        DiscountPct := LibraryRandom.RandDecInRange(1, 99, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToVendor(Vendor, DiscountPct, MinAmount, '');

        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", LibraryRandom.RandIntInRange(1, 10));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
        PurchaseLine.Modify(true);
    end;

    local procedure CreateOrderWithTwoLines(var PurchaseHeader: Record "Purchase Header"; var Vendor: Record "Vendor"; var Item: Record "Item")
    var
        PurchaseLine: Record "Purchase Line";
        Quantity: Integer;
        DirectUnitCost: Decimal;
    begin
        DirectUnitCost := LibraryRandom.RandDecInDecimalRange(1000, 3000, 2);
        LibraryInventory.CreateItemWithUnitPriceUnitCostAndPostingGroup(
          Item, LibraryRandom.RandDecInDecimalRange(1000, 3000, 2), DirectUnitCost);
        LibraryPurchase.CreateVendor(Vendor);
        Quantity := LibraryRandom.RandIntInRange(1, 10);
        //DirectUnitCost := LibraryRandom.RandDecInRange(1, 100, 2);

        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", Quantity);
        PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);
        PurchaseLine.Modify(true);

        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", Quantity);
        PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);
        PurchaseLine.Modify(true);
    end;

    local procedure CreateOrderWithAllPossibleLineTypes(var PurchaseHeader: Record "Purchase Header"; var ExpectedNumberOfLines: Integer)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        CreatePurchaseOrderWithLines(PurchaseHeader);

        LibraryGraphDocumentTools.CreatePurchaseLinesWithAllPossibleTypes(PurchaseHeader);

        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        ExpectedNumberOfLines := PurchaseLine.Count();
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    begin
        VATPostingSetup.SetRange("VAT Bus. Posting Group", VATBusPostingGroup);
        VATPostingSetup.SetRange("VAT Prod. Posting Group", VATProdPostingGroup);
        if not VATPostingSetup.FindFirst() then
            LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusPostingGroup, VATProdPostingGroup);
    end;

    local procedure GetGLAccountWithVATPostingGroup(var GLAccount: Record "G/L Account"; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    begin
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Direct Posting", true);
        GLAccount.SetRange("VAT Bus. Posting Group", VATBusPostingGroup);
        GLAccount.SetRange("VAT Prod. Posting Group", VATProdPostingGroup);
        if not GLAccount.FindFirst() then
            CreateGLAccountWithPostingGroup(GLAccount, VATBusPostingGroup, VATProdPostingGroup);
    end;

    local procedure CreateGLAccountWithPostingGroup(var GLAccount: Record "G/L Account"; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        GLAccount.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        GLAccount.Modify();
    end;

    local procedure RecallNotifications()
    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
    begin
        NotificationLifecycleMgt.RecallAllNotifications();
    end;
}
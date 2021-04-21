codeunit 139835 "APIV2 - Sales Order Lines E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Sales] [Order]
    end;

    var
        Assert: Codeunit "Assert";
        SalesInvLinesE2E: Codeunit "APIV2 - Sales Inv. Lines E2E";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryGraphDocumentTools: Codeunit "Library - Graph Document Tools";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySmallBusiness: Codeunit "Library - Small Business";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        LibraryERM: Codeunit "Library - ERM";
        IsInitialized: Boolean;
        OrderServiceNameTxt: Label 'salesOrders';
        OrderServiceLinesNameTxt: Label 'salesOrderLines';
        LineTypeFieldNameTxt: Label 'lineType';

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        LibrarySales.SetStockoutWarning(false);

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
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        asserterror LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the response text should be empty
        Assert.AreEqual('', ResponseText, 'Response JSON should be blank');
    end;

    [Test]
    procedure TestGetOrderLineDirectly()
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        OrderId: Text;
        LineNo: Integer;
        SequenceValue: Text;
    begin
        // [SCENARIO] Call GET on the Line of an order
        // [GIVEN] An order with a line.
        Initialize();
        OrderId := CreateSalesOrderWithLines(SalesHeader);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineNo := SalesLine."Line No.";

        // [WHEN] we GET all the lines with the order ID from the web service
        TargetURL := SalesInvLinesE2E.GetLinesURL(SalesLine.SystemId, Page::"APIV2 - Sales Orders", OrderServiceNameTxt, OrderServiceLinesNameTxt);
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
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        OrderId: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of a  order 
        // [GIVEN] An order with lines.
        Initialize();
        OrderId := CreateSalesOrderWithLines(SalesHeader);

        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.FindFirst();
        LineNo1 := Format(SalesLine."Line No.");
        SalesLine.FindLast();
        LineNo2 := Format(SalesLine."Line No.");

        // [WHEN] we GET all the lines with the  order ID from the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the lines returned should be valid (numbers and integration ids)
        VerifyOrderLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestGetOrderLinesDirectlyWithDocumentIdFilter()
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        OrderId: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of an order
        // [GIVEN] An order with lines.
        Initialize();
        OrderId := CreateSalesOrderWithLines(SalesHeader);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineNo1 := Format(SalesLine."Line No.");
        SalesLine.FindLast();
        LineNo2 := Format(SalesLine."Line No.");

        // [WHEN] we GET all the lines with the order ID from the web service
        TargetURL := SalesInvLinesE2E.GetLinesURLWithDocumentIdFilter(OrderId, Page::"APIV2 - Sales Orders", OrderServiceNameTxt, OrderServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the lines returned should be valid (numbers and integration ids)
        VerifyOrderLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestPostOrderLines()
    var
        Item: Record "Item";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
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
        OrderId := CreateSalesOrderWithLines(SalesHeader);
        LibraryInventory.CreateItem(Item);

        OrderLineJSON := CreateOrderLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] the response text should contain the order ID and the change should exist in the database
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        Evaluate(LineNo, LineNoFromJSON);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SetRange("Line No.", LineNo);
        Assert.IsFalse(SalesLine.IsEmpty(), 'The order line should exist');
    end;

    [Test]
    procedure TestModifyOrderLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ResponseText: Text;
        TargetURL: Text;
        OrderLineJSON: Text;
        LineNo: Integer;
        OrderId: Text;
        SalesQuantity: Integer;
    begin
        // [SCENARIO] PATCH a line of an  order
        // [GIVEN] An  order with lines and a valid JSON describing the fields that we want to change
        Initialize();
        OrderId := CreateSalesOrderWithLines(SalesHeader);
        Assert.AreNotEqual('', OrderId, 'ID should not be empty');
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.FindFirst();
        LineNo := SalesLine."Line No.";

        SalesQuantity := 4;
        OrderLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', Format(SalesQuantity));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] the line should be changed in the table and the response JSON text should contain our changed field
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');

        SalesLine.Reset();
        SalesLine.SetRange("Line No.", LineNo);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        Assert.IsTrue(SalesLine.FindFirst(), 'The  order line should exist after modification');
        Assert.AreEqual(SalesLine.Quantity, SalesQuantity, 'The patch of Sales line quantity was unsuccessful');
    end;

    [Test]
    procedure TestModifyOrderLineFailsOnSequenceIdOrDocumentIdChange()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ResponseText: Text;
        TargetURL: Text;
        OrderLineJSON: Array[2] of Text;
        LineNo: Integer;
        OrderId: Text;
        NewSequence: Integer;
    begin
        // [SCENARIO] PATCH a line of an order will fail if sequence is modified
        // [GIVEN] An order with lines and a valid JSON describing the fields that we want to change
        Initialize();
        OrderId := CreateSalesOrderWithLines(SalesHeader);
        Assert.AreNotEqual('', OrderId, 'ID should not be empty');
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineNo := SalesLine."Line No.";

        NewSequence := SalesLine."Line No." + 1;
        OrderLineJSON[1] := LibraryGraphMgt.AddPropertytoJSON('', 'sequence', NewSequence);
        OrderLineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', 'documentId', LibraryGraphMgt.StripBrackets(CreateGuid()));

        // [WHEN] we PATCH the line
        // [THEN] the request will fail
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesLine.SystemId, OrderServiceLinesNameTxt));
        asserterror LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON[1], ResponseText);

        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesLine.SystemId, OrderServiceLinesNameTxt));
        asserterror LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON[2], ResponseText);
    end;

    [Test]
    procedure TestDeleteOrderLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ResponseText: Text;
        TargetURL: Text;
        OrderId: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] DELETE a line from an  order
        // [GIVEN] An  order with lines
        Initialize();
        OrderId := CreateSalesOrderWithLines(SalesHeader);

        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.FindFirst();
        LineNo := SalesLine."Line No.";

        Commit();

        // [WHEN] we DELETE the first line of that order
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the line should no longer exist in the database
        SalesLine.Reset();
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SetRange("Line No.", LineNo);
        Assert.IsTrue(SalesLine.IsEmpty(), 'The order line should not exist');
    end;

    [Test]
    procedure TestCreateLineThroughPageAndAPI()
    var
        SalesHeader: Record "Sales Header";
        Item: Record "Item";
        PageSalesLine: Record "Sales Line";
        ApiSalesLine: Record "Sales Line";
        Customer: Record "Customer";
        TempIgnoredFieldsForComparison: Record 2000000041 temporary;
        PageRecordRef: RecordRef;
        ApiRecordRef: RecordRef;
        SalesOrder: TestPage "Sales Order";
        ResponseText: Text;
        TargetURL: Text;
        OrderLineJSON: Text;
        LineNoFromJSON: Text;
        OrderId: Text;
        LineNo: Integer;
        ItemQuantity: Integer;
        ItemNo: Code[20];
        CustomerNo: Code[20];
    begin
        // [SCENARIO] Create an order both through the client UI and through the API and compare their final values.
        // [GIVEN] An  order and a JSON describing the line we want to create
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        CustomerNo := Customer."No.";
        ItemNo := LibraryInventory.CreateItem(Item);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        OrderId := SalesHeader.SystemId;
        ItemQuantity := LibraryRandom.RandIntInRange(1, 100);
        OrderLineJSON := CreateOrderLineJSON(Item.SystemId, ItemQuantity);
        Commit();

        // [WHEN] we POST the JSON to the web service and when we create an order through the client UI
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] the response text should be valid, the order line should exist in the tables and the two Orders have the same field values.
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        Evaluate(LineNo, LineNoFromJSON);
        ApiSalesLine.SetRange("Document No.", SalesHeader."No.");
        ApiSalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        ApiSalesLine.SetRange("Line No.", LineNo);
        Assert.IsTrue(ApiSalesLine.FindFirst(), 'The  order line should exist');

        CreateOrderAndLinesThroughPage(SalesOrder, CustomerNo, ItemNo, ItemQuantity);
        PageSalesLine.SetRange("Document No.", SalesOrder."No.".Value());
        PageSalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        Assert.IsTrue(PageSalesLine.FindFirst(), 'The  order line should exist');

        ApiRecordRef.GetTable(ApiSalesLine);
        PageRecordRef.GetTable(PageSalesLine);

        // Ignore these fields when comparing Page and API Orders
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesLine.FieldNo("Line No."), Database::"Sales Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesLine.FieldNo("Document No."), Database::"Sales Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesLine.FieldNo("No."), Database::"Sales Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesLine.FieldNo(Subtype), Database::"Sales Line");
        LibraryUtility.AddTempField(
          TempIgnoredFieldsForComparison, ApiSalesLine.FieldNo("Recalculate Invoice Disc."), Database::"Sales Line"); // TODO: remove once other changes are checked in

        Assert.RecordsAreEqualExceptCertainFields(ApiRecordRef, PageRecordRef, TempIgnoredFieldsForComparison,
          'Page and API order lines do not match');
        RecallNotifications();
    end;

    [Test]
    procedure TestInsertingLineUpdatesOrderDiscountPct()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record "Customer";
        Item: Record "Item";
        TargetURL: Text;
        OrderLineJSON: Text;
        ResponseText: Text;
        MinAmount: Decimal;
        DiscountPct: Decimal;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Creating a line through API should update Discount Pct
        // [GIVEN] An  order for customer with order discount pct
        Initialize();
        CreateOrderWithTwoLines(SalesHeader, Customer, Item);
        SalesHeader.CALCFIELDS(Amount);
        MinAmount := SalesHeader.Amount + Item."Unit Price" / 2;
        DiscountPct := LibraryRandom.RandDecInDecimalRange(1, 90, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToCustomer(Customer, DiscountPct, MinAmount, SalesHeader."Currency Code");
        OrderLineJSON := CreateOrderLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        Commit();

        // [WHEN] We create a line through API
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] order discount is applied
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'itemId');
        VerifyTotals(SalesHeader, DiscountPct, SalesHeader."Invoice Discount Calculation"::"%");
    end;

    [Test]
    procedure TestModifyingLineUpdatesOrderDiscountPct()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record "Customer";
        Item: Record "Item";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        OrderLineJSON: Text;
        ResponseText: Text;
        MinAmount: Decimal;
        DiscountPct: Decimal;
        SalesQuantity: Integer;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Modifying a line through API should update Discount Pct
        // [GIVEN] An  order for customer with order discount pct
        Initialize();
        CreateOrderWithTwoLines(SalesHeader, Customer, Item);
        SalesHeader.CALCFIELDS(Amount);
        MinAmount := SalesHeader.Amount + Item."Unit Price" / 2;
        DiscountPct := LibraryRandom.RandDecInDecimalRange(1, 90, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToCustomer(Customer, DiscountPct, MinAmount, SalesHeader."Currency Code");
        OrderLineJSON := CreateOrderLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        FindFirstSalesLine(SalesHeader, SalesLine);
        SalesQuantity := SalesLine.Quantity * 2;

        Commit();

        OrderLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', Format(SalesQuantity));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] order discount is applied
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'itemId');
        VerifyTotals(SalesHeader, DiscountPct, SalesHeader."Invoice Discount Calculation"::"%");
    end;

    [Test]
    procedure TestDeletingLineMovesOrderDiscountPct()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record "Customer";
        Item: Record "Item";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        ResponseText: Text;
        MinAmount1: Decimal;
        DiscountPct1: Decimal;
        MinAmount2: Decimal;
        DiscountPct2: Decimal;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Deleting a line through API should update Discount Pct
        // [GIVEN] An  order for customer with order discount pct
        Initialize();
        CreateOrderWithTwoLines(SalesHeader, Customer, Item);
        SalesHeader.CALCFIELDS(Amount);
        FindFirstSalesLine(SalesHeader, SalesLine);

        MinAmount1 := SalesHeader.Amount - 2 * SalesLine."Line Amount";
        DiscountPct1 := LibraryRandom.RandDecInDecimalRange(1, 20, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToCustomer(Customer, DiscountPct1, MinAmount1, SalesHeader."Currency Code");

        MinAmount2 := SalesHeader.Amount - SalesLine."Line Amount" / 2;
        DiscountPct2 := LibraryRandom.RandDecInDecimalRange(30, 50, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToCustomer(Customer, DiscountPct2, MinAmount2, SalesHeader."Currency Code");

        CODEUNIT.RUN(CODEUNIT::"Sales - Calc Discount By Type", SalesLine);
        SalesHeader.Find();
        Assert.AreEqual(SalesHeader."Invoice Discount Value", DiscountPct2, 'Discount Pct was not assigned');
        Commit();

        // [WHEN] we DELETE the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] Lower order discount is applied
        VerifyTotals(SalesHeader, DiscountPct1, SalesHeader."Invoice Discount Calculation"::"%");
        RecallNotifications();
    end;

    [Test]
    procedure TestDeletingLineRemovesOrderDiscountPct()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record "Customer";
        Item: Record "Item";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        ResponseText: Text;
        MinAmount: Decimal;
        DiscountPct: Decimal;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Deleting a line through API should update Discount Pct
        // [GIVEN] An  order for customer with order discount pct
        Initialize();
        CreateOrderWithTwoLines(SalesHeader, Customer, Item);
        SalesHeader.CALCFIELDS(Amount);
        FindFirstSalesLine(SalesHeader, SalesLine);

        MinAmount := SalesHeader.Amount - SalesLine."Line Amount" / 2;
        DiscountPct := LibraryRandom.RandDecInDecimalRange(30, 50, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToCustomer(Customer, DiscountPct, MinAmount, SalesHeader."Currency Code");

        CODEUNIT.RUN(CODEUNIT::"Sales - Calc Discount By Type", SalesLine);
        SalesHeader.Find();
        Assert.AreEqual(SalesHeader."Invoice Discount Value", DiscountPct, 'Discount Pct was not assigned');
        Commit();

        // [WHEN] we DELETE the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] Lower order discount is applied
        VerifyTotals(SalesHeader, 0, SalesHeader."Invoice Discount Calculation"::"%");
        RecallNotifications();
    end;

    [Test]
    procedure TestInsertingLineKeepsOrderDiscountAmt()
    var
        SalesHeader: Record "Sales Header";
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
        SetupAmountDiscountTest(SalesHeader, DiscountAmount);
        OrderLineJSON := CreateOrderLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));

        Commit();

        // [WHEN] We create a line through API
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Discount Amount is Kept
        VerifyTotals(SalesHeader, DiscountAmount, SalesHeader."Invoice Discount Calculation"::Amount);
        RecallNotifications();
    end;

    [Test]
    procedure TestModifyingLineKeepsOrderDiscountAmt()
    var
        SalesHeader: Record "Sales Header";
        Item: Record "Item";
        SalesLine: Record "Sales Line";
        DiscountAmount: Decimal;
        TargetURL: Text;
        OrderLineJSON: Text;
        ResponseText: Text;
        SalesQuantity: Integer;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Modifying a line through API should keep existing Discount Amount
        // [GIVEN] An  order for customer with order discount amt
        Initialize();
        SetupAmountDiscountTest(SalesHeader, DiscountAmount);
        OrderLineJSON := CreateOrderLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));

        SalesQuantity := 0;
        OrderLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', Format(SalesQuantity));
        Commit();

        FindFirstSalesLine(SalesHeader, SalesLine);

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] order discount is kept
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'itemId');
        VerifyTotals(SalesHeader, DiscountAmount, SalesHeader."Invoice Discount Calculation"::Amount);
        RecallNotifications();
    end;

    [Test]
    procedure TestDeletingLineKeepsOrderDiscountAmt()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DiscountAmount: Decimal;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Deleting a line through API should update Discount Pct
        // [GIVEN] An  order for customer with order discount pct
        Initialize();
        SetupAmountDiscountTest(SalesHeader, DiscountAmount);
        Commit();

        FindFirstSalesLine(SalesHeader, SalesLine);

        // [WHEN] we DELETE the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] Lower order discount is applied
        VerifyTotals(SalesHeader, DiscountAmount, SalesHeader."Invoice Discount Calculation"::Amount);
        RecallNotifications();
    end;

    [Test]
    procedure TestGettingLinesWithDifferentTypes()
    var
        SalesHeader: Record "Sales Header";
        ExpectedNumberOfLines: Integer;
        TargetURL: Text;
        ResponseText: Text;
        LinesJSON: Text;
    begin
        // [SCENARIO] Getting a line through API lists all possible types
        // [GIVEN] An order with lines of different types
        Initialize();
        CreateOrderWithAllPossibleLineTypes(SalesHeader, ExpectedNumberOfLines);

        Commit();

        // [WHEN] we GET the lines
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(SalesHeader.SystemId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] All lines are shown in the response
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'value', LinesJSON);
        Assert.AreEqual(ExpectedNumberOfLines, LibraryGraphMgt.GetCollectionCountFromJSON(LinesJSON), 'Four lines should be returned');
        VerifySalesOrderLinesForSalesHeader(SalesHeader, LinesJSON);
    end;

    [Test]
    procedure TestPostingBlankLineDefaultsToCommentType()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        ResponseText: Text;
        OrderLineJSON: Text;
    begin
        // [SCENARIO] Posting a line with description only will get a type item
        // [GIVEN] A post request with description only
        Initialize();
        CreateSalesOrderWithLines(SalesHeader);

        Commit();

        OrderLineJSON := '{"description":"test"}';

        // [WHEN] we just POST a blank line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Line of type Item is created
        FindFirstSalesLine(SalesHeader, SalesLine);
        SalesLine.FindLast();
        Assert.AreEqual('', SalesLine."No.", 'No should be blank');
        Assert.AreEqual(SalesLine.Type, SalesLine.Type::" ", 'Wrong type is set');

        VerifyIdsAreBlank(ResponseText);
    end;

    [Test]
    procedure TestPostingCommentLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        ResponseText: Text;
        OrderLineJSON: Text;
    begin
        // [FEATURE] [Comment]
        // [SCENARIO] Posting a line with Type Comment and description will make a comment line
        // [GIVEN] A post request with type and description
        Initialize();
        CreateSalesOrderWithLines(SalesHeader);

        OrderLineJSON := '{"' + LineTypeFieldNameTxt + '":"Comment","description":"test"}';

        Commit();

        // [WHEN] we just POST a blank line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Line of type Item is created
        FindFirstSalesLine(SalesHeader, SalesLine);
        SalesLine.FindLast();
        Assert.AreEqual(SalesLine.Type, SalesLine.Type::" ", 'Wrong type is set');
        Assert.AreEqual('test', SalesLine.Description, 'Wrong description is set');

        LibraryGraphDocumentTools.VerifySalesObjectTxtDescriptionWithoutComplexTypes(SalesLine, ResponseText);
        VerifyIdsAreBlank(ResponseText);
    end;

    [Test]
    procedure TestPatchingTheIdToAccountChangesLineType()
    var
        SalesHeader: Record "Sales Header";
        GLAccount: Record "G/L Account";
        SalesLine: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        IntegrationManagement: Codeunit "Integration Management";
        TargetURL: Text;
        ResponseText: Text;
        OrderLineJSON: Text;
        OrderId: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] PATCH a Type on a line of an unposted Order
        // [GIVEN] An unposted Order with lines and a valid JSON describing the fields that we want to change
        Initialize();
        OrderId := CreateSalesOrderWithLines(SalesHeader);
        Assert.AreNotEqual('', OrderId, 'ID should not be empty');
        FindFirstSalesLine(SalesHeader, SalesLine);
        LineNo := SalesLine."Line No.";

        CreateVATPostingSetup(VATPostingSetup, SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group");
        GetGLAccountWithVATPostingGroup(GLAccount, SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group");

        OrderLineJSON := StrSubstNo('{"accountId":"%1"}', IntegrationManagement.GetIdWithoutBrackets(GLAccount.SystemId));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Line type is changed to Account
        FindFirstSalesLine(SalesHeader, SalesLine);
        Assert.AreEqual(SalesLine.Type::"G/L Account", SalesLine.Type, 'Type was not changed');
        Assert.AreEqual(GLAccount."No.", SalesLine."No.", 'G/L Account No was not set');

        VerifySalesLineResponseWithSalesLine(SalesLine, ResponseText);
    end;

    [Test]
    procedure TestPatchingTheIdToItemChangesLineType()
    var
        SalesHeader: Record "Sales Header";
        Item: Record "Item";
        SalesLine: Record "Sales Line";
        IntegrationManagement: Codeunit "Integration Management";
        ExpectedNumberOfLines: Integer;
        TargetURL: Text;
        ResponseText: Text;
        OrderLineJSON: Text;
        OrderId: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] PATCH a Type on a line of an unposted Order
        // [GIVEN] An unposted Order with lines and a valid JSON describing the fields that we want to change
        Initialize();
        CreateOrderWithAllPossibleLineTypes(SalesHeader, ExpectedNumberOfLines);
        OrderId := IntegrationManagement.GetIdWithoutBrackets(SalesHeader.SystemId);
        SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.FindFirst();
        SalesLine.SetRange(Type);

        Assert.AreNotEqual('', OrderId, 'ID should not be empty');
        LineNo := SalesLine."Line No.";
        LibraryInventory.CreateItem(Item);

        OrderLineJSON := StrSubstNo('{"itemId":"%1"}', IntegrationManagement.GetIdWithoutBrackets(Item.SystemId));
        Commit();

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Line type is changed to Item and other fields are updated
        SalesLine.Find();
        Assert.AreEqual(SalesLine.Type::Item, SalesLine.Type, 'Type was not changed');
        Assert.AreEqual(Item."No.", SalesLine."No.", 'Item No was not set');

        VerifySalesLineResponseWithSalesLine(SalesLine, ResponseText);
    end;

    [Test]
    procedure TestPatchingTheTypeBlanksIds()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        ResponseText: Text;
        OrderLineJSON: Text;
        OrderId: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] PATCH a Type on a line of an unposted Order
        // [GIVEN] An unposted Order with lines and a valid JSON describing the fields that we want to change
        Initialize();
        OrderId := CreateSalesOrderWithLines(SalesHeader);
        Assert.AreNotEqual('', OrderId, 'ID should not be empty');
        FindFirstSalesLine(SalesHeader, SalesLine);
        LineNo := SalesLine."Line No.";

        OrderLineJSON := StrSubstNo('{"%1":"%2"}', LineTypeFieldNameTxt, Format(SalesInvoiceLineAggregate."API Type"::Account));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesLine.SystemId, OrderServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Line type is changed to Account
        FindFirstSalesLine(SalesHeader, SalesLine);
        Assert.AreEqual(SalesLine.Type::"G/L Account", SalesLine.Type, 'Type was not changed');
        Assert.AreEqual('', SalesLine."No.", 'No should be blank');

        VerifyIdsAreBlank(ResponseText);
    end;

    [Test]
    procedure TestPostOrderLineWithItemVariant()
    var
        Item: Record "Item";
        ItemVariant: Record "Item Variant";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
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
        OrderId := CreateSalesOrderWithLines(SalesHeader);
        ItemNo := LibraryInventory.CreateItem(Item);
        ItemVariantCode := LibraryInventory.CreateItemVariant(ItemVariant, ItemNo);
        Commit();

        // [WHEN] we POST the JSON to the web service
        OrderLineJSON := CreateOrderLineJSONWithItemVariantId(Item.SystemId, LibraryRandom.RandIntInRange(1, 100), ItemVariant.SystemId);
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            Page::"APIV2 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] the response text should contain the order ID and the change should exist in the database
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        Evaluate(LineNo, LineNoFromJSON);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SetRange("Line No.", LineNo);
        SalesLine.SetRange("Variant Code", ItemVariantCode);
        Assert.IsFalse(SalesLine.IsEmpty(), 'The order line should exist');
    end;

    [Test]
    procedure TestPostOrderLineWithWrongItemVariant()
    var
        Item1: Record "Item";
        Item2: Record "Item";
        ItemVariant: Record "Item Variant";
        SalesHeader: Record "Sales Header";
        ItemNo1: Code[20];
        ItemNo2: Code[20];
        ItemVariantCode: Code[10];
        ResponseText: Text;
        TargetURL: Text;
        OrderLineJSON: Text;
        OrderId: Text;
    begin
        // [SCENARIO] POST a new line to an order with wrong item variant
        // [GIVEN] An existing order and a valid JSON describing the new order line with item variant
        Initialize();
        OrderId := CreateSalesOrderWithLines(SalesHeader);
        ItemNo1 := LibraryInventory.CreateItem(Item1);
        ItemNo2 := LibraryInventory.CreateItem(Item2);
        ItemVariantCode := LibraryInventory.CreateItemVariant(ItemVariant, ItemNo2);
        Commit();

        // [WHEN] we POST the JSON to the web service
        OrderLineJSON := CreateOrderLineJSONWithItemVariantId(Item1.SystemId, LibraryRandom.RandIntInRange(1, 100), ItemVariant.SystemId);
        TargetURL := LibraryGraphMgt
                  .CreateTargetURLWithSubpage(
                    OrderId,
                    Page::"APIV2 - Sales Orders",
                    OrderServiceNameTxt,
                    OrderServiceLinesNameTxt);

        // [THEN] the request will fail
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);
    end;

    local procedure CreateOrderWithAllPossibleLineTypes(var SalesHeader: Record "Sales Header"; var ExpectedNumberOfLines: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        CreateSalesOrderWithLines(SalesHeader);

        LibraryGraphDocumentTools.CreateSalesLinesWithAllPossibleTypes(SalesHeader);

        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        ExpectedNumberOfLines := SalesLine.Count();
    end;

    local procedure CreateSalesOrderWithLines(var SalesHeader: Record "Sales Header"): Text
    var
        SalesLine: Record "Sales Line";
        Item: Record "Item";
    begin
        LibrarySales.CreateSalesOrder(SalesHeader);
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 2);
        Commit();
        exit(SalesHeader.SystemId);
    end;

    [Normal]
    local procedure CreateOrderLineJSON(ItemId: Guid; Quantity: Integer): Text
    var
        IntegrationManagement: Codeunit "Integration Management";
        LineJSONTxt: Text;
    begin
        LineJSONTxt := LibraryGraphMgt.AddPropertytoJSON('', 'itemId', IntegrationManagement.GetIdWithoutBrackets(ItemId));
        LineJSONTxt := LibraryGraphMgt.AddComplexTypetoJSON(LineJSONTxt, 'quantity', Format(Quantity));
        exit(LineJSONTxt);
    end;

    local procedure CreateOrderLineJSONWithItemVariantId(ItemId: Guid; Quantity: Integer; ItemVariantId: Guid): Text
    var
        IntegrationManagement: Codeunit "Integration Management";
        LineJsonText: Text;
    begin
        LineJsonText := CreateOrderLineJSON(ItemId, Quantity);
        LineJsonText := LibraryGraphMgt.AddPropertytoJSON(LineJsonText, 'itemVariantId', IntegrationManagement.GetIdWithoutBrackets(ItemVariantId));
        exit(LineJsonText);
    end;

    local procedure CreateOrderAndLinesThroughPage(var SalesOrder: TestPage "Sales Order"; CustomerNo: Text; ItemNo: Text; ItemQuantity: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesOrder.OpenNew();
        SalesOrder."Sell-to Customer No.".SetValue(CustomerNo);

        SalesOrder.SalesLines.LAST();
        SalesOrder.SalesLines.next();
        SalesOrder.SalesLines.FilteredTypeField.SetValue(SalesLine.Type::Item);
        SalesOrder.SalesLines."No.".SetValue(ItemNo);

        SalesOrder.SalesLines.Quantity.SetValue(ItemQuantity);

        // Trigger Save
        SalesOrder.SalesLines.next();
        SalesOrder.SalesLines.Previous();
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

    local procedure VerifySalesOrderLinesForSalesHeader(var SalesHeader: Record "Sales Header"; JsonObjectTxt: Text)
    var
        SalesLine: Record "Sales Line";
        CurrentIndex: Integer;
    begin
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.FindSet();
        CurrentIndex := 0;

        repeat
            VerifySalesLineResponseWithSalesLine(SalesLine, LibraryGraphMgt.GetObjectFromCollectionByIndex(JsonObjectTxt, CurrentIndex));
            CurrentIndex += 1;
        until SalesLine.next() = 0;
    end;

    local procedure VerifySalesLineResponseWithSalesLine(var SalesLine: Record "Sales Line"; JsonObjectTxt: Text)
    begin
        LibraryGraphDocumentTools.VerifySalesObjectTxtDescriptionWithoutComplexTypes(SalesLine, JsonObjectTxt);
        LibraryGraphDocumentTools.VerifySalesIdsSetFromTxt(SalesLine, JsonObjectTxt);
    end;

    local procedure VerifyIdsAreBlank(JsonObjectTxt: Text)
    var
        IntegrationManagement: Codeunit "Integration Management";
        itemId: Text;
        accountId: Text;
        ExpectedId: Text;
        BlankGuid: Guid;
    begin
        ExpectedId := IntegrationManagement.GetIdWithoutBrackets(BlankGuid);

        Assert.IsTrue(LibraryGraphMgt.GetPropertyValueFromJSON(JsonObjectTxt, 'itemId', itemId), 'Could not find itemId');
        Assert.IsTrue(LibraryGraphMgt.GetPropertyValueFromJSON(JsonObjectTxt, 'accountId', accountId), 'Could not find accountId');

        Assert.AreEqual(UPPERCASE(ExpectedId), UPPERCASE(accountId), 'Account id should be blank');
        Assert.AreEqual(UPPERCASE(ExpectedId), UPPERCASE(itemId), 'Item id should be blank');
    end;

    local procedure CreateOrderWithTwoLines(var SalesHeader: Record "Sales Header"; var Customer: Record "Customer"; var Item: Record "Item")
    var
        SalesLine: Record "Sales Line";
        Quantity: Integer;
    begin
        LibraryInventory.CreateItemWithUnitPriceUnitCostAndPostingGroup(
          Item, LibraryRandom.RandDecInDecimalRange(1000, 3000, 2), LibraryRandom.RandDecInDecimalRange(1000, 3000, 2));
        LibrarySales.CreateCustomer(Customer);
        Quantity := LibraryRandom.RandIntInRange(1, 10);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", Quantity);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", Quantity);
    end;

    local procedure VerifyTotals(var SalesHeader: Record "Sales Header"; ExpectedInvDiscValue: Decimal; ExpectedInvDiscType: Option)
    var
        SalesOrderEntityBuffer: Record "Sales Order Entity Buffer";
    begin
        SalesHeader.Find();
        SalesHeader.CALCFIELDS(Amount, "Amount Including VAT", "Invoice Discount Amount", "Recalculate Invoice Disc.");
        Assert.AreEqual(ExpectedInvDiscType, SalesHeader."Invoice Discount Calculation", 'Wrong order discount type');
        Assert.AreEqual(ExpectedInvDiscValue, SalesHeader."Invoice Discount Value", 'Wrong order discount value');
        Assert.IsFalse(SalesHeader."Recalculate Invoice Disc.", 'Recalculate inv. discount should be false');

        if ExpectedInvDiscValue = 0 then
            Assert.AreEqual(0, SalesHeader."Invoice Discount Amount", 'Wrong sales order discount amount')
        else
            Assert.IsTrue(SalesHeader."Invoice Discount Amount" > 0, 'order discount amount value is wrong');

        // Verify Aggregate table
        SalesOrderEntityBuffer.Get(SalesHeader."No.");
        Assert.AreEqual(SalesHeader.Amount, SalesOrderEntityBuffer.Amount, 'Amount was not updated on Aggregate Table');
        Assert.AreEqual(
          SalesHeader."Amount Including VAT", SalesOrderEntityBuffer."Amount Including VAT",
          'Amount Including VAT was not updated on Aggregate Table');
        Assert.AreEqual(
          SalesHeader."Amount Including VAT" - SalesHeader.Amount, SalesOrderEntityBuffer."Total Tax Amount",
          'Total Tax Amount was not updated on Aggregate Table');
        Assert.AreEqual(
          SalesHeader."Invoice Discount Amount", SalesOrderEntityBuffer."Invoice Discount Amount",
          'Amount was not updated on Aggregate Table');
    end;

    local procedure FindFirstSalesLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
    end;

    local procedure SetupAmountDiscountTest(var SalesHeader: Record "Sales Header"; var DiscountAmount: Decimal)
    var
        Customer: Record "Customer";
        Item: Record "Item";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin
        CreateOrderWithTwoLines(SalesHeader, Customer, Item);
        SalesHeader.CALCFIELDS(Amount);
        DiscountAmount := LibraryRandom.RandDecInDecimalRange(1, SalesHeader.Amount / 2, 2);
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(DiscountAmount, SalesHeader);
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

































































































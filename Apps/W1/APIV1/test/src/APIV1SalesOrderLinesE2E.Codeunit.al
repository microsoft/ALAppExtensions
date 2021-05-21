codeunit 139735 "APIV1 - Sales Order Lines E2E"
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
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
        SalesInvLinesE2E: Codeunit "APIV1 - Sales Inv. Lines E2E";
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
        IF IsInitialized THEN
            EXIT;

        LibrarySales.SetStockoutWarning(FALSE);

        LibraryApplicationArea.EnableFoundationSetup();

        IsInitialized := TRUE;
        COMMIT();
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
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        ASSERTERROR LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

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
        IdValue: Text;
        SequenceValue: Text;
    begin
        // [SCENARIO] Call GET on the Line of an order
        // [GIVEN] An order with a line.
        Initialize();
        OrderId := CreateSalesOrderWithLines(SalesHeader);

        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
        LineNo := SalesLine."Line No.";

        // [WHEN] we GET all the lines with the order ID from the web service
        TargetURL := SalesInvLinesE2E.GetLinesURL(SalesInvoiceAggregator.GetIdFromDocumentIdAndSequence(OrderId, LineNo), PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt, OrderServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the line returned should be valid (numbers and integration id)
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'documentId');
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'id', IdValue);
        Assert.AreEqual(IdValue, SalesInvoiceAggregator.GetIdFromDocumentIdAndSequence(OrderId, LineNo), 'The id value is wrong.');
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'sequence', SequenceValue);
        Assert.AreEqual(SequenceValue, FORMAT(LineNo), 'The sequence value is wrong.');
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

        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.FINDFIRST();
        LineNo1 := FORMAT(SalesLine."Line No.");
        SalesLine.FINDLAST();
        LineNo2 := FORMAT(SalesLine."Line No.");

        // [WHEN] we GET all the lines with the  order ID from the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            PAGE::"APIV1 - Sales Orders",
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

        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
        LineNo1 := FORMAT(SalesLine."Line No.");
        SalesLine.FINDLAST();
        LineNo2 := FORMAT(SalesLine."Line No.");

        // [WHEN] we GET all the lines with the order ID from the web service
        TargetURL := SalesInvLinesE2E.GetLinesURLWithDocumentIdFilter(OrderId, PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt, OrderServiceLinesNameTxt);
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
        COMMIT();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] the response text should contain the order ID and the change should exist in the database
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        EVALUATE(LineNo, LineNoFromJSON);
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
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.FINDFIRST();
        LineNo := SalesLine."Line No.";

        SalesQuantity := 4;
        OrderLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', FORMAT(SalesQuantity));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(OrderId, LineNo, OrderServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] the line should be changed in the table and the response JSON text should contain our changed field
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');

        SalesLine.RESET();
        SalesLine.SETRANGE("Line No.", LineNo);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        Assert.IsTrue(SalesLine.FINDFIRST(), 'The  order line should exist after modification');
        Assert.AreEqual(SalesLine.Quantity, SalesQuantity, 'The patch of Sales line quantity was unsuccessful');
    end;

    [Test]
    procedure TestModifyOrderLineFailsOnSequenceIdOrDocumentIdChange()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ResponseText: Text;
        TargetURL: Text;
        OrderLineJSON: Array[3] of Text;
        LineNo: Integer;
        OrderId: Text;
        NewSequence: Integer;
    begin
        // [SCENARIO] PATCH a line of an order will fail if sequence is modified
        // [GIVEN] An order with lines and a valid JSON describing the fields that we want to change
        Initialize();
        OrderId := CreateSalesOrderWithLines(SalesHeader);
        Assert.AreNotEqual('', OrderId, 'ID should not be empty');
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
        LineNo := SalesLine."Line No.";

        NewSequence := SalesLine."Line No." + 1;
        OrderLineJSON[1] := LibraryGraphMgt.AddPropertytoJSON('', 'sequence', NewSequence);
        OrderLineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', 'documentId', LibraryGraphMgt.StripBrackets(CreateGuid()));
        OrderLineJSON[3] := LibraryGraphMgt.AddPropertytoJSON('', 'id', SalesInvoiceAggregator.GetIdFromDocumentIdAndSequence(CreateGuid(), NewSequence));

        // [WHEN] we PATCH the line
        // [THEN] the request will fail
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(OrderId, LineNo, OrderServiceLinesNameTxt));
        ASSERTERROR LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON[1], ResponseText);

        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(OrderId, LineNo, OrderServiceLinesNameTxt));
        ASSERTERROR LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON[2], ResponseText);

        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(OrderId, LineNo, OrderServiceLinesNameTxt));
        ASSERTERROR LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON[3], ResponseText);
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

        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.FINDFIRST();
        LineNo := SalesLine."Line No.";

        COMMIT();

        // [WHEN] we DELETE the first line of that order
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(OrderId, LineNo, OrderServiceLinesNameTxt));
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
        COMMIT();

        // [WHEN] we POST the JSON to the web service and when we create an order through the client UI
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] the response text should be valid, the order line should exist in the tables and the two Orders have the same field values.
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        EVALUATE(LineNo, LineNoFromJSON);
        ApiSalesLine.SETRANGE("Document No.", SalesHeader."No.");
        ApiSalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        ApiSalesLine.SETRANGE("Line No.", LineNo);
        Assert.IsTrue(ApiSalesLine.FINDFIRST(), 'The  order line should exist');

        CreateOrderAndLinesThroughPage(SalesOrder, CustomerNo, ItemNo, ItemQuantity);
        PageSalesLine.SETRANGE("Document No.", SalesOrder."No.".VALUE());
        PageSalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        Assert.IsTrue(PageSalesLine.FINDFIRST(), 'The  order line should exist');

        ApiRecordRef.GETTABLE(ApiSalesLine);
        PageRecordRef.GETTABLE(PageSalesLine);

        // Ignore these fields when comparing Page and API Orders
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesLine.FIELDNO("Line No."), DATABASE::"Sales Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesLine.FIELDNO("Document No."), DATABASE::"Sales Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesLine.FIELDNO("No."), DATABASE::"Sales Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesLine.FIELDNO(Subtype), DATABASE::"Sales Line");
        LibraryUtility.AddTempField(
          TempIgnoredFieldsForComparison, ApiSalesLine.FIELDNO("Recalculate Invoice Disc."), DATABASE::"Sales Line"); // TODO: remove once other changes are checked in

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
        COMMIT();

        // [WHEN] We create a line through API
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Orders",
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

        COMMIT();

        OrderLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', FORMAT(SalesQuantity));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", OrderServiceLinesNameTxt));
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
        SalesHeader.FIND();
        Assert.AreEqual(SalesHeader."Invoice Discount Value", DiscountPct2, 'Discount Pct was not assigned');
        COMMIT();

        // [WHEN] we DELETE the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", OrderServiceLinesNameTxt));
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
        SalesHeader.FIND();
        Assert.AreEqual(SalesHeader."Invoice Discount Value", DiscountPct, 'Discount Pct was not assigned');
        COMMIT();

        // [WHEN] we DELETE the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", OrderServiceLinesNameTxt));
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
        SetupAmountDiscountTest(SalesHeader, DiscountAmount);
        OrderLineJSON := CreateOrderLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));

        COMMIT();

        // [WHEN] We create a line through API
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        ASSERTERROR LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

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
        OrderLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', FORMAT(SalesQuantity));
        COMMIT();

        FindFirstSalesLine(SalesHeader, SalesLine);

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", OrderServiceLinesNameTxt));
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
        COMMIT();

        FindFirstSalesLine(SalesHeader, SalesLine);

        // [WHEN] we DELETE the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", OrderServiceLinesNameTxt));
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

        COMMIT();

        // [WHEN] we GET the lines
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] All lines are shown in the response
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'value', LinesJSON);
        Assert.AreEqual(ExpectedNumberOfLines, LibraryGraphMgt.GetCollectionCountFromJSON(LinesJSON), 'Four lines should be returned');
        VerifySalesOrderLinesForSalesHeader(SalesHeader, LinesJSON);
    end;

    [Test]
    procedure TestPostingBlankLineDefaultsToItemType()
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

        COMMIT();

        OrderLineJSON := '{"description":"test"}';

        // [WHEN] we just POST a blank line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Line of type Item is created
        FindFirstSalesLine(SalesHeader, SalesLine);
        SalesLine.FINDLAST();
        Assert.AreEqual('', SalesLine."No.", 'No should be blank');
        Assert.AreEqual(SalesLine.Type, SalesLine.Type::Item, 'Wrong type is set');

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

        COMMIT();

        // [WHEN] we just POST a blank line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            OrderServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Line of type Item is created
        FindFirstSalesLine(SalesHeader, SalesLine);
        SalesLine.FINDLAST();
        Assert.AreEqual(SalesLine.Type, SalesLine.Type::" ", 'Wrong type is set');
        Assert.AreEqual('test', SalesLine.Description, 'Wrong description is set');

        LibraryGraphDocumentTools.VerifySalesObjectTxtDescription(SalesLine, ResponseText);
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

        OrderLineJSON := STRSUBSTNO('{"accountId":"%1"}', IntegrationManagement.GetIdWithoutBrackets(GLAccount.SystemId));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", OrderServiceLinesNameTxt));
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
        SalesLine.SETRANGE(Type, SalesLine.Type::"G/L Account");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.FINDFIRST();
        SalesLine.SETRANGE(Type);

        Assert.AreNotEqual('', OrderId, 'ID should not be empty');
        LineNo := SalesLine."Line No.";
        LibraryInventory.CreateItem(Item);

        OrderLineJSON := STRSUBSTNO('{"itemId":"%1"}', IntegrationManagement.GetIdWithoutBrackets(Item.SystemId));
        COMMIT();

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", OrderServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderLineJSON, ResponseText);

        // [THEN] Line type is changed to Item and other fields are updated
        SalesLine.FIND();
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

        OrderLineJSON := STRSUBSTNO('{"%1":"%2"}', LineTypeFieldNameTxt, FORMAT(SalesInvoiceLineAggregate."API Type"::Account));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            OrderId,
            PAGE::"APIV1 - Sales Orders",
            OrderServiceNameTxt,
            SalesInvLinesE2E.GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", OrderServiceLinesNameTxt));
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
            PAGE::"APIV1 - Sales Orders",
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
                    PAGE::"APIV1 - Sales Orders",
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

        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        ExpectedNumberOfLines := SalesLine.COUNT();
    end;

    local procedure CreateSalesOrderWithLines(var SalesHeader: Record "Sales Header"): Text
    var
        SalesLine: Record "Sales Line";
        Item: Record "Item";
    begin
        LibrarySales.CreateSalesOrder(SalesHeader);
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 2);
        COMMIT();
        EXIT(SalesHeader.SystemId);
    end;

    [Normal]
    local procedure CreateOrderLineJSON(ItemId: Guid; Quantity: Integer): Text
    var
        IntegrationManagement: Codeunit "Integration Management";
        LineJSONTxt: Text;
    begin
        LineJSONTxt := LibraryGraphMgt.AddPropertytoJSON('', 'itemId', IntegrationManagement.GetIdWithoutBrackets(ItemId));
        LineJSONTxt := LibraryGraphMgt.AddComplexTypetoJSON(LineJSONTxt, 'quantity', FORMAT(Quantity));
        EXIT(LineJSONTxt);
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
        SalesOrder.OPENNEW();
        SalesOrder."Sell-to Customer No.".SETVALUE(CustomerNo);

        SalesOrder.SalesLines.LAST();
        SalesOrder.SalesLines.NEXT();
        SalesOrder.SalesLines.FilteredTypeField.SETVALUE(SalesLine.Type::Item);
        SalesOrder.SalesLines."No.".SETVALUE(ItemNo);

        SalesOrder.SalesLines.Quantity.SETVALUE(ItemQuantity);

        // Trigger Save
        SalesOrder.SalesLines.NEXT();
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
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.FINDSET();
        CurrentIndex := 0;

        REPEAT
            VerifySalesLineResponseWithSalesLine(SalesLine, LibraryGraphMgt.GetObjectFromCollectionByIndex(JsonObjectTxt, CurrentIndex));
            CurrentIndex += 1;
        UNTIL SalesLine.NEXT() = 0;
    end;

    local procedure VerifySalesLineResponseWithSalesLine(var SalesLine: Record "Sales Line"; JsonObjectTxt: Text)
    begin
        LibraryGraphDocumentTools.VerifySalesObjectTxtDescription(SalesLine, JsonObjectTxt);
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
        SalesHeader.FIND();
        SalesHeader.CALCFIELDS(Amount, "Amount Including VAT", "Invoice Discount Amount", "Recalculate Invoice Disc.");
        Assert.AreEqual(ExpectedInvDiscType, SalesHeader."Invoice Discount Calculation", 'Wrong order discount type');
        Assert.AreEqual(ExpectedInvDiscValue, SalesHeader."Invoice Discount Value", 'Wrong order discount value');
        Assert.IsFalse(SalesHeader."Recalculate Invoice Disc.", 'Recalculate inv. discount should be false');

        IF ExpectedInvDiscValue = 0 THEN
            Assert.AreEqual(0, SalesHeader."Invoice Discount Amount", 'Wrong sales order discount amount')
        ELSE
            Assert.IsTrue(SalesHeader."Invoice Discount Amount" > 0, 'order discount amount value is wrong');

        // Verify Aggregate table
        SalesOrderEntityBuffer.GET(SalesHeader."No.");
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
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
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
        VATPostingSetup.SETRANGE("VAT Bus. Posting Group", VATBusPostingGroup);
        VATPostingSetup.SETRANGE("VAT Prod. Posting Group", VATProdPostingGroup);
        if not VATPostingSetup.FINDFIRST() then
            LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusPostingGroup, VATProdPostingGroup);
    end;

    local procedure GetGLAccountWithVATPostingGroup(var GLAccount: Record "G/L Account"; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    begin
        GLAccount.SETRANGE("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SETRANGE("Direct Posting", TRUE);
        GLAccount.SETRANGE("VAT Bus. Posting Group", VATBusPostingGroup);
        GLAccount.SETRANGE("VAT Prod. Posting Group", VATProdPostingGroup);
        if not GLAccount.FINDFIRST() then
            CreateGLAccountWithPostingGroup(GLAccount, VATBusPostingGroup, VATProdPostingGroup);
    end;

    local procedure CreateGLAccountWithPostingGroup(var GLAccount: Record "G/L Account"; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.VALIDATE("VAT Bus. Posting Group", VATBusPostingGroup);
        GLAccount.VALIDATE("VAT Prod. Posting Group", VATProdPostingGroup);
        GLAccount.MODIFY();
    end;

    local procedure RecallNotifications()
    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
    begin
        NotificationLifecycleMgt.RecallAllNotifications();
    end;
}

































































































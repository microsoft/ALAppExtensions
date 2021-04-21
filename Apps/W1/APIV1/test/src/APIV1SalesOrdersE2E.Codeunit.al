codeunit 139711 "APIV1 - Sales Orders E2E"
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
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryGraphDocumentTools: Codeunit "Library - Graph Document Tools";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryERM: Codeunit "Library - ERM";
        OrderServiceNameTxt: Label 'salesOrders', Locked = true;
        DiscountAmountFieldTxt: Label 'discountAmount', Locked = true;
        ActionShipAndInvoiceTxt: Label 'Microsoft.NAV.shipAndInvoice', Locked = true;
        NotEmptyResponseErr: Label 'Response body should be empty.', Locked = true;
        OrderStillExistsErr: Label 'The sales order still exists.', Locked = true;
        CannotFindInvoiceErr: Label 'Cannot find the invoice.', Locked = true;
        CannotFindShipmentErr: Label 'Cannot find the shipment.', Locked = true;
        InvoiceStatusErr: Label 'The invoice status is incorrect.';

    [Test]
    procedure TestGetOrders()
    var
        SalesHeader: Record "Sales Header";
        OrderNo: array[2] of Text;
        OrderJSON: array[2] of Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184721] Create Sales Orders and use a GET method to retrieve them

        // [GIVEN] 2 orders in the table
        LibrarySales.CreateSalesOrder(SalesHeader);
        OrderNo[1] := SalesHeader."No.";

        LibrarySales.CreateSalesOrder(SalesHeader);
        OrderNo[2] := SalesHeader."No.";
        Commit();

        // [WHEN] we GET all the orders from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 orders should exist in the response
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, 'number', OrderNo[1], OrderNo[2], OrderJSON[1], OrderJSON[2]),
          'Could not find the orders in JSON');
        LibraryGraphMgt.VerifyIDInJson(OrderJSON[1]);
        LibraryGraphMgt.VerifyIDInJson(OrderJSON[2]);
    end;

    [Test]
    procedure TestPostOrders()
    var
        SalesHeader: Record "Sales Header";
        SellToCustomer: Record "Customer";
        BillToCustomer: Record "Customer";
        ShipToCustomer: Record "Customer";
        CustomerNo: Text;
        OrderDate: Date;
        PostingDate: Date;
        ResponseText: Text;
        OrderNumber: Text;
        TargetURL: Text;
        OrderWithComplexJSON: Text;
    begin
        // [SCENARIO 184721] Create sales orders JSON and use HTTP POST to create them

        // [GIVEN] a customer
        LibrarySales.CreateCustomerWithAddress(SellToCustomer);
        LibrarySales.CreateCustomerWithAddress(BillToCustomer);
        LibrarySales.CreateCustomerWithAddress(ShipToCustomer);
        CustomerNo := SellToCustomer."No.";
        OrderDate := WorkDate();
        PostingDate := WorkDate();

        // [GIVEN] a JSON text with an order that contains the customer and an adress as complex type
        OrderWithComplexJSON := CreateOrderJSONWithAddress(SellToCustomer, BillToCustomer, ShipToCustomer, OrderDate, PostingDate);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderWithComplexJSON, ResponseText);

        // [THEN] the response text should have the correct Id, order address and the order should exist in the table with currency code set by default
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', OrderNumber), 'Could not find sales order number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        SalesHeader.Reset();
        SalesHeader.SetRange("No.", OrderNumber);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        SalesHeader.SetRange("Document Date", OrderDate);
        SalesHeader.SetRange("Posting Date", PostingDate);
        Assert.IsTrue(SalesHeader.FindFirst(), 'The order should exist');
        Assert.AreEqual('', SalesHeader."Currency Code", 'The order should have the LCY currency code set by default');

        LibraryGraphDocumentTools.VerifySalesDocumentSellToAddress(SellToCustomer, SalesHeader, ResponseText, false, false);
        LibraryGraphDocumentTools.VerifySalesDocumentBillToAddress(BillToCustomer, SalesHeader, ResponseText, false, false);
        LibraryGraphDocumentTools.VerifySalesDocumentShipToAddress(ShipToCustomer, SalesHeader, ResponseText, false, false);
    end;

    [Test]
    procedure TestPostOrderForCustomerWithLocationCode()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record "Customer";
        Location: Record "Location";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        ResponseText: Text;
        OrderNumber: Text;
        TargetURL: Text;
        OrderJSON: Text;
    begin
        // [SCENARIO 184721] Create sales order for customer with location and use HTTP POST to create it

        // [GIVEN] an order with customer with location code
        LibrarySales.CreateCustomer(Customer);
        LibraryWarehouse.CreateLocation(Location);
        Customer.Validate("Location Code", Location.Code);
        Customer.Modify();

        OrderJSON := LibraryGraphMgt.AddPropertytoJSON('', 'customerNumber', Customer."No.");
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderJSON, ResponseText);

        // [THEN] the response text should contain the correct Id and the order should be created, location should be set
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', OrderNumber),
          'Could not find the sales order number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        SalesHeader.Reset();
        SalesHeader.SetRange("No.", OrderNumber);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
        Assert.IsTrue(SalesHeader.FindFirst(), 'The order should exist');
        Assert.AreEqual(Location.Code, SalesHeader."Location Code", 'The location code is not correct');
    end;

    [Test]
    procedure TestPostOrderWithCurrency()
    var
        SalesHeader: Record "Sales Header";
        Currency: Record "Currency";
        Customer: Record "Customer";
        CustomerNo: Text;
        ResponseText: Text;
        OrderNumber: Text;
        TargetURL: Text;
        OrderJSON: Text;
        CurrencyCode: Code[10];
    begin
        // [SCENARIO 184721] Create sales order with specific currency set and use HTTP POST to create it

        // [GIVEN] an order with a non-LCY currencyCode set
        LibrarySales.CreateCustomer(Customer);
        CustomerNo := Customer."No.";

        OrderJSON := LibraryGraphMgt.AddPropertytoJSON('', 'customerNumber', CustomerNo);
        Currency.SETFILTER(Code, '<>%1', '');
        Currency.FindFirst();
        CurrencyCode := Currency.Code;
        OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'currencyCode', CurrencyCode);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderJSON, ResponseText);

        // [THEN] the response text should contain the correct Id and the order should be created
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', OrderNumber),
          'Could not find the sales order number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        SalesHeader.Reset();
        SalesHeader.SetRange("No.", OrderNumber);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        Assert.IsTrue(SalesHeader.FindFirst(), 'The order should exist');
        Assert.AreEqual(CurrencyCode, SalesHeader."Currency Code", 'The order should have the correct currency code');
    end;

    [Test]
    procedure TestModifyOrders()
    begin
        TestMultipleModifyOrders(false, false);
    end;

    [Test]
    procedure TestEmptyModifyOrders()
    begin
        TestMultipleModifyOrders(true, false);
    end;

    [Test]
    procedure TestPartialModifyOrders()
    begin
        TestMultipleModifyOrders(false, true);
    end;

    local procedure TestMultipleModifyOrders(EmptyData: Boolean; PartiallyEmptyData: Boolean)
    var
        SellToCustomer: Record "Customer";
        BillToCustomer: Record "Customer";
        ShipToCustomer: Record "Customer";
        SalesHeader: Record "Sales Header";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        OrderId: Guid;
        ResponseText: Text;
        TargetURL: Text;
        OrderJSON: Text;
        OrderWithComplexJSON: Text;
        SellToAddressComplexTypeJSON: Text;
        ShipToAddressComplexTypeJSON: Text;
    begin
        // [SCENARIO 184721] Create sales order, use a PATCH method to change it and then verify the changes
        // [GIVEN] a customer with address

        // [GIVEN] customers
        LibrarySales.CreateCustomerWithAddress(SellToCustomer);
        LibrarySales.CreateCustomerWithAddress(BillToCustomer);

        // [GIVEN] a sales person
        LibrarySales.CreateSalesperson(SalespersonPurchaser);

        // [GIVEN] an order
        CreateOrderWithLines(SellToCustomer, SalesHeader);
        OrderId := SalesHeader.SystemId;
        Assert.AreNotEqual('', OrderId, 'ID should not be empty');


        IF EmptyData THEN
            OrderJSON := '{}'
        ELSE BEGIN
            OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'salesperson', SalespersonPurchaser.Code);
            OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'customerNumber', SellToCustomer."No.");
            OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'billToCustomerNumber', BillToCustomer."No.");
        END;

        // [GIVEN] a JSON text with an order that has the addresses complex types
        OrderWithComplexJSON := OrderJSON;
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(SellToAddressComplexTypeJSON, SellToCustomer, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(ShipToAddressComplexTypeJSON, ShipToCustomer, EmptyData, PartiallyEmptyData);
        OrderWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(OrderWithComplexJSON, 'sellingPostalAddress', SellToAddressComplexTypeJSON);
        OrderWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(OrderWithComplexJSON, 'shippingPostalAddress', ShipToAddressComplexTypeJSON);

        Commit();

        // [WHEN] we PATCH the JSON to the web service, with the unique order ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(OrderId, PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderWithComplexJSON, ResponseText);

        // [THEN] the order should have the Unit of Measure and address as a value in the table
        Assert.IsTrue(SalesHeader.GetBySystemId(OrderId), 'The sales order should exist in the table');
        IF NOT EmptyData THEN
            Assert.AreEqual(SalesHeader."Salesperson Code", SalespersonPurchaser.Code, 'The patch of Sales Person code was unsuccessful');

        LibraryGraphDocumentTools.VerifySalesDocumentSellToAddress(SellToCustomer, SalesHeader, ResponseText, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.VerifySalesDocumentBillToAddress(BillToCustomer, SalesHeader, ResponseText, EmptyData, false);
        LibraryGraphDocumentTools.VerifySalesDocumentShipToAddress(ShipToCustomer, SalesHeader, ResponseText, EmptyData, PartiallyEmptyData);
    end;

    [Test]
    procedure TestDeleteOrders()
    var
        SalesHeader: Record "Sales Header";
        OrderNo: array[2] of Text;
        OrderId: array[2] of Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184721] Create sales orders and use HTTP DELETE to delete them

        // [GIVEN] 2 orders in the table
        LibrarySales.CreateSalesOrder(SalesHeader);
        OrderNo[1] := SalesHeader."No.";
        OrderId[1] := SalesHeader.SystemId;
        Assert.AreNotEqual('', OrderId[1], 'ID should not be empty');

        LibrarySales.CreateSalesOrder(SalesHeader);
        OrderNo[2] := SalesHeader."No.";
        OrderId[2] := SalesHeader.SystemId;
        Assert.AreNotEqual('', OrderId[2], 'ID should not be empty');
        Commit();

        // [WHEN] we DELETE the orders from the web service, with the orders' unique IDs
        TargetURL := LibraryGraphMgt.CreateTargetURL(OrderId[1], PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);
        TargetURL := LibraryGraphMgt.CreateTargetURL(OrderId[2], PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the orders shouldn't exist in the table
        IF SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo[1]) THEN
            Assert.ExpectedError('The order should not exist');

        IF SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo[2]) THEN
            Assert.ExpectedError('The order should not exist');
    end;

    [Test]
    procedure TestCreateOrderThroughPageAndAPI()
    var
        PageSalesHeader: Record "Sales Header";
        ApiSalesHeader: Record "Sales Header";
        Customer: Record "Customer";
        TempIgnoredFieldsForComparison: Record 2000000041 temporary;
        RecordField: Record Field;
        ApiRecordRef: RecordRef;
        PageRecordRef: RecordRef;
        SalesOrder: TestPage "Sales Order";
        CustomerNo: Text;
        DocumentDate: Date;
        PostingDate: Date;
        ResponseText: Text;
        TargetURL: Text;
        OrderWithComplexJSON: Text;
    begin
        // [SCENARIO 184721] Create an order both through the client UI and through the API and compare them. They should be the same and have the same fields autocompleted wherever needed.
        LibraryGraphDocumentTools.InitializeUIPage();

        // [GIVEN] a customer
        LibrarySales.CreateCustomer(Customer);
        CustomerNo := Customer."No.";
        DocumentDate := WorkDate();
        PostingDate := WorkDate();

        // [GIVEN] a json describing our new order
        OrderWithComplexJSON := CreateOrderJSONWithAddress(Customer, Customer, Customer, DocumentDate, PostingDate);
        Commit();

        // [WHEN] we POST the JSON to the web service and create another order through the test page
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderWithComplexJSON, ResponseText);

        CreateOrderThroughTestPage(SalesOrder, Customer, DocumentDate, DocumentDate);

        // [THEN] the order should exist in the table and match the order created from the page
        ApiSalesHeader.Reset();
        ApiSalesHeader.SetRange("Document Type", ApiSalesHeader."Document Type"::Order);
        ApiSalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        ApiSalesHeader.SetRange("Document Date", DocumentDate);
        ApiSalesHeader.SetRange("Posting Date", PostingDate);
        Assert.IsTrue(ApiSalesHeader.FindFirst(), 'The order should exist');

        // Ignore these fields when comparing Page and API Orders
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("No."), DATABASE::"Sales Header");
        LibraryUtility.AddTempField(
          TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("Posting Description"), DATABASE::"Sales Header");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO(Id), DATABASE::"Sales Header");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("Order Date"), DATABASE::"Sales Header");    // it is always set as Today() in API
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("Shipment Date"), DATABASE::"Sales Header"); // it is always set as Today() in API
        // Special ignore case for ES
        RecordField.SetRange(TableNo, DATABASE::"Sales Header");
        RecordField.SetRange(FieldName, 'Due Date Modified');
        if RecordField.FindFirst() then
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, RecordField."No.", DATABASE::"Sales Header");

        // Time zone will impact how the date from the page vs WebService is saved. If removed this will fail in snap between 12:00 - 1 AM
        IF Time() < 020000T THEN
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("Posting Date"), DATABASE::"Sales Header");

        PageSalesHeader.Get(PageSalesHeader."Document Type"::Order, SalesOrder."No.".VALUE());
        ApiRecordRef.GetTable(ApiSalesHeader);
        PageRecordRef.GetTable(PageSalesHeader);

        Assert.RecordsAreEqualExceptCertainFields(ApiRecordRef, PageRecordRef, TempIgnoredFieldsForComparison,
          'Page and API order do not match');
    end;

    [Test]
    procedure TestGetOrdersAppliesDiscountPct()
    var
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        DiscountPct: Decimal;
    begin
        // [SCENARIO 184721] When an order is created, the GET Method should update the order and assign a total

        // [GIVEN] an order without totals assigned
        LibraryGraphDocumentTools.CreateDocumentWithDiscountPctPending(SalesHeader, DiscountPct, SalesHeader."Document Type"::Order);
        SalesHeader.CalcFields("Recalculate Invoice Disc.");
        Assert.IsTrue(SalesHeader."Recalculate Invoice Disc.", 'Setup error - recalculate Invoice disc. should be set');
        Commit();

        // [WHEN] we GET the order from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.SystemId, PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the order should exist in the response and Order Discount Should be Applied
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        LibraryGraphDocumentTools.VerifySalesTotals(
          SalesHeader, ResponseText, DiscountPct, SalesHeader."Invoice Discount Calculation"::"%");
    end;

    [Test]
    procedure TestGetOrdersRedistributesDiscountAmt()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        ResponseText: Text;
        TargetURL: Text;
        DiscountPct: Decimal;
        DiscountAmt: Decimal;
    begin
        // [SCENARIO 184721] When an order is created, the GET Method should update the order and redistribute the discount amount

        // [GIVEN] an order with discount amount that should be redistributed
        LibraryGraphDocumentTools.CreateDocumentWithDiscountPctPending(SalesHeader, DiscountPct, SalesHeader."Document Type"::Order);
        SalesHeader.CalcFields(Amount);
        DiscountAmt := LibraryRandom.RandDecInRange(1, ROUND(SalesHeader.Amount / 2, 1), 1);
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(DiscountAmt, SalesHeader);
        GetFirstSalesOrderLine(SalesHeader, SalesLine);
        SalesLine.Validate(Quantity, SalesLine.Quantity + 1);
        SalesLine.Modify(true);
        SalesHeader.CalcFields("Recalculate Invoice Disc.");
        Commit();

        // [WHEN] we GET the order from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.SystemId, PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the order should exist in the response and Order Discount Should be Applied
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        LibraryGraphDocumentTools.VerifySalesTotals(
          SalesHeader, ResponseText, DiscountAmt, SalesHeader."Invoice Discount Calculation"::Amount);
    end;

    [Test]
    procedure TestModifyOrderSetManualDiscount()
    var
        SalesHeader: Record "Sales Header";
        InvoiceDiscountAmount: Decimal;
        TargetURL: Text;
        OrderJSON: Text;
        ResponseText: Text;
        OrderNo: Text;
        OrderId: Guid;
    begin
        // [SCENARIO 184721] Create Sales Order, use a PATCH method to change it and then verify the changes

        // [GIVEN] an order with lines
        CreateOrderWithLines(SalesHeader);
        OrderId := SalesHeader.SystemId;
        OrderNo := SalesHeader."No.";
        SalesHeader.CalcFields(Amount);
        InvoiceDiscountAmount := Round(SalesHeader.Amount / 2, LibraryERM.GetCurrencyAmountRoundingPrecision(SalesHeader."Currency Code"), '=');

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(OrderId, PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt);
        OrderJSON := StrSubstNo('{"%1": %2}', DiscountAmountFieldTxt, Format(InvoiceDiscountAmount, 0, 9));
        Commit();

        LibraryGraphMgt.PatchToWebService(TargetURL, OrderJSON, ResponseText);

        // [THEN] Response contains the updated value
        VerifyValidPostRequest(ResponseText, OrderNo);
        LibraryGraphDocumentTools.VerifyValidDiscountAmount(ResponseText, InvoiceDiscountAmount);

        // [THEN] Header value was updated
        SalesHeader.Find();
        SalesHeader.CalcFields("Invoice Discount Amount");
        Assert.AreEqual(InvoiceDiscountAmount, SalesHeader."Invoice Discount Amount", 'Invoice discount Amount was not set');
    end;

    [Test]
    procedure TestClearingManualDiscounts()
    var
        SalesHeader: Record "Sales Header";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        TargetURL: Text;
        OrderJSON: Text;
        ResponseText: Text;
        OrderNo: Text;
    begin
        // [SCENARIO 184721] Clearing manually set discount

        // [GIVEN] an order
        CreateOrderWithLines(SalesHeader);
        OrderNo := SalesHeader."No.";
        SalesHeader.CalcFields(Amount);
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(SalesHeader.Amount / 2, SalesHeader);

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        OrderJSON := STRSUBSTNO('{"%1": %2}', DiscountAmountFieldTxt, Format(0, 0, 9));
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.SystemId, PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt);
        Commit();

        LibraryGraphMgt.PatchToWebService(TargetURL, OrderJSON, ResponseText);

        // [THEN] Discount should be removed
        VerifyValidPostRequest(ResponseText, OrderNo);
        LibraryGraphDocumentTools.VerifyValidDiscountAmount(ResponseText, 0);

        // [THEN] Header value was updated
        SalesHeader.Find();
        SalesHeader.CalcFields("Invoice Discount Amount");
        Assert.AreEqual(0, SalesHeader."Invoice Discount Amount", 'Invoice discount Amount was not set');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionShipAndInvoice()
    var
        SalesHeader: Record "Sales Header";
        OrderId: Guid;
        OrderNo: Code[20];
        OrderNoSeries: Code[20];
        ShippingNo: Code[20];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can ship and invoice a sales order through the API.

        // [GIVEN] a sales order with lines
        CreateOrderWithLines(SalesHeader);
        OrderId := SalesHeader.SystemId;
        OrderNo := SalesHeader."No.";
        OrderNoSeries := SalesHeader."No. Series";
        ShippingNo := SalesHeader."Shipping No.";
        Commit();

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(OrderId, PAGE::"APIV1 - Sales Orders", OrderServiceNameTxt, ActionShipAndInvoiceTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Order is deleted
        Assert.IsFalse(SalesHeader.GetBySystemId(OrderId), OrderStillExistsErr);

        // [THEN] Posted sales shipment is created
        VerifyPostedShipmentCreated(OrderNo, OrderNoSeries);

        // [THEN] Posted sales invoice is created
        VerifyPostedInvoiceCreated(OrderNo, OrderNoSeries);

        // [THEN] Record was deleted from Sales Oreder Entity Buffer
        VerifySalesOrderEntityBufferDeletedAfterPosting(OrderNo);
    end;

    local procedure CreateOrderWithLines(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomerWithAddress(Customer);
        CreateOrderWithLines(Customer, SalesHeader);
    end;

    local procedure CreateOrderWithLines(var Customer: Record Customer; var SalesHeader: Record "Sales Header")
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
    begin
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
    end;

    local procedure VerifyPostedShipmentCreated(OrderNo: Code[20]; OrderNoSeries: Code[20])
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        SalesShipmentHeader.SetCurrentKey("Order No.");
        SalesShipmentHeader.SetRange("Order No. Series", OrderNoSeries);
        SalesShipmentHeader.SetRange("Order No.", OrderNo);
        Assert.IsFalse(SalesShipmentHeader.IsEmpty(), CannotFindShipmentErr);
    end;

    local procedure VerifyPostedInvoiceCreated(OrderNo: Code[20]; OrderNoSeries: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
    begin
        SalesInvoiceHeader.SetCurrentKey("Order No.");
        SalesInvoiceHeader.SetRange("Pre-Assigned No. Series", '');
        SalesInvoiceHeader.SetRange("Order No. Series", OrderNoSeries);
        SalesInvoiceHeader.SetRange("Order No.", OrderNo);
        Assert.IsTrue(SalesInvoiceHeader.FindFirst(), CannotFindInvoiceErr);
        SalesInvoiceEntityAggregate.SetRange(Id, SalesInvoiceHeader.SystemId);
        Assert.IsTrue(SalesInvoiceEntityAggregate.FindFirst(), CannotFindInvoiceErr);
        Assert.AreEqual(SalesInvoiceEntityAggregate.Status::Open, SalesInvoiceEntityAggregate.Status, InvoiceStatusErr);
    end;

    local procedure VerifySalesOrderEntityBufferDeletedAfterPosting(OrderNo: Code[20])
    var
        SalesOrderEntityBuffer: Record "Sales Order Entity Buffer";
    begin
        Assert.IsFalse(SalesOrderEntityBuffer.Get(OrderNo), 'Sales Order Entity buffer was supposed to be deleted after posting.');
    end;

    local procedure CreateOrderJSONWithAddress(SellToCustomer: Record "Customer"; BillToCustomer: Record "Customer"; ShipToCustomer: Record "Customer"; OrderDate: Date; PostingDate: Date): Text
    var
        OrderJSON: Text;
        SellToAddressComplexTypeJSON: Text;
        ShipToAddressComplexTypeJSON: Text;
        OrderWithComplexJSON: Text;
    begin
        OrderJSON := LibraryGraphMgt.AddPropertytoJSON('', 'customerNumber', SellToCustomer."No.");
        OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'orderDate', OrderDate);
        OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'postingDate', PostingDate);
        OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'billToCustomerNumber', BillToCustomer."No.");

        OrderWithComplexJSON := OrderJSON;
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(SellToAddressComplexTypeJSON, SellToCustomer, false, false);
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(ShipToAddressComplexTypeJSON, ShipToCustomer, false, false);
        OrderWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(OrderWithComplexJSON, 'sellingPostalAddress', SellToAddressComplexTypeJSON);
        OrderWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(OrderWithComplexJSON, 'shippingPostalAddress', ShipToAddressComplexTypeJSON);
        exit(OrderWithComplexJSON);
    end;

    local procedure CreateOrderThroughTestPage(var SalesOrder: TestPage "Sales Order"; Customer: Record "Customer"; DocumentDate: Date; PostingDate: Date)
    begin
        SalesOrder.OpenNew();
        SalesOrder."Sell-to Customer No.".SetValue(Customer."No.");
        SalesOrder."Document Date".SetValue(DocumentDate);
        SalesOrder."Posting Date".SetValue(PostingDate);
    end;

    local procedure GetFirstSalesOrderLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.FindFirst();
    end;

    local procedure VerifyValidPostRequest(ResponseText: Text; var OrderNo: Text)
    begin
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', OrderNo),
          'Could not find sales Order number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
    end;
}

codeunit 139851 "APIV2 - Purchase Orders E2E"
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
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryGraphDocumentTools: Codeunit "Library - Graph Document Tools";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySmallBusiness: Codeunit "Library - Small Business";
        OrderServiceNameTxt: Label 'purchaseOrders', Locked = true;
        ActionRecieveAndInvoiceTxt: Label 'Microsoft.NAV.receiveAndInvoice', Locked = true;
        NotEmptyResponseErr: Label 'Response body should be empty.', Locked = true;
        OrderStillExistsErr: Label 'The purchase order still exists.', Locked = true;
        DiscountAmountFieldTxt: Label 'discountAmount', Locked = true;
        CannotFindInvoiceErr: Label 'Cannot find the invoice.', Locked = true;
        InvoiceStatusErr: Label 'The invoice status is incorrect.', Locked = true;

    local procedure Initialize()
    begin
        WorkDate := Today();
    end;

    [Test]
    procedure TestGetOrders()
    var
        PurchaseHeader: Record "Purchase Header";
        OrderNo: array[2] of Text;
        OrderJSON: array[2] of Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184721] Create Purchase Orders and use a GET method to retrieve them
        // [GIVEN] 2 orders in the table
        Initialize();
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        OrderNo[1] := PurchaseHeader."No.";

        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        OrderNo[2] := PurchaseHeader."No.";
        Commit();

        // [WHEN] we GET all the orders from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Orders", OrderServiceNameTxt);
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
        PurchaseHeader: Record "Purchase Header";
        BuyFromVendor: Record "Vendor";
        PayToVendor: Record "Vendor";
        ShipToVendor: Record "Vendor";
        VendorNo: Text;
        OrderDate: Date;
        PostingDate: Date;
        ResponseText: Text;
        OrderNumber: Text;
        TargetURL: Text;
        OrderJSON: Text;
    begin
        // [SCENARIO 184721] Create purchase orders JSON and use HTTP POST to create them
        Initialize();

        // [GIVEN] a customer
        LibraryPurchase.CreateVendorWithAddress(BuyFromVendor);
        LibraryPurchase.CreateVendorWithAddress(PayToVendor);
        LibraryPurchase.CreateVendorWithAddress(ShipToVendor);
        ShipToVendor.County := 'test';
        ShipToVendor.Modify(true);
        Commit();
        VendorNo := BuyFromVendor."No.";
        OrderDate := Today();
        PostingDate := Today();

        // [GIVEN] a JSON text with an order that contains the vendor and an address
        OrderJSON := CreateOrderJSONWithAddress(BuyFromVendor, PayToVendor, ShipToVendor, OrderDate, PostingDate);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Orders", OrderServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderJSON, ResponseText);

        // [THEN] the response text should have the correct Id, order address and the order should exist in the table with currency code set by default
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', OrderNumber), 'Could not find purchase order number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("No.", OrderNumber);
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetRange("Buy-from Vendor No.", VendorNo);
        PurchaseHeader.SetRange("Document Date", OrderDate);
        PurchaseHeader.SetRange("Posting Date", PostingDate);
        Assert.IsTrue(PurchaseHeader.FindFirst(), 'The order should exist');
        Assert.AreEqual('', PurchaseHeader."Currency Code", 'The order should have the LCY currency code set by default');

        LibraryGraphDocumentTools.CheckPurchaseDocumentBuyFromAddress(BuyFromVendor, PurchaseHeader, false, false);
        LibraryGraphDocumentTools.CheckPurchaseDocumentPayToAddress(PayToVendor, PurchaseHeader, false, false);
        LibraryGraphDocumentTools.CheckPurchaseDocumentShipToAddress(ShipToVendor, PurchaseHeader, false, false);
    end;

    [Test]
    procedure TestPostOrdersWithEmptyShippingAddress()
    var
        PurchaseHeader: Record "Purchase Header";
        BuyFromVendor: Record "Vendor";
        PayToVendor: Record "Vendor";
        VendorNo: Text;
        OrderDate: Date;
        PostingDate: Date;
        ResponseText: Text;
        OrderNumber: Text;
        TargetURL: Text;
        OrderJSON: Text;
    begin
        // [SCENARIO 184721] Create purchase orders JSON and use HTTP POST to create them
        Initialize();

        // [GIVEN] a customer
        LibraryPurchase.CreateVendorWithAddress(BuyFromVendor);
        LibraryPurchase.CreateVendorWithAddress(PayToVendor);
        VendorNo := BuyFromVendor."No.";
        OrderDate := Today();
        PostingDate := Today();

        // [GIVEN] a JSON text with an order that contains the vendor and an address
        OrderJSON := CreateOrderJSONWithoutShipTo(BuyFromVendor, PayToVendor, OrderDate, PostingDate);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Orders", OrderServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderJSON, ResponseText);

        // [THEN] the response text should have the correct Id, order address and the order should exist in the table with currency code set by default
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', OrderNumber), 'Could not find purchase order number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("No.", OrderNumber);
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetRange("Buy-from Vendor No.", VendorNo);
        PurchaseHeader.SetRange("Document Date", OrderDate);
        PurchaseHeader.SetRange("Posting Date", PostingDate);
        Assert.IsTrue(PurchaseHeader.FindFirst(), 'The order should exist');
        Assert.AreEqual('', PurchaseHeader."Currency Code", 'The order should have the LCY currency code set by default');
        CheckShippingDetailsNotEmpty(PurchaseHeader);

        LibraryGraphDocumentTools.CheckPurchaseDocumentBuyFromAddress(BuyFromVendor, PurchaseHeader, false, false);
        LibraryGraphDocumentTools.CheckPurchaseDocumentPayToAddress(PayToVendor, PurchaseHeader, false, false);
    end;

    [Test]
    procedure TestPostOrderForCustomerWithLocationCode()
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record "Vendor";
        Location: Record "Location";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        ResponseText: Text;
        OrderNumber: Text;
        TargetURL: Text;
        OrderJSON: Text;
    begin
        // [SCENARIO 184721] Create purchase order for vendor with location and use HTTP POST to create it
        Initialize();

        // [GIVEN] an order with vendor with location code
        LibraryPurchase.CreateVendor(Vendor);
        LibraryWarehouse.CreateLocation(Location);
        Vendor.Validate("Location Code", Location.Code);
        Vendor.Modify();

        OrderJSON := LibraryGraphMgt.AddPropertytoJSON('', 'vendorNumber', Vendor."No.");
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Orders", OrderServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderJSON, ResponseText);

        // [THEN] the response text should contain the correct Id and the order should be created, location should be set
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', OrderNumber),
          'Could not find the sales order number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("No.", OrderNumber);
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetRange("Buy-from Vendor No.", Vendor."No.");
        Assert.IsTrue(PurchaseHeader.FindFirst(), 'The order should exist');
        Assert.AreEqual(Location.Code, PurchaseHeader."Location Code", 'The location code is not correct');
    end;

    [Test]
    procedure TestPostOrderWithCurrency()
    var
        PurchaseHeader: Record "Purchase Header";
        Currency: Record "Currency";
        Vendor: Record "Vendor";
        VendorNo: Text;
        ResponseText: Text;
        OrderNumber: Text;
        TargetURL: Text;
        OrderJSON: Text;
        CurrencyCode: Code[10];
    begin
        // [SCENARIO 184721] Create purchase order with specific currency set and use HTTP POST to create it
        Initialize();

        // [GIVEN] an order with a non-LCY currencyCode set
        LibraryPurchase.CreateVendor(Vendor);
        VendorNo := Vendor."No.";

        OrderJSON := LibraryGraphMgt.AddPropertytoJSON('', 'vendorNumber', VendorNo);
        Currency.SetFilter(Code, '<>%1', '');
        Currency.FindFirst();
        CurrencyCode := Currency.Code;
        OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'currencyCode', CurrencyCode);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Orders", OrderServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderJSON, ResponseText);

        // [THEN] the response text should contain the correct Id and the order should be created
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', OrderNumber),
          'Could not find the sales order number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("No.", OrderNumber);
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetRange("Buy-from Vendor No.", VendorNo);
        Assert.IsTrue(PurchaseHeader.FindFirst(), 'The order should exist');
        Assert.AreEqual(CurrencyCode, PurchaseHeader."Currency Code", 'The order should have the correct currency code');
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
        BuyFromVendor: Record "Vendor";
        PayToVendor: Record "Vendor";
        ShipToVendor: Record "Vendor";
        PurchaseHeader: Record "Purchase Header";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        LibrarySales: Codeunit "Library - Sales";
        OrderId: Guid;
        ResponseText: Text;
        TargetURL: Text;
        OrderJSON: Text;
    begin
        // [SCENARIO 184721] Create Purchase order, use a PATCH method to change it and then verify the changes
        Initialize();

        // [GIVEN] vendors
        LibraryPurchase.CreateVendorWithAddress(BuyFromVendor);
        LibraryPurchase.CreateVendorWithAddress(PayToVendor);
        LibraryPurchase.CreateVendorWithAddress(ShipToVendor);


        // [GIVEN] a sales person
        LibrarySales.CreateSalesperson(SalespersonPurchaser);

        // [GIVEN] an order
        CreateOrderWithLines(BuyFromVendor, PurchaseHeader);
        OrderId := PurchaseHeader.SystemId;
        Assert.AreNotEqual('', OrderId, 'ID should not be empty');


        if EmptyData then
            OrderJSON := '{}'
        else begin
            OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'purchaser', SalespersonPurchaser.Code);
            OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'vendorNumber', BuyFromVendor."No.");
            OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'payToVendorNumber', PayToVendor."No.");
        end;

        // [GIVEN] a JSON text with an order that has the addresses
        LibraryGraphDocumentTools.GetVendorAddressJSON(OrderJSON, BuyFromVendor, 'buyFrom', EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.GetVendorAddressJSON(OrderJSON, ShipToVendor, 'shipTo', EmptyData, PartiallyEmptyData);

        Commit();

        // [WHEN] we PATCH the JSON to the web service, with the unique order ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(OrderId, Page::"APIV2 - Purchase Orders", OrderServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, OrderJSON, ResponseText);

        // [THEN] the order should have the purchaser and address as a value in the table
        Assert.IsTrue(PurchaseHeader.GetBySystemId(OrderId), 'The purchase order should exist in the table');
        if not EmptyData then
            Assert.AreEqual(PurchaseHeader."Purchaser Code", SalespersonPurchaser.Code, 'The patch of Purchaser code was unsuccessful');

        LibraryGraphDocumentTools.CheckPurchaseDocumentBuyFromAddress(BuyFromVendor, PurchaseHeader, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.CheckPurchaseDocumentPayToAddress(PayToVendor, PurchaseHeader, EmptyData, false);
        LibraryGraphDocumentTools.CheckPurchaseDocumentShipToAddress(ShipToVendor, PurchaseHeader, EmptyData, PartiallyEmptyData);
    end;

    [Test]
    procedure TestDeleteOrders()
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        OrderNo: array[2] of Text;
        OrderId: array[2] of Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184721] Create purchase orders and use HTTP DELETE to delete them
        // [GIVEN] 2 orders in the table
        Initialize();
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        OrderNo[1] := PurchaseHeader."No.";
        OrderId[1] := PurchaseHeader.SystemId;
        Assert.AreNotEqual('', OrderId[1], 'ID should not be empty');

        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        OrderNo[2] := PurchaseHeader."No.";
        OrderId[2] := PurchaseHeader.SystemId;
        Assert.AreNotEqual('', OrderId[2], 'ID should not be empty');
        Commit();

        // [WHEN] we DELETE the orders from the web service, with the orders' unique IDs
        TargetURL := LibraryGraphMgt.CreateTargetURL(OrderId[1], Page::"APIV2 - Purchase Orders", OrderServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);
        TargetURL := LibraryGraphMgt.CreateTargetURL(OrderId[2], Page::"APIV2 - Purchase Orders", OrderServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the orders shouldn't exist in the table
        if SalesHeader.Get(PurchaseHeader."Document Type"::Order, OrderNo[1]) then
            Assert.ExpectedError('The order should not exist');

        if SalesHeader.Get(PurchaseHeader."Document Type"::Order, OrderNo[2]) then
            Assert.ExpectedError('The order should not exist');
    end;

    [Test]
    procedure TestCreateOrderThroughPageAndAPI()
    var
        PagePurchaseHeader: Record "Purchase Header";
        ApiPurchaseHeader: Record "Purchase Header";
        Vendor: Record "Vendor";
        TempIgnoredFieldsForComparison: Record 2000000041 temporary;
        RecordField: Record Field;
        ApiRecordRef: RecordRef;
        PageRecordRef: RecordRef;
        PurchaseOrder: TestPage "Purchase Order";
        VendorNo: Text;
        OrderDate: Date;
        PostingDate: Date;
        ResponseText: Text;
        TargetURL: Text;
        OrderJSON: Text;
    begin
        // [SCENARIO 184721] Create an order both through the client UI and through the API and compare them. They should be the same and have the same fields autocompleted wherever needed.
        Initialize();
        LibraryGraphDocumentTools.InitializeUIPage();

        // [GIVEN] a customer
        LibraryPurchase.CreateVendor(Vendor);
        VendorNo := Vendor."No.";
        OrderDate := Today();
        PostingDate := Today();

        // [GIVEN] a json describing our new order
        OrderJSON := CreateOrderJSONWithAddress(Vendor, Vendor, Vendor, OrderDate, PostingDate);
        Commit();

        // [WHEN] we POST the JSON to the web service and create another order through the test page
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Orders", OrderServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OrderJSON, ResponseText);

        CreateOrderThroughTestPage(PurchaseOrder, Vendor, OrderDate, OrderDate);

        // [THEN] the order should exist in the table and match the order created from the page
        ApiPurchaseHeader.Reset();
        ApiPurchaseHeader.SetRange("Document Type", ApiPurchaseHeader."Document Type"::Order);
        ApiPurchaseHeader.SetRange("Buy-from Vendor No.", VendorNo);
        ApiPurchaseHeader.SetRange("Document Date", OrderDate);
        ApiPurchaseHeader.SetRange("Posting Date", PostingDate);
        Assert.IsTrue(ApiPurchaseHeader.FindFirst(), 'The order should exist');

        // Ignore these fields when comparing Page and API Orders
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiPurchaseHeader.FieldNo("No."), Database::"Purchase Header");
        LibraryUtility.AddTempField(
          TempIgnoredFieldsForComparison, ApiPurchaseHeader.FieldNo("Posting Description"), Database::"Purchase Header");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiPurchaseHeader.FieldNo(Id), Database::"Purchase Header");
        // Special ignore case for ES
        RecordField.SetRange(TableNo, Database::"Purchase Header");
        RecordField.SetRange(FieldName, 'Due Date Modified');
        if RecordField.FindFirst() then
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, RecordField."No.", Database::"Purchase Header");
        // Special ignore case for GB, work item 390270
        RecordField.SetRange(TableNo, Database::"Purchase Header");
        RecordField.SetRange(FieldName, 'Invoice Receipt Date');
        if RecordField.FindFirst() then
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, RecordField."No.", Database::"Purchase Header");

        // Time zone will impact how the date from the page vs WebService is saved. If removed this will fail in snap between 12:00 - 1 AM
        if Time() < 020000T then begin
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiPurchaseHeader.FieldNo("Order Date"), Database::"Purchase Header");
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiPurchaseHeader.FieldNo("Posting Date"), Database::"Purchase Header");
        end;

        PagePurchaseHeader.Get(PagePurchaseHeader."Document Type"::Order, PurchaseOrder."No.".Value());
        ApiRecordRef.GetTable(ApiPurchaseHeader);
        PageRecordRef.GetTable(PagePurchaseHeader);

        Assert.RecordsAreEqualExceptCertainFields(ApiRecordRef, PageRecordRef, TempIgnoredFieldsForComparison,
          'Page and API order do not match');
    end;

    [Test]
    procedure TestGetOrdersAppliesDiscountPct()
    var
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        TargetURL: Text;
        DiscountPct: Decimal;
    begin
        // [SCENARIO 184721] When an order is created, the GET Method should update the order and assign a total
        // [GIVEN] an order without totals assigned
        Initialize();
        CreateDocumentWithDiscountPctPending(PurchaseHeader, DiscountPct, PurchaseHeader."Document Type"::Order);
        PurchaseHeader.CalcFields("Recalculate Invoice Disc.");
        Assert.IsTrue(PurchaseHeader."Recalculate Invoice Disc.", 'Setup error - recalculate Invoice disc. should be set');
        Commit();

        // [WHEN] we GET the order from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(PurchaseHeader.SystemId, Page::"APIV2 - Purchase Orders", OrderServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the order should exist in the response and Order Discount Should be Applied
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        LibraryGraphDocumentTools.VerifyPurchaseTotals(
          PurchaseHeader, ResponseText, DiscountPct, PurchaseHeader."Invoice Discount Calculation"::"%");
    end;

    [Test]
    procedure TestGetOrdersRedistributesDiscountAmt()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
        ResponseText: Text;
        TargetURL: Text;
        DiscountPct: Decimal;
        DiscountAmt: Decimal;
    begin
        // [SCENARIO 184721] When an order is created, the GET Method should update the order and redistribute the discount amount
        // [GIVEN] an order with discount amount that should be redistributed
        Initialize();
        CreateDocumentWithDiscountPctPending(PurchaseHeader, DiscountPct, PurchaseHeader."Document Type"::Order);
        PurchaseHeader.CalcFields(Amount);
        DiscountAmt := LibraryRandom.RandDecInRange(1, ROUND(PurchaseHeader.Amount / 2, 1), 1);
        PurchCalcDiscByType.ApplyInvDiscBasedOnAmt(DiscountAmt, PurchaseHeader);
        GetFirstPurchaseOrderLine(PurchaseHeader, PurchaseLine);
        PurchaseLine.Validate(Quantity, PurchaseLine.Quantity + 1);
        PurchaseLine.Modify(true);
        PurchaseHeader.CalcFields("Recalculate Invoice Disc.");
        Commit();

        // [WHEN] we GET the order from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(PurchaseHeader.SystemId, Page::"APIV2 - Purchase Orders", OrderServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the order should exist in the response and Order Discount Should be Applied
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        LibraryGraphDocumentTools.VerifyPurchaseTotals(
          PurchaseHeader, ResponseText, DiscountAmt, PurchaseHeader."Invoice Discount Calculation"::Amount);
    end;

    [Test]
    procedure TestModifyOrderSetManualDiscount()
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record "Vendor";
        InvoiceDiscountAmount: Decimal;
        TargetURL: Text;
        OrderJSON: Text;
        ResponseText: Text;
        OrderNo: Text;
        OrderId: Guid;
    begin
        // [SCENARIO 184721] Create Sales Order, use a PATCH method to change it and then verify the changes
        Initialize();

        // [GIVEN] an order with lines
        LibraryPurchase.CreateVendorWithAddress(Vendor);
        CreateOrderWithLines(Vendor, PurchaseHeader);
        OrderId := PurchaseHeader.SystemId;
        OrderNo := PurchaseHeader."No.";
        PurchaseHeader.CalcFields(Amount);
        InvoiceDiscountAmount := Round(PurchaseHeader.Amount / 2, LibraryERM.GetCurrencyAmountRoundingPrecision(PurchaseHeader."Currency Code"), '=');

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(OrderId, Page::"APIV2 - Purchase Orders", OrderServiceNameTxt);
        OrderJSON := StrSubstNo('{"%1": %2}', DiscountAmountFieldTxt, Format(InvoiceDiscountAmount, 0, 9));
        Commit();

        LibraryGraphMgt.PatchToWebService(TargetURL, OrderJSON, ResponseText);

        // [THEN] Response contains the updated value
        VerifyValidPostRequest(ResponseText, OrderNo);
        LibraryGraphDocumentTools.VerifyValidDiscountAmount(ResponseText, InvoiceDiscountAmount);

        // [THEN] Header value was updated
        PurchaseHeader.Find();
        PurchaseHeader.CalcFields("Invoice Discount Amount");
        Assert.AreEqual(InvoiceDiscountAmount, PurchaseHeader."Invoice Discount Amount", 'Invoice discount Amount was not set');
    end;

    [Test]
    procedure TestClearingManualDiscounts()
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record "Vendor";
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
        TargetURL: Text;
        OrderJSON: Text;
        ResponseText: Text;
        OrderNo: Text;
    begin
        // [SCENARIO 184721] Clearing manually set discount
        Initialize();

        // [GIVEN] an order
        CreateOrderWithLines(Vendor, PurchaseHeader);
        OrderNo := PurchaseHeader."No.";
        PurchaseHeader.CalcFields(Amount);
        PurchCalcDiscByType.ApplyInvDiscBasedOnAmt(PurchaseHeader.Amount / 2, PurchaseHeader);

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        OrderJSON := StrSubstNo('{"%1": %2}', DiscountAmountFieldTxt, Format(0, 0, 9));
        TargetURL := LibraryGraphMgt.CreateTargetURL(PurchaseHeader.SystemId, Page::"APIV2 - Purchase Orders", OrderServiceNameTxt);
        Commit();

        LibraryGraphMgt.PatchToWebService(TargetURL, OrderJSON, ResponseText);

        // [THEN] Discount should be removed
        VerifyValidPostRequest(ResponseText, OrderNo);
        LibraryGraphDocumentTools.VerifyValidDiscountAmount(ResponseText, 0);

        // [THEN] Header value was updated
        PurchaseHeader.Find();
        PurchaseHeader.CalcFields("Invoice Discount Amount");
        Assert.AreEqual(0, PurchaseHeader."Invoice Discount Amount", 'Invoice discount Amount was not set');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionRecieveAndInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        OrderId: Guid;
        OrderNo: Code[20];
        OrderNoSeries: Code[20];
        ReceivingNo: Code[20];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can recieve and invoice a purchase order through the API.

        // [GIVEN] Create vendors and a Purchase order with lines
        LibraryPurchase.CreateVendorWithAddress(Vendor);
        CreateOrderWithLines(Vendor, PurchaseHeader);
        OrderId := PurchaseHeader.SystemId;
        OrderNo := PurchaseHeader."No.";
        OrderNoSeries := PurchaseHeader."No. Series";
        ReceivingNo := PurchaseHeader."Receiving No.";
        Commit();

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(OrderId, Page::"APIV2 - Purchase Orders", OrderServiceNameTxt, ActionRecieveAndInvoiceTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Order is deleted
        Assert.IsFalse(PurchaseHeader.GetBySystemId(OrderId), OrderStillExistsErr);


        // [THEN] Posted sales invoice is created
        VerifyPostedInvoiceCreated(OrderNo, OrderNoSeries);

        // [THEN] Record was deleted from Sales Oreder Entity Buffer
        VerifyPurchOrderEntityBufferDeletedAfterPosting(OrderNo);
    end;

    local procedure CreateOrderJSONWithAddress(BuyFromVendor: Record "Vendor"; PayToVendor: Record "Vendor"; ShipToVendor: Record "Vendor"; OrderDate: Date; PostingDate: Date): Text
    var
        OrderJSON: Text;
    begin
        OrderJSON := LibraryGraphMgt.AddPropertytoJSON('', 'vendorNumber', BuyFromVendor."No.");
        OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'orderDate', OrderDate);
        OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'postingDate', PostingDate);
        OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'payToVendorNumber', PayToVendor."No.");

        LibraryGraphDocumentTools.GetVendorAddressJSON(OrderJSON, BuyFromVendor, 'buyFrom', false, false);
        LibraryGraphDocumentTools.GetVendorAddressJSON(OrderJSON, ShipToVendor, 'shipTo', false, false);

        exit(OrderJSON);
    end;

    local procedure CreateOrderJSONWithoutShipTo(BuyFromVendor: Record "Vendor"; PayToVendor: Record "Vendor"; OrderDate: Date; PostingDate: Date): Text
    var
        OrderJSON: Text;
    begin
        OrderJSON := LibraryGraphMgt.AddPropertytoJSON('', 'vendorNumber', BuyFromVendor."No.");
        OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'orderDate', OrderDate);
        OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'postingDate', PostingDate);
        OrderJSON := LibraryGraphMgt.AddPropertytoJSON(OrderJSON, 'payToVendorNumber', PayToVendor."No.");

        LibraryGraphDocumentTools.GetVendorAddressJSON(OrderJSON, BuyFromVendor, 'buyFrom', false, false);

        exit(OrderJSON);
    end;

    local procedure CreateOrderThroughTestPage(var PurchaseOrder: TestPage "Purchase Order"; Vendor: Record "Vendor"; DocumentDate: Date; PostingDate: Date)
    begin
        PurchaseOrder.OpenNew();
        PurchaseOrder."Buy-from Vendor No.".SetValue(Vendor."No.");
        PurchaseOrder."Document Date".SetValue(DocumentDate);
        PurchaseOrder."Posting Date".SetValue(PostingDate);
    end;

    local procedure CheckShippingDetailsNotEmpty(var PurchaseHeader: Record "Purchase Header")
    begin
        Assert.AreNotEqual(PurchaseHeader."Ship-to Name", '', 'The ship-to name should not be empty.');
        Assert.AreNotEqual(PurchaseHeader."Ship-to Address", '', 'The ship-to address should not be empty.');
        Assert.AreNotEqual(PurchaseHeader."Ship-to City", '', 'The ship-to city should not be empty.');
        Assert.AreNotEqual(PurchaseHeader."Ship-to Country/Region Code", '', 'The ship-to country should not be empty.');
        Assert.AreNotEqual(PurchaseHeader."Ship-to Post Code", '', 'The ship-to post code should not be empty.');
    end;

    local procedure CreateOrderWithLines(var Vendor: Record Vendor; var PurchaseHeader: Record "Purchase Header")
    var
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
        PurchaseLine.Modify(true);
    end;

    local procedure CreateDocumentWithDiscountPctPending(var PurchaseHeader: Record "Purchase Header"; var DiscountPct: Decimal; DocumentType: Enum "Purchase Document Type")
    var
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        Vendor: Record Vendor;
    begin
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInDecimalRange(1, 100, 2), LibraryRandom.RandDecInDecimalRange(1, 100, 2));
        LibraryPurchase.CreateVendor(Vendor);
        DiscountPct := LibraryRandom.RandDecInRange(1, 99, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToVendor(Vendor, DiscountPct, 0, '');

        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", LibraryRandom.RandIntInRange(1, 10));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
        PurchaseLine.Modify(true);
    end;

    local procedure GetFirstPurchaseOrderLine(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.FindFirst();
    end;

    local procedure VerifyValidPostRequest(ResponseText: Text; var OrderNo: Text)
    begin
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', OrderNo),
          'Could not find sales Order number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
    end;

    local procedure VerifyPostedInvoiceCreated(OrderNo: Code[20]; OrderNoSeries: Code[20])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvEntityAggregate: Record "Purch. Inv. Entity Aggregate";
    begin
        PurchInvHeader.SetCurrentKey("Order No.");
        PurchInvHeader.SetRange("Pre-Assigned No. Series", '');
        PurchInvHeader.SetRange("Order No. Series", OrderNoSeries);
        PurchInvHeader.SetRange("Order No.", OrderNo);
        Assert.IsTrue(PurchInvHeader.FindFirst(), CannotFindInvoiceErr);
        PurchInvEntityAggregate.SetRange(Id, PurchInvHeader.SystemId);
        Assert.IsTrue(PurchInvEntityAggregate.FindFirst(), CannotFindInvoiceErr);
        Assert.AreEqual(PurchInvEntityAggregate.Status::Open, PurchInvEntityAggregate.Status, InvoiceStatusErr);
    end;

    local procedure VerifyPurchOrderEntityBufferDeletedAfterPosting(OrderNo: Code[20])
    var
        PurchaseOrderEntityBuffer: Record "Purchase Order Entity Buffer";
    begin
        Assert.IsFalse(PurchaseOrderEntityBuffer.Get(OrderNo), 'Purchase Order Entity buffer was supposed to be deleted after posting.');
    end;

}
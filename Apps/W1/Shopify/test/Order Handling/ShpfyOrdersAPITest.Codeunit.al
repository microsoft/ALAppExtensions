codeunit 139608 "Shpfy Orders API Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestExtractShopifyOrdersToImport()
    var
        Shop: Record "Shpfy Shop";
        OrdersToImport: Record "Shpfy Orders to Import";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        OrderHandlingHelper: Codeunit "Shpfy Order Handling Helper";
        OrdersAPI: Codeunit "Shpfy Orders API";
        Cursor: Text;
        JOrdersToImport: JsonObject;
    begin
        // [SCENARIO] Create a randpom expected Json structure for the OrdersToImport and see of all orders are available in the "Shpfy Orders to Import" table.
        // [SCENARIO] At start we reset the "Shpfy Orders to Import" table so we can see how many record are added.
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        Clear(OrdersToImport);
        if not OrdersToImport.IsEmpty then
            OrdersToImport.DeleteAll();

        // [GIVEN] the shopify shop
        Shop := CommunicationMgt.GetShopRecord();
        // [GIVEN] the orders to import as a json structure.
        JOrdersToImport := OrderHandlingHelper.GetOrdersToImport();
        // [GIVEN] the cursor text varable for retreiving the last cursor.

        // [WHEN] Execute ShpfyOrdersAPI.ExtractShopifyOrdersToImport
        OrdersAPI.ExtractShopifyOrdersToImport(Shop, JOrdersToImport, Cursor);
        // [THEN] The result must be true.
        LibraryAssert.IsTrue(OrdersAPI.ExtractShopifyOrdersToImport(Shop, JOrdersToImport, Cursor), 'Extracting orders must return true.');

        // [THEN] The last cursor must have lenght of 92 characters.
        LibraryAssert.AreEqual(92, StrLen(Cursor), 'The cursor has a lenght of 92 characters');

        // [THEN] The number of orders that where imported must be the same as in the table "Shpfy Order to Import".
        LibraryAssert.AreEqual(OrderHandlingHelper.CountOrdersToImport(JOrdersToImport), OrdersToImport.Count, 'All orders to import are in the "Shpfy Orders to Import" table');
    end;

    [Test]
    procedure UnitTestImportShopifyOrder()
    var
        Shop: Record "Shpfy Shop";
        OrderHeader: Record "Shpfy Order Header";
        OrdersToImport: Record "Shpfy Orders to Import";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ImportOrder: Codeunit "Shpfy Import Order";
        OrderHandlingHelper: Codeunit "Shpfy Order Handling Helper";
        JShopifyOrder: JsonObject;
        JShopifyLineItems: JsonArray;
    begin
        // [SCENARIO] Import a Shopify order from the "Shpfy Orders to Import" record.
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");

        // [GIVEN] the shopify shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Customer Mapping Type" := "Shpfy Customer Mapping"::"By EMail/Phone";
        if not Shop.Modify() then
            Shop.Insert();
        ImportOrder.SetShop(Shop);

        // [GIVEN] the order to import as a json structure.
        JShopifyOrder := OrderHandlingHelper.CreateShopifyOrderAsJson(Shop, OrdersToImport, JShopifyLineItems);

        // [WHEN] ShpfyImportOrder.ImportOrder
        ImportShopifyOrder(Shop, OrderHeader, OrdersToImport, ImportOrder, JShopifyOrder, JShopifyLineItems);

        // [THEN] ShpfyOrdersToImport.Id = ShpfyOrderHeader."Shopify Order Id"
        LibraryAssert.AreEqual(OrdersToImport.Id, OrderHeader."Shopify Order Id", 'ShpfyOrdersToImport.Id = ShpfyOrderHeader."Shopify Order Id"');

        // [THEN] ShpfyOrdersToImport."Order No." = ShpfyOrderHeader."Shopify Order No."
        LibraryAssert.AreEqual(OrdersToImport."Order No.", OrderHeader."Shopify Order No.", 'ShpfyOrdersToImport."Order No." = ShpfyOrderHeader."Shopify Order No."');

        // [THEN] ShpfyOrdersToImport."Order Amount" = ShpfyOrderHeader."Total Amount"
        LibraryAssert.AreEqual(OrdersToImport."Order Amount", OrderHeader."Total Amount", 'ShpfyOrdersToImport."Order Amount" = ShpfyOrderHeader."Total Amount"');
    end;

    // [Test]
    procedure UnitTestDoMappingsOnAShopifyOrder()
    var
        Shop: Record "Shpfy Shop";
        OrderHeader: Record "Shpfy Order Header";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        OrderMapping: Codeunit "Shpfy Order Mapping";
        ImportOrder: Codeunit "Shpfy Import Order";
        Result: Boolean;
    begin
        // [SCENARION] Crating a random Shopify Order and try to map customer and product data.
        // [SCENARION] If everithing succeed the function will return true.
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");

        // [GIVEN] the shopify shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Customer Mapping Type" := "Shpfy Customer Mapping"::"By EMail/Phone";
        if not Shop.Modify() then
            Shop.Insert();
        ImportOrder.SetShop(Shop);

        // [GIVEN] ShpfyImportOrder.ImportOrder
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder);

        // [WHEN] ShpfyOrderMapping.DoMapping(ShpfyOrderHeader)
        Result := OrderMapping.DoMapping(OrderHeader);

        // [THEN] The result must be true if everthing is mapped.
        LibraryAssert.IsTrue(Result, 'Order Mapping must succeed.');
    end;

    // [Test]
    procedure UnitTestImportShopifyOrderAndCreateSalesDocument()
    var
        Shop: Record "Shpfy Shop";
        OrderHeader: Record "Shpfy Order Header";
        SalesHeader: Record "Sales Header";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ImportOrder: codeunit "Shpfy Import Order";
        ProcessOrders: Codeunit "Shpfy Process Orders";
    begin
        // [SCENARION] Crating a random Shopify Order and try to map customer and product data.
        // [SCENARION] When the sales document is created, everything will be mapped and the sales document must exist.
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");

        // [GIVEN] the shopify shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Customer Mapping Type" := "Shpfy Customer Mapping"::"By EMail/Phone";
        if not Shop.Modify() then
            Shop.Insert();
        ImportOrder.SetShop(Shop);

        // [GIVEN] ShpfyImportOrder.ImportOrder
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder);
        Commit();

        // [WHEN]
        ProcessOrders.ProcessShopifyOrder(OrderHeader);
        OrderHeader.Find();

        // [THEN] Sales document is created from Shopify order
        SalesHeader.SetRange("Shpfy Order Id", OrderHeader."Shopify Order Id");
        LibraryAssert.IsTrue(SalesHeader.FindLast(), 'Sales document is created from Shopify order');

        case SalesHeader."Document Type" of
            "Sales Document Type"::Order:
                // [THEN] ShShpfyOrderHeader."Sales Order No." = SalesHeader."No."
                LibraryAssert.AreEqual(OrderHeader."Sales Order No.", SalesHeader."No.", 'ShpfyOrderHeader."Sales Order No." = SalesHeader."No."');
            "Sales document Type"::Invoice:
                // [THEN] ShShpfyOrderHeader."Sales Invoice No." = SalesHeader."No."
                LibraryAssert.AreEqual(OrderHeader."Sales Invoice No.", SalesHeader."No.", 'ShpfyOrderHeader."Sales Invoice No." = SalesHeader."No."');
            else
                Error('Invalid Document Type');
        end;
    end;

    local procedure ImportShopifyOrder(var Shop: Record "Shpfy Shop"; var OrderHeader: Record "Shpfy Order Header"; var OrdersToImport: Record "Shpfy Orders to Import"; var ImportOrder: codeunit "Shpfy Import Order"; var JShopifyOrder: JsonObject; var JShopifyLineItems: JsonArray)
    var
        OrderLine: Record "Shpfy Order Line";
        JOrderLine: JsonToken;
    begin
        OrdersToImport."Shop Code" := Shop.Code;
        OrdersToImport.Modify();
        ImportOrder.ImportOrderHeader(OrdersToImport, OrderHeader, JShopifyOrder);
        foreach JOrderline in JShopifyLineItems do
            ImportOrder.ImportOrderLine(OrderHeader, OrderLine, JOrderLine);
    end;

    local procedure ImportShopifyOrder(var Shop: Record "Shpfy Shop"; var OrderHeader: Record "Shpfy Order Header"; var ImportOrder: codeunit "Shpfy Import Order")
    var
        OrdersToImport: Record "Shpfy Orders to Import";
        OrderHandlingHelper: Codeunit "Shpfy Order Handling Helper";
        JShopifyOrder: JsonObject;
        JShopifyLineItems: JsonArray;
    begin
        JShopifyOrder := OrderHandlingHelper.CreateShopifyOrderAsJson(Shop, OrdersToImport, JShopifyLineItems);
        ImportShopifyOrder(Shop, OrderHeader, OrdersToImport, ImportOrder, JShopifyOrder, JShopifyLineItems);
    end;
}
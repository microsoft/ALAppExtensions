codeunit 139608 "Shpfy Orders API Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestExtractShopifyOrdersToImport()
    var
        ShpfyShop: Record "Shpfy Shop";
        ShpfyOrdersToImport: Record "Shpfy Orders to Import";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ShpfyOrderHandlingHelper: Codeunit "Shpfy Order Handling Helper";
        ShpfyOrdersAPI: Codeunit "Shpfy Orders API";
        Cursor: Text;
        JOrdersToImport: JsonObject;
    begin
        // [SCENARIO] Create a randpom expected Json structure for the OrdersToImport and see of all orders are available in the "Shpfy Orders to Import" table.
        // [SCENARIO] At start we reset the "Shpfy Orders to Import" table so we can see how many record are added.
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        Clear(ShpfyOrdersToImport);
        if not ShpfyOrdersToImport.IsEmpty then
            ShpfyOrdersToImport.DeleteAll();

        // [GIVEN] the shopify shop
        ShpfyShop := ShpfyCommunicationMgt.GetShopRecord();
        // [GIVEN] the orders to import as a json structure.
        JOrdersToImport := ShpfyOrderHandlingHelper.GetOrdersToImport();
        // [GIVEN] the cursor text varable for retreiving the last cursor.

        // [WHEN] Execute ShpfyOrdersAPI.ExtractShopifyOrdersToImport
        ShpfyOrdersAPI.ExtractShopifyOrdersToImport(ShpfyShop, JOrdersToImport, Cursor);
        // [THEN] The result must be true.
        LibraryAssert.IsTrue(ShpfyOrdersAPI.ExtractShopifyOrdersToImport(ShpfyShop, JOrdersToImport, Cursor), 'Extracting orders must return true.');

        // [THEN] The last cursor must have lenght of 92 characters.
        LibraryAssert.AreEqual(92, StrLen(Cursor), 'The cursor has a lenght of 92 characters');

        // [THEN] The number of orders that where imported must be the same as in the table "Shpfy Order to Import".
        LibraryAssert.AreEqual(ShpfyOrderHandlingHelper.CountOrdersToImport(JOrdersToImport), ShpfyOrdersToImport.Count, 'All orders to import are in the "Shpfy Orders to Import" table');
    end;

    [Test]
    procedure UnitTestImportShopifyOrder()
    var
        ShpfyShop: Record "Shpfy Shop";
        ShpfyOrderHeader: Record "Shpfy Order Header";
        ShpfyOrdersToImport: Record "Shpfy Orders to Import";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ShpfyImportOrder: codeunit "Shpfy Import Order";
        ShpfyOrderHandlingHelper: Codeunit "Shpfy Order Handling Helper";
        JShopifyOrder: JsonObject;
    begin
        // [SCENARIO] Import a Shopify order from the "Shpfy Orders to Import" record.
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        ShpfyImportOrder.SetTestInProgress(true);

        // [GIVEN] the shopify shop
        ShpfyShop := ShpfyCommunicationMgt.GetShopRecord();
        ShpfyShop."Customer Mapping Type" := "Shpfy Customer Mapping"::"By EMail/Phone";
        if not ShpfyShop.Modify() then
            ShpfyShop.Insert();
        ShpfyImportOrder.SetShop(ShpfyShop);

        // [GIVEN] the order to import as a json structure.
        JShopifyOrder := ShpfyOrderHandlingHelper.CreateShopifyOrderAsJson(ShpfyShop, ShpfyOrdersToImport);

        // [WHEN] ShpfyImportOrder.ImportOrder
        ShpfyImportOrder.ImportOrder(ShpfyOrdersToImport, ShpfyOrderHeader, JShopifyOrder);

        // [THEN] ShpfyOrdersToImport.Id = ShpfyOrderHeader."Shopify Order Id"
        LibraryAssert.AreEqual(ShpfyOrdersToImport.Id, ShpfyOrderHeader."Shopify Order Id", 'ShpfyOrdersToImport.Id = ShpfyOrderHeader."Shopify Order Id"');

        // [THEN] ShpfyOrdersToImport."Order No." = ShpfyOrderHeader."Shopify Order No."
        LibraryAssert.AreEqual(ShpfyOrdersToImport."Order No.", ShpfyOrderHeader."Shopify Order No.", 'ShpfyOrdersToImport."Order No." = ShpfyOrderHeader."Shopify Order No."');

        // [THEN] ShpfyOrdersToImport."Order Amount" = ShpfyOrderHeader."Total Amount"
        LibraryAssert.AreEqual(ShpfyOrdersToImport."Order Amount", ShpfyOrderHeader."Total Amount", 'ShpfyOrdersToImport."Order Amount" = ShpfyOrderHeader."Total Amount"');
    end;

    // [Test]
    procedure UnitTestDoMappingsonaShopifyOrder()
    var
        ShpfyShop: Record "Shpfy Shop";
        ShpfyOrderHeader: Record "Shpfy Order Header";
        ShpfyOrdersToImport: Record "Shpfy Orders to Import";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ShpfyOrderMapping: Codeunit "Shpfy Order Mapping";
        ShpfyImportOrder: codeunit "Shpfy Import Order";
        ShpfyOrderHandlingHelper: Codeunit "Shpfy Order Handling Helper";
        JShopifyOrder: JsonObject;
        Result: Boolean;
    begin
        // [SCENARION] Crating a random Shopify Order and try to map customer and product data.
        // [SCENARION] If everithing succeed the function will return true.
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        ShpfyImportOrder.SetTestInProgress(true);

        // [GIVEN] the shopify shop
        ShpfyShop := ShpfyCommunicationMgt.GetShopRecord();
        ShpfyShop."Customer Mapping Type" := "Shpfy Customer Mapping"::"By EMail/Phone";
        if not ShpfyShop.Modify() then
            ShpfyShop.Insert();
        ShpfyImportOrder.SetShop(ShpfyShop);

        // [GIVEN] ShpfyImportOrder.ImportOrder
        JShopifyOrder := ShpfyOrderHandlingHelper.CreateShopifyOrderAsJson(ShpfyShop, ShpfyOrdersToImport);
        ShpfyImportOrder.ImportOrder(ShpfyOrdersToImport, ShpfyOrderHeader, JShopifyOrder);

        // [WHEN] ShpfyOrderMapping.DoMapping(ShpfyOrderHeader)
        Result := ShpfyOrderMapping.DoMapping(ShpfyOrderHeader);

        // [THEN] The result must be true if everthing is mapped.
        LibraryAssert.IsTrue(Result, 'Order Mapping must succeed.');
    end;

    // [Test]
    procedure UnitTestImportShopifyOrderAndCreateSalesDocument()
    var
        ShpfyShop: Record "Shpfy Shop";
        ShpfyOrderHeader: Record "Shpfy Order Header";
        ShpfyOrdersToImport: Record "Shpfy Orders to Import";
        SalesHeader: Record "Sales Header";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ShpfyImportOrder: codeunit "Shpfy Import Order";
        ShpfyOrderHandlingHelper: Codeunit "Shpfy Order Handling Helper";
        ShpfyProcessOrders: Codeunit "Shpfy Process Orders";
        JShopifyOrder: JsonObject;
    begin
        // [SCENARION] Crating a random Shopify Order and try to map customer and product data.
        // [SCENARION] When the sales document is created, everything will be mapped and the sales document must exist.
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        ShpfyImportOrder.SetTestInProgress(true);

        // [GIVEN] the shopify shop
        ShpfyShop := ShpfyCommunicationMgt.GetShopRecord();
        ShpfyShop."Customer Mapping Type" := "Shpfy Customer Mapping"::"By EMail/Phone";
        if not ShpfyShop.Modify() then
            ShpfyShop.Insert();
        ShpfyImportOrder.SetShop(ShpfyShop);

        // [GIVEN] ShpfyImportOrder.ImportOrder
        JShopifyOrder := ShpfyOrderHandlingHelper.CreateShopifyOrderAsJson(ShpfyShop, ShpfyOrdersToImport);
        ShpfyImportOrder.ImportOrder(ShpfyOrdersToImport, ShpfyOrderHeader, JShopifyOrder);

        // [WHEN]
        ShpfyProcessOrders.ProcessShopifyOrder(ShpfyOrderHeader);
        ShpfyOrderHeader.Find();

        // [THEN] Sales document is created from Shopify order
        SalesHeader.SetRange("Shpfy Order Id", ShpfyOrderHeader."Shopify Order Id");
        LibraryAssert.IsTrue(SalesHeader.FindLast(), 'Sales document is created from Shopify order');

        case SalesHeader."Document Type" of
            "Sales Document Type"::Order:
                // [THEN] ShShpfyOrderHeader."Sales Order No." = SalesHeader."No."
                LibraryAssert.AreEqual(ShpfyOrderHeader."Sales Order No.", SalesHeader."No.", 'ShpfyOrderHeader."Sales Order No." = SalesHeader."No."');
            "Sales document Type"::Invoice:
                // [THEN] ShShpfyOrderHeader."Sales Invoice No." = SalesHeader."No."
                LibraryAssert.AreEqual(ShpfyOrderHeader."Sales Invoice No.", SalesHeader."No.", 'ShpfyOrderHeader."Sales Invoice No." = SalesHeader."No."');
            else
                Error('Invalid Document Type');
        end;
    end;

}
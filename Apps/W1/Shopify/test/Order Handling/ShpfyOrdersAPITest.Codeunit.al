codeunit 139608 "Shpfy Orders API Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        Any: Codeunit Any;

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
        Initialize();
        Clear(OrdersToImport);
        if not OrdersToImport.IsEmpty then
            OrdersToImport.DeleteAll();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();
        // [GIVEN] the orders to import as a json structure.
        JOrdersToImport := OrderHandlingHelper.GetOrdersToImport(false);
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
    procedure UnitTestExtractB2BShopifyOrdersToImport()
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
        Initialize();
        Clear(OrdersToImport);
        if not OrdersToImport.IsEmpty then
            OrdersToImport.DeleteAll();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();
        // [GIVEN] the orders to import as a json structure.
        JOrdersToImport := OrderHandlingHelper.GetOrdersToImport(true);
        // [GIVEN] the cursor text varable for retreiving the last cursor.

        // [WHEN] Execute ShpfyOrdersAPI.ExtractShopifyOrdersToImport
        OrdersAPI.ExtractShopifyOrdersToImport(Shop, JOrdersToImport, Cursor);
        // [THEN] The result must be true.
        LibraryAssert.IsTrue(OrdersAPI.ExtractShopifyOrdersToImport(Shop, JOrdersToImport, Cursor), 'Extracting orders must return true.');

        // [THEN] The number of orders with Purchasing Entity = Company that where imported must be the same as in the table "Shpfy Order to Import".
        OrdersToImport.SetRange("Purchasing Entity", OrdersToImport."Purchasing Entity"::Company);
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
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Customer Mapping Type" := "Shpfy Customer Mapping"::"By EMail/Phone";
        if not Shop.Modify() then
            Shop.Insert();
        ImportOrder.SetShop(Shop.Code);

        // [GIVEN] the order to import as a json structure.
        JShopifyOrder := OrderHandlingHelper.CreateShopifyOrderAsJson(Shop, OrdersToImport, JShopifyLineItems, false);

        // [WHEN] ShpfyImportOrder.ImportOrder
        ImportShopifyOrder(Shop, OrderHeader, OrdersToImport, ImportOrder, JShopifyOrder, JShopifyLineItems);

        // [THEN] ShpfyOrdersToImport.Id = ShpfyOrderHeader."Shopify Order Id"
        LibraryAssert.AreEqual(OrdersToImport.Id, OrderHeader."Shopify Order Id", 'ShpfyOrdersToImport.Id = ShpfyOrderHeader."Shopify Order Id"');

        // [THEN] ShpfyOrdersToImport."Order No." = ShpfyOrderHeader."Shopify Order No."
        LibraryAssert.AreEqual(OrdersToImport."Order No.", OrderHeader."Shopify Order No.", 'ShpfyOrdersToImport."Order No." = ShpfyOrderHeader."Shopify Order No."');

        // [THEN] ShpfyOrdersToImport."Order Amount" = ShpfyOrderHeader."Total Amount"
        LibraryAssert.AreEqual(OrdersToImport."Order Amount", OrderHeader."Total Amount", 'ShpfyOrdersToImport."Order Amount" = ShpfyOrderHeader."Total Amount"');
    end;

    [Test]
    procedure UnitTestImportB2BShopifyOrder()
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
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Company Mapping Type" := "Shpfy Company Mapping"::"By EMail/Phone";
        if not Shop.Modify() then
            Shop.Insert();
        ImportOrder.SetShop(Shop.Code);

        // [GIVEN] the order to import as a json structure.
        JShopifyOrder := OrderHandlingHelper.CreateShopifyOrderAsJson(Shop, OrdersToImport, JShopifyLineItems, true);

        // [WHEN] ShpfyImportOrder.ImportOrder
        ImportShopifyOrder(Shop, OrderHeader, OrdersToImport, ImportOrder, JShopifyOrder, JShopifyLineItems);

        // [THEN] ShpfyOrdersToImport.Id = ShpfyOrderHeader."Shopify Order Id"
        LibraryAssert.AreEqual(OrdersToImport.Id, OrderHeader."Shopify Order Id", 'ShpfyOrdersToImport.Id = ShpfyOrderHeader."Shopify Order Id"');

        // [THEN] ShpfyOrdersToImport."Order No." = ShpfyOrderHeader."Shopify Order No."
        LibraryAssert.AreEqual(OrdersToImport."Order No.", OrderHeader."Shopify Order No.", 'ShpfyOrdersToImport."Order No." = ShpfyOrderHeader."Shopify Order No."');

        // [THEN] ShpfyOrderHeader.B2B = true
        LibraryAssert.IsTrue(OrderHeader.B2B, 'ShpfyOrderHeader.B2B = true');

        // [THEN] ShpfyOrderHeader."Company Id" is not empty
        LibraryAssert.AreNotEqual(OrderHeader."Company Id", '', 'ShpfyOrderHeader."Company Id" is not empty');
    end;

    [Test]
    procedure UnitTestDoMappingsOnAShopifyOrder()
    var
        Shop: Record "Shpfy Shop";
        OrderHeader: Record "Shpfy Order Header";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        OrderMapping: Codeunit "Shpfy Order Mapping";
        ImportOrder: Codeunit "Shpfy Import Order";
        Result: Boolean;
    begin
        // [SCENARIO] Creating a random Shopify Order and try to map customer and product data.
        // [SCENARIO] If everithing succeed the function will return true.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Customer Mapping Type" := "Shpfy Customer Mapping"::"By EMail/Phone";
        if not Shop.Modify() then
            Shop.Insert();
        ImportOrder.SetShop(Shop.Code);

        // [GIVEN] ShpfyImportOrder.ImportOrder
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder, false);

        // [WHEN] ShpfyOrderMapping.DoMapping(ShpfyOrderHeader)
        Result := OrderMapping.DoMapping(OrderHeader);

        // [THEN] The result must be true if everthing is mapped.
        LibraryAssert.IsTrue(Result, 'Order Mapping must succeed.');
    end;

    [Test]
    procedure UnitTestDoMappingsOnAB2BShopifyOrder()
    var
        Shop: Record "Shpfy Shop";
        OrderHeader: Record "Shpfy Order Header";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        OrderMapping: Codeunit "Shpfy Order Mapping";
        ImportOrder: Codeunit "Shpfy Import Order";
        Result: Boolean;
    begin
        // [SCENARIO] Creating a random Shopify Order and try to map customer and product data.
        // [SCENARIO] If everithing succeed the function will return true.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Company Mapping Type" := "Shpfy Company Mapping"::"By EMail/Phone";
        if not Shop.Modify() then
            Shop.Insert();
        ImportOrder.SetShop(Shop.Code);

        // [GIVEN] ShpfyImportOrder.ImportOrder
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder, true);

        // [WHEN] ShpfyOrderMapping.DoMapping(ShpfyOrderHeader)
        Result := OrderMapping.DoMapping(OrderHeader);

        // [THEN] The result must be true if everthing is mapped.
        LibraryAssert.IsTrue(Result, 'Order Mapping must succeed.');
    end;

    [Test]
    procedure UnitTestImportShopifyOrderAndCreateSalesDocument()
    var
        Shop: Record "Shpfy Shop";
        OrderHeader: Record "Shpfy Order Header";
        SalesHeader: Record "Sales Header";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ImportOrder: Codeunit "Shpfy Import Order";
        ProcessOrders: Codeunit "Shpfy Process Orders";
    begin
        // [SCENARIO] Creating a random Shopify Order and try to map customer and product data.
        // [SCENARIO] When the sales document is created, everything will be mapped and the sales document must exist.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Customer Mapping Type" := "Shpfy Customer Mapping"::"By EMail/Phone";
        if not Shop.Modify() then
            Shop.Insert();
        ImportOrder.SetShop(Shop.Code);

        // [GIVEN] ShpfyImportOrder.ImportOrder
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder, false);
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

    [Test]
    procedure UnitTestImportB2BShopifyOrderAndCreateSalesDocument()
    var
        Shop: Record "Shpfy Shop";
        OrderHeader: Record "Shpfy Order Header";
        SalesHeader: Record "Sales Header";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ImportOrder: Codeunit "Shpfy Import Order";
        ProcessOrders: Codeunit "Shpfy Process Orders";
    begin
        // [SCENARIO] Creating a random Shopify Order and try to map customer and product data.
        // [SCENARIO] When the sales document is created, everything will be mapped and the sales document must exist.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Customer Mapping Type" := "Shpfy Customer Mapping"::"By EMail/Phone";
        if not Shop.Modify() then
            Shop.Insert();
        ImportOrder.SetShop(Shop.Code);

        // [GIVEN] ShpfyImportOrder.ImportOrder
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder, true);
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

    [Test]
    procedure UnitTestCreateSalesDocumentTaxPriorityCode()
    var
        Shop: Record "Shpfy Shop";
        OrderHeader: Record "Shpfy Order Header";
        SalesHeader: Record "Sales Header";
        TaxArea: Record "Tax Area";
        ShopifyTaxArea: Record "Shpfy Tax Area";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ImportOrder: Codeunit "Shpfy Import Order";
        ProcessOrders: Codeunit "Shpfy Process Orders";
    begin
        // [SCENARIO] When the sales document is created, tax priority is taken from the shop.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Tax Area Priority" := Shop."Tax Area Priority"::"Ship-to -> Sell-to -> Bill-to";
        Shop."County Source" := Shop."County Source"::"Code";
        if not Shop.Modify() then
            Shop.Insert();
        ImportOrder.SetShop(Shop.Code);

        // [GIVEN] Shopify Tax Area and BC Tax Area
        CreateTaxArea(TaxArea, ShopifyTaxArea, Shop);

        // [GIVEN] ShpfyImportOrder.ImportOrder
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder, false);
        OrderHeader."Ship-to City" := ShopifyTaxArea.County;
        OrderHeader."Ship-to Country/Region Code" := ShopifyTaxArea."Country/Region Code";
        OrderHeader."Ship-to County" := ShopifyTaxArea."County Code";
        OrderHeader.Modify();
        Commit();

        // [WHEN] Order is processed
        ProcessOrders.ProcessShopifyOrder(OrderHeader);
        OrderHeader.Find();

        // [THEN] Sales document is created from Shopify order with correct tax area
        SalesHeader.SetRange("Shpfy Order Id", OrderHeader."Shopify Order Id");
        LibraryAssert.IsTrue(SalesHeader.FindLast(), 'Sales document is created from Shopify order');
        LibraryAssert.AreEqual(SalesHeader."Tax Area Code", TaxArea.Code, 'Tax Area Code is taken from the ship-to address');
    end;

    [Test]
    procedure UnitTestCreateSalesDocumentTaxPriorityName()
    var
        Shop: Record "Shpfy Shop";
        OrderHeader: Record "Shpfy Order Header";
        SalesHeader: Record "Sales Header";
        TaxArea: Record "Tax Area";
        ShopifyTaxArea: Record "Shpfy Tax Area";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ImportOrder: Codeunit "Shpfy Import Order";
        ProcessOrders: Codeunit "Shpfy Process Orders";
    begin
        // [SCENARIO] When the sales document is created, tax priority is taken from the shop
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Tax Area Priority" := Shop."Tax Area Priority"::"Sell-to -> Ship-to -> Bill-to";
        Shop."County Source" := Shop."County Source"::"Name";
        if not Shop.Modify() then
            Shop.Insert();
        ImportOrder.SetShop(Shop.Code);

        // [GIVEN] Shopify Tax Area and BC Tax Area
        CreateTaxArea(TaxArea, ShopifyTaxArea, Shop);

        // [GIVEN] ShpfyImportOrder.ImportOrder
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder, false);
        OrderHeader."Sell-to City" := ShopifyTaxArea.County;
        OrderHeader."Sell-to Country/Region Code" := ShopifyTaxArea."Country/Region Code";
        OrderHeader."Sell-to County" := CopyStr(ShopifyTaxArea.County, 1, MaxStrLen(OrderHeader."Sell-to County"));
        OrderHeader.Modify();
        Commit();

        // [WHEN] Order is processed
        ProcessOrders.ProcessShopifyOrder(OrderHeader);
        OrderHeader.Find();

        // [THEN] Sales document is created from Shopify order with correct tax area
        SalesHeader.SetRange("Shpfy Order Id", OrderHeader."Shopify Order Id");
        LibraryAssert.IsTrue(SalesHeader.FindLast(), 'Sales document is created from Shopify order');
        LibraryAssert.AreEqual(SalesHeader."Tax Area Code", TaxArea.Code, 'Tax Area Code is taken from the sell-to address');
    end;

    [Test]
    procedure UnitTestCreateSalesDocumentTaxPriorityEmpty()
    var
        Shop: Record "Shpfy Shop";
        OrderHeader: Record "Shpfy Order Header";
        SalesHeader: Record "Sales Header";
        TaxArea: Record "Tax Area";
        ShopifyTaxArea: Record "Shpfy Tax Area";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ImportOrder: Codeunit "Shpfy Import Order";
        ProcessOrders: Codeunit "Shpfy Process Orders";
    begin
        // [SCENARIO] When the sales document is created, tax area is empty if there is no mapping
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Tax Area Priority" := Shop."Tax Area Priority"::"Ship-to -> Sell-to -> Bill-to";
        Shop."County Source" := Shop."County Source"::"Code";
        if not Shop.Modify() then
            Shop.Insert();
        ImportOrder.SetShop(Shop.Code);

        // [GIVEN] Shopify Tax Area and BC Tax Area
        CreateTaxArea(TaxArea, ShopifyTaxArea, Shop);

        // [GIVEN] ShpfyImportOrder.ImportOrder
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder, false);
        OrderHeader."Ship-to City" := ShopifyTaxArea.County;
        OrderHeader."Ship-to Country/Region Code" := ShopifyTaxArea."Country/Region Code";
        OrderHeader."Ship-to County" := ShopifyTaxArea."County Code";
        OrderHeader.Modify();

        // [GIVEN] Delete tax area mapping
        ShopifyTaxArea.Delete();
        Commit();

        // [WHEN] Order is processed
        ProcessOrders.ProcessShopifyOrder(OrderHeader);
        OrderHeader.Find();

        // [THEN] Sales document is created from Shopify order with correct tax area
        SalesHeader.SetRange("Shpfy Order Id", OrderHeader."Shopify Order Id");
        LibraryAssert.IsTrue(SalesHeader.FindLast(), 'Sales document is created from Shopify order');
        LibraryAssert.AreEqual(SalesHeader."Tax Area Code", '', 'Tax Area Code is empty');
    end;

    [Test]
    procedure UnitTestCreateSalesDocumentReserve()
    var
        Shop: Record "Shpfy Shop";
        OrderHeader: Record "Shpfy Order Header";
        OrderLine: Record "Shpfy Order Line";
        SalesHeader: Record "Sales Header";
        ShopifyCustomer: Record "Shpfy Customer";
        Customer: Record Customer;
        Item: Record Item;
        ShopifyVariant: Record "Shpfy Variant";
        SalesLine: Record "Sales Line";
        ItemJournalLine: Record "Item Journal Line";
        ProcessOrders: Codeunit "Shpfy Process Orders";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        OrderHeaderId: BigInteger;
    begin
        // [SCENARIO] If a customer has the reserve option set to always, the order line will be reserved
        Initialize();

        // [GIVEN] A Shopify sales order
        Shop := CommunicationMgt.GetShopRecord();
        LibrarySales.CreateCustomer(Customer);
        Customer.Reserve := Customer.Reserve::Always;
        Customer.Modify();

        ShopifyCustomer.Id := LibraryRandom.RandIntInRange(100000, 999999);
        ShopifyCustomer."Customer SystemId" := Customer.SystemId;
        ShopifyCustomer."Shop Id" := Shop."Shop Id";
        ShopifyCustomer.Insert();

        OrderHeader."Customer Id" := ShopifyCustomer.Id;
        OrderHeader."Shop Code" := Shop.Code;
        OrderHeader."Shopify Order Id" := LibraryRandom.RandIntInRange(100000, 999999);
        OrderHeaderId := OrderHeader."Shopify Order Id";
        OrderHeader.Insert();

        LibraryInventory.CreateItem(Item);
        LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, Item."No.", '', '', 10);
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
        ShopifyVariant."Item SystemId" := Item.SystemId;
        ShopifyVariant.Id := LibraryRandom.RandIntInRange(100000, 999999);
        ShopifyVariant."Shop Code" := Shop.Code;
        ShopifyVariant.Insert();
        OrderLine."Shopify Order Id" := OrderHeader."Shopify Order Id";
        OrderLine."Shopify Variant Id" := ShopifyVariant.Id;
        OrderLine.Quantity := 1;
        OrderLine.Insert();
        Commit();

        // [WHEN] Order is processed
        ProcessOrders.ProcessShopifyOrder(OrderHeader);

        // [THEN] Sales document is created from Shopify order and order line is reserved
        SalesHeader.SetRange("Shpfy Order Id", OrderHeaderId);
        LibraryAssert.IsTrue(SalesHeader.FindLast(), 'Sales document is created from Shopify order');
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("No.", Item."No.");
        SalesLine.FindFirst();
        SalesLine.CalcFields("Reserved Quantity");
        LibraryAssert.AreNotEqual(SalesLine."Reserved Quantity", 0, 'Order line is reserved');
    end;

    local procedure CreateTaxArea(var TaxArea: Record "Tax Area"; var ShopifyTaxArea: Record "Shpfy Tax Area"; Shop: Record "Shpfy Shop")
    var
        ShopifyCustomerTemplate: Record "Shpfy Customer Template";
        CountryRegion: Record "Country/Region";
        CountryRegionCode: Code[20];
        CountyCode: Code[2];
        County: Text[30];
    begin
        CountryRegion.FindFirst();
        CountryRegionCode := CountryRegion.Code;
        Evaluate(CountyCode, Any.AlphabeticText(MaxStrLen(CountyCode)));
        County := CopyStr(Any.AlphabeticText(MaxStrLen(County)), 1, MaxStrLen(County));
        ShopifyCustomerTemplate."Shop Code" := Shop.Code;
        ShopifyCustomerTemplate."Country/Region Code" := CountryRegionCode;
        if ShopifyCustomerTemplate.Insert() then;
        ShopifyTaxArea."Country/Region Code" := CountryRegionCode;
        ShopifyTaxArea."County Code" := CountyCode;
        ShopifyTaxArea.County := County;
        ShopifyTaxArea."Tax Area Code" := CountyCode;
        if ShopifyTaxArea.Insert() then;
        TaxArea.Code := CountyCode;
        if TaxArea.Insert() then;
    end;

    local procedure ImportShopifyOrder(var Shop: Record "Shpfy Shop"; var OrderHeader: Record "Shpfy Order Header"; var OrdersToImport: Record "Shpfy Orders to Import"; var ImportOrder: Codeunit "Shpfy Import Order"; var JShopifyOrder: JsonObject; var JShopifyLineItems: JsonArray)
    var
    begin
        ImportOrder.ImportCreateAndUpdateOrderHeaderFromMock(Shop.Code, OrdersToImport.Id, JShopifyOrder);
        ImportOrder.ImportCreateAndUpdateOrderLinesFromMock(OrdersToImport.Id, JShopifyLineItems);
        Commit();
        OrderHeader.Get(OrdersToImport.Id);
    end;

    local procedure ImportShopifyOrder(var Shop: Record "Shpfy Shop"; var OrderHeader: Record "Shpfy Order Header"; var ImportOrder: Codeunit "Shpfy Import Order"; B2B: Boolean)
    var
        OrdersToImport: Record "Shpfy Orders to Import";
        OrderHandlingHelper: Codeunit "Shpfy Order Handling Helper";
        JShopifyOrder: JsonObject;
        JShopifyLineItems: JsonArray;
    begin
        JShopifyOrder := OrderHandlingHelper.CreateShopifyOrderAsJson(Shop, OrdersToImport, JShopifyLineItems, B2B);
        ImportShopifyOrder(Shop, OrderHeader, OrdersToImport, ImportOrder, JShopifyOrder, JShopifyLineItems);
    end;

    local procedure Initialize()
    var
        OrdersAPISubscriber: Codeunit "Shpfy Orders API Subscriber";
    begin
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        if BindSubscription(OrdersAPISubscriber) then;
    end;
}
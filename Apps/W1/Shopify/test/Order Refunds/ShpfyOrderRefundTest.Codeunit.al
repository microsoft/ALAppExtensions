codeunit 139611 "Shpfy Order Refund Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        LibraryAssert: Codeunit "Library Assert";
        Any: Codeunit Any;
        ShopifyIds: Dictionary of [Text, List of [BigInteger]];
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        // [FEATURE] [Account Schedule] [Chart]
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestCreateCrMemoFromRefundWithFullyRefundedItem()
    var
        SalesHeader: Record "Sales Header";
        RefundHeader: Record "Shpfy Refund Header";
        RefundId: BigInteger;
        IReturnRefundProcess: Interface "Shpfy IReturnRefund Process";
        CanCreateDocument: boolean;
        ErrorInfo: ErrorInfo;
    begin
        // [SCENARIO] Create a Credit Memo from a Shopify Refund where the item is totally refunded.
        Initialize();

        // [GIVEN] Set the process of the document: "Auto Create Credit Memo";
        IReturnRefundProcess := Enum::"Shpfy ReturnRefund ProcessType"::"Auto Create Credit Memo";
        // [GIVEN] The document type Refund
        // [GIVEN] The RefundId of the refund for creating the credit Memo.
        RefundId := ShopifyIds.Get('Refund').Get(1);

        // [WHEN] Execute IReturnRefundProcess.CanCreateSalesDocumentFor(enum::"Shpfy Source Document Type"::Refund, RefundId, errorInfo)
        CanCreateDocument := IReturnRefundProcess.CanCreateSalesDocumentFor(enum::"Shpfy Source Document Type"::Refund, RefundId, errorInfo);
        // [THEN] CancreateDocument must be true
        LibraryAssert.IsTrue(CanCreateDocument, 'The result of IReturnRefundProcess.CanCreateSalesDocumentFor must be true');

        // [WHEN] Execute IReturnRefundProcess.CreateSalesDocument(Enum::"Shpfy Source Document Type"::Refund, RefundId)
        SalesHeader := IReturnRefundProcess.CreateSalesDocument(Enum::"Shpfy Source Document Type"::Refund, RefundId);
        // [THEN] SalesHeader."Document Type" = Enum::"Sales Document Type"::"Credit Memo"
        LibraryAssert.AreEqual(Enum::"Sales Document Type"::"Credit Memo", SalesHeader."Document Type", 'SalesHeader."Document Type" must be a Credit Memo');
        // [THEN] Test if SalesHeader."Amount Including VAT" is equal to RefundHeader."Total Refunded Amount"
        RefundHeader.Get(RefundId);
        SalesHeader.CalcFields("Amount Including VAT");
        LibraryAssert.AreEqual(RefundHeader."Total Refunded Amount", SalesHeader."Amount Including VAT", 'The SalesHeader."Amount Including VAT" must be equal to RefundHeader."Total Refunded Amount".');
        // Tear down
        ResetProccesOnRefund(RefundId);
    end;

    [Test]
    procedure UnitTestCreateCrMemoFromRefundForOnlyShipment()
    var
        SalesHeader: Record "Sales Header";
        RefundHeader: Record "Shpfy Refund Header";
        RefundId: BigInteger;
        IReturnRefundProcess: Interface "Shpfy IReturnRefund Process";
        CanCreateDocument: boolean;
        ErrorInfo: ErrorInfo;
    begin
        // [SCENARIO] Create a Credit Memo from a Shopify Refund where only the shipment is refunded.
        Initialize();

        // [GIVEN] Set the process of the document: "Auto Create Credit Memo";
        IReturnRefundProcess := Enum::"Shpfy ReturnRefund ProcessType"::"Auto Create Credit Memo";
        // [GIVEN] The document type Refund
        // [GIVEN] The RefundId of the refund for creating the credit Memo.
        RefundId := ShopifyIds.Get('Refund').Get(2);

        // [WHEN] Execute IReturnRefundProcess.CanCreateSalesDocumentFor(enum::"Shpfy Source Document Type"::Refund, RefundId, errorInfo)
        CanCreateDocument := IReturnRefundProcess.CanCreateSalesDocumentFor(enum::"Shpfy Source Document Type"::Refund, RefundId, errorInfo);
        // [THEN] CancreateDocument must be true
        LibraryAssert.IsTrue(CanCreateDocument, 'The result of IReturnRefundProcess.CanCreateSalesDocumentFor must be true');

        // [WHEN] Execute IReturnRefundProcess.CreateSalesDocument(Enum::"Shpfy Source Document Type"::Refund, RefundId)
        SalesHeader := IReturnRefundProcess.CreateSalesDocument(Enum::"Shpfy Source Document Type"::Refund, RefundId);
        // [THEN] SalesHeader."Document Type" = Enum::"Sales Document Type"::"Credit Memo"
        LibraryAssert.AreEqual(Enum::"Sales Document Type"::"Credit Memo", SalesHeader."Document Type", 'SalesHeader."Document Type" must be a Credit Memo');
        // [THEN] Test if SalesHeader."Amount Including VAT" is equal to RefundHeader."Total Refunded Amount"
        RefundHeader.Get(RefundId);
        SalesHeader.CalcFields("Amount Including VAT");
        LibraryAssert.AreNearlyEqual(RefundHeader."Total Refunded Amount", SalesHeader."Amount Including VAT", 0.5, 'The SalesHeader."Amount Including VAT" must be equal to RefundHeader."Total Refunded Amount".');
        // Tear down
        ResetProccesOnRefund(RefundId);
    end;

    [Test]
    procedure UnitTestCreateCrMemoFromRefundWithNotRefundedItem()
    var
        SalesHeader: Record "Sales Header";
        RefundHeader: Record "Shpfy Refund Header";
        RefundId: BigInteger;
        IReturnRefundProcess: Interface "Shpfy IReturnRefund Process";
        CanCreateDocument: boolean;
        ErrorInfo: ErrorInfo;
    begin
        // [SCENARIO] Create a Credit Memo from a Shopify Refund where the item is not refunded.
        Initialize();

        // [GIVEN] Set the process of the document: "Auto Create Credit Memo";
        IReturnRefundProcess := Enum::"Shpfy ReturnRefund ProcessType"::"Auto Create Credit Memo";
        // [GIVEN] The document type Refund
        // [GIVEN] The RefundId of the refund for creating the credit Memo.
        RefundId := ShopifyIds.Get('Refund').Get(1);

        // [WHEN] Execute IReturnRefundProcess.CanCreateSalesDocumentFor(enum::"Shpfy Source Document Type"::Refund, RefundId, errorInfo)
        CanCreateDocument := IReturnRefundProcess.CanCreateSalesDocumentFor(enum::"Shpfy Source Document Type"::Refund, RefundId, errorInfo);
        // [THEN] CancreateDocument must be true
        LibraryAssert.IsTrue(CanCreateDocument, 'The result of IReturnRefundProcess.CanCreateSalesDocumentFor must be true');

        // [WHEN] Execute IReturnRefundProcess.CreateSalesDocument(Enum::"Shpfy Source Document Type"::Refund, RefundId)
        SalesHeader := IReturnRefundProcess.CreateSalesDocument(Enum::"Shpfy Source Document Type"::Refund, RefundId);
        // [THEN] SalesHeader."Document Type" = Enum::"Sales Document Type"::"Credit Memo"
        LibraryAssert.AreEqual(Enum::"Sales Document Type"::"Credit Memo", SalesHeader."Document Type", 'SalesHeader."Document Type" must be a Credit Memo');
        // [THEN] Test if SalesHeader."Amount Including VAT" is equal to RefundHeader."Total Refunded Amount"
        RefundHeader.Get(RefundId);
        SalesHeader.CalcFields("Amount Including VAT");
        LibraryAssert.AreEqual(RefundHeader."Total Refunded Amount", SalesHeader."Amount Including VAT", 'The SalesHeader."Amount Including VAT" must be equal to RefundHeader."Total Refunded Amount".');

        // Tear down
        ResetProccesOnRefund(RefundId);
    end;

    [Test]
    procedure UnitTestCanCreateCreditMemo()
    var
        RefundsAPI: Codeunit "Shpfy Refunds API";
        RefundId1: BigInteger;
        RefundId2: BigInteger;
        RefundId3: BigInteger;
    begin
        // [SCENARIO] Can create credit memo check returns
        // Non-zero refund = true
        // Linked return refund = true
        // Zero and not linked refund = false
        Initialize();

        // [GIVEN] Non-zero refund
        RefundId1 := ShopifyIds.Get('Refund').Get(5);
        // [GIVEN] Linked return refund
        RefundId2 := ShopifyIds.Get('Refund').Get(4);
        // [GIVEN] Zero and not linked refund
        RefundId3 := ShopifyIds.Get('Refund').Get(6);

        // [WHEN] Execute VerifyRefundCanCreateCreditMemo
        RefundsAPI.VerifyRefundCanCreateCreditMemo(RefundId1);
        RefundsAPI.VerifyRefundCanCreateCreditMemo(RefundId2);
        asserterror RefundsAPI.VerifyRefundCanCreateCreditMemo(RefundId3);

        // [THEN] Only RefundId3 throws an error
        LibraryAssert.ExpectedError('The refund imported from Shopify can''t be used to create a credit memo. Only refunds for paid items can be used to create credit memos.');
    end;

    [Test]
    procedure UnitTestFillInRefundLineWithLocation()
    var
        RefundLine: Record "Shpfy Refund Line";
        RefundsAPI: Codeunit "Shpfy Refunds API";
        OrderRefundsHelper: Codeunit "Shpfy Order Refunds Helper";
        RefundId: BigInteger;
        JRefundLine: JsonObject;
        ReturnLocations: Dictionary of [BigInteger, BigInteger];
        RefundLocationId: BigInteger;
        RefundLineId: BigInteger;
    begin
        // [SCENARIO] Import refund lines with location
        Initialize();

        // [GIVEN] Refund Header
        RefundId := OrderRefundsHelper.CreateRefundHeader();
        // [GIVEN] Refund Line  response
        RefundLocationId := Any.IntegerInRange(100000, 999999);
        RefundLineId := Any.IntegerInRange(100000, 999999);
        CreateRefundLineResponse(JRefundLine, RefundLineId, RefundLocationId);

        // [WHEN] Execute RefundsAPI.FillInRefundLine
        RefundsAPI.FillInRefundLine(RefundId, JRefundLine, false, ReturnLocations);

        // [THEN] Refund Line with location is created
        LibraryAssert.IsTrue(RefundLine.Get(RefundId, RefundLineId), 'Refund line not creatred');
        LibraryAssert.AreEqual(RefundLocationId, RefundLine."Location Id", 'Refund line location not set');
    end;

    [Test]
    procedure UnitTestFillInRefundLineWithReturnLocations()
    var
        RefundLine: Record "Shpfy Refund Line";
        RefundsAPI: Codeunit "Shpfy Refunds API";
        OrderRefundsHelper: Codeunit "Shpfy Order Refunds Helper";
        RefundId: BigInteger;
        JRefundLine: JsonObject;
        ReturnLocations: Dictionary of [BigInteger, BigInteger];
        RefundLineId: BigInteger;
        ReturnLocationId: BigInteger;
    begin
        // [SCENARIO] Import refund lines with locations
        Initialize();

        // [GIVEN] Refund Header
        RefundId := OrderRefundsHelper.CreateRefundHeader();
        // [GIVEN] Refund Line  response
        RefundLineId := Any.IntegerInRange(100000, 999999);
        CreateRefundLineResponse(JRefundLine, RefundLineId, 0);
        //[GIVEN] Return Locations
        ReturnLocationId := Any.IntegerInRange(100000, 999999);
        ReturnLocations.Add(RefundLineId, ReturnLocationId);

        // [WHEN] Execute RefundsAPI.FillInRefundLine
        RefundsAPI.FillInRefundLine(RefundId, JRefundLine, false, ReturnLocations);

        // [THEN] Refund Line with location is created
        LibraryAssert.IsTrue(RefundLine.Get(RefundId, RefundLineId), 'Refund line not creatred');
        LibraryAssert.AreEqual(ReturnLocationId, RefundLine."Location Id", 'Refund line location not set');
    end;

    [Test]
    procedure UnitTestCreateSalesOrderLineFromRefundWithDefaultLocation()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Shop: Record "Shpfy Shop";
        Location: Record Location;
        OrderRefundsHelper: Codeunit "Shpfy Order Refunds Helper";
        IReturnRefundProcess: Interface "Shpfy IReturnRefund Process";
        RefundId: BigInteger;
        OrderId, OrderLineId : BigInteger;
        ReturnId: BigInteger;
    begin
        // [SCENARIO] Create sales credit memo line from refund with default location
        Initialize();

        // [GIVEN] Location
        CreateLocation(Location);

        // [GIVEN] Shop with setup to use default return location
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Return Location Priority" := Enum::"Shpfy Return Location Priority"::"Default Return Location";
        Shop."Return Location" := Location.Code;
        Shop.Modify(false);

        //[GIVEN] Processed Shopify Order
        CerateProcessedShopifyOrder(OrderId, OrderLineId);
        // [GIVEN] Shopify Return
        CreateShopifyReturn(ReturnId, OrderId);
        // [GIVEN] Refund Header
        RefundId := OrderRefundsHelper.CreateRefundHeader(OrderId, ReturnId, 156.38, Shop.Code);
        // [GIVEN] Refund line without location
        OrderRefundsHelper.CreateRefundLine(RefundId, OrderLineId, 0);

        // [WHEN] Execute create credit memo
        IReturnRefundProcess := Enum::"Shpfy ReturnRefund ProcessType"::"Auto Create Credit Memo";
        SalesHeader := IReturnRefundProcess.CreateSalesDocument(Enum::"Shpfy Source Document Type"::Refund, RefundId);

        // [THEN] Credit Memo Line with default location is created
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LibraryAssert.AreEqual(Location.Code, SalesLine."Location Code", 'Sales line location not set');
    end;

    [Test]
    procedure UnitTestCreateSalesCrMemoLineFromRefundWithReturnLocation()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Shop: Record "Shpfy Shop";
        Location: Record Location;
        OrderRefundsHelper: Codeunit "Shpfy Order Refunds Helper";
        IReturnRefundProcess: Interface "Shpfy IReturnRefund Process";
        RefundId: BigInteger;
        OrderId, OrderLineId : BigInteger;
        ReturnId: BigInteger;
        LocationId: BigInteger;
    begin
        // [SCENARIO] Create sales credit memo line from refund with return location
        Initialize();

        // [GIVEN] Shop with setup to use original return location
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Return Location Priority" := Enum::"Shpfy Return Location Priority"::"Original -> Default Location";
        Shop."Return Location" := '';
        Shop.Modify(false);
        // [GIVEN] Location
        CreateLocation(Location);
        // [GIVEN] Shop Location
        LocationId := CreateShopLocation(Shop.Code, Location.Code);
        //[GIVEN] Processed Shopify Order
        CerateProcessedShopifyOrder(OrderId, OrderLineId);
        // [GIVEN] Shopify Return
        CreateShopifyReturn(ReturnId, OrderId);
        // [GIVEN] Refund Header
        RefundId := OrderRefundsHelper.CreateRefundHeader(OrderId, ReturnId, 156.38, Shop.Code);
        // [GIVEN] Refund line without location
        OrderRefundsHelper.CreateRefundLine(RefundId, OrderLineId, LocationId);

        // [WHEN] Execute create credit memo
        IReturnRefundProcess := Enum::"Shpfy ReturnRefund ProcessType"::"Auto Create Credit Memo";
        SalesHeader := IReturnRefundProcess.CreateSalesDocument(Enum::"Shpfy Source Document Type"::Refund, RefundId);

        // [THEN] Credit Memo Line with return location is created
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LibraryAssert.AreEqual(Location.Code, SalesLine."Location Code", 'Sales line location not set');
    end;

    local procedure Initialize()
    var
        OrderRefundsHelper: Codeunit "Shpfy Order Refunds Helper";
    begin
        Any.SetDefaultSeed();

        if IsInitialized then
            exit;

        ShpfyInitializeTest.Run();
        ShopifyIds := OrderRefundsHelper.CreateShopifyDocuments();

        IsInitialized := true;
        Commit();
    end;

    local procedure ResetProccesOnRefund(ReFundId: Integer)
    var
        ShpfyDocLinkToDoc: Record "Shpfy Doc. Link To Doc.";
    begin
        ShpfyDocLinkToDoc.SetRange("Shopify Document Type", ShpfyDocLinkToDoc."Shopify Document Type"::"Shopify Shop Refund");
        ShpfyDocLinkToDoc.SetRange("Shopify Document Id", ReFundId);
        ShpfyDocLinkToDoc.DeleteAll();
    end;

    local procedure CreateRefundLineResponse(var JRefundLine: JsonObject; RefundLineId: BigInteger; RefundLocationId: BigInteger)
    begin
        JRefundLine.ReadFrom(StrSubstNo('{"lineItem": {"id": "gid://shopify/LineItem/%1"}, "quantity": 1, "restockType": "no_restock", "location": {"legacyResourceId": %2}}', RefundLineId, RefundLocationId));
    end;

    local procedure CerateProcessedShopifyOrder(var OrderId: BigInteger; var OrderLineId: BigInteger)
    var
        OrderRefundsHelper: Codeunit "Shpfy Order Refunds Helper";
    begin
        OrderRefundsHelper.SetDefaultSeed();
        OrderId := OrderRefundsHelper.CreateShopifyOrder();
        OrderLineId := OrderRefundsHelper.CreateOrderLine(OrderId, 10000, Any.IntegerInRange(100000, 999999), Any.IntegerInRange(100000, 999999));
        OrderRefundsHelper.ProcessShopifyOrder(OrderId);
    end;

    local procedure CreateShopifyReturn(var ReturnId: BigInteger; OrderId: BigInteger)
    var
        OrderRefundsHelper: Codeunit "Shpfy Order Refunds Helper";
    begin
        OrderRefundsHelper.SetDefaultSeed();
        ReturnId := OrderRefundsHelper.CreateReturn(OrderId);
        OrderRefundsHelper.CreateReturnLine(ReturnId, OrderId, '');
    end;

    local procedure CreateLocation(var Location: Record Location)
    begin
        Location.Init();
        Location.Code := Any.AlphanumericText(10);
        Location.Insert();
    end;

    local procedure CreateShopLocation(ShopCode: Code[20]; LocationCode: Code[10]): BigInteger
    var
        ShopLocation: Record "Shpfy Shop Location";
    begin
        ShopLocation.Init();
        ShopLocation."Shop Code" := ShopCode;
        ShopLocation.Id := Any.IntegerInRange(100000, 999999);
        ShopLocation."Default Location Code" := LocationCode;
        ShopLocation.Insert(false);
        exit(ShopLocation.Id);
    end;
}
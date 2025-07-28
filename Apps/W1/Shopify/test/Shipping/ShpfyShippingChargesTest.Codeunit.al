// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using Microsoft.Foundation.Shipping;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Item;
using System.TestLibraries.Utilities;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Enums;

codeunit 139546 "Shpfy Shipping Charges Test"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        ShipmentMethod: Record "Shipment Method";
        ShippingAgent: Record "Shipping Agent";
        ShippingAgentServices: Record "Shipping Agent Services";
        Shop: Record "Shpfy Shop";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibraryAssert: Codeunit "Library Assert";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        OrdersAPISubscriber: Codeunit "Shpfy Orders API Subscriber";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    #region Test Methods
    [Test]
    procedure UnitTestValidateShopifyOrderShippingAgentServiceMapping()
    var
        OrderHeader: Record "Shpfy Order Header";
        Item: Record Item;
        ShpfyShipmentMethodMapping: Record "Shpfy Shipment Method Mapping";
        OrderShippingCharges: Record "Shpfy Order Shipping Charges";
        OrderMapping: Codeunit "Shpfy Order Mapping";
        ImportOrder: Codeunit "Shpfy Import Order";
        ShippingChargesType: Enum "Sales Line Type";
    begin
        // [SCENARIO] Creating a random Shopify order and try to map shipping agent and service data from the Shopify shipment method mapping.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();

        // [GIVEN] Shopify order is imported
        BindSubscription(OrdersAPISubscriber);
        ImportOrder.SetShop(Shop.Code);
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder, false);
        UnbindSubscription(OrdersAPISubscriber);

        // [GIVEN] Order shipping charges are created for the Shopify order
        CreateOrderShippingCharges(OrderShippingCharges, OrderHeader."Shopify Order Id");

        // [GIVEN] Created shopify shipment method mapping from the shipping charges
        Item := ShpfyInitializeTest.GetDummyItem();
        CreateShopifyShipmentMethodMapping(
            ShpfyShipmentMethodMapping,
            ShippingChargesType::Item,
            ShipmentMethod.Code,
            ShippingAgent.Code,
            ShippingAgentServices.Code,
            Item."No.",
            OrderShippingCharges.Title
        );

        // [WHEN] Order mapping is done
        OrderMapping.DoMapping(OrderHeader);

        // [THEN] Order header is mapped with the correct shipping agent and service code
        LibraryAssert.AreEqual(ShpfyShipmentMethodMapping."Shipping Agent Code", OrderHeader."Shipping Agent Code", 'Shipping Agent Code must be correct');
        LibraryAssert.AreEqual(ShpfyShipmentMethodMapping."Shipping Agent Service Code", OrderHeader."Shipping Agent Service Code", 'Shipping Agent Service Code must be correct');
    end;

    [Test]
    procedure UnitTestValidateSalesOrderShippingAgentServiceMapping()
    var
        OrderHeader: Record "Shpfy Order Header";
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        OrderShippingCharges: Record "Shpfy Order Shipping Charges";
        ShpfyShipmentMethodMapping: Record "Shpfy Shipment Method Mapping";
        ProcessOrder: Codeunit "Shpfy Process Order";
        ImportOrder: Codeunit "Shpfy Import Order";
        ShippingChargesType: Enum "Sales Line Type";
    begin
        // [SCENARIO] Creating Sales document from a Shopify order and try to map shipping agent and service data.
        Initialize();

        // [GIVEN] Shopify shop
        Shop := CommunicationMgt.GetShopRecord();

        // [GIVEN] Shopify order is imported
        BindSubscription(OrdersAPISubscriber);
        ImportOrder.SetShop(Shop.Code);
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder, false);
        UnbindSubscription(OrdersAPISubscriber);

        // [GIVEN] Order shipping charges are created for the Shopify order
        CreateOrderShippingCharges(OrderShippingCharges, OrderHeader."Shopify Order Id");

        // [GIVEN] Created shopify shipment method mapping from the shipping charges
        Item := ShpfyInitializeTest.GetDummyItem();
        CreateShopifyShipmentMethodMapping(
            ShpfyShipmentMethodMapping,
            ShippingChargesType::Item,
            ShipmentMethod.Code,
            ShippingAgent.Code,
            ShippingAgentServices.Code,
            Item."No.",
            OrderShippingCharges.Title
        );

        // [WHEN] Order is processed
        ProcessOrder.Run(OrderHeader);

        // [THEN] Sales document with correct shipping agent and service code is created.
        AssertSalesHeaderValues(OrderHeader, SalesHeader, ShpfyShipmentMethodMapping);
    end;

    [Test]
    procedure UnitTestMapShippingChargesForEmptyType()
    var
        OrderHeader: Record "Shpfy Order Header";
        ShpfyShipmentMethodMapping: Record "Shpfy Shipment Method Mapping";
        OrderShippingCharges: Record "Shpfy Order Shipping Charges";
        ProcessOrder: Codeunit "Shpfy Process Order";
        ImportOrder: Codeunit "Shpfy Import Order";
        ShippingChargesType: Enum "Sales Line Type";
    begin
        // [SCENARIO] Create sales line from a Shopify order and try to map shipping charges account information when type is empty.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();

        // [GIVEN] Shopify order is imported
        BindSubscription(OrdersAPISubscriber);
        ImportOrder.SetShop(Shop.Code);
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder, false);
        UnbindSubscription(OrdersAPISubscriber);

        // [GIVEN] Order shipping charges are created for the Shopify order
        CreateOrderShippingCharges(OrderShippingCharges, OrderHeader."Shopify Order Id");

        // [GIVEN] Created shopify shipment method mapping from the shipping charges
        CreateShopifyShipmentMethodMapping(
            ShpfyShipmentMethodMapping,
            ShippingChargesType::" ",
            ShipmentMethod.Code,
            ShippingAgent.Code,
            ShippingAgentServices.Code,
            CopyStr(LibraryRandom.RandText(20), 1, 20),
            OrderShippingCharges.Title
        );

        // [WHEN] Order is processed
        ProcessOrder.Run(OrderHeader);

        // [THEN] Sales line is created with the correct shipping charges account information
        AssertSalesLineValues(
            OrderShippingCharges,
            ShpfyShipmentMethodMapping,
            ShippingChargesType::"G/L Account",
            Shop."Shipping Charges Account"
        );
    end;

    [Test]
    procedure UnitTestMapShippingChargesForItemType()
    var
        OrderHeader: Record "Shpfy Order Header";
        Item: Record Item;
        ShpfyShipmentMethodMapping: Record "Shpfy Shipment Method Mapping";
        OrderShippingCharges: Record "Shpfy Order Shipping Charges";
        ProcessOrder: Codeunit "Shpfy Process Order";
        ImportOrder: Codeunit "Shpfy Import Order";
        ShippingChargesType: Enum "Sales Line Type";
    begin
        // [SCENARIO] Create sales line from a Shopify order and try to map shipping charges account information when type is an item.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();

        // [GIVEN] Shopify order is imported
        BindSubscription(OrdersAPISubscriber);
        ImportOrder.SetShop(Shop.Code);
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder, false);
        UnbindSubscription(OrdersAPISubscriber);

        // [GIVEN] Order shipping charges are created for the Shopify order
        CreateOrderShippingCharges(OrderShippingCharges, OrderHeader."Shopify Order Id");

        // [GIVEN] Created shopify shipment method mapping from the shipping charges
        Item := ShpfyInitializeTest.GetDummyItem();
        CreateShopifyShipmentMethodMapping(
            ShpfyShipmentMethodMapping,
            ShippingChargesType::Item,
            ShipmentMethod.Code,
            ShippingAgent.Code,
            ShippingAgentServices.Code,
            Item."No.",
            OrderShippingCharges.Title
        );

        // [WHEN] Order is processed
        ProcessOrder.Run(OrderHeader);

        // [THEN] Sales line is created with the correct shipping charges account information
        AssertSalesLineValues(
            OrderShippingCharges,
            ShpfyShipmentMethodMapping,
            ShippingChargesType::Item,
            ShpfyShipmentMethodMapping."Shipping Charges No."
        );
    end;

    [Test]
    procedure UnitTestMapShippingChargesForGLType()
    var
        OrderHeader: Record "Shpfy Order Header";
        GLAccount: Record "G/L Account";
        ShpfyShipmentMethodMapping: Record "Shpfy Shipment Method Mapping";
        OrderShippingCharges: Record "Shpfy Order Shipping Charges";
        ImportOrder: Codeunit "Shpfy Import Order";
        ProcessOrder: Codeunit "Shpfy Process Order";
        ShippingChargesType: Enum "Sales Line Type";
    begin
        // [SCENARIO] Create sales line from a Shopify order and try to map shipping charges account information when type is an gl account.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();

        // [GIVEN] ShpfyImportOrder.ImportOrder
        BindSubscription(OrdersAPISubscriber);
        ImportOrder.SetShop(Shop.Code);
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder, false);
        UnbindSubscription(OrdersAPISubscriber);

        // [GIVEN] Order shipping charges are created for the Shopify order
        CreateOrderShippingCharges(OrderShippingCharges, OrderHeader."Shopify Order Id");

        // [GIVEN] Created shopify shipment method mapping from the shipping charges
        CreateGLAccount(GLAccount);
        CreateShopifyShipmentMethodMapping(
            ShpfyShipmentMethodMapping,
            ShippingChargesType::"G/L Account",
            ShipmentMethod.Code,
            ShippingAgent.Code,
            ShippingAgentServices.Code,
            GLAccount."No.",
            OrderShippingCharges.Title
        );

        // [WHEN] Order is processed
        ProcessOrder.Run(OrderHeader);

        // [THEN] Sales line is created with the correct shipping charges account information
        AssertSalesLineValues(
            OrderShippingCharges,
            ShpfyShipmentMethodMapping,
            ShippingChargesType::"G/L Account",
            ShpfyShipmentMethodMapping."Shipping Charges No."
        );
    end;

    [Test]
    procedure UnitTestMapShippingChargesForItemChargeType()
    var
        OrderHeader: Record "Shpfy Order Header";
        ItemCharge: Record "Item Charge";
        ShpfyShipmentMethodMapping: Record "Shpfy Shipment Method Mapping";
        OrderShippingCharges: Record "Shpfy Order Shipping Charges";
        RefundGLAccount: Record "G/L Account";
        ImportOrder: Codeunit "Shpfy Import Order";
        ProcessOrder: Codeunit "Shpfy Process Order";
        ShippingChargesType: Enum "Sales Line Type";
    begin
        // [SCENARIO] Create sales line from a Shopify order and try to map shipping charges account information when type is an item charge.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();

        // [GIVEN] ShpfyImportOrder.ImportOrder
        BindSubscription(OrdersAPISubscriber);
        ImportOrder.SetShop(Shop.Code);
        ImportShopifyOrder(Shop, OrderHeader, ImportOrder, false);
        UnbindSubscription(OrdersAPISubscriber);

        // [GIVEN] Order shipping charges are created for the Shopify order
        CreateOrderShippingCharges(OrderShippingCharges, OrderHeader."Shopify Order Id");

        // [GIVEN] Created Item Charge
        RefundGLAccount.Get(Shop."Refund Account");
        LibraryInventory.CreateItemCharge(ItemCharge);
        ItemCharge.Validate("VAT Prod. Posting Group", RefundGLAccount."VAT Prod. Posting Group");
        ItemCharge.Modify(true);

        // [GIVEN] Created shopify shipment method mapping from the shipping charges
        CreateShopifyShipmentMethodMapping(
            ShpfyShipmentMethodMapping,
            ShippingChargesType::"Charge (Item)",
            ShipmentMethod.Code,
            ShippingAgent.Code,
            ShippingAgentServices.Code,
            ItemCharge."No.",
            OrderShippingCharges.Title
        );

        // [WHEN] Order is processed
        ProcessOrder.Run(OrderHeader);

        // [THEN] Sales line is created with the correct shipping charges account information
        AssertSalesLineValues(
            OrderShippingCharges,
            ShpfyShipmentMethodMapping,
            ShippingChargesType::"Charge (Item)",
            ShpfyShipmentMethodMapping."Shipping Charges No."
        );
    end;
    #endregion

    #region Local Procedures
    local procedure Initialize()
    var
        ShippingTime: DateFormula;
    begin
        if IsInitialized then
            exit;

        Codeunit.Run(Codeunit::"Shpfy Initialize Test");

        Evaluate(ShippingTime, '<1W>');
        CreateShipmentMethod(ShipmentMethod);
        LibraryInventory.CreateShippingAgent(ShippingAgent);
        LibraryInventory.CreateShippingAgentService(ShippingAgentServices, ShippingAgent.Code, ShippingTime);

        Commit();

        IsInitialized := true;
    end;

    local procedure CreateShopifyShipmentMethodMapping(
        var ShpfyShipmentMethodMapping: Record "Shpfy Shipment Method Mapping";
        ShippingChargesType: Enum "Sales Line Type";
        ShipmentMethodCode: Code[10];
        ShippingAgentCode: Code[10];
        ShippingAgentServiceCode: Code[10];
        ShippingChargesNo: Code[20];
        Name: Text[50]
    )
    begin
        ShpfyShipmentMethodMapping.Init();
        ShpfyShipmentMethodMapping."Shop Code" := Shop.Code;
        ShpfyShipmentMethodMapping.Name := Name;
        ShpfyShipmentMethodMapping."Shipment Method Code" := ShipmentMethodCode;
        ShpfyShipmentMethodMapping."Shipping Charges Type" := ShippingChargesType;
        ShpfyShipmentMethodMapping."Shipping Charges No." := ShippingChargesNo;
        ShpfyShipmentMethodMapping."Shipping Agent Code" := ShippingAgentCode;
        ShpfyShipmentMethodMapping."Shipping Agent Service Code" := ShippingAgentServiceCode;
        ShpfyShipmentMethodMapping.Insert(true);
    end;

    local procedure CreateShipmentMethod(LocalShipmentMethod: Record "Shipment Method")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        LocalShipmentMethod.Init();
        LocalShipmentMethod.Code := CopyStr(LibraryUtility.GenerateRandomText(MaxStrLen(LocalShipmentMethod.Code)), 1, MaxStrLen(LocalShipmentMethod.Code));
        LocalShipmentMethod.Insert(true);
    end;

    local procedure ImportShopifyOrder(var ShopifyShop: Record "Shpfy Shop"; var OrderHeader: Record "Shpfy Order Header"; var OrdersToImport: Record "Shpfy Orders to Import"; var ImportOrder: Codeunit "Shpfy Import Order"; var JShopifyOrder: JsonObject; var JShopifyLineItems: JsonArray)
    var
    begin
        ImportOrder.ImportCreateAndUpdateOrderHeaderFromMock(ShopifyShop.Code, OrdersToImport.Id, JShopifyOrder);
        ImportOrder.ImportCreateAndUpdateOrderLinesFromMock(OrdersToImport.Id, JShopifyLineItems);
        Commit();
        OrderHeader.Get(OrdersToImport.Id);
    end;

    local procedure ImportShopifyOrder(var ShopifyShop: Record "Shpfy Shop"; var OrderHeader: Record "Shpfy Order Header"; var ImportOrder: Codeunit "Shpfy Import Order"; B2B: Boolean)
    var
        OrdersToImport: Record "Shpfy Orders to Import";
        OrderHandlingHelper: Codeunit "Shpfy Order Handling Helper";
        JShopifyLineItems: JsonArray;
        JShopifyOrder: JsonObject;
    begin
        JShopifyOrder := OrderHandlingHelper.CreateShopifyOrderAsJson(ShopifyShop, OrdersToImport, JShopifyLineItems, B2B);
        ImportShopifyOrder(ShopifyShop, OrderHeader, OrdersToImport, ImportOrder, JShopifyOrder, JShopifyLineItems);
    end;

    local procedure CreateOrderShippingCharges(var OrderShippingCharges: Record "Shpfy Order Shipping Charges"; ShopifyOrderId: BigInteger)
    begin
        OrderShippingCharges.Init();
        OrderShippingCharges."Shopify Shipping Line Id" := LibraryRandom.RandInt(100000);
        OrderShippingCharges."Shopify Order Id" := ShopifyOrderId;
        OrderShippingCharges.Title := CopyStr(LibraryRandom.RandText(50), 1, MaxStrLen(OrderShippingCharges.Title));
        OrderShippingCharges.Amount := LibraryRandom.RandDec(10, 0);
        OrderShippingCharges.Insert(true);
    end;

    local procedure CreateGLAccount(var GLAccount: Record "G/L Account")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup,
           VATPostingSetup."VAT Calculation Type"::"Normal VAT", LibraryRandom.RandDecInDecimalRange(10, 25, 0));
        GLAccount.Get(LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, Enum::"General Posting Type"::Sale));
        GLAccount."Direct Posting" := true;

        ShpfyInitializeTest.CreateVATPostingSetup(Shop."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group");

        GLAccount.Modify(false);
    end;

    local procedure AssertSalesLineValues(
        OrderShippingCharges: Record "Shpfy Order Shipping Charges";
        ShpfyShipmentMethodMapping: Record "Shpfy Shipment Method Mapping";
        SalesLineType: Enum "Sales Line Type";
        ExpectedChargesAccountNo: Code[20]
    )
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        SalesHeader.SetRange("Shpfy Order Id", OrderShippingCharges."Shopify Order Id");
        LibraryAssert.IsTrue(SalesHeader.FindLast(), 'Sales document is not created from Shopify order');

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLineType);
        SalesLine.SetRange(Description, OrderShippingCharges.Title);

        LibraryAssert.IsTrue(SalesLine.FindLast(), 'Sales line is not created from Shopify order');
        LibraryAssert.AreEqual(ExpectedChargesAccountNo, SalesLine."No.", 'Shipping Charges Account is not as expected');
        LibraryAssert.AreEqual(ShpfyShipmentMethodMapping."Shipping Agent Code", SalesLine."Shipping Agent Code", 'Shipping Agent Code is not as expected');
        LibraryAssert.AreEqual(ShpfyShipmentMethodMapping."Shipping Agent Service Code", SalesLine."Shipping Agent Service Code", 'Shipping Agent Service Code is not as expected');
    end;

    local procedure AssertSalesHeaderValues(
        OrderHeader: Record "Shpfy Order Header";
        SalesHeader: Record "Sales Header";
        ShpfyShipmentMethodMapping: Record "Shpfy Shipment Method Mapping"
    )
    begin
        SalesHeader.SetRange("Shpfy Order Id", OrderHeader."Shopify Order Id");
        LibraryAssert.IsTrue(SalesHeader.FindLast(), 'Sales document is not created from Shopify order');
        LibraryAssert.AreEqual(ShpfyShipmentMethodMapping."Shipping Agent Code", SalesHeader."Shipping Agent Code", 'Shipping Agent Code must be the same as in the shipment method mapping.');
        LibraryAssert.AreEqual(ShpfyShipmentMethodMapping."Shipping Agent Service Code", SalesHeader."Shipping Agent Service Code", 'Shipping Agent Service Code must be the same as in the shipment method mapping.');
    end;
    #endregion
}

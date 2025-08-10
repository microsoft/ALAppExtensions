// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;

/// <summary>
/// Codeunit Shpfy Inventory API Test (ID 139586).
/// </summary>
codeunit 139586 "Shpfy Inventory API Test"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;
    SingleInstance = true;

    trigger OnRun()
    begin
        // [FEATURE] [Shopify]
        isInitialized := false;
    end;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        LibraryInventory: Codeunit "Library - Inventory";
        isInitialized: Boolean;

    local procedure Initialize()

    begin
        if isInitialized then
            exit;
        isInitialized := true;
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
    end;

    [Test]
    procedure UnitTestGetStock()
    var
        Shop: Record "Shpfy Shop";
        ShopLocation: Record "Shpfy Shop Location";
        Item: Record Item;
        ShopifyProduct: Record "Shpfy Product";
        ShopInventory: Record "Shpfy Shop Inventory";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        InventoryAPI: Codeunit "Shpfy Inventory API";
        StockCalculate: Enum "Shpfy Stock Calculation";
        StockResult: Decimal;
    begin
        // [SCENARIO] Calculates the stock for a given Shopify Shop Inventory record.
        // [SCENARIO] For this testing we create dummy records and execute a event to set the stock result.
        // [SCENARIO] Normally the stock will be calculates by the function CalcAvailQuantities of the codeunit "Item Availability Forms Mgt".
        // [SCENARIO] Because this is a standard functionality of BC, we don't do the testing of this code in this test.

        // [GINVEN] A ShopInventory record
        Initialize();

        Shop := CommunicationMgt.GetShopRecord();
        CreateShopLocation(ShopLocation, Shop.Code, StockCalculate::Disabled);

        CreateItem(Item);
        UpdateItemInventory(Item, 9);
        CreateShpfyProduct(ShopifyProduct, ShopInventory, Item.SystemId, Shop.Code, ShopLocation.Id);

        StockResult := InventoryAPI.GetStock(ShopInventory);
        // [THEN] StockResult = Stock
        LibraryAssert.AreEqual(0, StockResult, 'Must zero with Stock calculation disabled');


        ShopLocation."Stock Calculation" := ShopLocation."Stock Calculation"::"Projected Available Balance Today";
        ShopLocation.Modify();
        StockResult := InventoryAPI.GetStock(ShopInventory);
        LibraryAssert.AreEqual(9, StockResult, 'must be 9');
    end;

    local procedure CreateItem(var Item: Record Item)
    begin
        LibraryInventory.CreateItemWithoutVAT(Item);
    end;

    local procedure CreateShpfyProduct(var ShopifyProduct: Record "Shpfy Product"; var ShopInventory: Record "Shpfy Shop Inventory"; ItemSystemId: Guid; ShopCode: Code[20]; ShopLocationId: BigInteger)
    var
        ShopifyVariant: Record "Shpfy Variant";
    begin
        ShopifyProduct.Init();
        ShopifyProduct.Id := Any.IntegerInRange(10000, 999999);
        ShopifyProduct."Item SystemId" := ItemSystemId;
        ShopifyProduct."Shop Code" := ShopCode;
        ShopifyProduct.Insert();
        ShopifyVariant.Init();
        ShopifyVariant.Id := Any.IntegerInRange(10000, 999999);
        ShopifyVariant."Product Id" := ShopifyProduct.Id;
        ShopifyVariant."Item SystemId" := ItemSystemId;
        ShopifyVariant."Shop Code" := ShopCode;
        ShopifyVariant.Insert();

        ShopInventory.Init();
        ShopInventory."Inventory Item Id" := Any.IntegerInRange(10000, 999999);
        ShopInventory."Shop Code" := ShopCode;
        ShopInventory."Location Id" := ShopLocationId;
        ShopInventory."Product Id" := ShopifyProduct.Id;
        ShopInventory."Variant Id" := ShopifyVariant.Id;
        ShopInventory.Insert();
    end;

    local procedure CreateShopLocation(var ShopLocation: Record "Shpfy Shop Location"; ShopCode: Code[20]; StockCalculation: Enum "Shpfy Stock Calculation")
    begin
        ShopLocation.Init();
        ShopLocation."Shop Code" := ShopCode;
        ShopLocation.Id := Any.IntegerInRange(10000, 999999);
        ShopLocation."Stock Calculation" := StockCalculation;
        ShopLocation.Insert();
    end;

    local procedure UpdateItemInventory(Item: Record Item; Qty: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, Item."No.", '', '', Qty);
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
    end;
}

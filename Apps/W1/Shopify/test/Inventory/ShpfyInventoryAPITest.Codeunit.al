/// <summary>
/// Codeunit Shpfy Inventory API Test (ID 139586).
/// </summary>
codeunit 139586 "Shpfy Inventory API Test"
{
    Subtype = Test;
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
        Stock: Decimal;
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
        ShpfyShop: Record "Shpfy Shop";
        ShpfyShopLocation: Record "Shpfy Shop Location";
        Item: Record Item;
        ShpfyProduct: Record "Shpfy Product";
        ShpfyShopInventory: Record "Shpfy Shop Inventory";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ShpfyInventoryAPI: Codeunit "Shpfy Inventory API";
        StockCalculate: Enum "Shpfy Stock Calculation";
        StockResult: Decimal;
    begin
        // [SCENARIO] Calculates the stock for a given Shopify Shop Inventory record.
        // [SCENARIO] For this testing we create dummy records and execute a event to set the stock result.
        // [SCENARIO] Normally the stock will be calculates by the function CalcAvailQuantities of the codeunit "Item Availability Forms Mgt".
        // [SCENARIO] Because this is a standard functionality of BC, we don't do the testing of this code in this test.

        // [GINVEN] A ShopInventory record
        Initialize();

        ShpfyShop := ShpfyCommunicationMgt.GetShopRecord();
        CreateShopLocation(ShpfyShopLocation, ShpfyShop.Code, StockCalculate::Disabled);

        CreateItem(Item);
        UpdateItemInventory(Item, 9);
        CreateShpfyProduct(ShpfyProduct, ShpfyShopInventory, Item.SystemId, ShpfyShop.Code, ShpfyShopLocation.Id);

        StockResult := ShpfyInventoryAPI.GetStock(ShpfyShopInventory);
        // [THEN] StockResult = Stock
        LibraryAssert.AreEqual(0, StockResult, 'Must zero with Stock calculation disabled');


        ShpfyShopLocation."Stock Calculation" := ShpfyShopLocation."Stock Calculation"::"Projected Available Balance Today";
        ShpfyShopLocation.Modify();
        StockResult := ShpfyInventoryAPI.GetStock(ShpfyShopInventory);
        LibraryAssert.AreEqual(9, StockResult, 'must be 9');
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Inventory Events", 'OnBeforeCalculationStock', '', true, false)]
    local procedure OnCalculateStock(Item: Record Item; ShopifyShop: Record "Shpfy Shop"; LocationFilter: Text; CurrentShopifyStock: Decimal; var StockResult: Decimal; var Handled: Boolean)
    begin
        StockResult := Stock;
        Handled := true;
    end;

    local procedure CreateItem(var Item: Record Item)
    begin
        LibraryInventory.CreateItemWithoutVAT(Item);
    end;

    local procedure CreateShpfyProduct(var ShpfyProduct: Record "Shpfy Product"; var ShpfyShopInventory: Record "Shpfy Shop Inventory"; ItemSystemId: Guid; ShopCode: Code[20]; ShpfyShopLocationId: BigInteger)
    var
        ShpfyVariant: Record "Shpfy Variant";
    begin
        ShpfyProduct.Init();
        ShpfyProduct.Id := Any.IntegerInRange(10000, 999999);
        ShpfyProduct."Item SystemId" := ItemSystemId;
        ShpfyProduct."Shop Code" := ShopCode;
        ShpfyProduct.Insert();
        ShpfyVariant.Init();
        ShpfyVariant.Id := Any.IntegerInRange(10000, 999999);
        ShpfyVariant."Product Id" := ShpfyProduct.Id;
        ShpfyVariant."Item SystemId" := ItemSystemId;
        ShpfyVariant."Shop Code" := ShopCode;
        ShpfyVariant.Insert();

        ShpfyShopInventory.Init();
        ShpfyShopInventory."Inventory Item Id" := Any.IntegerInRange(10000, 999999);
        ShpfyShopInventory."Shop Code" := ShopCode;
        ShpfyShopInventory."Location Id" := ShpfyShopLocationId;
        ShpfyShopInventory."Product Id" := ShpfyProduct.Id;
        ShpfyShopInventory."Variant Id" := ShpfyVariant.Id;
        ShpfyShopInventory.Insert();
    end;

    local procedure CreateShopLocation(var ShpfyShopLocation: Record "Shpfy Shop Location"; ShopCode: Code[20]; StockCalculation: Enum "Shpfy Stock Calculation")
    begin
        ShpfyShopLocation.Init();
        ShpfyShopLocation."Shop Code" := ShopCode;
        ShpfyShopLocation.Id := Any.IntegerInRange(10000, 999999);
        ShpfyShopLocation."Stock Calculation" := StockCalculation;
        ShpfyShopLocation.Insert();
    end;

    local procedure UpdateItemInventory(Item: Record Item; Qty: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, Item."No.", '', '', Qty);
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
    end;
}
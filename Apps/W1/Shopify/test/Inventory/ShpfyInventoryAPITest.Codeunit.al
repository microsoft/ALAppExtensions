/// <summary>
/// Codeunit Shpfy Inventory API Test (ID 139586).
/// </summary>
codeunit 139586 "Shpfy Inventory API Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;
    SingleInstance = true;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
#pragma warning disable AA0072
        This: Codeunit "Shpfy Inventory API Test";
#pragma warning restore AA0072
        Stock: Decimal;

    [Test]
    procedure UnitTestGetStock()
    var
        ShpfyShopInventory: Record "Shpfy Shop Inventory";
        ShpfyInventoryAPI: Codeunit "Shpfy Inventory API";
        StockResult: Decimal;
    begin
        // [SCENARIO] Calculates the stock for a given Shopify Shop Inventory record.
        // [SCENARIO] For this testing we create dummy records and execute a event to set the stock result.
        // [SCENARIO] Normally the stock will be calculates by the function CalcAvailQuantities of the codeunit "Item Availability Forms Mgt".
        // [SCENARIO] Because this is a standard functionality of BC, we don't do the testing of this code in this test.

        // [GINVEN] A ShopInventory record
        ShpfyShopInventory := RandomShopInventoryRecord();

        // [WHEN] GetStock is invoked of codeunit "Shpfy Inventory API"
        if BindSubscription(This) then;
        StockResult := ShpfyInventoryAPI.GetStock(ShpfyShopInventory);
        if UnbindSubscription(This) then;

        // [THEN] StockResult = Stock
        LibraryAssert.AreEqual(Stock, StockResult, 'ShpfyInventoryAPI.GetStock(ShopInventory)');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Inventory Events", 'OnBeforeCalculationStock', '', true, false)]
    local procedure OnCalculateStock(Item: Record Item; ShopifyShop: Record "Shpfy Shop"; LocationFilter: Text; CurrentShopifyStock: Decimal; var StockResult: Decimal; var Handled: Boolean)
    begin
        StockResult := Stock;
        Handled := true;
    end;

    local procedure RandomShopInventoryRecord() ShopInventory: Record "Shpfy Shop Inventory";
    var
        Item: Record Item;
        ShpfyShopLocation: Record "Shpfy Shop Location";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyShop: Record "Shpfy Shop";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
    begin
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        Stock := Any.DecimalInRange(1000, 2);

        Item.Init();
        Item."No." := Any.AlphabeticText(MaxStrLen(Item."No."));
        Item.Insert();

        ShpfyShop := ShpfyCommunicationMgt.GetShopRecord();

        ShpfyShopLocation.Init();
        ShpfyShopLocation."Shop Code" := ShpfyShop.Code;
        ShpfyShopLocation.Id := Any.IntegerInRange(10000, 999999);
        ShpfyShopLocation.Disabled := false;
        ShpfyShopLocation.Insert();

        ShpfyProduct.Init();
        ShpfyProduct.Id := Any.IntegerInRange(10000, 999999);
        ShpfyProduct."Item SystemId" := Item.SystemId;
        ShpfyProduct."Shop Code" := ShpfyShop.Code;
        ShpfyProduct.Insert();

        ShpfyVariant.Init();
        ShpfyVariant.Id := Any.IntegerInRange(10000, 999999);
        ShpfyVariant."Product Id" := ShpfyProduct.Id;
        ShpfyVariant."Item SystemId" := Item.SystemId;
        ShpfyVariant."Shop Code" := ShpfyShop.Code;
        ShpfyVariant.Insert();

        ShopInventory.Init();
        ShopInventory."Inventory Item Id" := Any.IntegerInRange(10000, 999999);
        ShopInventory."Shop Code" := ShpfyShop.Code;
        ShopInventory."Location Id" := ShpfyShopLocation.Id;
        ShopInventory."Product Id" := ShpfyProduct.Id;
        ShopInventory."Variant Id" := ShpfyVariant.Id;
        ShopInventory.Insert();
        Commit();
    end;
}
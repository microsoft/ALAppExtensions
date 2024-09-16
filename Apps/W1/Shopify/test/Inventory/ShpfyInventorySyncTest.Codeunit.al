/// <summary>
/// Codeunit Shpfy Inventory Sync Test (ID 139696).
/// </summary>
/// 
codeunit 139696 "Shpfy Inventory Sync Test"
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
        isInitialized: Boolean;

    local procedure Initialize()

    begin
        if isInitialized then
            exit;
        isInitialized := true;
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
    end;

    [Test]
    procedure SyncInventoryForDisabledLocations()
    var
        Shop: Record "Shpfy Shop";
        ShopLocation: Record "Shpfy Shop Location";
        ShopInventory: Record "Shpfy Shop Inventory";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        StockCalculation: Enum "Shpfy Stock Calculation";
    begin
        // [SCENARIO] Inventory will not be synced for locations with stock calculation disabled

        // [GIVEN] Location with stock calculation disabled
        Initialize();
        Shop := CommunicationMgt.GetShopRecord();
        CreateShopLocation(ShopLocation, Shop.Code, StockCalculation::Disabled);

        // [WHEN] Inventory is synced
        ShopInventory.Reset();
        ShopInventory.SetRange("Shop Code", Shop.Code);
        Codeunit.Run(Codeunit::"Shpfy Sync Inventory", ShopInventory);

        // [THEN] ShopInventory is empty
        LibraryAssert.RecordIsEmpty(ShopInventory);
    end;

    local procedure CreateShopLocation(var ShopLocation: Record "Shpfy Shop Location"; ShopCode: Code[20]; StockCalculation: Enum "Shpfy Stock Calculation")
    begin
        ShopLocation.Init();
        ShopLocation."Shop Code" := ShopCode;
        ShopLocation.Id := Any.IntegerInRange(10000, 999999);
        ShopLocation."Stock Calculation" := StockCalculation;
        ShopLocation.Insert();
    end;
}
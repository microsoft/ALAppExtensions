namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Sync Inventory (ID 30197).
/// </summary>
codeunit 30197 "Shpfy Sync Inventory"
{
    Access = Internal;
    TableNo = "Shpfy Shop Inventory";

    var
        InventoryApi: Codeunit "Shpfy Inventory API";


    trigger OnRun()
    var
        ShopInventory: Record "Shpfy Shop Inventory";
        ShopLocation: Record "Shpfy Shop Location";
    begin
        SetShopAndLocationFilters(Rec, ShopInventory, ShopLocation);

        if ShopLocation.FindSet(false) then begin
            InventoryApi.SetShop(ShopLocation."Shop Code");
            InventoryApi.SetInventoryIds(ShopLocation.Id);
            repeat
                InventoryApi.ImportStock(ShopLocation);
            until ShopLocation.Next() = 0;
        end;
        InventoryApi.RemoveUnusedInventoryIds();

        InventoryApi.ExportStock(ShopInventory);
    end;

    local procedure SetShopAndLocationFilters(var FilteredInventory: Record "Shpfy Shop Inventory"; var ShopInventory: Record "Shpfy Shop Inventory"; var ShopLocation: Record "Shpfy Shop Location")
    var
        ShopFilter: Text;
        LocationFilter: BigInteger;
    begin
        ShopFilter := FilteredInventory.GetFilter("Shop Code");
        Evaluate(LocationFilter, FilteredInventory.GetFilter("Location Id"));

        if ShopFilter <> '' then begin
            ShopLocation.SetRange("Shop Code", ShopFilter);
            ShopInventory.SetRange("Shop Code", ShopFilter);
        end;

        if LocationFilter <> 0 then begin
            ShopLocation.SetRange(Id, LocationFilter);
            ShopInventory.SetRange("Location Id", LocationFilter);
        end;
    end;
}
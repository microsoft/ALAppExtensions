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
        ShopFilter: Text;
    begin
        ShopFilter := Rec.GetFilter("Shop Code");
        if ShopFilter <> '' then begin
            ShopLocation.SetRange("Shop Code", ShopFilter);
            ShopInventory.SetRange("Shop Code", ShopFilter);
        end;
        if ShopLocation.FindSet(false, false) then begin
            InventoryApi.SetShop(ShopLocation."Shop Code");
            repeat
                InventoryApi.ImportStock(ShopLocation);
            until ShopLocation.Next() = 0;
        end;


        if ShopInventory.FindSet() then
            repeat
                InventoryApi.ExportStock(ShopInventory);
            until ShopInventory.Next() = 0;

        if ShopLocation.FindSet(false, false) then begin
            InventoryApi.SetShop(ShopLocation."Shop Code");
            repeat
                InventoryApi.ImportStock(ShopLocation);
            until ShopLocation.Next() = 0;
        end;

    end;
}
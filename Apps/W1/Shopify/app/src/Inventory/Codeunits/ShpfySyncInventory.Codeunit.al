// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
        ShopFilter: Text;
    begin
        ShopFilter := Rec.GetFilter("Shop Code");
        if ShopFilter <> '' then begin
            ShopLocation.SetRange("Shop Code", ShopFilter);
            ShopInventory.SetRange("Shop Code", ShopFilter);
        end;
        ShopLocation.SetFilter("Stock Calculation", '<>%1', ShopLocation."Stock Calculation"::Disabled);
        if ShopLocation.FindSet(false) then begin
            InventoryApi.SetShop(ShopLocation."Shop Code");
            InventoryApi.SetInventoryIds();
            repeat
                InventoryApi.ImportStock(ShopLocation);
            until ShopLocation.Next() = 0;
        end;
        InventoryApi.RemoveUnusedInventoryIds();

        InventoryApi.ExportStock(ShopInventory);
    end;
}
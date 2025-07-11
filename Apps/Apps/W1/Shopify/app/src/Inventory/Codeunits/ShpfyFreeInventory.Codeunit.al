namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

codeunit 30283 "Shpfy Free Inventory" implements "Shpfy Stock Calculation"
{
    procedure GetStock(var Item: Record Item): decimal;
    begin
        Item.CalcFields(Inventory, "Reserved Qty. on Inventory");
        exit(Item.Inventory - Item."Reserved Qty. on Inventory");
    end;
}
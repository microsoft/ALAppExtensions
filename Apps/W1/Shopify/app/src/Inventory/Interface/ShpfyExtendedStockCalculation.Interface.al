namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

interface "Shpfy Extended Stock Calculation" extends "Shpfy Stock Calculation"
{
    procedure GetStock(var Item: Record Item; var ShopLocation: Record "Shpfy Shop Location"): Decimal;
}
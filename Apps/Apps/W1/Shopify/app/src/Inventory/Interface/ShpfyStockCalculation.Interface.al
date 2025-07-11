namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

interface "Shpfy Stock Calculation"
{
    procedure GetStock(var Item: Record Item): Decimal;
}
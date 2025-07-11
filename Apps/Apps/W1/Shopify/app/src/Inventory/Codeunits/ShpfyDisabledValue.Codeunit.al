namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

codeunit 30210 "Shpfy Disabled Value" implements "Shpfy Stock Calculation"
{
    procedure GetStock(var Item: Record Item): decimal;
    begin
        exit(0);
    end;
}


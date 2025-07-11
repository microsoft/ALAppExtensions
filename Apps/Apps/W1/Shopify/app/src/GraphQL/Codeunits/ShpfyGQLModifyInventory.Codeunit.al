namespace Microsoft.Integration.Shopify;

codeunit 30102 "Shpfy GQL Modify Inventory" implements "Shpfy IGraphQL"
{
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"mutation inventorySetOnHandQuantities($input:InventorySetOnHandQuantitiesInput!) { inventorySetOnHandQuantities(input: $input) { userErrors { field message }}}","variables":{"input":{"reason":"correction","setQuantities":[]}}}');
    end;

    procedure GetExpectedCost(): Integer
    begin
        exit(10);
    end;
}
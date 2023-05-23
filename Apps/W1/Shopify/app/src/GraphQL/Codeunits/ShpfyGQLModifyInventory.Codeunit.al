codeunit 30102 "Shpfy GQL Modify Inventory" implements "Shpfy IGraphQL"
{
<<<<<<< HEAD

=======
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"mutation {inventoryBulkAdjustQuantityAtLocation(inventoryItemAdjustments: {availableDelta: {{DeltaQuantity}}, inventoryItemId: \"gid://shopify/InventoryItem/{{InventoryItemId}}\"} locationId: \"gid://shopify/Location/{{LocationId}}\" ) {inventoryLevels {available}}}"}');
    end;

    procedure GetExpectedCost(): Integer
    begin
        exit(11);
    end;
<<<<<<< HEAD

}
=======
}
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

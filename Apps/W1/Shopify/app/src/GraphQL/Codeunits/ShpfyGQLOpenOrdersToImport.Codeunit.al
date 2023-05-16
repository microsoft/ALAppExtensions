codeunit 30205 "Shpfy GQL OpenOrdersToImport" implements "Shpfy IGraphQL"
{
    Access = Internal;

    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{orders(first:25, query: \"status:open updated_at:>''{{Time}}''\"){ pageInfo { hasNextPage } edges { cursor node { legacyResourceId name createdAt updatedAt channel { name } test fullyPaid unpaid riskLevel displayFinancialStatus displayFulfillmentStatus subtotalLineItemsQuantity totalPriceSet { shopMoney { amount currencyCode } } customAttributes { key value } tags }}}}"}');
    end;

    internal procedure GetExpectedCost(): Integer
    begin
        exit(102);
    end;
}
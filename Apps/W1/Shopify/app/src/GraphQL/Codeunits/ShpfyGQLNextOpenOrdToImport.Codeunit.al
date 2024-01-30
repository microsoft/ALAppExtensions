namespace Microsoft.Integration.Shopify;

codeunit 30206 "Shpfy GQL NextOpenOrdToImport" implements "Shpfy IGraphQL"
{
    Access = Internal;

    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{orders(first:150, after:\"{{After}}\", query: \"status:open updated_at:>''{{Time}}''\"){pageInfo{hasNextPage} edges{cursor node{legacyResourceId name createdAt updatedAt test fullyPaid unpaid riskLevel displayFinancialStatus displayFulfillmentStatus subtotalLineItemsQuantity totalPriceSet{shopMoney{amount currencyCode}} customAttributes{key value} tags purchasingEntity { ... on PurchasingCompany { company { id }}}}}}}"}');
    end;

    internal procedure GetExpectedCost(): Integer
    begin
        exit(602);
    end;
}
namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL OrdersToImport (ID 30145) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30145 "Shpfy GQL OrdersToImport" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{orders(first:25, query: \"updated_at:>''{{Time}}''\"){pageInfo{hasNextPage} edges{cursor node{legacyResourceId name createdAt updatedAt channel { name } test fullyPaid unpaid riskLevel displayFinancialStatus displayFulfillmentStatus subtotalLineItemsQuantity totalPriceSet{shopMoney{amount currencyCode}} customAttributes{key value} tags}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(102);
    end;
}

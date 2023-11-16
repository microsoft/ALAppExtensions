namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL NextOrdersToImport (ID 30138) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30138 "Shpfy GQL NextOrdersToImport" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{orders(first:25, after:\"{{After}}\", query: \"updated_at:>''{{Time}}''\"){ pageInfo { hasNextPage } edges { cursor node { legacyResourceId name createdAt updatedAt channel { name } test fullyPaid unpaid riskLevel closed displayFinancialStatus displayFulfillmentStatus subtotalLineItemsQuantity totalPriceSet { shopMoney { amount currencyCode } } customAttributes { key value } tags }}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(103);
    end;
}

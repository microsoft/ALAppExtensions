/// <summary>
/// Codeunit Shpfy GQL NextOrdersToImport (ID 30138) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30138 "Shpfy GQL NextOrdersToImport" implements "Shpfy IGraphQL"
{

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query": "{orders(first:250, after:\"{{After}}\", query: \"status:open updated_at:>''{{Time}}''\"){pageInfo{hasNextPage} edges{cursor node{legacyResourceId name createdAt updatedAt test fullyPaid unpaid riskLevel displayFinancialStatus displayFulfillmentStatus subtotalLineItemsQuantity totalPriceSet{shopMoney{amount currencyCode}} customAttributes{key value} tags}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    procedure GetExpectedCost(): Integer
    begin
        exit(752);
    end;
}

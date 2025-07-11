namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL NextRevFulfillOrdLns (ID 30349) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30349 "Shpfy GQL NextRevFulfillOrdLns" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ reverseFulfillmentOrder(id: \"{{FulfillOrderId}}\") { lineItems(first: 10, after:\"{{After}}\") { pageInfo { endCursor hasNextPage } nodes { id fulfillmentLineItem { id lineItem { id name } } dispositions { id quantity type location { id legacyResourceId } } } } } }"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(15);
    end;
}

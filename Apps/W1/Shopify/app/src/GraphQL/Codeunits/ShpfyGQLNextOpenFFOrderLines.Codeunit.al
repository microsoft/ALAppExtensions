namespace Microsoft.Integration.Shopify;

codeunit 30237 "Shpfy GQL NextOpenFFOrderLines" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{fulfillmentOrder(id: \"gid:\/\/shopify\/FulfillmentOrder\/{{FulfillmentOrderId}}\") {lineItems(first: 25, after:\"{{After}}\") {pageInfo {hasNextPage} edges {cursor node {id totalQuantity remainingQuantity lineItem {product {legacyResourceId} variant {legacyResourceId}}}}}}}"}');
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
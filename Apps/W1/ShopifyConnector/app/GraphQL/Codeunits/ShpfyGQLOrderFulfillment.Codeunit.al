/// <summary>
/// Codeunit Shpfy GQL OrderFulfillment (ID 30143) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30143 "Shpfy GQL OrderFulfillment" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "query {order(id: \"gid://shopify/Order/{{OrderId}}\") {fulfillmentOrders(first: 1) {edges {cursor node {assignedLocation {location {legacyResourceId}} lineItems(first: 250) {edges {node {lineItem {id}}}}}} pageInfo {hasNextPage}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(500);
    end;

}

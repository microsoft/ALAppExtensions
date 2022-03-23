/// <summary>
/// Codeunit Shpfy GQL NextOrderFulfillm (ID 30137) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30137 "Shpfy GQL NextOrderFulfillm" implements "Shpfy IGraphQL"
{

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query": "query {order(id: \"gid://shopify/Order/{{OrderId}}\") {fulfillmentOrders(first: 1, after:\"{{After}}\") {edges {cursor node {assignedLocation {location {legacyResourceId}} lineItems(first: 250) {edges {node {lineItem {id}}}}}} pageInfo {hasNextPage}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    procedure GetExpectedCost(): Integer
    begin
        exit(500);
    end;

}

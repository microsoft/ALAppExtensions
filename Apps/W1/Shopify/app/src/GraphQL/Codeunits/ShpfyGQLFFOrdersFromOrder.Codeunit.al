namespace Microsoft.Integration.Shopify;

codeunit 30267 "Shpfy GQL FFOrdersFromOrder" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{order(id: \"gid:\/\/shopify\/Order\/{{OrderId}}\") { legacyResourceId fulfillmentOrders(first: 25, query:\"-status:closed\") { pageInfo { hasNextPage } edges { cursor node { id updatedAt status assignedLocation {location {legacyResourceId}} order {legacyResourceId} deliveryMethod {methodType}}}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(134);
    end;
}
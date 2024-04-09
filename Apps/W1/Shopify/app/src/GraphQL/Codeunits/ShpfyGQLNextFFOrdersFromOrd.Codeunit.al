namespace Microsoft.Integration.Shopify;

codeunit 30268 "Shpfy GQL NextFFOrdersFromOrd" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{order(id: \"gid:\/\/shopify\/Order\/{{OrderId}}\") { legacyResourceId fulfillmentOrders(first: 25, after:\"{{After}}\", query:\"-status:closed\") { pageInfo { hasNextPage } edges { cursor node { id updatedAt assignedLocation {location {legacyResourceId}} order {legacyResourceId} deliveryMethod {methodType}}}}}}"}');
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
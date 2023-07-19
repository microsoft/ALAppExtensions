codeunit 30267 "Shpfy GQL FFOrdersFromOrder" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{order(id: \"gid:\/\/shopify\/Order\/{{OrderId}}\") { legacyResourceId fulfillmentOrders(first: 25) { pageInfo { hasNextPage } edges { cursor node { id assignedLocation {location {legacyResourceId}} order {legacyResourceId}}}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(78);
    end;
}
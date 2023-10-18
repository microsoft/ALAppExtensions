namespace Microsoft.Integration.Shopify;

codeunit 30234 "Shpfy GQL OpenFulfillmOrders" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{fulfillmentOrders(first: 25, includeClosed: false) { pageInfo { hasNextPage } edges { cursor node { id updatedAt assignedLocation {location {legacyResourceId}} order {legacyResourceId}}}}}"}');
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
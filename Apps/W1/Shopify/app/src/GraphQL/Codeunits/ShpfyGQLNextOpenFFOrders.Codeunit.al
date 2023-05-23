codeunit 30236 "Shpfy GQL NextOpenFFOrders" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
<<<<<<< HEAD
        exit('{"query":"{fulfillmentOrders(first: 25, after:\"{{After}}\", includeClosed: false) { pageInfo { hasNextPage } edges { cursor node { id updatedAt assignedLocation {location {legacyResourceId}} order {legacyResourceId}}}}}"}');
=======
        exit('{"query":"{fulfillmentOrders(first: 25, after:\"{{After}}\", includeClosed: false) { pageInfo { hasNextPage } edges { cursor node { id assignedLocation {location {legacyResourceId}} order {legacyResourceId}}}}}"}');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
<<<<<<< HEAD
        exit(102);
=======
        exit(52);
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    end;
}
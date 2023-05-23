codeunit 30267 "Shpfy GQL FFOrdersFromOrder" implements "Shpfy IGraphQL"
{
<<<<<<< HEAD

=======
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
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
<<<<<<< HEAD
}
=======
}
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL RevFulfillOrders (ID 30105) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30105 "Shpfy GQL RevFulfillOrders" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ return(id: \"gid://shopify/Return/{{ReturnId}}\") { reverseFulfillmentOrders(first: 10) { pageInfo { endCursor hasNextPage } nodes { id } } } }"}');

    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(7);
    end;
}

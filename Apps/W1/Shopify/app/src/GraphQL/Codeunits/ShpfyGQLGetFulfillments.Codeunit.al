/// <summary>
/// Codeunit Shpfy GQL Get Fulfillments (ID 30356) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30356 "Shpfy GQL Get Fulfillments" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{order (id: \"gid://shopify/Order/{{OrderId}}\") { fulfillmentOrders ( first: {{NumberOfOrders}}) { nodes { id }}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(6);
    end;
}


/// <summary>
/// Codeunit Shpfy GQL LocationOrderLines (ID 30134) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30134 "Shpfy GQL LocationOrderLines" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{order(id: \"gid://shopify/Order/{{OrderId}}\"){lineItems(first: {{OrderLines}}){edges{node{id fulfillmentService{location{legacyResourceId}}}}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(25);
    end;

}

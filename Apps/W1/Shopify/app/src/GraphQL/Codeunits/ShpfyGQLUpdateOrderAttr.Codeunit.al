/// <summary>
/// Codeunit Shpfy GQL UpdateOrderAttr (ID 30149) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30149 "Shpfy GQL UpdateOrderAttr" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation  {orderUpdate(input: {id: \"gid://shopify/Order/{{OrderId}}\" customAttributes: {{CustomAttributes}}}) {order {name}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(100);
    end;

}

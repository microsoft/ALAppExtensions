namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL CloseOrder (ID 30217) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30217 "Shpfy GQL CloseOrder" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { orderClose(input: { id: \"gid://shopify/Order/{{OrderId}}\" }) { order { legacyResourceId closed closedAt }, userErrors {field, message}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(55);
    end;
}
namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL ProductMetafieldIds (ID 30332) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30332 "Shpfy GQL ProductMetafieldIds" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{product(id: \"gid://shopify/Product/{{ProductId}}\") { metafields(first: 50) {edges{node{legacyResourceId updatedAt}}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(50);
    end;

}

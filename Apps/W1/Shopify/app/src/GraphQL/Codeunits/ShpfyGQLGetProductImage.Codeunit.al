namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL GetProductImage (ID 30365) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30365 "Shpfy GQL GetProductImage" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ product(id: \"gid://shopify/Product/{{ProductId}}\") { media(query: \"id:{{ImageId}}\", first:1) { edges {node { id }}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(4);
    end;
}

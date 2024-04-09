namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL NextCatalogProducts (ID 30310) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30310 "Shpfy GQL NextCatalogProducts" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{catalog(id: \"gid://shopify/Catalog/{{CatalogId}}\"){ id publication { id products(first: 250, after:\"{{After}}\") { edges { cursor node { id }} pageInfo { hasNextPage }}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(15);
    end;
}

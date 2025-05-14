namespace Microsoft.Integration.Shopify;

codeunit 30402 "Shpfy GQL Catalog Markets" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{ catalog (id: \"gid://shopify/Catalog/{{CatalogId}}\") { id title ... on MarketCatalog { markets(first: 5) { pageInfo { hasNextPage } edges { cursor node { id name }}}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(120);
    end;
}
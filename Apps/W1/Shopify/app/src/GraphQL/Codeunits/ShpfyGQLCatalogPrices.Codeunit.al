namespace Microsoft.Integration.Shopify;

codeunit 30296 "Shpfy GQL CatalogPrices" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "query { catalog(id: \"gid://shopify/Catalog/{{CatalogId}}\") { id priceList {id currency prices(first:100) {edges {cursor node {variant {id} price {amount} compareAtPrice {amount}}} pageInfo {hasNextPage}}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(204);
    end;
}

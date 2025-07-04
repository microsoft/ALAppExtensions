namespace Microsoft.Integration.Shopify;

codeunit 30401 "Shpfy GQL NextMarketCatalogs" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{ catalogs(first:25, type: MARKET, after:\"{{After}}\", query: \"status:ACTIVE\"){ pageInfo { hasNextPage } edges { cursor node { id title priceList { currency }}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(27);
    end;
}

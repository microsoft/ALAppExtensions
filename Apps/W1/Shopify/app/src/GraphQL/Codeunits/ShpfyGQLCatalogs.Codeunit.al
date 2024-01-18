namespace Microsoft.Integration.Shopify;

codeunit 30291 "Shpfy GQL Catalogs" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{catalogs(first:25, query: \"company_id:''{{CompanyId}}'' status:ACTIVE\"){ pageInfo{hasNextPage} edges{cursor node{ id title}}}}"}');
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
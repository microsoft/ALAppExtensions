namespace Microsoft.Integration.Shopify;

codeunit 30294 "Shpfy GQL CreatePublication" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { publicationCreate(input: {autoPublish: true, catalogId: \"gid://shopify/CompanyLocationCatalog/{{CatalogId}}\", defaultState: ALL_PRODUCTS}) { publication {id}, userErrors {field, message}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(10);
    end;
}

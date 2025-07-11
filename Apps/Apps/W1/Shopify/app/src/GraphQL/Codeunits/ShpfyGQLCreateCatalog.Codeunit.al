namespace Microsoft.Integration.Shopify;

codeunit 30293 "Shpfy GQL CreateCatalog" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { catalogCreate(input: {title: \"{{Title}}\", status: ACTIVE, context: {companyLocationIds: \"gid://shopify/CompanyLocation/{{CompanyLocationId}}\"}}) { catalog {id}, userErrors {field, message}}}"}');
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

namespace Microsoft.Integration.Shopify;

codeunit 30288 "Shpfy GQL CompanyAssignMainCon" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { companyAssignMainContact(companyId: \"gid://shopify/Company/{{CompanyId}}\", companyContactId: \"gid://shopify/CompanyContact/{{CompanyContactId}}\") { company {id}, userErrors {field, message}}}"}');
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
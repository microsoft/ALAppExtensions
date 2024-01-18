namespace Microsoft.Integration.Shopify;

codeunit 30289 "Shpfy GQL CompanyAssignConRole" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { companyContactAssignRole(companyContactId: \"gid://shopify/CompanyContact/{{ContactId}}\", companyContactRoleId: \"gid://shopify/CompanyContactRole/{{ContactRoleId}}\", companyLocationId: \"gid://shopify/CompanyLocation/{{LocationId}}\") { companyContactRoleAssignment {id}, userErrors {field, message}}}"}');
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
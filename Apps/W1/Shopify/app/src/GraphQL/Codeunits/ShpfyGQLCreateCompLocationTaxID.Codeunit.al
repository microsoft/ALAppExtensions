namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL CreateCompLocTaxId (ID 30369) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30369 "Shpfy GQL CreateCompLocTaxId" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"mutation {companyLocationCreateTaxRegistration(locationId: \"gid://shopify/CompanyLocation/{{LocationId}}\", taxId: \"{{TaxId}}\") {companyLocation {id, name, taxRegistrationId}, userErrors {field, message}}}"}');
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
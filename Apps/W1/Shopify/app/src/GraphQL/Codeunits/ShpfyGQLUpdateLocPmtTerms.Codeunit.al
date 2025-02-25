namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL UpdateLocPmtTerms (ID 30370) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30370 "Shpfy GQL UpdateLocPmtTerms" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"mutation {companyLocationUpdate(companyLocationId: \"gid://shopify/CompanyLocation/{{LocationId}}\", input: {buyerExperienceConfiguration: {paymentTermsTemplateId: \"gid://shopify/PaymentTermsTemplate/{{PaymentTermsId}}\"}}) {companyLocation {id, name}, userErrors {field, message}}}"}');
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
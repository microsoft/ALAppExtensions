namespace Microsoft.Integration.Shopify;

codeunit 30168 "Shpfy GQL CompLocations" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{companyLocations(first:20, query: \"company_id:''{{CompanyId}}''\") {pageInfo { hasNextPage } edges { cursor node { id name billingAddress {address1 address2 city countryCode phone province recipient zip zoneCode} buyerExperienceConfiguration {paymentTermsTemplate {id}} taxRegistrationId}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(24);
    end;
}
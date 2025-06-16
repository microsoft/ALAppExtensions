namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL CreateCompanyLocation (ID 30105) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30105 "Shpfy GQL CreateCompLocation" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { companyLocationCreate( companyId: \"gid://shopify/Company/{{CompanyId}}\" input: { externalId: \"{{ExternalId}}\" name: \"{{Name}}\" phone: \"{{Phone}}\" taxExempt: {{TaxExempt}} taxRegistrationId: \"{{TaxRegistrationId}}\" billingAddress: { address1: \"{{BillingAddress1}}\" address2: \"{{BillingAddress2}}\" city: \"{{BillingCity}}\" countryCode: {{BillingCountryCode}} firstName: \"{{BillingFirstName}}\" lastName: \"{{BillingLastName}}\" phone: \"{{BillingPhone}}\" zoneCode: \"{{BillingZoneCode}}\" zip: \"{{BillingZip}}\" } shippingAddress: { address1: \"{{ShippingAddress1}}\" address2: \"{{ShippingAddress2}}\" city: \"{{ShippingCity}}\" countryCode: {{ShippingCountryCode}} firstName: \"{{ShippingFirstName}}\" lastName: \"{{ShippingLastName}}\" phone: \"{{ShippingPhone}}\" zoneCode: \"{{ShippingZoneCode}}\" zip: \"{{ShippingZip}}\" } billingSameAsShipping: {{BillingSameAsShipping}} buyerExperienceConfiguration: { checkoutToDraft: {{CheckoutToDraft}} paymentTermsTemplateId: \"gid://shopify/PaymentTermsTemplate/{{PaymentTermsTemplateId}}\" editableShippingAddress: {{EditableShippingAddress}} } } ) { companyLocation { id name billingAddress { address1 address2 city countryCode phone province recipient zip zoneCode } shippingAddress { address1 address2 city countryCode phone province recipient zip zoneCode } buyerExperienceConfiguration { paymentTermsTemplate { id } checkoutToDraft editableShippingAddress } taxRegistrationId taxExemptions } userErrors { field message } } }"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(15);
    end;
}

/// <summary>
/// Codeunit Shpfy GQL Customer (ID 30127) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30127 "Shpfy GQL Customer" implements "Shpfy IGraphQL"
{

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"{customer(id: \"gid://shopify/Customer/{{CustomerId}}\") {legacyResourceId firstName lastName email phone acceptsMarketing acceptsMarketingUpdatedAt taxExempt taxExemptions verifiedEmail state hasNote note createdAt updatedAt tags addresses {id company firstName lastName address1 address2 zip city countryCodeV2 country provinceCode province phone} defaultAddress {id} metafields(namespace: \"D365BC\" first: 10) {edges {node {id namespace ownerType legacyResourceId key value}}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    procedure GetExpectedCost(): Integer
    begin
        exit(15);
    end;
}

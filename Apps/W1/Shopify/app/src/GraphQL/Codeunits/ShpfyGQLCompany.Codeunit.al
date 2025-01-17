namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL Company (ID 30301) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30302 "Shpfy GQL Company" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{company(id: \"gid://shopify/Company/{{CompanyId}}\") {name id note createdAt updatedAt mainContact { id customer { id firstName lastName email phone}} locations(first:1, sortKey: CREATED_AT ) {edges { node { id name billingAddress {address1 address2 city countryCode phone province recipient zip zoneCode} taxRegistrationId }}} metafields(first: 50) {edges {node {id namespace ownerType legacyResourceId key value type}}}}}"}');
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

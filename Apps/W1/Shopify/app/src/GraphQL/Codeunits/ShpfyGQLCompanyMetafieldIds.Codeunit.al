namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL CompanyMetafieldIds (ID 30215) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30215 "Shpfy GQL CompanyMetafieldIds" implements "Shpfy IGraphQL"
{
    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"{company(id: \"gid://shopify/Company/{{CompanyId}}\") {metafields(first: 50) {edges {node {id namespace ownerType legacyResourceId }}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    procedure GetExpectedCost(): Integer
    begin
        exit(50);
    end;

}

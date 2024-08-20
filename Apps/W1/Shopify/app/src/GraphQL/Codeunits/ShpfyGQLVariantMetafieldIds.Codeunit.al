namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL VariantMetafieldIds (ID 30336) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30336 "Shpfy GQL VariantMetafieldIds" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{productVariant(id: \"gid://shopify/ProductVariant/{{VariantId}}\") { metafields(first: 50) {edges{ node{legacyResourceId updatedAt}}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(50);
    end;

}

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL ProductVariantDelete (ID 30344) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30344 "Shpfy GQL ProductVariantDelete" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"mutation {productVariantDelete(id: \"gid://shopify/ProductVariant/{{VariantId}}\") {deletedProductVariantId userErrors{field message}}}"}');
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

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL ProductById (ID 30146) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30146 "Shpfy GQL ProductById" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{product(id: \"gid://shopify/Product/{{ProductId}}\") {createdAt updatedAt hasOnlyDefaultVariant description(truncateAt: {{MaxLengthDescription}}) descriptionHtml onlineStorePreviewUrl onlineStoreUrl productType status tags title vendor seo{description, title} images(first: 1) {edges{node{id}}} metafields(first: 50) {edges {node {id namespace type legacyResourceId key value}}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(25);
    end;

}

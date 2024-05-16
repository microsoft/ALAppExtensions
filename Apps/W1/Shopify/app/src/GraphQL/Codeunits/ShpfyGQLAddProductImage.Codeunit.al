namespace Microsoft.Integration.Shopify;

codeunit 30219 "Shpfy GQL AddProductImage" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { productCreateMedia(media: {mediaContentType: IMAGE, originalSource: \"{{ResourceUrl}}\"}, productId: \"gid://shopify/Product/{{ProductId}}\") { media { ...mediaFieldsByType } mediaUserErrors {code field message}}} fragment mediaFieldsByType on Media { ... on MediaImage { id }}"}');
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
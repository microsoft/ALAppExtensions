namespace Microsoft.Integration.Shopify;

codeunit 30221 "Shpfy GQL UpdateProductImage" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { productUpdateMedia(media: {id: \"gid://shopify/MediaImage/{{ImageId}}\" previewImageSource: \"{{ResourceUrl}}\"}, productId: \"gid://shopify/Product/{{ProductId}}\") { media { ...mediaFieldsByType }}} fragment mediaFieldsByType on Media { ... on MediaImage { id }}"}');
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
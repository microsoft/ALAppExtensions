codeunit 30221 "Shpfy GQL UpdateProductImage" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { productImageUpdate(productId: \"gid://shopify/Product/{{ProductId}}\", image: {id: \"gid://shopify/ProductImage/{{ImageId}}\", src: \"{{ResourceUrl}}\"}) { image { id }}}"}');
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
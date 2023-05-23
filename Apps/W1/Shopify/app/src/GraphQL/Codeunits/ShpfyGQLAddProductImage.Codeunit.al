codeunit 30219 "Shpfy GQL AddProductImage" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { productAppendImages(input: {id: \"gid://shopify/Product/{{ProductId}}\", images: {src: \"{{ResourceUrl}}\"}}) { newImages { id }}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(10);
    end;
<<<<<<< HEAD
}






=======
}
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

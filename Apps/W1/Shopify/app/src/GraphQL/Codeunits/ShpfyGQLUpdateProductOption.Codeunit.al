namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL UpdateProductOption (ID 30344) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30344 "Shpfy GQL UpdateProductOption" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { productOptionUpdate(productId: \"gid://shopify/Product/{{ProductId}}\", option: {id: \"gid://shopify/ProductOption/{{OptionId}}\", name: \"{{OptionName}}\"}) { product { id } userErrors { field message } } }"}');
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
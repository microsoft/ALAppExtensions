namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL ProductOptionUpdate (ID 30213) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30213 "Shpfy GQL ProductOptionUpdate" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { productOptionUpdate(productId: \"gid://shopify/Product/{{ProductId}}\", option: {id: \"{{OptionId}}\", name: \"{{OptionName}}\"}) { product { id options { id name }} userErrors {field message}}}"}');
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

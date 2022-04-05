/// <summary>
/// Codeunit Shpfy GQL VariantIds (ID 70007695) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30151 "Shpfy GQL VariantIds" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{product(id: \"gid://shopify/Product/{{ProductId}}\") {variants(first:200){pageInfo{hasNextPage} edges{cursor node{legacyResourceId updatedAt}}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(220);
    end;

}

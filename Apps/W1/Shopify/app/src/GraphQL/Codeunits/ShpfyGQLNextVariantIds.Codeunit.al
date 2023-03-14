/// <summary>
/// Codeunit Shpfy GQL NextVariantIds (ID 30141) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30141 "Shpfy GQL NextVariantIds" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{product(id: \"gid://shopify/Product/{{ProductId}}\") {variants(first:200, after:\"{{After}}}}\"){pageInfo{hasNextPage} edges{cursor node{legacyResourceId updatedAt}}}}}"}');
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

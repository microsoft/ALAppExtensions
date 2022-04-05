/// <summary>
/// Codeunit Shpfy GQL NextVariantImages (ID 70007686) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30142 "Shpfy GQL NextVariantImages" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{productVariants(first:200, after:\"{{After}}\"){pageInfo{hasNextPage} edges{cursor node{legacyResourceId image(maxHeight: 360, maxWidth: 360) {id, transformedSrc}}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(420);
    end;

}

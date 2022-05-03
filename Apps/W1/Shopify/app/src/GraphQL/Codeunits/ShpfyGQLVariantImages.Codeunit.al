/// <summary>
/// Codeunit Shpfy GQL VariantImages (ID 30152) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30152 "Shpfy GQL VariantImages" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{productVariants(first:200){pageInfo{hasNextPage} edges{cursor node{legacyResourceId image(maxHeight: 360, maxWidth: 360) {id, transformedSrc}}}}}"}');
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

/// <summary>
/// Codeunit Shpfy GQL ProductImages (ID 70007683) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30148 "Shpfy GQL ProductImages" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{products(first:100){pageInfo{hasNextPage},edges{cursor node{legacyResourceId images(maxHeight: 360, maxWidth: 360, first: 1) {edges {node {id, transformedSrc}}}}}}}"}');
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

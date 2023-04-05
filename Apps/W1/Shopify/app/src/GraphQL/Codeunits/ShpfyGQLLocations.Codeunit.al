/// <summary>
/// Codeunit Shpfy GQL Locations (ID 30100) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30100 "Shpfy GQL Locations" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{locations(first: 10) { edges {node {id isActive isPrimary name legacyResourceId}cursor} pageInfo {hasNextPage}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(12);
    end;
}
namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL NextInvEntries (ID 30136) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30136 "Shpfy GQL NextInvEntries" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{location(id:\"gid://shopify/Location/{{LocationId}}\"){inventoryLevels(first:100, after:\"{{After}}\"){pageInfo{hasNextPage} edges{cursor node{id quantities(names: \"available\") {quantity} item{id variant{id product{id}}}}}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(403);
    end;

}

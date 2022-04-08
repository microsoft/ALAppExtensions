/// <summary>
/// Codeunit Shpfy GQL ProductIds (ID 70007692) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30147 "Shpfy GQL ProductIds" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{products(first:200, query: \"updated_at:>''{{Time}}'' gift_card:false\"){pageInfo{hasNextPage} edges{cursor node{id updatedAt}}}}"}');
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

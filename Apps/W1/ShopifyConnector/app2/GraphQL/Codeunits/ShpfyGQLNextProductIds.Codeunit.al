/// <summary>
/// Codeunit Shpfy GQL NextProductIds (ID 30139) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30139 "Shpfy GQL NextProductIds" implements "Shpfy IGraphQL"
{

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"{products(first:200, after:\"{{After}}\", query: \"updated_at:>''{{Time}}''\"){pageInfo{hasNextPage} edges{cursor node{id updatedAt}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    procedure GetExpectedCost(): Integer
    begin
        exit(220);
    end;

}

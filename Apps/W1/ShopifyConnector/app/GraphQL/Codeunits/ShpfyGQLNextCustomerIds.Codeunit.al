/// <summary>
/// Codeunit Shpfy GQL NextCustomerIds (ID 30135) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30135 "Shpfy GQL NextCustomerIds" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{customers(first:200, after:\"{{After}}\", query: \"updated_at:>''{{LastSync}}''\"){pageInfo{hasNextPage} edges{cursor node{id updatedAt}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(202);
    end;
}

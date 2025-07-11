namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL NextCompanyIds (ID 30300) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30300 "Shpfy GQL NextCompanyIds" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{companies(first:200, after:\"{{After}}\", query: \"updated_at:>''{{LastSync}}''\"){pageInfo{hasNextPage} edges{cursor node{id updatedAt}}}}"}');
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

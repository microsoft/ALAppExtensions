namespace Microsoft.Integration.Shopify;

codeunit 30242 "Shpfy GQL NextAllCustomerIds" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{customers(first:100, after:\"{{After}}\"){pageInfo{endCursor hasNextPage} nodes{ legacyResourceId }}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(103);
    end;
}

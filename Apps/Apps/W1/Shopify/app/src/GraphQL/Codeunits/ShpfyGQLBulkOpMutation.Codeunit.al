namespace Microsoft.Integration.Shopify;

codeunit 30276 "Shpfy GQL BulkOpMutation" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { bulkOperationRunMutation(mutation: \"{{BulkMutation}}\", stagedUploadPath: \"{{ResourceUrl}}\") { bulkOperation { id status } userErrors { field message }}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(10);
    end;
}
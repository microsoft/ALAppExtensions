namespace Microsoft.Integration.Shopify;

codeunit 30277 "Shpfy GQL BulkOperations" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "query { currentBulkOperation(type: MUTATION) { id status errorCode createdAt completedAt fileSize url partialDataUrl }}"}');
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
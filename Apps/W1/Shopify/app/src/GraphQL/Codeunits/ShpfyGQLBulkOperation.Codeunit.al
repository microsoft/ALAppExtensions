namespace Microsoft.Integration.Shopify;

codeunit 30282 "Shpfy GQL BulkOperation" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "query { node(id: \"gid://shopify/BulkOperation/{{BulkOperationId}}\") { ... on BulkOperation { status errorCode completedAt url partialDataUrl }}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(1);
    end;
}
namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL DraftOrderComplete (ID 30341) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30341 "Shpfy GQL DraftOrderComplete" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation {draftOrderComplete(id: \"gid://shopify/DraftOrder/{{DraftOrderId}}\") { draftOrder { order { legacyResourceId, name }} userErrors { field, message }}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(11);
    end;
}

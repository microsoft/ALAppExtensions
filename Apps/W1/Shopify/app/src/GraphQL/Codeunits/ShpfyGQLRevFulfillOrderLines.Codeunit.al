namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL RevFulfillOrderLines (ID 30348) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30348 "Shpfy GQL RevFulfillOrderLines" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ reverseFulfillmentOrder(id: \"{{FulfillOrderId}}\") { id lineItems(first: 10) { nodes { id fulfillmentLineItem { id lineItem { id name } } dispositions { id quantity type location { id legacyResourceId } } } } } }"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(15);
    end;
}

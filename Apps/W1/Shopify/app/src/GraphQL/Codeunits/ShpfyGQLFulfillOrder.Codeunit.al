// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL Fulfill Order (ID 30313) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30355 "Shpfy GQL Fulfill Order" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { fulfillmentCreate ( fulfillment: { lineItemsByFulfillmentOrder: [{ fulfillmentOrderId: \"gid://shopify/FulfillmentOrder/{{FulfillmentOrderId}}\" }] }) { fulfillment {id, status} userErrors {field, message}}}"}');
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

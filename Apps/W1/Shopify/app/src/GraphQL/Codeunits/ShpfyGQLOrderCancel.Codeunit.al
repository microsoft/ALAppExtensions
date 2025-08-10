// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL CancelOrder (ID 30307) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30307 "Shpfy GQL OrderCancel" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { orderCancel(orderId: \"gid://shopify/Order/{{OrderId}}\", notifyCustomer: {{NotifyCustomer}}, refund: {{Refund}}, restock: {{Restock}}, reason: {{CancelReason}}) { orderCancelUserErrors {field, message}}}"}');
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

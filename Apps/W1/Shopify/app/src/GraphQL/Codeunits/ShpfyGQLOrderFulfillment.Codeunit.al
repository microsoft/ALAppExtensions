// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL OrderFulfillment (ID 30143) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30143 "Shpfy GQL OrderFulfillment" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "query {order(id: \"gid://shopify/Order/{{OrderId}}\") { legacyResourceId fulfillments { legacyResourceId name createdAt updatedAt displayStatus status totalQuantity location { legacyResourceId } trackingInfo { number url company } service { serviceName type } fulfillmentLineItems(first: 10) { pageInfo { endCursor hasNextPage } nodes { id quantity originalTotalSet { presentmentMoney { amount } shopMoney { amount }} lineItem { id isGiftCard }}}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(37);
    end;

}

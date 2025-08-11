// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL RefundShippingLines (ID 30399) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30399 "Shpfy GQL NextRefundShipLines" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ refund(id: \"gid://shopify/Refund/{{RefundId}}\") { refundShippingLines(first: 10, after:\"{{After}}\") { pageInfo { endCursor hasNextPage } nodes { id shippingLine { title } subtotalAmountSet { presentmentMoney { amount } shopMoney { amount }} taxAmountSet { presentmentMoney { amount } shopMoney { amount }}}}}}"}');
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
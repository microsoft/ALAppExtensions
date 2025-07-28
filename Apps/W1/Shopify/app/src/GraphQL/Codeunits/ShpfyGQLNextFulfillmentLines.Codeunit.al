// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL NextFulfillmentLines (ID 30137) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30137 "Shpfy GQL NextFulfillmentLines" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{ fulfillment(id: \"gid://shopify/Fulfillment/{{FulfillmentId}}\") {fulfillmentLineItems(first: 10, after:\"{{After}}\") { pageInfo { endCursor hasNextPage } nodes { id quantity originalTotalSet { presentmentMoney { amount } shopMoney { amount } } lineItem { id }}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(33);
    end;

}

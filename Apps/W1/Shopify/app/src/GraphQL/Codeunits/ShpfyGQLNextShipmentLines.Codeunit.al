// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

codeunit 30222 "Shpfy GQL NextShipmentLines" implements "Shpfy IGraphQL"
{
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{order(id: \"gid://shopify/Order/{{OrderId}}\") {shippingLines(first: 10, after:\"{{After}}\") { pageInfo { endCursor hasNextPage } nodes { id title code source discountAllocations { allocatedAmountSet { presentmentMoney { amount } shopMoney { amount }}} originalPriceSet { presentmentMoney { amount } shopMoney { amount }} discountedPriceSet { presentmentMoney { amount } shopMoney { amount }} taxLines { title rate ratePercentage priceSet { presentmentMoney { amount } shopMoney {amount}}}}}}}"}');
    end;

    internal procedure GetExpectedCost(): Integer
    begin
        exit(73);
    end;
}
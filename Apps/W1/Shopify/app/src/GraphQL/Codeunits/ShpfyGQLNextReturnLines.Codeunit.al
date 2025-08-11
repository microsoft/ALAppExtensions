// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

codeunit 30227 "Shpfy GQL NextReturnLines" implements "Shpfy IGraphQL"
{

    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ return(id: \"gid://shopify/Return/{{ReturnId}}\") { returnLineItems(first: 10, after:\"{{After}}\") { pageInfo { endCursor hasNextPage } nodes { ... on ReturnLineItem { id quantity returnReason returnReasonNote refundableQuantity refundedQuantity customerNote totalWeight { unit value } withCodeDiscountedTotalPriceSet { presentmentMoney { amount } shopMoney { amount } } fulfillmentLineItem { id lineItem { id } quantity originalTotalSet { presentmentMoney { amount } shopMoney { amount } } discountedTotalSet { presentmentMoney { amount } shopMoney { amount }}}}}}}}"}');
    end;

    internal procedure GetExpectedCost(): Integer
    begin
        exit(3);
    end;
}
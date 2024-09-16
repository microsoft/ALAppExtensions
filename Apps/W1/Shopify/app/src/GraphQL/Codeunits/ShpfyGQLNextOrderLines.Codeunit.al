namespace Microsoft.Integration.Shopify;

codeunit 30209 "Shpfy GQL NextOrderLines" implements "Shpfy IGraphQL"
{
    Access = Internal;

    procedure GetGraphQL(): Text
    begin
        exit('{"query": "query { order(id: \"gid:\/\/shopify\/Order\/{{OrderId}}\") { legacyResourceId lineItems(first: 3, after:\"{{After}}\") { pageInfo { hasNextPage endCursor } nodes { id name quantity currentQuantity nonFulfillableQuantity sku title variantTitle isGiftCard product { legacyResourceId } variant { legacyResourceId } customAttributes { key value } refundableQuantity requiresShipping restockable fulfillmentStatus duties { countryCodeOfOrigin price { presentmentMoney { amount } shopMoney { amount }} taxLines { channelLiable priceSet { presentmentMoney { amount } shopMoney { amount }} rate ratePercentage title }} taxable fulfillableQuantity fulfillmentService { location { legacyResourceId name } shippingMethods { code label } serviceName } discountAllocations { allocatedAmountSet { presentmentMoney { amount } shopMoney { amount }}} discountedTotalSet { presentmentMoney { amount } shopMoney { amount }} discountedUnitPriceSet { presentmentMoney { amount } shopMoney { amount }} originalTotalSet { presentmentMoney { amount } shopMoney { amount }} originalUnitPriceSet { presentmentMoney { amount } shopMoney { amount }} totalDiscountSet { presentmentMoney { amount } shopMoney { amount }} unfulfilledDiscountedTotalSet { presentmentMoney { amount } shopMoney { amount }} taxLines { channelLiable rate ratePercentage title priceSet { presentmentMoney { amount } shopMoney { amount }}}}}}}"}');
    end;

    procedure GetExpectedCost(): Integer
    begin
        exit(65)
    end;
}
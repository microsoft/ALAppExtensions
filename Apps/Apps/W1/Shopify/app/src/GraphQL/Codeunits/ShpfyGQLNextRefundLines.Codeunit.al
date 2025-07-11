namespace Microsoft.Integration.Shopify;

codeunit 30232 "Shpfy GQL NextRefundLines" implements "Shpfy IGraphQL"
{

    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ refund(id: \"gid://shopify/Refund/{{RefundId}}\") { refundLineItems(first: 10, after:\"{{After}}\") { pageInfo { endCursor hasNextPage } nodes { lineItem { id } quantity restockType location { legacyResourceId } restocked priceSet { presentmentMoney { amount } shopMoney { amount }} subtotalSet { presentmentMoney { amount } shopMoney { amount }} totalTaxSet { presentmentMoney { amount } shopMoney { amount }}}}}}"}');
    end;

    internal procedure GetExpectedCost(): Integer
    begin
        exit(53);
    end;
}
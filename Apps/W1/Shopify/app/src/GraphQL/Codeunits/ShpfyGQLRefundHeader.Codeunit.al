namespace Microsoft.Integration.Shopify;

codeunit 30229 "Shpfy GQL RefundHeader" implements "Shpfy IGraphQL"
{

    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ refund(id: \"gid://shopify/Refund/{{RefundId}}\") { createdAt updatedAt note duties { amountSet { presentmentMoney { amount } shopMoney { amount }} originalDuty { countryCodeOfOrigin harmonizedSystemCode id price { presentmentMoney { amount } shopMoney { amount }} taxLines { channelLiable title rate ratePercentage priceSet { presentmentMoney { amount } shopMoney { amount }}}}} return { id } order { legacyResourceId } totalRefundedSet { presentmentMoney { amount } shopMoney { amount }}}}"}');
    end;

    internal procedure GetExpectedCost(): Integer
    begin
        exit(3);
    end;
}
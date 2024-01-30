namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL CreateFulfillment (ID 30215) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30215 "Shpfy GQL CreateFulfillment" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { fulfillmentCreate(input: {orderId: "gid://shopify/Order/{{OrderId}}", locationId: "gid://shopify/Location/{{LocationId}}", lineItems: [{id: "gid://shopify/LineItem/{{OrderLineId}}", quantity: {{Quantity}}}], notifyCustomer: true, trackingCompany: "{{TrackingCompany}}", trackingNumbers: "{{TrackingNo}}", trackingUrls: "{{TrackingUrl}}"}) {fulfillment { legacyResourceId name createdAt updatedAt deliveredAt displayStatus estimatedDeliveryAt status totalQuantity location { legacyResourceId } trackingInfo { number url company } service { serviceName type shippingMethods { code label }} fulfillmentLineItems(first: 10) { pageInfo { endCursor hasNextPage } nodes { id quantity originalTotalSet { presentmentMoney { amount } shopMoney { amount }} lineItem { id product { isGiftCard }}}}}, userErrors {field, message}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(55);
    end;
}
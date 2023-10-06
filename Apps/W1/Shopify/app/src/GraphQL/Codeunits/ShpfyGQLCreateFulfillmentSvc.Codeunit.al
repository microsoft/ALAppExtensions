namespace Microsoft.Integration.Shopify;

codeunit 30233 "Shpfy GQL CreateFulfillmentSvc" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { fulfillmentServiceCreate(name: \"Business Central Fulfillment Service\", fulfillmentOrdersOptIn: true, callbackUrl: \"https://www.shopifyconnector.com/callback_url\") {fulfillmentService {id fulfillmentOrdersOptIn}}}"}');
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
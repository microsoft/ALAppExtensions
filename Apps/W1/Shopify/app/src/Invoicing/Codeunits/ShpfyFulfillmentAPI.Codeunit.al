namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Fulfillment API (ID 30361).
/// </summary>
codeunit 30361 "Shpfy Fulfillment API"
{
    Access = Internal;

    var
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";

    /// <summary>
    /// Creates a fulfillment for a provided fulfillment order id.
    /// </summary>
    /// <param name="FulfillmentOrderId">Fulfillment order id.</param>
    internal procedure CreateFulfillment(FulfillmentOrderId: BigInteger)
    var
        JResponse: JsonToken;
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
    begin
        GraphQLType := "Shpfy GraphQL Type"::FulfillOrder;
        Parameters.Add('FulfillmentOrderId', Format(FulfillmentOrderId));
        JResponse := ShpfyCommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
    end;

    /// <summary>
    /// Gets fulfillment order ids for a provided shopify order id.
    /// </summary>
    /// <param name="OrderId">Shopify order id to get fulfillments from.</param>
    /// <param name="NumberOfLines">Number of fulfillment orders to get.</param>
    /// <returns>List of fulfillment order ids.</returns>
    internal procedure GetFulfillmentOrderIds(OrderId: Text; NumberOfLines: Integer) FulfillmentOrderList: List of [BigInteger]
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
        JFulfillments: JsonToken;
    begin
        GraphQLType := "Shpfy GraphQL Type"::GetFulfillmentOrderIds;
        Parameters.Add('OrderId', OrderId);
        Parameters.Add('NumberOfOrders', Format(NumberOfLines));
        JFulfillments := ShpfyCommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        FulfillmentOrderList := ParseFulfillmentOrders(JFulfillments);

        exit(FulfillmentOrderList);
    end;

    /// <summary>
    /// Sets a global shopify shop to be used for fulfillment api functionality.
    /// </summary>
    /// <param name="ShopCode">Shopify shop code to be set.</param>
    internal procedure SetShop(ShopCode: Code[20])
    begin
        ShpfyCommunicationMgt.SetShop(ShopCode);
    end;

    local procedure ParseFulfillmentOrders(JFulfillments: JsonToken) FulfillmentOrderList: List of [BigInteger]
    var
        ShpfyJsonHelper: Codeunit "Shpfy Json Helper";
        JArray: JsonArray;
        JToken: JsonToken;
    begin
        JArray := ShpfyJsonHelper.GetJsonArray(JFulfillments, 'data.order.fulfillmentOrders.nodes');

        foreach JToken in JArray do
            FulfillmentOrderList.Add(ShpfyCommunicationMgt.GetIdOfGId(ShpfyJsonHelper.GetValueAsText(JToken, 'id')));
    end;
}
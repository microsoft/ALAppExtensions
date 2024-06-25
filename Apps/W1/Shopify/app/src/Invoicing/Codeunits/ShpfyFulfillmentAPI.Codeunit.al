namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Fulfillment API (ID 30315).
/// </summary>
codeunit 30315 "Shpfy Fulfillment API"
{
    var
        ShpfyJsonHelper: Codeunit "Shpfy Json Helper";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";

    /// <summary>
    /// Fulfills shopify orders for each fulfillment id parsed from a completed draft order.
    /// </summary>
    /// <param name="JResponse">Json response from a completed draft order</param>
    /// <param name="ShopCode">Shopify shop code to be used.</param>
    internal procedure FulfillShopifyOrder(JResponse: JsonToken; ShopCode: Code[20])
    var
        FulfillmentOrderList: List of [Text];
        FulfillmentOrderId: Text;
        ResponseJsonToken: JsonToken;
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
    begin
        ShpfyCommunicationMgt.SetShop(ShopCode);
        FulfillmentOrderList := ParseFulfillmentOrders(JResponse);
        GraphQLType := "Shpfy GraphQL Type"::FulfillOrder;

        foreach FulfillmentOrderId in FulfillmentOrderList do begin
            Parameters.Add('FulfillmentOrderId', FulfillmentOrderId);
            ResponseJsonToken := ShpfyCommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            Clear(Parameters);
        end;
    end;

    local procedure ParseFulfillmentOrders(ResponseJsonToken: JsonToken) FulfillmentOrderList: List of [Text]
    var
        Counter: Integer;
        FulfillmentOrderArray: JsonArray;
        FulfillmentObject: JsonObject;
        FulfillmentOrderToken: JsonToken;
        JToken: JsonToken;
    begin
        FulfillmentObject := ResponseJsonToken.AsObject();
        FulfillmentObject.SelectToken('data.draftOrderComplete.draftOrder.order.fulfillmentOrders.nodes', JToken);
        FulfillmentOrderArray := ShpfyJsonHelper.GetJsonArray(JToken, '');

        for Counter := 0 to FulfillmentOrderArray.Count() - 1 do begin
            FulfillmentOrderArray.Get(Counter, FulfillmentOrderToken);
            FulfillmentOrderList.Add(Format(ShpfyCommunicationMgt.GetIdOfGId(ShpfyJsonHelper.GetValueAsText(FulfillmentOrderToken, 'id'))));
        end;
    end;
}
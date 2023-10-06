namespace Microsoft.Integration.Shopify;

codeunit 30238 "Shpfy Fulfillment Orders API"
{
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        GraphQLType: Enum "Shpfy GraphQL Type";


    internal procedure RegisterFulfillmentService(var Shop: Record "Shpfy Shop")
    var
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
    begin
        CommunicationMgt.SetShop(Shop);
        GraphQLType := "Shpfy GraphQL Type"::CreateFulfillmentService;
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);

        Shop."Fulfillment Service Activated" := true;
        Shop.Modify();
    end;

    internal procedure GetShopifyFulfillmentOrders()
    var
        Shop: Record "Shpfy Shop";
    begin
        Shop.Reset();
        if Shop.FindSet() then
            repeat
                if not Shop."Fulfillment Service Activated" then
                    RegisterFulfillmentService(Shop);

                GetShopifyFulFillmentOrders(Shop);
            until Shop.Next() = 0;
    end;

    internal procedure GetShopifyFulFillmentOrders(Shop: Record "Shpfy Shop")
    var
        Cursor: Text;
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
    begin
        CommunicationMgt.SetShop(Shop);

        GraphQLType := "Shpfy GraphQL Type"::GetOpenFulfillmentOrders;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then
                if ExtractFulfillmentOrders(Shop, JResponse.AsObject(), Cursor) then begin
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := "Shpfy GraphQL Type"::GetNextOpenFulfillmentOrders;
                end else
                    break;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.fulfillmentOrders.pageInfo.hasNextPage');
        Commit();
    end;

    internal procedure GetFulFillmentOrderLines(Shop: Record "Shpfy Shop"; FulfillmentOrderHeader: Record "Shpfy FulFillment Order Header")
    var
        Cursor: Text;
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
    begin
        CommunicationMgt.SetShop(Shop);

        Parameters.Add('FulfillmentOrderId', format(FulfillmentOrderHeader."Shopify Fulfillment Order Id"));

        GraphQLType := "Shpfy GraphQL Type"::GetOpenFulfillmentOrderLines;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then
                if ExtractFulfillmentOrderLines(Shop, FulfillmentOrderHeader, JResponse.AsObject(), Cursor) then begin
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := "Shpfy GraphQL Type"::GetNextOpenFulfillmentOrderLines;
                end else
                    break;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.fulfillmentOrder.lineItems.pageInfo.hasNextPage');
        Commit();
    end;

    internal procedure ExtractFulfillmentOrders(var ShopifyShop: Record "Shpfy Shop"; JResponse: JsonObject; var Cursor: Text): Boolean
    var
        JFulfillmentOrders: JsonArray;
        JItem: JsonToken;
    begin
        if JsonHelper.GetJsonArray(JResponse, JFulfillmentOrders, 'data.fulfillmentOrders.edges') then begin
            foreach JItem in JFulfillmentOrders do
                ExtractFulfillmentOrder(ShopifyShop, JItem, Cursor);
            exit(true);
        end;
    end;

    internal procedure ExtractFulfillmentOrdersFromOrder(var ShopifyShop: Record "Shpfy Shop"; JResponse: JsonObject; var Cursor: Text): Boolean
    var
        JFulfillmentOrders: JsonArray;
        JItem: JsonToken;
    begin
        if JsonHelper.GetJsonArray(JResponse, JFulfillmentOrders, 'data.order.fulfillmentOrders.edges') then begin
            foreach JItem in JFulfillmentOrders do
                ExtractFulfillmentOrder(ShopifyShop, JItem, Cursor);

            exit(true);
        end;
    end;

    internal procedure ExtractFulfillmentOrder(var ShopifyShop: Record "Shpfy Shop"; JFulfillmentOrder: JsonToken; var Cursor: Text)
    var
        FulfillmentOrderHeader: Record "Shpfy FulFillment Order Header";
        Id: BigInteger;
        JNode: JsonObject;
    begin
        Cursor := JsonHelper.GetValueAsText(JFulfillmentOrder.AsObject(), 'cursor');
        if JsonHelper.GetJsonObject(JFulfillmentOrder.AsObject(), JNode, 'node') then begin
            Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'id'));

            if FulfillmentOrderHeader.Get(Id) then begin
                if FulfillmentOrderHeader."Updated At" = JsonHelper.GetValueAsDateTime(JNode, 'updatedAt') then
                    exit;
            end else
                Clear(FulfillmentOrderHeader);
            FulfillmentOrderHeader."Shopify Fulfillment Order Id" := Id;
            FulfillmentOrderHeader."Shop Id" := ShopifyShop."Shop Id";
            FulfillmentOrderHeader."Shop Code" := ShopifyShop.Code;
            FulfillmentOrderHeader."Shopify Order Id" := JsonHelper.GetValueAsBigInteger(JNode, 'order.legacyResourceId');
            FulfillmentOrderHeader."Shopify Location Id" := JsonHelper.GetValueAsBigInteger(JNode, 'assignedLocation.location.legacyResourceId');
            FulfillmentOrderHeader."Updated At" := JsonHelper.GetValueAsDateTime(JNode, 'updatedAt');
            FulfillmentOrderHeader.Status := CopyStr(JsonHelper.GetValueAsText(JNode, 'status'), 1, MaxStrLen(FulfillmentOrderHeader.Status));
            if not FulfillmentOrderHeader.Insert() then
                FulfillmentOrderHeader.Modify();
            GetFulfillmentOrderLines(ShopifyShop, FulfillmentOrderHeader);
        end;
    end;

    internal procedure ExtractFulfillmentOrderLines(var ShopifyShop: Record "Shpfy Shop"; var FulfillmentOrderHeader: Record "Shpfy FulFillment Order Header"; JResponse: JsonObject; var Cursor: Text): Boolean
    var
        FulfillmentOrderLine: Record "Shpfy FulFillment Order Line";
        Id: BigInteger;
        JFulfillmentOrderLines: JsonArray;
        JNode: JsonObject;
        JItem: JsonToken;
    begin
        if JsonHelper.GetJsonArray(JResponse, JFulfillmentOrderLines, 'data.fulfillmentOrder.lineItems.edges') then begin
            foreach JItem in JFulfillmentOrderLines do begin
                Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                    Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'id'));

                    if not FulfillmentOrderLine.Get(FulfillmentOrderHeader."Shopify Fulfillment Order Id", Id) then begin
                        FulfillmentOrderLine."Shopify Fulfillment Order Id" := FulfillmentOrderHeader."Shopify Fulfillment Order Id";
                        FulfillmentOrderLine."Shopify Fulfillm. Ord. Line Id" := Id;
                        FulfillmentOrderLine.Insert();
                    end;

                    FulfillmentOrderLine."Shopify Order Id" := FulfillmentOrderHeader."Shopify Order Id";
                    FulfillmentOrderLine."Shopify Location Id" := FulfillmentOrderHeader."Shopify Location Id";
                    FulfillmentOrderLine."Shopify Product Id" := JsonHelper.GetValueAsBigInteger(JNode, 'lineItem.product.legacyResourceId');
                    FulfillmentOrderLine."Shopify Variant Id" := JsonHelper.GetValueAsBigInteger(JNode, 'lineItem.variant.legacyResourceId');
                    FulfillmentOrderLine."Total Quantity" := JsonHelper.GetValueAsDecimal(JNode, 'totalQuantity');
                    FulfillmentOrderLine."Remaining Quantity" := JsonHelper.GetValueAsDecimal(JNode, 'remainingQuantity');
                    FulfillmentOrderLine.Modify();
                end;
            end;
            exit(true);
        end;
    end;

    internal procedure GetShopifyFulfillmentOrdersFromShopifyOrder(Shop: Record "Shpfy Shop"; OrderId: BigInteger)
    var
        Cursor: Text;
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
    begin
        if CommunicationMgt.GetTestInProgress() then
            exit;

        CommunicationMgt.SetShop(Shop);

        if not Shop."Fulfillment Service Activated" then
            RegisterFulfillmentService(Shop);

        GraphQLType := "Shpfy GraphQL Type"::GetFulfillmentOrdersFromOrder;
        repeat
            if Parameters.ContainsKey('OrderId') then
                Parameters.Set('OrderId', Format(OrderId))
            else
                Parameters.Add('OrderId', Format(OrderId));
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then
                if ExtractFulfillmentOrdersFromOrder(Shop, JResponse.AsObject(), Cursor) then begin
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := "Shpfy GraphQL Type"::GetNextFulfillmentOrdersFromOrder;
                end else
                    break;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.order.fulfillmentOrders.pageInfo.hasNextPage');
    end;
}
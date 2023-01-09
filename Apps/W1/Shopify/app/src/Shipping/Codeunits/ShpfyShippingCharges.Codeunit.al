/// <summary>
/// Codeunit Shpfy Shipping Charges (ID 30191).
/// </summary>
codeunit 30191 "Shpfy Shipping Charges"
{
    Access = Internal;

    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    /// <summary> 
    /// Description for UpdateShippingCostInfos.
    /// </summary>
    /// <param name="OrderId">Parameter of type BigInteger.</param>
    internal procedure UpdateShippingCostInfos(OrderId: BigInteger)
    var
        OrderHeader: Record "Shpfy Order Header";
    begin
        if OrderHeader.Get(OrderId) then
            UpdateShippingCostInfos(OrderHeader);
    end;

    /// <summary> 
    /// Description for UpdateShippingCostInfos.
    /// </summary>
    /// <param name="OrderId">Parameter of type BigInteger.</param>
    /// <param name="JShippingLines">Parameter of type JsonArray.</param>
    internal procedure UpdateShippingCostInfos(OrderId: BigInteger; JShippingLines: JsonArray)
    var
        OrderHeader: Record "Shpfy Order Header";
    begin
        if OrderHeader.Get(OrderId) then
            UpdateShippingCostInfos(OrderHeader, JShippingLines);
    end;

    /// <summary> 
    /// Description for UpdateShippingCostInfos.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure UpdateShippingCostInfos(OrderHeader: Record "Shpfy Order Header")
    var
        Parameters: Dictionary of [Text, Text];
        ShpfyGraphQLType: Enum "Shpfy GraphQL Type";
        JOrder: JsonObject;
        JShipmentLines: JsonArray;
        JResponse: JsonToken;
        Url: Text;
        JShippingCosts: JsonArray;
        ORderShippingLinesUrlTxt: Label 'orders/%1.json?fields=shipping_lines', Comment = '%1 = Shopify order id', Locked = true;
    begin
        if CommunicationMgt.GetTestInProgress() then
            exit;
        CommunicationMgt.SetShop(OrderHeader."Shop Code");
        Parameters.Add('OrderId', Format(OrderHeader."Shopify Order Id"));
        ShpfyGraphQLType := "Shpfy GraphQL Type"::GetShipmentLines;
        JResponse := CommunicationMgt.ExecuteGraphQL(ShpfyGraphQLType, Parameters);
        if JsonHelper.GetJsonObject(JResponse, JOrder, 'data.order') then begin
            ShpfyGraphQLType := "Shpfy GraphQL Type"::GetNextShipmentLines;
            repeat
                JShipmentLines := JsonHelper.GetJsonArray(JOrder, 'shippingLines.nodes');
                UpdateShippingCostInfos(OrderHeader, JShipmentLines);
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', JsonHelper.GetValueAsText(JOrder, 'shippingLines.pageInfo.endCursor'));
            until not JsonHelper.GetValueAsBoolean(JOrder, 'shippingLines.pageInfo.ha  sNextPage')
        end;
    end;

    /// <summary> 
    /// Description for UpdateShippingCostInfos.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="JShippingLines">Parameter of type JsonArray.</param>
    internal procedure UpdateShippingCostInfos(OrderHeader: Record "Shpfy Order Header"; JShippingLines: JsonArray)
    var
        OrderShippingCharges: Record "Shpfy Order Shipping Charges";
        ShipmentMethodMapping: Record "Shpfy Shipment Method Mapping";
        DataCapture: Record "Shpfy Data Capture";
        RecordRef: RecordRef;
        Id: BigInteger;
        JToken: JsonToken;
        IsNew: Boolean;
    begin
        foreach JToken in JShippingLines do begin
            Id := JsonHelper.GetValueAsBigInteger(JToken, 'id');
            IsNew := not OrderShippingCharges.Get(Id);
            if IsNew then begin
                Clear(OrderShippingCharges);
                OrderShippingCharges."Shopify Shipping Line Id" := Id;
                OrderShippingCharges."Shopify Order Id" := OrderHeader."Shopify Order Id";
            end;
            RecordRef.GetTable(OrderShippingCharges);
            JsonHelper.GetValueIntoField(JToken, 'title', RecordRef, OrderShippingCharges.FieldNo(Title));
            JsonHelper.GetValueIntoField(JToken, 'code', RecordRef, OrderShippingCharges.FieldNo(Code));
            JsonHelper.GetValueIntoField(JToken, 'source', RecordRef, OrderShippingCharges.FieldNo(Source));
            JsonHelper.GetValueIntoField(JToken, 'originalPriceSet.shopMoney.amount', RecordRef, OrderShippingCharges.FieldNo(Amount));
            JsonHelper.GetValueIntoField(JToken, 'originalPriceSet.presentmentMoney.amount', RecordRef, OrderShippingCharges.FieldNo("Presentment Amount"));
            JsonHelper.GetValueIntoField(JToken, 'discountedPriceSet.shopMoney.amount', RecordRef, OrderShippingCharges.FieldNo("Discount Amount"));
            JsonHelper.GetValueIntoField(JToken, 'discountedPriceSet.presentmentMoney.amount', RecordRef, OrderShippingCharges.FieldNo("Presentment Discount Amount"));
            if IsNew then
                RecordRef.Insert()
            else
                RecordRef.Modify();
            RecordRef.SetTable(OrderShippingCharges);
            RecordRef.Close();
            DataCapture.Add(Database::"Shpfy Order Shipping Charges", OrderShippingCharges.SystemId, JToken);
            if not ShipmentMethodMapping.Get(OrderHeader."Shop Code", OrderShippingCharges.Title) then begin
                Clear(ShipmentMethodMapping);
                ShipmentMethodMapping."Shop Code" := OrderHeader."Shop Code";
                ShipmentMethodMapping.Name := OrderShippingCharges.Title;
                ShipmentMethodMapping.Insert();
            end;
        end;
    end;
}
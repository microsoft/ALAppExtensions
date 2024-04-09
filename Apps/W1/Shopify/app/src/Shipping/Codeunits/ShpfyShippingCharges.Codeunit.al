namespace Microsoft.Integration.Shopify;

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
        GraphQLType: Enum "Shpfy GraphQL Type";
        JOrder: JsonObject;
        JShipmentLines: JsonArray;
        JResponse: JsonToken;
    begin
        if CommunicationMgt.GetTestInProgress() then
            exit;
        CommunicationMgt.SetShop(OrderHeader."Shop Code");
        Parameters.Add('OrderId', Format(OrderHeader."Shopify Order Id"));
        GraphQLType := "Shpfy GraphQL Type"::GetShipmentLines;
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        if JsonHelper.GetJsonObject(JResponse, JOrder, 'data.order') then begin
            GraphQLType := "Shpfy GraphQL Type"::GetNextShipmentLines;
            repeat
                JShipmentLines := JsonHelper.GetJsonArray(JOrder, 'shippingLines.nodes');
                UpdateShippingCostInfos(OrderHeader, JShipmentLines);
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', JsonHelper.GetValueAsText(JOrder, 'shippingLines.pageInfo.endCursor'));
            until not JsonHelper.GetValueAsBoolean(JOrder, 'shippingLines.pageInfo.hasNextPage')
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
            Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JToken, 'id'));
            IsNew := not OrderShippingCharges.Get(Id);
            if IsNew then begin
                Clear(OrderShippingCharges);
                OrderShippingCharges."Shopify Shipping Line Id" := Id;
                OrderShippingCharges."Shopify Order Id" := OrderHeader."Shopify Order Id";
            end;
            RecordRef.GetTable(OrderShippingCharges);
            JsonHelper.GetValueIntoField(JToken, 'title', RecordRef, OrderShippingCharges.FieldNo(Title));
            JsonHelper.GetValueIntoField(JToken, 'code', RecordRef, OrderShippingCharges.FieldNo(Code));
            JsonHelper.GetValueIntoField(JToken, 'code', RecordRef, OrderShippingCharges.FieldNo("Code Value"));
            JsonHelper.GetValueIntoField(JToken, 'source', RecordRef, OrderShippingCharges.FieldNo(Source));
            JsonHelper.GetValueIntoField(JToken, 'originalPriceSet.shopMoney.amount', RecordRef, OrderShippingCharges.FieldNo(Amount));
            JsonHelper.GetValueIntoField(JToken, 'originalPriceSet.presentmentMoney.amount', RecordRef, OrderShippingCharges.FieldNo("Presentment Amount"));
            RecordRef.SetTable(OrderShippingCharges);
            OrderShippingCharges."Discount Amount" := GetShippingDiscountAmount(JsonHelper.GetJsonArray(JToken, 'discountAllocations'), 'shopMoney');
            OrderShippingCharges."Presentment Discount Amount" := GetShippingDiscountAmount(JsonHelper.GetJsonArray(JToken, 'discountAllocations'), 'presentmentMoney');
            if IsNew then
                OrderShippingCharges.Insert()
            else
                OrderShippingCharges.Modify();
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

    local procedure GetShippingDiscountAmount(JDiscountAllocations: JsonArray; MoneyType: Text) Result: Decimal
    var
        JAllocationAmountSet: JsonToken;
        amountLbl: Label 'allocatedAmountSet.%1.amount', Locked = true, Comment = '%1 = MoneyType (shopMoney or presentmentMoney)';
    begin
        Result := 0;
        foreach JAllocationAmountSet in JDiscountAllocations do
            Result += JsonHelper.GetValueAsDecimal(JAllocationAmountSet, StrSubstNo(amountLbl, MoneyType));
    end;
}
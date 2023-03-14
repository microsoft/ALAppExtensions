/// <summary>
/// Codeunit Shpfy Order Fulfillments (ID 30160).
/// </summary>
codeunit 30160 "Shpfy Order Fulfillments"
{
    Access = Internal;

    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    local procedure ConvertToFulFillmentStatus(Value: Text): Enum "Shpfy Fulfillment Status"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Fulfillment Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Fulfillment Status".FromInteger(Enum::"Shpfy Fulfillment Status".Ordinals().Get(Enum::"Shpfy Fulfillment Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Fulfillment Status"::" ");
    end;

    local procedure ConvertToShipmentStatus(Value: Text): Enum "Shpfy Shipment Status"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Shipment Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Shipment Status".FromInteger(Enum::"Shpfy Shipment Status".Ordinals().Get(Enum::"Shpfy Shipment Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Shipment Status"::" ");
    end;

    /// <summary> 
    /// Get FulFillment Infos.
    /// </summary>
    /// <param name="OrderId">Parameter of type BigInteger.</param>
    /// <param name="JFulfillments">Parameter of type JsonArray.</param>
    internal procedure GetFulfillmentInfos(OrderId: BigInteger; JFulfillments: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach Jtoken in JFulfillments do
            ImportFulfillment(JToken);
    end;

    /// <summary> 
    /// Description for ImportFulfillment.
    /// </summary>
    /// <param name="JFulfillment">Parameter of type JsonToken.</param>
    /// <returns>Return variable "BigInteger".</returns>
    internal procedure ImportFulfillment(JFulfillment: JsonToken): BigInteger
    var
        DataCapture: Record "Shpfy Data Capture";
        OrderFulfillment: Record "Shpfy Order Fulfillment";
        GiftCard: Codeunit "Shpfy Gift Cards";
        RecRef: RecordRef;
        Id: BigInteger;
        IsNew: Boolean;
        JArray: JsonArray;
    begin
        Id := JsonHelper.GetValueAsBigInteger(JFulfillment, 'id');
        IsNew := not OrderFulfillment.Get(Id);
        if IsNew then begin
            Clear(OrderFulfillment);
            OrderFulfillment."Shopify Fulfillment Id" := Id;
            OrderFulfillment."Shopify Order Id" := JsonHelper.GetValueAsBigInteger(JFulfillment, 'order_id');
        end;
        OrderFulfillment.Status := ConvertToFulFillmentStatus(JsonHelper.GetValueAsText(JFulfillment, 'status'));
        OrderFulfillment."Shipment Status" := ConvertToShipmentStatus(JsonHelper.GetValueAsText(JFulfillment, 'shipment_status'));
#pragma warning disable AA0139
        OrderFulfillment."Tracking Numbers" := JsonHelper.GetArrayAsText(JFulfillment, 'tracking_numbers', MaxStrLen(OrderFulfillment."Tracking Numbers"));
        OrderFulfillment."Tracking URLs" := JsonHelper.GetArrayAsText(JFulfillment, 'tracking_urls', MaxStrLen(OrderFulfillment."Tracking URLs"));
#pragma warning restore AA0139
        RecRef.GetTable(OrderFulfillment);
        JsonHelper.GetValueIntoField(JFulfillment, 'created_at', RecRef, OrderFulfillment.FieldNo("Created At"));
        JsonHelper.GetValueIntoField(JFulfillment, 'updated_at', RecRef, OrderFulfillment.FieldNo("Updated At"));
        JsonHelper.GetValueIntoField(JFulfillment, 'tracking_number', RecRef, OrderFulfillment.FieldNo("Tracking Number"));
        JsonHelper.GetValueIntoField(JFulfillment, 'tracking_url', RecRef, OrderFulfillment.FieldNo("Tracking URL"));
        JsonHelper.GetValueIntoField(JFulfillment, 'tracking_company', RecRef, OrderFulfillment.FieldNo("Tracking Company"));
        JsonHelper.GetValueIntoField(JFulfillment, 'name', RecRef, OrderFulfillment.FieldNo(Name));
        JsonHelper.GetValueIntoField(JFulfillment, 'notify_customer', RecRef, OrderFulfillment.FieldNo("Notify Customer"));
        JsonHelper.GetValueIntoField(JFulfillment, 'receipt.test_case', RecRef, OrderFulfillment.FieldNo("Test Case"));
        JsonHelper.GetValueIntoField(JFulfillment, 'receipt.authorization', RecRef, OrderFulfillment.FieldNo(Authorization));
        JsonHelper.GetValueIntoField(JFulfillment, 'service', RecRef, OrderFulfillment.FieldNo(Service));
        if IsNew then
            RecRef.Insert()
        else
            RecRef.Modify();
        RecRef.SetTable(OrderFulfillment);
        RecRef.Close();

        if OrderFulfillment.Service = 'gift_card' then
            if JsonHelper.GetJsonArray(JFulfillment, JArray, 'receipt.gift_cards') then
                GiftCard.AddSoldGiftCards(JArray);

        DataCapture.Add(Database::"Shpfy Order Fulfillment", OrderFulfillment.SystemId, JFulfillment);
        exit(id);
    end;
}
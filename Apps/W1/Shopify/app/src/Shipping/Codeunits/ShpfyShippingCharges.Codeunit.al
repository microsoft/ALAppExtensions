/// <summary>
/// Codeunit Shpfy Shipping Charges (ID 30191).
/// </summary>
codeunit 30191 "Shpfy Shipping Charges"
{
    Access = Internal;

    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JHelper: Codeunit "Shpfy Json Helper";

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
        Url: Text;
        JResponse: JsonToken;
        JShippingCosts: JsonArray;
        ORderShippingLinesUrlTxt: Label 'orders/%1.json?fields=shipping_lines', Comment = '%1 = Shopify order id', Locked = true;
    begin
        CommunicationMgt.SetShop(OrderHeader."Shop Code");
        Url := CommunicationMgt.CreateWebRequestURL(StrSubstNo(OrderShippingLinesUrlTxt, OrderHeader."Shopify Order Id"));
        JResponse := CommunicationMgt.ExecuteWebRequest(Url, 'GET', JResponse);
        if JHelper.GetJsonArray(JResponse, JShippingCosts, 'order.shipping_lines') then
            UpdateShippingCostInfos(OrderHeader, JShippingCosts);
    end;

    /// <summary> 
    /// Description for UpdateShippingCostInfos.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="JShippingLines">Parameter of type JsonArray.</param>
    internal procedure UpdateShippingCostInfos(OrderHeader: Record "Shpfy Order Header"; JShippingLines: JsonArray)
    var
        ShippingCost: Record "Shpfy Order Shipping Charges";
        ShippingMethod: Record "Shpfy Shipment Method Mapping";
        DataCapture: Record "Shpfy Data Capture";
        RecRef: RecordRef;
        Id: BigInteger;
        JDiscounts: JsonArray;
        JToken: JsonToken;
        IsNew: Boolean;
    begin
        foreach JToken in JShippingLines do begin
            Id := JHelper.GetValueAsBigInteger(JToken, 'id');
            IsNew := not ShippingCost.Get(Id);
            if IsNew then begin
                Clear(ShippingCost);
                ShippingCost."Shopify Shipping Line Id" := Id;
                ShippingCost."Shopify Order Id" := OrderHeader."Shopify Order Id";
            end;
            if JHelper.GetJsonArray(JToken, JDiscounts, 'discount_allocations') then
                ShippingCost."Discount Amount" := GetDiscountAmount(JDiscounts)
            else
                ShippingCost."Discount Amount" := 0;
            RecRef.GetTable(ShippingCost);
            JHelper.GetValueIntoField(JToken, 'title', RecRef, ShippingCost.FieldNo(Title));
            JHelper.GetValueIntoField(JToken, 'code', RecRef, ShippingCost.FieldNo(Code));
            JHelper.GetValueIntoField(JToken, 'source', RecRef, ShippingCost.FieldNo(Source));
            JHelper.GetValueIntoField(JToken, 'price_set.shop_money.amount', RecRef, ShippingCost.FieldNo(Amount));
            if IsNew then
                RecRef.Insert()
            else
                RecRef.Modify();
            RecRef.SetTable(ShippingCost);
            RecRef.Close();
            DataCapture.Add(Database::"Shpfy Order Shipping Charges", ShippingCost.SystemId, JToken);
            if not ShippingMethod.Get(OrderHeader."Shop Code", ShippingCost.Title) then begin
                Clear(ShippingMethod);
                ShippingMethod."Shop Code" := OrderHeader."Shop Code";
                ShippingMethod.Name := ShippingCost.Title;
                ShippingMethod.Insert();
            end;
        end;
    end;

    /// <summary> 
    /// Description for GetDiscountAmount.
    /// </summary>
    /// <param name="JDiscounts">Parameter of type JsonArray.</param>
    /// <returns>Return variable "Decimal".</returns>
    local procedure GetDiscountAmount(JDiscounts: JsonArray) Result: Decimal
    var
        JToken: JsonToken;
    begin
        foreach JToken in JDiscounts do
            Result += JHelper.GetValueAsDecimal(JToken, 'amount_set.shop_money.amount')
    end;
}
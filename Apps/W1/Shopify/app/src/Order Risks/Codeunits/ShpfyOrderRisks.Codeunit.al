/// <summary>
/// Codeunit Shpfy Order Risks (ID 30170).
/// </summary>
codeunit 30170 "Shpfy Order Risks"
{
    Access = Internal;

    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    /// <summary> 
    /// Description for UpdateOrderRisks.
    /// </summary>
    /// <param name="OrderId">Parameter of type BigInteger.</param>
    internal procedure UpdateOrderRisks(OrderId: BigInteger)
    var
        OrderHeader: Record "Shpfy Order Header";
    begin
        if OrderHeader.Get(OrderId) then
            UpdateOrderRisks(OrderHeader);
    end;

    /// <summary> 
    /// Description for UpdateOrderRisks.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure UpdateOrderRisks(OrderHeader: Record "Shpfy Order Header")
    var
        JResponse: JsonToken;
        JRisks: JsonArray;
        Parameters: Dictionary of [text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
    begin
        if CommunicationMgt.GetTestInProgress() then
            exit;
        CommunicationMgt.SetShop(OrderHeader."Shop Code");
        Parameters.Add('OrderId', Format(OrderHeader."Shopify Order Id"));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::OrderRisks, Parameters);
        if JsonHelper.GetJsonArray(JResponse, JRisks, 'data.order.risks') then
            UpdateOrderRisks(OrderHeader, JRisks);
    end;

    /// <summary> 
    /// Description for UpdateOrderRisks.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="JRisks">Parameter of type JsonArray.</param>
    internal procedure UpdateOrderRisks(OrderHeader: Record "Shpfy Order Header"; JRisks: JsonArray)
    var
        OrderRisk: Record "Shpfy Order Risk";
        RecordRef: RecordRef;
        LineNo: Integer;
        JToken: JsonToken;
    begin
        OrderRisk.SetRange("Order Id", OrderHeader."Shopify Order Id");
        OrderRisk.DeleteAll(false);
        foreach JToken in JRisks do begin
            LineNo += 1;
            Clear(OrderRisk);
            OrderRisk."Order Id" := OrderHeader."Shopify Order Id";
            OrderRisk."Line No." := LineNo;
            OrderRisk.Level := ConvertToRiskLevel(JsonHelper.GetValueAsText(JToken, 'level'));
            RecordRef.GetTable(OrderRisk);
            JsonHelper.GetValueIntoField(JToken, 'display', RecordRef, OrderRisk.FieldNo(Display));
            JsonHelper.GetValueIntoField(JToken, 'message', RecordRef, OrderRisk.FieldNo(Message));
            RecordRef.Insert();
            RecordRef.Close();
        end;
    end;

    local procedure ConvertToRiskLevel(Value: Text): Enum "Shpfy Risk Level"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Risk Level".Names().Contains(Value) then
            exit(Enum::"Shpfy Risk Level".FromInteger(Enum::"Shpfy Risk Level".Ordinals().Get(Enum::"Shpfy Risk Level".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Risk Level"::" ");
    end;

}
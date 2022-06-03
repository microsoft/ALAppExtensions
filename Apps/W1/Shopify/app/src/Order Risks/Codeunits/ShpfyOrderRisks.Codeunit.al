/// <summary>
/// Codeunit Shpfy Order Risks (ID 30170).
/// </summary>
codeunit 30170 "Shpfy Order Risks"
{
    Access = Internal;

    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JHelper: Codeunit "Shpfy Json Helper";

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
        CommunicationMgt.SetShop(OrderHeader."Shop Code");
        Parameters.Add('OrderId', Format(OrderHeader."Shopify Order Id"));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::OrderRisks, Parameters);
        if JHelper.GetJsonArray(JResponse, JRisks, 'data.order.risks') then
            UpdateOrderRisks(OrderHeader, JRisks);
    end;

    /// <summary> 
    /// Description for UpdateOrderRisks.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="JRisks">Parameter of type JsonArray.</param>
    internal procedure UpdateOrderRisks(OrderHeader: Record "Shpfy Order Header"; JRisks: JsonArray)
    var
        Risk: Record "Shpfy Order Risk";
        RecRef: RecordRef;
        LineNo: Integer;
        JToken: JsonToken;
    begin
        Risk.SetRange("Order Id", OrderHeader."Shopify Order Id");
        Risk.DeleteAll(false);
        foreach JToken in JRisks do begin
            LineNo += 1;
            Clear(Risk);
            Risk."Order Id" := OrderHeader."Shopify Order Id";
            Risk."Line No." := LineNo;
            Risk.Level := ConvertToRiskLevel(JHelper.GetValueAsText(JToken, 'level'));
            RecRef.GetTable(Risk);
            JHelper.GetValueIntoField(JToken, 'display', RecRef, Risk.FieldNo(Display));
            JHelper.GetValueIntoField(JToken, 'message', RecRef, Risk.FieldNo(Message));
            RecRef.Insert();
            RecRef.Close();
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
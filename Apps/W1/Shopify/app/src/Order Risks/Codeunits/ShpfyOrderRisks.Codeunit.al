// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

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
        JRiskAssessments: JsonArray;
        Parameters: Dictionary of [text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
    begin
        if CommunicationMgt.GetTestInProgress() then
            exit;
        CommunicationMgt.SetShop(OrderHeader."Shop Code");
        Parameters.Add('OrderId', Format(OrderHeader."Shopify Order Id"));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::OrderRisks, Parameters);
        if JsonHelper.GetJsonArray(JResponse, JRiskAssessments, 'data.order.risk.assessments') then
            UpdateOrderRisks(OrderHeader, JRiskAssessments);
    end;

    /// <summary> 
    /// Description for UpdateOrderRisks.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="JRiskAssesments">Parameter of type JsonArray.</param>
    internal procedure UpdateOrderRisks(OrderHeader: Record "Shpfy Order Header"; JRiskAssesments: JsonArray)
    var
        OrderRisk: Record "Shpfy Order Risk";
        RecordRef: RecordRef;
        RiskLevel: Enum "Shpfy Risk Level";
        LineNo: Integer;
        ProviderTitle: Text;
        JFacts: JsonArray;
        JProvider: JsonObject;
        JRiskAssessment: JsonToken;
        JFact: JsonToken;
    begin
        OrderRisk.SetRange("Order Id", OrderHeader."Shopify Order Id");
        OrderRisk.DeleteAll(false);
        foreach JRiskAssessment in JRiskAssesments do begin
            if JsonHelper.GetJsonObject(JRiskAssessment, JProvider, 'provider') then
                ProviderTitle := JsonHelper.GetValueAsText(JProvider, 'title')
            else
                ProviderTitle := 'Shopify';
            RiskLevel := ConvertToRiskLevel(JsonHelper.GetValueAsText(JRiskAssessment, 'riskLevel'));
            if JsonHelper.GetJsonArray(JRiskAssessment, JFacts, 'facts') then
                foreach JFact in JFacts do begin
                    LineNo += 1;
                    Clear(OrderRisk);
                    OrderRisk."Order Id" := OrderHeader."Shopify Order Id";
                    OrderRisk."Line No." := LineNo;
                    OrderRisk.Level := RiskLevel;
                    OrderRisk.Provider := CopyStr(ProviderTitle, 1, MaxStrLen(OrderRisk.Provider));
                    OrderRisk.Sentiment := ConvertToSentiment(JsonHelper.GetValueAsText(JFact, 'sentiment'));
                    RecordRef.GetTable(OrderRisk);
                    JsonHelper.GetValueIntoField(JFact, 'description', RecordRef, OrderRisk.FieldNo(Message));
                    RecordRef.Insert();
                    RecordRef.Close();
                end;
        end;
    end;

    internal procedure ConvertToRiskLevel(Value: Text): Enum "Shpfy Risk Level"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Risk Level".Names().Contains(Value) then
            exit(Enum::"Shpfy Risk Level".FromInteger(Enum::"Shpfy Risk Level".Ordinals().Get(Enum::"Shpfy Risk Level".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Risk Level"::" ");
    end;

    local procedure ConvertToSentiment(Value: Text): Enum "Shpfy Assessment Sentiment"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Assessment Sentiment".Names().Contains(Value) then
            exit(Enum::"Shpfy Assessment Sentiment".FromInteger(Enum::"Shpfy Assessment Sentiment".Ordinals().Get(Enum::"Shpfy Assessment Sentiment".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Assessment Sentiment"::" ");
    end;
}
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.AI;

using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Finance.Deferral;
using System.AI;
using System.Azure.KeyVault;
using System.Log;
using System.Telemetry;

codeunit 6129 "E-Doc. Deferral Matching" implements "AOAI Function", IEDocAISystem
{
    Access = Internal;
    TableNo = "E-Document Purchase Line";
    EventSubscriberInstance = Manual;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnRun()
    var
        DeferralTemplate: Record "Deferral Template";
        TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary;
        EDocumentAIProcessor: Codeunit "E-Doc. AI Tool Processor";
        EDocActivityLogBuilder: Codeunit "Activity Log Builder";
        Response: Codeunit "AOAI Operation Response";
        FunctionResponse: Codeunit "AOAI Function Response";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EDocImpSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";
        RecordRef: RecordRef;
        Reasoning: Text;
        MistakesCount: Integer;
        MatchedCount: Integer;
        TelemetryDimensions: Dictionary of [Text, Text];
        ActivityLogTitleTxt: Label 'Deferral template %1', Comment = '%1 = Deferral template Code';
    begin
        if DeferralTemplate.IsEmpty() then
            exit;

        if EDocumentAIProcessor.Setup(this) then
            if not EDocumentAIProcessor.Process(CreateUserMessage(Rec), Response) then
                exit;

        foreach FunctionResponse in Response.GetFunctionResponses() do begin
            TempEDocLineMatchBuffer := FunctionResponse.GetResult();
            OnGetDeferralMatchFunctionResponse(TempEDocLineMatchBuffer);

            if not Rec.Get(Rec."E-Document Entry No.", TempEDocLineMatchBuffer."Line No.") then begin
                MistakesCount += 1;
                continue;
            end;

            if TryValidateDeferralCode(TempEDocLineMatchBuffer, Rec) then begin
                if not DeferralTemplate.Get(TempEDocLineMatchBuffer."Deferral Code") then begin
                    MistakesCount += 1;
                    continue;
                end;

                MatchedCount += 1;
                Rec.Modify(true);
                RecordRef := DeferralTemplate;
                Reasoning := TempEDocLineMatchBuffer."Deferral Reason";
                EDocActivityLogBuilder
                    .Init(Database::"E-Document Purchase Line", Rec.FieldNo("[BC] Deferral Code"), Rec.SystemId)
                    .SetExplanation(Reasoning)
                    .SetType(Enum::"Activity Log Type"::"AI")
                    .SetReferenceSource(Page::"Deferral Template Card", RecordRef)
                    .SetReferenceTitle(StrSubstNo(ActivityLogTitleTxt, Rec."[BC] Deferral Code"))
                    .Log();

                EDocImpSessionTelemetry.SetLineBool(Rec.SystemId, 'Deferral Template AI Match', true);
            end;
        end;

        TelemetryDimensions.Add('Total lines', Format(Rec.Count()));
        TelemetryDimensions.Add('Proposed deferrals', Format(Response.GetFunctionResponses().Count));
        TelemetryDimensions.Add('Matched deferrals', Format(MatchedCount));
        TelemetryDimensions.Add('Processing mistakes', Format(MistakesCount));
        FeatureTelemetry.LogUsage('0000PUM', EDocumentAIProcessor.GetEDocumentMatchingAssistanceName(), GetFeatureName(), TelemetryDimensions);
    end;

    [TryFunction]
    local procedure TryValidateDeferralCode(TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary; var EDocumentPurchaseLine: Record "E-Document Purchase Line")
    begin
        EDocumentPurchaseLine.Validate("[BC] Deferral Code", TempEDocLineMatchBuffer."Deferral Code");
    end;

    local procedure CreateUserMessage(var EDocumentPurchaseLine: Record "E-Document Purchase Line"): Text
    var
        UserMessage: JsonArray;
        UserMessageTxt: Text;
    begin
        UserMessage.Add(BuildEDocumentPurchaseLines(EDocumentPurchaseLine));
        UserMessage.Add(BuildDeferralTemplates());
        UserMessage.WriteTo(UserMessageTxt);
        exit(UserMessageTxt);
    end;

    local procedure BuildEDocumentPurchaseLines(var EDocumentPurchaseLine: Record "E-Document Purchase Line") EDocumentPurchaseLinesJson: JsonObject
    var
        JsonObject: JsonObject;
        EDocumentPurchaseLineArray: JsonArray;
    begin
        EDocumentPurchaseLine.Ascending(true);
        if EDocumentPurchaseLine.FindSet() then
            repeat
                Clear(JsonObject);
                JsonObject.Add('id', EDocumentPurchaseLine."Line No.");
                JsonObject.Add('description', EDocumentPurchaseLine.Description);
                EDocumentPurchaseLineArray.Add(JsonObject);
            until EDocumentPurchaseLine.Next() = 0;

        EDocumentPurchaseLinesJson.Add('purchaseLines', EDocumentPurchaseLineArray);
    end;

    local procedure BuildDeferralTemplates() DeferralTemplatesJson: JsonObject
    var
        DeferralTemplate: Record "Deferral Template";
        JsonObject: JsonObject;
        DeferralTemplateArray: JsonArray;
    begin
        if DeferralTemplate.FindSet() then
            repeat
                Clear(JsonObject);
                JsonObject.Add('deferralCode', DeferralTemplate."Deferral Code");
                JsonObject.Add('numberOfPeriods', DeferralTemplate."No. of Periods");
                JsonObject.Add('description', DeferralTemplate.Description);
                DeferralTemplateArray.Add(JsonObject);
            until DeferralTemplate.Next() = 0;

        DeferralTemplatesJson.Add('deferralTemplates', DeferralTemplateArray);
    end;

    #region "AOAI Function" interface implementation
    procedure GetPrompt(): JsonObject
    var
        ToolDefinition: JsonObject;
        FunctionDefinition: JsonObject;
        ParametersDefinition: JsonObject;
        FunctionDescriptionLbl: Label 'Analyzes each invoice line for deferral requirements and matches with appropriate templates. Must be called for every line, regardless of deferral decision.', Locked = true;
    begin
        ParametersDefinition.ReadFrom(NavApp.GetResourceAsText('AITools/DeferralMatching-FunctionParameters.json'));

        FunctionDefinition.Add('name', GetName());
        FunctionDefinition.Add('description', FunctionDescriptionLbl);
        FunctionDefinition.Add('parameters', ParametersDefinition);

        ToolDefinition.Add('type', 'function');
        ToolDefinition.Add('function', FunctionDefinition);

        exit(ToolDefinition);
    end;

    internal procedure Execute(Arguments: JsonObject): Variant
    var
        TempEDocLineMatchBufferLocal: Record "EDoc Line Match Buffer" temporary;
    begin
        TempEDocLineMatchBufferLocal."Line No." := Arguments.GetInteger('lineId');
        TempEDocLineMatchBufferLocal."Deferral Code" := CopyStr(Arguments.GetText('deferralCode'), 1, MaxStrLen(TempEDocLineMatchBufferLocal."Deferral Code"));
        TempEDocLineMatchBufferLocal."Deferral Reason" := CopyStr(Arguments.GetText('deferralReasoning'), 1, MaxStrLen(TempEDocLineMatchBufferLocal."Deferral Reason"));

        // Guarding insert as LLM result could be contain duplicate line numbers.
        exit(TempEDocLineMatchBufferLocal);
    end;

    procedure GetName(): Text
    begin
        exit('match_lines_deferral');
    end;
    #endregion "AOAI Function" interface implementation

    #region "E-Document AI System" interface implementation
    procedure GetSystemPrompt(): SecretText
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        PromptSecretText: SecretText;
        PromptSecretNameTok: Label 'DeferralMatching-SystemPrompt270', Locked = true;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(PromptSecretNameTok, PromptSecretText) then
            PromptSecretText := SecretStrSubstNo('');
        exit(PromptSecretText);
    end;

    procedure GetTools(): List of [Interface "AOAI Function"]
    var
        List: List of [Interface "AOAI Function"];
    begin
        List.Add(this);
        exit(List);
    end;

    procedure GetFeatureName(): Text
    begin
        exit('EDocument Deferral Matching')
    end;
    #endregion "E-Document AI System" interface implementation


    [IntegrationEvent(false, false)]
    local procedure OnGetDeferralMatchFunctionResponse(TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary)
    begin
    end;

}
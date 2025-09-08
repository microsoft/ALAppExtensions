// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.AI;

using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using System.AI;
using System.Azure.KeyVault;
using System.Log;
using System.Telemetry;

codeunit 6105 "E-Doc. Similar Descriptions" implements "AOAI Function", IEDocAISystem
{
    Access = Internal;
    TableNo = "E-Document Purchase Line";
    EventSubscriberInstance = Manual;
    InherentPermissions = X;
    InherentEntitlements = X;

    var
        EDocumentNo: Integer;

    trigger OnRun()
    var
        TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary;
        EDocumentAIProcessor: Codeunit "E-Doc. AI Tool Processor";
        EDocActivityLogBuilder: Codeunit "Activity Log Builder";
        Response: Codeunit "AOAI Operation Response";
        FunctionResponse: Codeunit "AOAI Function Response";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EDocImpSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";
        ProcessedCount: Integer;
        MatchedCount: Integer;
        TelemetryDimensions: Dictionary of [Text, Text];
        ActivityLogTitleTxt: Label 'Similar descriptions for %1', Comment = '%1 = Line description';
        AISimilarDescEventTok: Label 'Similar Descriptions AI Match', Locked = true;
    begin
        if not EDocumentAIProcessor.Setup(this) then
            exit;
        if not EDocumentAIProcessor.Process(CreateUserMessage(Rec), Response) then
            exit;

        foreach FunctionResponse in Response.GetFunctionResponses() do begin
            TempEDocLineMatchBuffer := FunctionResponse.GetResult();
            OnGetSimilarDescriptionsFunctionResponse(TempEDocLineMatchBuffer);

            if not Rec.Get(Rec."E-Document Entry No.", TempEDocLineMatchBuffer."Line No.") then
                continue;

            ProcessedCount += 1;

            // Store similar descriptions for potential use by other systems
            if TempEDocLineMatchBuffer."Historical Matching Reasoning" <> '' then begin
                MatchedCount += 1;
                EDocActivityLogBuilder
                    .Init(Database::"E-Document Purchase Line", Rec.FieldNo(Description), Rec.SystemId)
                    .SetExplanation(TempEDocLineMatchBuffer."Historical Matching Reasoning")
                    .SetType(Enum::"Activity Log Type"::"AI")
                    .SetReferenceTitle(StrSubstNo(ActivityLogTitleTxt, Rec.Description))
                    .Log();

                EDocImpSessionTelemetry.SetLineBool(Rec.SystemId, AISimilarDescEventTok, true);
            end;
        end;

        TelemetryDimensions.Add('Total lines', Format(Rec.Count()));
        TelemetryDimensions.Add('Processed lines', Format(ProcessedCount));
        TelemetryDimensions.Add('Matched lines', Format(MatchedCount));
        FeatureTelemetry.LogUsage('0000PUO', EDocumentAIProcessor.GetEDocumentMatchingAssistanceName(), GetFeatureName(), TelemetryDimensions);
    end;

    /// <summary>
    /// Public method to get similar descriptions for a single line description
    /// </summary>
    /// <param name="LineDescription">The description to generate similar terms for</param>
    /// <returns>List of similar description terms</returns>
    procedure GetSimilarDescriptions(LineDescription: Text): List of [Text]
    var
        TempEDocumentPurchaseLine: Record "E-Document Purchase Line" temporary;
        TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary;
        EDocumentAIProcessor: Codeunit "E-Doc. AI Tool Processor";
        Response: Codeunit "AOAI Operation Response";
        FunctionResponse: Codeunit "AOAI Function Response";
        SimilarDescriptions: List of [Text];
        SimilarTermsArray: JsonArray;
        TermToken: JsonToken;
        TermText: Text;
    begin
        if LineDescription = '' then
            exit(SimilarDescriptions);

        // Create a temporary line record for the AI call
        TempEDocumentPurchaseLine.Init();
        TempEDocumentPurchaseLine."E-Document Entry No." := 1;
        TempEDocumentPurchaseLine."Line No." := 1;
        TempEDocumentPurchaseLine.Description := LineDescription;
        TempEDocumentPurchaseLine.Insert();

        // Process with AI
        if not EDocumentAIProcessor.Setup(this) then
            exit(SimilarDescriptions);
        if not EDocumentAIProcessor.Process(CreateUserMessage(TempEDocumentPurchaseLine), Response) then
            exit(SimilarDescriptions);

        // Extract similar descriptions from function responses
        foreach FunctionResponse in Response.GetFunctionResponses() do begin
            TempEDocLineMatchBuffer := FunctionResponse.GetResult();

            // Parse the similar descriptions from the stored reasoning field
            if TempEDocLineMatchBuffer."Historical Matching Reasoning" <> '' then
                // The similar descriptions are stored as JSON in the reasoning field
                if SimilarTermsArray.ReadFrom(TempEDocLineMatchBuffer."Historical Matching Reasoning") then
                    foreach TermToken in SimilarTermsArray do
                        if TermToken.IsValue() then begin
                            TermText := TermToken.AsValue().AsText().Trim();
                            if (TermText <> '') and (StrLen(TermText) > 3) then
                                SimilarDescriptions.Add(TermText);
                        end;
        end;

        exit(SimilarDescriptions);
    end;

    local procedure CreateUserMessage(var EDocumentPurchaseLine: Record "E-Document Purchase Line"): Text
    var
        UserMessage: JsonArray;
        UserMessageTxt: Text;
    begin
        // Store document number for later use
        if EDocumentPurchaseLine.FindFirst() then
            EDocumentNo := EDocumentPurchaseLine."E-Document Entry No.";

        UserMessage.Add(BuildEDocumentPurchaseLines(EDocumentPurchaseLine));
        UserMessage.WriteTo(UserMessageTxt);

        OnUserMessageCreated(UserMessageTxt);
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
                JsonObject.Add('lineId', EDocumentPurchaseLine."Line No.");
                JsonObject.Add('description', EDocumentPurchaseLine.Description);
                if EDocumentPurchaseLine."Unit Price" <> 0 then
                    JsonObject.Add('unitPrice', EDocumentPurchaseLine."Unit Price");
                EDocumentPurchaseLineArray.Add(JsonObject);
            until EDocumentPurchaseLine.Next() = 0;

        EDocumentPurchaseLinesJson.Add('purchaseLines', EDocumentPurchaseLineArray);
    end;

    #region "AOAI Function" interface implementation
    procedure GetPrompt(): JsonObject
    var
        ToolDefinition: JsonObject;
        FunctionDefinition: JsonObject;
        ParametersDefinition: JsonObject;
        FunctionDescriptionTok: Label 'Generates similar descriptions for invoice lines to help with historical matching.', Locked = true;
    begin
        ParametersDefinition.ReadFrom(NavApp.GetResourceAsText('AITools/SimilarDescriptions-ToolDef.json'));

        FunctionDefinition.Add('name', GetName());
        FunctionDefinition.Add('description', FunctionDescriptionTok);
        FunctionDefinition.Add('parameters', ParametersDefinition);

        ToolDefinition.Add('type', 'function');
        ToolDefinition.Add('function', FunctionDefinition);

        exit(ToolDefinition);
    end;

    procedure Execute(Arguments: JsonObject): Variant
    var
        TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary;
        SimilarDescriptionsArray: JsonArray;
        DescriptionToken: JsonToken;
        SimilarDescriptionsText: Text;
        SimilarDescriptionsJson: Text;
        Description: Text;
    begin
        Clear(TempEDocLineMatchBuffer);
        TempEDocLineMatchBuffer."E-Document Entry No." := EDocumentNo;
        TempEDocLineMatchBuffer."Line No." := Arguments.GetInteger('lineId');

        if Arguments.Contains('similarDescriptions') then begin
            Arguments.Get('similarDescriptions', DescriptionToken);
            if DescriptionToken.IsArray() then begin
                SimilarDescriptionsArray := DescriptionToken.AsArray();

                // Store the array as JSON for easy parsing later
                SimilarDescriptionsArray.WriteTo(SimilarDescriptionsJson);
                TempEDocLineMatchBuffer."Historical Matching Reasoning" := CopyStr(SimilarDescriptionsJson, 1, MaxStrLen(TempEDocLineMatchBuffer."Historical Matching Reasoning"));

                // Also build a readable text version for logging
                foreach DescriptionToken in SimilarDescriptionsArray do
                    if DescriptionToken.IsValue() then begin
                        Description := DescriptionToken.AsValue().AsText().Trim();
                        if (Description <> '') and (StrLen(Description) > 3) then begin
                            if SimilarDescriptionsText <> '' then
                                SimilarDescriptionsText += ', ';
                            SimilarDescriptionsText += Description;
                        end;
                    end;
            end;
        end;

        if Arguments.Contains('reasoning') and (SimilarDescriptionsText <> '') then
            // Combine reasoning with similar descriptions for activity logging
            SimilarDescriptionsText := 'Similar terms: ' + SimilarDescriptionsText + '. ' + Arguments.GetText('reasoning');

        exit(TempEDocLineMatchBuffer);
    end;

    procedure GetName(): Text
    begin
        exit('generate_similar_descriptions');
    end;
    #endregion "AOAI Function" interface implementation

    #region "E-Document AI System" interface implementation
    procedure GetSystemPrompt(): SecretText
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        PromptSecretText: SecretText;
        PromptSecretNameTok: Label 'EDocSimilarDescriptions-SystemPrompt', Locked = true;
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
        exit('EDocument Similar Descriptions')
    end;
    #endregion "E-Document AI System" interface implementation

    [IntegrationEvent(false, false)]
    local procedure OnGetSimilarDescriptionsFunctionResponse(TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUserMessageCreated(UserMessageTxt: Text)
    begin
    end;

}

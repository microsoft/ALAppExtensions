// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Purchases.Vendor;
using System.Agents;
using System.TestLibraries.Agents;
using System.TestTools.AIEvaluate;

codeunit 133719 "PA Unscripted Test"
{
    Subtype = Test;
    TestType = AITest;
    TestPermissions = Disabled;
    Access = Internal;

    /// <summary>
    /// Executes unscripted test scenarios where the test framework dynamically determines
    /// and applies necessary user interventions to reach a valid purchase invoice.
    /// Collects granular metrics at each stage of the invoice processing pipeline.
    /// </summary>
    [Test]
    procedure ReachValidInvoice()
    var
        AgentTask: Record "Agent Task";
        PayablesAgentUtilities: Codeunit "Payables Agent Utilities";
        OutputDictionary: Dictionary of [Text, JsonToken];
        DataCreatedSuccessfully: Boolean;
    begin
        PayablesAgentUtilities.InitializeTest(AgentTask);
        ResolveUserInterventions(AgentTask, OutputDictionary);
        DataCreatedSuccessfully := PayablesAgentUtilities.VerifyExpectedTestOutcome(AgentTask, OutputDictionary);
        PayablesAgentUtilities.LogTestExecutionDetails(AgentTask, OutputDictionary, DataCreatedSuccessfully);
    end;

    local procedure ResolveUserInterventions(var AgentTask: Record "Agent Task"; var OutputDictionary: Dictionary of [Text, JsonToken])
    var
        EDocument: Record "E-Document";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        Vendor: Record Vendor;
        PayablesAgentUtilities: Codeunit "Payables Agent Utilities";
        LibraryAgent: Codeunit "Library - Agent";
        InterventionType: Option;
        EvaluationResults: JsonObject;
        UserInterventionMessage: Text;
        UserInterventionCounter: Integer;
        ContinueProcessing: Boolean;
    begin
        UserInterventionCounter := 0;
        ContinueProcessing := true;
        while ContinueProcessing do begin
            if not PayablesAgentUtilities.ValidateTaskReadyForUserIntervention(AgentTask, UserInterventionMessage, OutputDictionary) then
                exit;

            ValidateMessage(UserInterventionMessage, InterventionType, EvaluationResults);
            AddEvaluationResultToOutputDictionary(EvaluationResults, UserInterventionCounter, OutputDictionary);
            case InterventionType of
                InterventionTypes::VENDOR_MISSING:
                    begin
                        PayablesAgentUtilities.RequestTaskToCreateVendor(AgentTask, OutputDictionary);
                        PayablesAgentUtilities.GetEDocumentFromAgentTask(AgentTask, EDocument);
                        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
                        if Vendor.Get(EDocumentPurchaseHeader."[BC] Vendor No.") then begin
                            Vendor.Validate(Blocked, Enum::"Vendor Blocked"::" ");
                            Vendor.Modify(true);
                            LibraryAgent.ContinueTaskAndWait(AgentTask, '');
                        end
                    end;
                InterventionTypes::DRAFT_READY:
                    begin
                        LibraryAgent.ContinueTaskAndWait(AgentTask, '');
                        ContinueProcessing := false;
                    end;
                else
                    ContinueProcessing := false;
            end;
            UserInterventionCounter += 1;
        end;
    end;


    [TryFunction]
    procedure ValidateMessage(GeneratedMessage: Text; var InterventionType: Option; var EvaluationResults: JsonObject)
    var
        PromptEvaluator: Codeunit "Prompt Evaluator";
        AIEvaluateData: Codeunit "AI Evaluate Data";
        AIEvaluate: Codeunit "AI Evaluate";
        EvaluatorStream: InStream;
        Output: JsonObject;
        OutputToken: JsonToken;
    begin
        Clear(EvaluationResults);
        // Read prompty file
        NavApp.GetResource('PromptyPrompts/DetectInterventionType.prompty', EvaluatorStream, TextEncoding::UTF8);
        PromptEvaluator.Read(EvaluatorStream);

        // Set data
        AIEvaluateData.AddElementToData('agentMessage', GeneratedMessage);
        EvaluationResults.Add('generatedMessage', GeneratedMessage);

        // Evaluate
        AIEvaluate.SetEvaluator(PromptEvaluator);
        Output := AIEvaluate.Evaluate(AIEvaluateData);

        // Parse output
        Output.Get('interventionType', OutputToken);
        EvaluationResults.Add('interventionType', OutputToken.AsValue().AsText());

        Output.Get('interventionTypeIndex', OutputToken);
        InterventionType := OutputToken.AsValue().AsInteger();
        EvaluationResults.Add('interventionTypeIndex', InterventionType);

        Output.Get('confidence', OutputToken);
        EvaluationResults.Add('confidence', OutputToken.AsValue().AsInteger());

        Output.Get('reasoning', OutputToken);
        EvaluationResults.Add('reasoning', OutputToken.AsValue().AsText());
    end;

    local procedure AddEvaluationResultToOutputDictionary(EvaluationResults: JsonObject; UserInterventionCounter: Integer; var OutputDictionary: Dictionary of [Text, JsonToken])
    var
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if OutputDictionary.ContainsKey('InterventionClassification') then begin
            OutputDictionary.Get('InterventionClassification', JsonToken);
            OutputDictionary.Remove('InterventionClassification');
            JsonArray := JsonToken.AsArray();
        end;
        JsonObject.Add('UserInterventionCounter', UserInterventionCounter);
        JsonObject.Add('EvaluationResults', EvaluationResults);
        JsonArray.Add(JsonObject);
        OutputDictionary.Add('InterventionClassification', JsonArray.AsToken());
    end;

    var
        InterventionTypes: Option VENDOR_MISSING,DRAFT_READY,ACCOUNT_MISSING,UNKNOWN;
}

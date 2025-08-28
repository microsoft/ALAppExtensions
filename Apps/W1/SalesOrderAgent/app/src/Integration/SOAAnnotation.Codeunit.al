// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.Azure.KeyVault;
using System.AI;

codeunit 4399 "SOA Annotation"
{
    Access = Internal;
    Permissions = tabledata "Agent Task Message" = r;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SOAImpl: Codeunit "SOA Impl";
        AnnotationAccessTokenCodeLbl: Label '1251', Locked = true;
        AnnotationAgentTaskFailureCodeLbl: Label '1252', Locked = true;
        AnnotationTooManyEntriesCodeLbl: Label '1253', Locked = true;
        AnnotationIrrelevantCodeLbl: Label '1254', Locked = true;
        AnnotationAccessTokenLbl: Label 'The agent can''t currently access the selected mailbox because the mailbox access token is missing. Please reactivate the agent after signing in to Business Central again.';
        AnnotationAgentTaskFailureLbl: Label 'The agent can''t currently access the selected mailbox.';
        AnnotationIrrelevantLbl: Label 'Note that this incoming message appears not to be relevant for %1', Comment = '%1 = Agent Name';

    internal procedure GetAgentAnnotations(AgentUserId: Guid; var Annotations: Record "Agent Annotation")
    var
        SOASetup: Record "SOA Setup";
        SOABilling: Codeunit "SOA Billing";
    begin
        SOASetup.SetRange("Agent User Security ID", AgentUserId);
        if not SOASetup.FindFirst() then
            exit;

        SOASetup.CalcFields(State);
        if SOASetup.State = SOASetup.State::Disabled then
            exit;

        Clear(Annotations);

        if ShouldAddAccessTokenAnnotation() then
            AddAccessTokenAnnotation(Annotations)
        else
            if ShouldAddAgentTaskFailureAnnotation() then
                AddAgentTaskFailureAnnotation(Annotations);

        if SOABilling.TooManyUnpaidEntries() then
            AddUnpaidEntriesAnnotation(Annotations);
    end;

    local procedure ShouldAddAccessTokenAnnotation(): Boolean
    var
        SOATask: Record "SOA Task";
        Counter: Integer;
        Failures: Integer;
    begin
#pragma warning disable AA0233
        if SOATask.FindLast() then;
#pragma warning restore AA0233
        repeat
            Counter += 1;
            if not SOATask."Access Token Retrieved" then
                Failures += 1
#pragma warning disable AA0181
        until (SOATask.Next(-1) = 0) or (Counter >= GetFailedTaskLimit());
#pragma warning restore AA0181

        exit(Failures >= GetFailedTaskLimit());
    end;

    local procedure AddAccessTokenAnnotation(var Annotations: Record "Agent Annotation")
    begin
        Clear(Annotations);
        Annotations.Code := AnnotationAccessTokenCodeLbl;
        Annotations.Message := AnnotationAccessTokenLbl;
        Annotations.Severity := Annotations.Severity::Warning;
        if Annotations.Insert() then;
    end;

    local procedure ShouldAddAgentTaskFailureAnnotation(): Boolean
    var
        SOATask: Record "SOA Task";
        Failures: Integer;
        Counter: Integer;
    begin
#pragma warning disable AA0233
        if SOATask.FindLast() then;
#pragma warning restore AA0233
        repeat
            Counter += 1;
            if SOATask.Status = SOATask.Status::"In Progress" then
                Failures += 1
#pragma warning disable AA0181
        until (SOATask.Next(-1) = 0) or (Counter >= GetFailedTaskLimit());
#pragma warning restore AA0181

        if Counter < GetFailedTaskLimit() then
            exit(false);

        exit(Failures >= GetFailedTaskLimit());
    end;

    local procedure AddAgentTaskFailureAnnotation(var Annotations: Record "Agent Annotation")
    begin
        Clear(Annotations);
        Annotations.Code := AnnotationAgentTaskFailureCodeLbl;
        Annotations.Message := AnnotationAgentTaskFailureLbl;
        Annotations.Severity := Annotations.Severity::Warning;
        if Annotations.Insert() then
            Session.LogMessage('0000PQ8', 'Agent task failure detected.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions())
        else
            Session.LogMessage('0000PQ9', 'Failed to insert annotation for agent task failure.', Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions());
    end;

    local procedure AddUnpaidEntriesAnnotation(var Annotations: Record "Agent Annotation")
    var
        SOABilling: Codeunit "SOA Billing";
    begin
        Clear(Annotations);
        Annotations.Code := AnnotationTooManyEntriesCodeLbl;
        Annotations.Message := CopyStr(SOABilling.GetTooManyUnpaidEntriesMessage(), 1, MaxStrLen(Annotations.Message));
        Annotations.Severity := Annotations.Severity::Error;
        if Annotations.Insert() then
            Session.LogMessage('0000PQA', 'Too many unpaid entries detected for agent.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions())
        else
            Session.LogMessage('0000PQB', 'Failed to insert annotation for too many unpaid entries.', Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions());
    end;

    local procedure GetFailedTaskLimit(): Integer
    begin
        exit(5);
    end;

    internal procedure GetAgentTaskMessageAnnotations(AgentTaskMessage: Record "Agent Task Message"; var Annotations: Record "Agent Annotation" temporary)
    var
        Agent: Codeunit Agent;
        IrrelevanceReason: Text;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if CheckIfMessageRelevant(AgentTaskMessage."Task ID", IrrelevanceReason) then
            exit; // Message is relevant, no annotation needed

        CustomDimensions := SOAImpl.GetCustomDimensions();
        CustomDimensions.Add('taskid', Format(AgentTaskMessage."Task ID"));

        Clear(Annotations);
        Annotations.Code := AnnotationIrrelevantCodeLbl;
        Annotations.Message := CopyStr(StrSubstNo(AnnotationIrrelevantLbl, Agent.GetDisplayName(AgentTaskMessage."Agent User Security ID")), 1, MaxStrLen(Annotations.Message));
        Annotations.Details := CopyStr(IrrelevanceReason, 1, MaxStrLen(Annotations.Details));
        Annotations.Severity := Annotations.Severity::Warning;
        if Annotations.Insert() then
            Session.LogMessage('0000PPH', 'Irrelevant message detected for agent.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions)
        else
            Session.LogMessage('0000PQC', 'Failed to insert annotation for irrelevant message.', Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;

    local procedure CheckIfMessageRelevant(TaskId: BigInteger; var IrrelevanceReason: Text): Boolean
    var
        AgentTaskMessages: Record "Agent Task Message";
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        SOAValidationFunc: Codeunit "SOA Validation Function";
        Prompt: SecretText;
        AgentTaskMessage: Text;
        InStream: InStream;
        CustomDimensions: Dictionary of [Text, Text];
        IrrelevantValidationErr: Label 'SOA irrelevant validation failed. Status: %1, Error: %2', Comment = '%1 = Status Code, %2 = Error', Locked = true;
    begin
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT41Latest());

        CustomDimensions := SOAImpl.GetCustomDimensions();
        CustomDimensions.Add('taskid', Format(TaskId));

        if not GetIrrelevantPrompt(Prompt) then begin
            Session.LogMessage('0000PPC', 'Unable to retrieve SOA Irrelevant Prompt from Azure Key Vault.', Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit(true);
        end;

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Sales Order Agent");

        AOAIChatMessages.SetPrimarySystemMessage(Prompt);
        AOAIChatMessages.AddTool(SOAValidationFunc);
        AOAIChatMessages.SetToolInvokePreference(Enum::"AOAI Tool Invoke Preference"::"Invoke Tools Only");

        SetAOAIParameters(AOAIChatMessages, AOAIChatCompletionParams);

        AgentTaskMessages.ReadIsolation(IsolationLevel::ReadUncommitted);
        AgentTaskMessages.SetAutoCalcFields(Content);
        AgentTaskMessages.SetRange("Task ID", TaskId);

        AgentTaskMessages.SetAscending(ID, true);
        if AgentTaskMessages.FindSet() then
            repeat
                AgentTaskMessages.Content.CreateInStream(InStream, TextEncoding::UTF8);
                InStream.Read(AgentTaskMessage);
                if AgentTaskMessages.Type = AgentTaskMessages.Type::Input then
                    AOAIChatMessages.AddUserMessage(AgentTaskMessage)
                else
                    if AgentTaskMessages.Type = AgentTaskMessages.Type::Output then
                        AOAIChatMessages.AddAssistantMessage(AgentTaskMessage);
            until AgentTaskMessages.Next() = 0
        else begin
            Session.LogMessage('0000PPD', 'No messages found for the task.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit(true);
        end;

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if not AOAIOperationResponse.IsSuccess() then begin
            Session.LogMessage('0000PPE', StrSubstNo(IrrelevantValidationErr, AOAIOperationResponse.GetStatusCode(), AOAIOperationResponse.GetError()), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit(true);
        end;

        if not AOAIOperationResponse.IsFunctionCall() then begin
            Session.LogMessage('0000PPF', 'SOA irrelevant validation: response did not contain a function call.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit(true);
        end;

        if not SOAValidationFunc.IsIrrelevant() then begin
            Session.LogMessage('0000PPG', 'SOA message determined as relevant.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit(true);
        end;

        IrrelevanceReason := SOAValidationFunc.GetIrrelevantReason();
        exit(false);
    end;

    local procedure SetAOAIParameters(AOAIChatMessages: Codeunit "AOAI Chat Messages"; AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params")
    begin
        AOAIChatMessages.SetHistoryLength(999); // Include all messages in the chat history
        AOAIChatCompletionParams.SetTemperature(0);
    end;

    local procedure GetIrrelevantPrompt(var Prompt: SecretText): Boolean
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        exit(AzureKeyVault.GetAzureKeyVaultSecret('BCSOA-Irrelevance-Prompt', Prompt));
    end;
}
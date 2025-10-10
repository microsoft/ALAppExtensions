// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.Azure.KeyVault;
using System.AI;
using System.Telemetry;

codeunit 4399 "SOA Annotation"
{
    Access = Internal;
    Permissions = tabledata "Agent Task Message" = r, tabledata "Agent Task Message Attachment" = rM;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SOAImpl: Codeunit "SOA Impl";
        SOASetupCU: Codeunit "SOA Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        AnnotationProcessingLimitReachedCodeLbl: Label 'DAILYLIMITREACHED', Locked = true, MaxLength = 20;
        AnnotationAccessTokenCodeLbl: Label '1251', Locked = true;
        AnnotationAgentTaskFailureCodeLbl: Label '1252', Locked = true;
        AnnotationAgentTaskSendRepliesFailureCodeLbl: Label 'SENDREPLYFAIL', MaxLength = 20, Locked = true;
        AnnotationTooManyEntriesCodeLbl: Label '1253', Locked = true;
        AnnotationIrrelevantCodeLbl: Label '1254', Locked = true;
        AnnotationAccessTokenLbl: Label 'The agent can''t currently access the selected mailbox because the mailbox access token is missing. Please reactivate the agent after signing in to Business Central again.';
        AnnotationProcessingLimitReachedLbl: Label 'You have reached today''s limit of %1 tasks. You can update this limit in the agent settings or return tomorrow to continue.', Comment = '%1 = Process Limit';
        AnnotationAgentTaskFailureLbl: Label 'The agent can''t currently access the selected mailbox.';
        AnnotationAgentTaskSendRepliesFailureLbl: Label 'The agent can''t currently send email replies from the selected mailbox. Please ensure the mailbox has the proper ''send as'' permissions in the Exchange admin portal.';
        AnnotationIrrelevantLbl: Label 'All or parts of this message may not be relevant for %1', Comment = '%1 = Agent Name';

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

        if ShouldAddOverProcessLimitAnnotation(SOASetup) then
            AddOverProcessLimitAnnotation(Annotations, SOASetup);
        if ShouldAddAccessTokenAnnotation() then
            AddAccessTokenAnnotation(Annotations)
        else
            if ShouldAddAgentTaskFailureAnnotation() then
                AddAgentTaskFailureAnnotation(Annotations)
            else
                if ShouldAddAgentTaskSendRepliesFailureAnnotation() then
                    AddAgentTaskSendRepliesFailureAnnotation(Annotations);

        if SOABilling.TooManyUnpaidEntries() then
            AddUnpaidEntriesAnnotation(Annotations);
    end;

    local procedure ShouldAddOverProcessLimitAnnotation(var SOASetup: Record "SOA Setup"): Boolean
    var
        SOAEmailMgt: Codeunit "SOA Email Setup";
        Processed: Integer;
        ProcessLimit: Integer;
    begin
        ProcessLimit := SOAImpl.GetProcessLimitPerDay(SOASetup);
        Processed := SOAEmailMgt.GetEmailCountProcessedWithin24hrs();
        exit(Processed >= ProcessLimit);
    end;

    local procedure AddOverProcessLimitAnnotation(var Annotations: Record "Agent Annotation"; var SOASetup: Record "SOA Setup")
    var
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        Clear(Annotations);
        Annotations.Code := AnnotationProcessingLimitReachedCodeLbl;
        Annotations.Message := StrSubstNo(AnnotationProcessingLimitReachedLbl, SOASetup."Message Limit");
        Annotations.Severity := Annotations.Severity::Warning;

        TelemetryDimensions.Add('Limit', Format(SOASetup."Message Limit"));
        if Annotations.Insert() then
            FeatureTelemetry.LogUsage('0000PZ6', SOASetupCU.GetFeatureName(), 'Daily message limit reached.', TelemetryDimensions)
        else
            FeatureTelemetry.LogError('0000PZ7', SOASetupCU.GetFeatureName(), 'Daily message limit reached.', 'Failed to insert annotation for daily message limit reached.', GetLastErrorCallStack(), TelemetryDimensions);
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
        Counter: Integer;
        Failures: Integer;
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

        exit(Failures >= GetFailedTaskLimit());
    end;

    local procedure AddAgentTaskFailureAnnotation(var Annotations: Record "Agent Annotation")
    var
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        Clear(Annotations);
        Annotations.Code := AnnotationAgentTaskFailureCodeLbl;
        Annotations.Message := AnnotationAgentTaskFailureLbl;
        Annotations.Severity := Annotations.Severity::Warning;
        if Annotations.Insert() then
            FeatureTelemetry.LogUsage('0000PQ8', SOASetupCU.GetFeatureName(), 'Agent task failure detected.', TelemetryDimensions)
        else
            FeatureTelemetry.LogError('0000PQ9', SOASetupCU.GetFeatureName(), 'Agent task failure detected.', 'Failed to insert annotation for agent task failure.', GetLastErrorCallStack(), TelemetryDimensions);
    end;

    local procedure ShouldAddAgentTaskSendRepliesFailureAnnotation(): Boolean
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
            if (SOATask.Status = SOATask.Status::Succeeded) and not SOATask."Send Replies Successful" then
                Failures += 1;
#pragma warning disable AA0181
        until (SOATask.Next(-1) = 0) or (Counter >= GetFailedTaskLimit());
#pragma warning restore AA0181

        exit(Failures >= GetFailedTaskLimit());
    end;

    local procedure AddAgentTaskSendRepliesFailureAnnotation(var Annotations: Record "Agent Annotation")
    var
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        Clear(Annotations);
        Annotations.Code := AnnotationAgentTaskSendRepliesFailureCodeLbl;
        Annotations.Message := AnnotationAgentTaskSendRepliesFailureLbl;
        Annotations.Severity := Annotations.Severity::Warning;
        if Annotations.Insert() then
            FeatureTelemetry.LogUsage('0000QG5', SOASetupCU.GetFeatureName(), 'Agent send replies failure detected.', TelemetryDimensions)
        else
            FeatureTelemetry.LogError('0000QG4', SOASetupCU.GetFeatureName(), 'Agent send replies failure detected.', 'Failed to insert annotation for agent send replies failure.', GetLastErrorCallStack(), TelemetryDimensions);
    end;

    local procedure AddUnpaidEntriesAnnotation(var Annotations: Record "Agent Annotation")
    var
        SOABilling: Codeunit "SOA Billing";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        Clear(Annotations);
        Annotations.Code := AnnotationTooManyEntriesCodeLbl;
        Annotations.Message := CopyStr(SOABilling.GetTooManyUnpaidEntriesMessage(), 1, MaxStrLen(Annotations.Message));
        Annotations.Severity := Annotations.Severity::Error;
        if Annotations.Insert() then
            FeatureTelemetry.LogUsage('0000PQA', SOASetupCU.GetFeatureName(), 'Too many unpaid entries detected for agent.', TelemetryDimensions)
        else
            FeatureTelemetry.LogError('0000PQB', SOASetupCU.GetFeatureName(), 'Too many unpaid entries detected for agent.', 'Failed to insert annotation for too many unpaid entries.', GetLastErrorCallStack(), TelemetryDimensions);
    end;

    local procedure GetFailedTaskLimit(): Integer
    begin
        exit(5);
    end;

    internal procedure GetAgentTaskMessageAnnotations(AgentTaskMessage: Record "Agent Task Message"; var Annotations: Record "Agent Annotation" temporary)
    var
        Agent: Codeunit Agent;
        IrrelevanceReason: Text;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if CheckReleavanceOfAgentTaskMessage(AgentTaskMessage, IrrelevanceReason) then
            exit; // Message is relevant, no annotation needed

        TelemetryDimensions.Add('TaskId', Format(AgentTaskMessage."Task ID"));

        Clear(Annotations);
        Annotations.Code := AnnotationIrrelevantCodeLbl;
        Annotations.Message := CopyStr(StrSubstNo(AnnotationIrrelevantLbl, Agent.GetDisplayName(AgentTaskMessage."Agent User Security ID")), 1, MaxStrLen(Annotations.Message));
        Annotations.Details := CopyStr(IrrelevanceReason, 1, MaxStrLen(Annotations.Details));
        Annotations.Severity := Annotations.Severity::Warning;
        if Annotations.Insert() then
            FeatureTelemetry.LogUsage('0000PPH', SOASetupCU.GetFeatureName(), 'Irrelevant message detected for agent.', TelemetryDimensions)
        else
            FeatureTelemetry.LogError('0000PQC', SOASetupCU.GetFeatureName(), 'Irrelevant message detected for agent.', 'Failed to insert annotation for irrelevant message.', GetLastErrorCallStack(), TelemetryDimensions);
    end;

    local procedure CheckReleavanceOfAgentTaskMessage(var AgentTaskMessage: Record "Agent Task Message"; var IrrelevanceReason: Text): Boolean
    var
        IsMessageRelevant: Boolean;
        IsAttachmentRelevant: Boolean;
    begin
        IsMessageRelevant := CheckIfMessageRelevant(AgentTaskMessage, IrrelevanceReason);
        IsAttachmentRelevant := CheckIfAttachmentRelevant(AgentTaskMessage);

        //If the message is deemed irrelevant, but at least one attachment is relevant, then the message should be considered relevant.
        if not IsMessageRelevant and IsAttachmentRelevant then
            IsMessageRelevant := true;

        exit(IsMessageRelevant);
    end;

    internal procedure CheckIfAttachmentRelevant(var AgentTaskMessage: Record "Agent Task Message"): Boolean
    var
        AgentTaskMessageAttachment: Record "Agent Task Message Attachment";
        SOABilling: Codeunit "SOA Billing";
        SOABillingTask: Codeunit "SOA Billing Task";
        IrrelevanceReason: Text;
        IsAttachmentRelevant: Boolean;
    begin
        AgentTaskMessageAttachment.ReadIsolation(IsolationLevel::ReadCommitted);
        AgentTaskMessageAttachment.SetRange("Task ID", AgentTaskMessage."Task ID");
        AgentTaskMessageAttachment.SetRange("Message ID", AgentTaskMessage.ID);
        AgentTaskMessageAttachment.SetRange(Ignored, false);
        if not AgentTaskMessageAttachment.FindSet() then
            exit(false);

        repeat
            // Check each attachment for relevance
            if not CheckIfAttachmentRelevant(AgentTaskMessage, AgentTaskMessageAttachment, IrrelevanceReason) then begin
                AgentTaskMessageAttachment.Ignored := true;
                AgentTaskMessageAttachment.Modify();
                SOABilling.LogIrrelevantAttachment(AgentTaskMessageAttachment.SystemId, AgentTaskMessage."Task ID", AgentTaskMessage.ID);
            end
            else begin
                IsAttachmentRelevant := true;
                SOABilling.LogRelevantAttachment(AgentTaskMessageAttachment.SystemId, AgentTaskMessage."Task ID", AgentTaskMessage.ID);
            end;
            SOABillingTask.ScheduleBillingTask();
        until AgentTaskMessageAttachment.Next() = 0;
        Commit();
        exit(IsAttachmentRelevant);
    end;

    local procedure CheckIfAttachmentRelevant(AgentTaskMessage: Record "Agent Task Message"; AgentTaskMessageAttachment: Record "Agent Task Message Attachment"; var IrrelevanceReason: Text): Boolean
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        SOAValidationFunc: Codeunit "SOA Validation Function";
        Prompt: SecretText;
        AgentTaskMessageTxt: Text;
        AgentAttachmentTxt: Text;
        InStream: InStream;
        TelemetryDimensions: Dictionary of [Text, Text];
        IrrelevantValidationErr: Label 'SOA attachment irrelevant validation failed. Status: %1, Error: %2', Comment = '%1 = Status Code, %2 = Error', Locked = true;
        AttachmentUserMessageTxt: Label '<message>%1</message> <attachment>%2</attachment>', Locked = true;
    begin
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT41Latest());

        TelemetryDimensions.Add('TaskId', Format(AgentTaskMessageAttachment."Task ID"));
        TelemetryDimensions.Add('MessageId', Format(AgentTaskMessageAttachment."Message ID"));
        TelemetryDimensions.Add('AgentUserSecurityId', Format(AgentTaskMessage."Agent User Security ID"));

        if not GetIrrelevantAttachmentPrompt(Prompt) then begin
            FeatureTelemetry.LogError('0000Q7L', SOASetupCU.GetFeatureName(), 'Retrieve SOA Irrelevant Prompt', 'Unable to retrieve SOA Irrelevant Prompt from Azure Key Vault.', GetLastErrorCallStack(), TelemetryDimensions);
            exit(false);
        end;

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Sales Order Agent");

        AOAIChatMessages.SetPrimarySystemMessage(Prompt);
        AOAIChatMessages.AddTool(SOAValidationFunc);
        AOAIChatMessages.SetToolInvokePreference(Enum::"AOAI Tool Invoke Preference"::"Invoke Tools Only");

        SetAOAIParameters(AOAIChatMessages, AOAIChatCompletionParams);

        AgentTaskMessage.CalcFields(Content);
        AgentTaskMessage.Content.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(AgentTaskMessageTxt);

        AgentTaskMessageAttachment.CalcFields("Text Content");
        AgentTaskMessageAttachment."Text Content".CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(AgentAttachmentTxt);

        if AgentAttachmentTxt = '' then begin
            FeatureTelemetry.LogUsage('0000Q7M', SOASetupCU.GetFeatureName(), 'No attachment content found for the task.', TelemetryDimensions);
            exit(false);
        end;

        AOAIChatMessages.AddUserMessage(StrSubstNo(AttachmentUserMessageTxt, AgentTaskMessageTxt, AgentAttachmentTxt));
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if not AOAIOperationResponse.IsSuccess() then begin
            FeatureTelemetry.LogError('0000Q7N', SOASetupCU.GetFeatureName(), 'Retrieve SOA Attachment Validation', StrSubstNo(IrrelevantValidationErr, AOAIOperationResponse.GetStatusCode(), AOAIOperationResponse.GetError()), GetLastErrorCallStack(), TelemetryDimensions);
            exit(false);
        end;

        if not AOAIOperationResponse.IsFunctionCall() then begin
            FeatureTelemetry.LogError('0000Q7O', SOASetupCU.GetFeatureName(), 'SOA attachment irrelevant validation', 'Response did not contain a function call.', GetLastErrorCallStack(), TelemetryDimensions);
            exit(false);
        end;

        if not SOAValidationFunc.IsIrrelevant() then begin
            FeatureTelemetry.LogUsage('0000Q7P', SOASetupCU.GetFeatureName(), 'SOA attachment determined as relevant.', TelemetryDimensions);
            exit(true);
        end;

        FeatureTelemetry.LogUsage('0000Q7Q', SOASetupCU.GetFeatureName(), 'SOA attachment determined as irrelevant.', TelemetryDimensions);
        IrrelevanceReason := SOAValidationFunc.GetIrrelevantReason();
        exit(false);
    end;

    local procedure CheckIfMessageRelevant(AgentTaskMessage: Record "Agent Task Message"; var IrrelevanceReason: Text): Boolean
    var
        AgentTaskMessages: Record "Agent Task Message";
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        SOAValidationFunc: Codeunit "SOA Validation Function";
        Prompt: SecretText;
        AgentTaskMessageTxt: Text;
        InStream: InStream;
        TelemetryDimensions: Dictionary of [Text, Text];
        IrrelevantValidationErr: Label 'SOA irrelevant validation failed. Status: %1, Error: %2', Comment = '%1 = Status Code, %2 = Error', Locked = true;
    begin
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT41Latest());

        TelemetryDimensions.Add('TaskId', Format(AgentTaskMessage."Task ID"));
        TelemetryDimensions.Add('AgentUserSecurityId', Format(AgentTaskMessage."Agent User Security ID"));

        if not GetIrrelevantMessagePrompt(Prompt) then begin
            FeatureTelemetry.LogError('0000PPC', SOASetupCU.GetFeatureName(), 'Retrieve SOA Irrelevant Prompt', 'Unable to retrieve SOA Irrelevant Prompt from Azure Key Vault.', GetLastErrorCallStack(), TelemetryDimensions);
            exit(true);
        end;

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Sales Order Agent");

        AOAIChatMessages.SetPrimarySystemMessage(Prompt);
        AOAIChatMessages.AddTool(SOAValidationFunc);
        AOAIChatMessages.SetToolInvokePreference(Enum::"AOAI Tool Invoke Preference"::"Invoke Tools Only");

        SetAOAIParameters(AOAIChatMessages, AOAIChatCompletionParams);

        AgentTaskMessages.ReadIsolation(IsolationLevel::ReadUncommitted);
        AgentTaskMessages.SetAutoCalcFields(Content);
        AgentTaskMessages.SetRange("Task ID", AgentTaskMessage."Task ID");

        AgentTaskMessages.SetAscending(ID, true);
        if AgentTaskMessages.FindSet() then
            repeat
                AgentTaskMessages.Content.CreateInStream(InStream, TextEncoding::UTF8);
                InStream.Read(AgentTaskMessageTxt);
                if AgentTaskMessages.Type = AgentTaskMessages.Type::Input then
                    AOAIChatMessages.AddUserMessage(AgentTaskMessageTxt)
                else
                    if AgentTaskMessages.Type = AgentTaskMessages.Type::Output then
                        AOAIChatMessages.AddAssistantMessage(AgentTaskMessageTxt);
            until AgentTaskMessages.Next() = 0
        else begin
            FeatureTelemetry.LogUsage('0000PPD', SOASetupCU.GetFeatureName(), 'No messages found for the task.', TelemetryDimensions);
            exit(true);
        end;

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if not AOAIOperationResponse.IsSuccess() then begin
            FeatureTelemetry.LogError('0000PPE', SOASetupCU.GetFeatureName(), 'AOAIOperationResponse', StrSubstNo(IrrelevantValidationErr, AOAIOperationResponse.GetStatusCode(), AOAIOperationResponse.GetError()), GetLastErrorCallStack(), TelemetryDimensions);
            exit(true);
        end;

        if not AOAIOperationResponse.IsFunctionCall() then begin
            FeatureTelemetry.LogError('0000PPF', SOASetupCU.GetFeatureName(), 'AOAIOperationResponse IsFunctionCall', 'SOA irrelevant validation: response did not contain a function call.', GetLastErrorCallStack(), TelemetryDimensions);
            exit(true);
        end;

        if not SOAValidationFunc.IsIrrelevant() then begin
            FeatureTelemetry.LogUsage('0000PPG', SOASetupCU.GetFeatureName(), 'SOA message determined as relevant.', TelemetryDimensions);
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

    [NonDebuggable]
    local procedure GetIrrelevantMessagePrompt(var Prompt: SecretText): Boolean
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        BCSOAResponsibilitiesPrompt: SecretText;
        BCSOAIrrelevanceMessage: SecretText;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret('BCSOAResponsibilitiesV27', BCSOAResponsibilitiesPrompt) then
            exit(false);
        if not AzureKeyVault.GetAzureKeyVaultSecret('BCSOAIrrelevanceMessageV27', BCSOAIrrelevanceMessage) then
            exit(false);

        Prompt := SecretStrSubstNo(BCSOAIrrelevanceMessage.Unwrap(), BCSOAResponsibilitiesPrompt);
        exit(true);
    end;

    [NonDebuggable]
    local procedure GetIrrelevantAttachmentPrompt(var Prompt: SecretText): Boolean
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        BCSOAResponsibilitiesPrompt: SecretText;
        BCSOAIrrelevanceAttachment: SecretText;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret('BCSOAResponsibilitiesV27', BCSOAResponsibilitiesPrompt) then
            exit(false);
        if not AzureKeyVault.GetAzureKeyVaultSecret('BCSOAIrrelevanceAttachmentV27', BCSOAIrrelevanceAttachment) then
            exit(false);

        Prompt := SecretStrSubstNo(BCSOAIrrelevanceAttachment.Unwrap(), BCSOAResponsibilitiesPrompt);
        exit(true);
    end;
}
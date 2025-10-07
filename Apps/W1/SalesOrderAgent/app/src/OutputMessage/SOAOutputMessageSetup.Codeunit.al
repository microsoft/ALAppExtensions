// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.AI;
using System.Telemetry;

codeunit 4402 "SOA Output Message Setup"
{
    Permissions = tabledata "Agent Task Message" = rM;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Verifies the entered signature for correctness by checking for harmful content, grammatical errors, and missing elements.
    /// Harmful content is blocked, while other issues prompt the user for confirmation before proceeding.
    /// </summary>
    /// <param name="SignatureAsTxt">User input signature text</param>
    internal procedure CheckSignature(SignatureAsTxt: Text)
    var
        IsValid: Boolean;
        IsHarmful: Boolean;
        InvalidReason: Text;
        ImagePlaceHolderLbl: Label '[SOA_IMAGE_', Locked = true;
        ImagePlaceHolderErr: Label 'The signature contains unsupported text "SOA_IMAGE". Please remove them and try again.';
        UnsuccessfulSignatureCheckErr: Label 'We are having trouble using the AI service. Please try again shortly.';
        NewSignatureEmptyLbl: Label 'You did not set a signature. Are you sure you want to proceed without one?';
        TooBigImagesErr: Label 'The total size of images in the signature exceeds the allowed limit. Please reduce the size or number of images and try again.';
        ContainsHarmfulLbl: Label 'The input contains potentially harmful content and could not be saved. Please revise and try again.';
        NotCompleteLbl: Label 'The email signature seems incomplete. Please consider editing based on the AI suggestions:\%1\\Would you like to proceed with it as is?', Comment = '%1 - suggestions';
    begin
        if SignatureAsTxt = '' then begin
            if not Confirm(NewSignatureEmptyLbl, false) then
                Error('');
            exit;
        end;

        if StrPos(SignatureAsTxt, ImagePlaceHolderLbl) > 0 then
            Error(ImagePlaceHolderErr);

        if GetSignatureImagesTotalSize(SignatureAsTxt) > 40000 then //around 10000 tokens
            Error(TooBigImagesErr);

        if not CheckMailTemplate(SignatureAsTxt, IsValid, IsHarmful, InvalidReason) then begin
            LogTelemetryError('0000Q9G', 'CheckMailSignature');
            Error(UnsuccessfulSignatureCheckErr);
        end;

        if IsHarmful then
            Error(ContainsHarmfulLbl);

        if not IsValid then
            if not Confirm(StrSubstNo(NotCompleteLbl, InvalidReason), false) then
                Error('');
    end;

    /// <summary>
    /// Appends the custom signature to the email body. Called by platform.
    /// </summary>
    /// <param name="AgentTaskMessage">Contains mail body which need to be updated with custom signature text</param>
    internal procedure PrepareOutputMessage(AgentTaskMessage: Record "Agent Task Message")
    var
        SOASetup: Record "SOA Setup";
        SOABilling: Codeunit "SOA Billing";
        SOABillingTask: Codeunit "SOA Billing Task";
    begin
        if AgentTaskMessage.Type <> AgentTaskMessage.Type::Output then
            exit;

        SOABilling.LogEmailGenerated(AgentTaskMessage.ID, AgentTaskMessage."Task ID", AgentTaskMessage."Input Message ID");
        SOABillingTask.ScheduleBillingTask();
        SOASetup.ReadIsolation(IsolationLevel::ReadCommitted);
        SOASetup.GetBasedOnAgentUserSecurityID(AgentTaskMessage."Agent User Security ID", true);
        if not SOASetup."Configure Email Template" then
            exit;

        if not AddSignatureToMessageBody(AgentTaskMessage) then
            LogTelemetryError('0000Q9G', 'AppendSignatureToMessageBody');
    end;

    [NonDebuggable]
    local procedure CheckMailTemplate(SignatureAsTxt: Text; var IsValid: Boolean; var IsHarmful: Boolean; var InvalidReason: Text): Boolean
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIFunctionResponse: Codeunit "AOAI Function Response";
        SOAMailTemplateValidation: Codeunit "SOA Email Template Validation";
        SystemInstructions: SecretText;
    begin
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT41Latest());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Sales Order Agent");

        SystemInstructions := GetMailTemplateCheckSystemInstructions();
        AOAIChatMessages.SetPrimarySystemMessage(SystemInstructions);

        AOAIChatMessages.AddTool(SOAMailTemplateValidation);
        AOAIChatMessages.SetToolChoice('{"type": "function", "function": {"name": "EmailSignature_Validation"}}');
        AOAIChatMessages.SetToolInvokePreference(Enum::"AOAI Tool Invoke Preference"::"Invoke Tools Only");

        AOAIChatMessages.AddUserMessage(SignatureAsTxt);

        AOAIChatCompletionParams.SetMaxTokens(GetMaxTokens());
        AOAIChatCompletionParams.SetTemperature(0);

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if not AOAIOperationResponse.IsSuccess() then
            exit(false);

        if not AOAIOperationResponse.IsFunctionCall() then
            exit(false);

        foreach AOAIFunctionResponse in AOAIOperationResponse.GetFunctionResponses() do
            IsValid := SOAMailTemplateValidation.Execute(AOAIFunctionResponse.GetArguments());

        InvalidReason := SOAMailTemplateValidation.GetInvalidReason();
        IsHarmful := SOAMailTemplateValidation.GetIsHarmful();

        if IsValid then
            InvalidReason := '';

        exit(true);
    end;

    local procedure AddSignatureToMessageBody(OutputAgentTaskMessage: Record "Agent Task Message"): Boolean
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIFunctionResponse: Codeunit "AOAI Function Response";
        SOAOutputMessageValidation: Codeunit "SOA Output Message Validation";
        Images: Dictionary of [Text, Text];
        SystemInstructions: SecretText;
        NewMessageContent: Text;
    begin
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT41Latest());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Sales Order Agent");

        SystemInstructions := GetAddSignatureSystemInstructions();
        AOAIChatMessages.SetPrimarySystemMessage(SystemInstructions);

        AOAIChatMessages.AddTool(SOAOutputMessageValidation);
        AOAIChatMessages.SetToolChoice('{"type": "function", "function": {"name": "EmailSignature_Append"}}');
        AOAIChatMessages.SetToolInvokePreference(Enum::"AOAI Tool Invoke Preference"::"Invoke Tools Only");

        AOAIChatMessages.AddUserMessage(GetMailBody(OutputAgentTaskMessage));
        AOAIChatMessages.AddUserMessage(PrepareSignatureText(GetSignatureText(OutputAgentTaskMessage."Agent User Security ID"), Images));

        AOAIChatCompletionParams.SetMaxTokens(GetMaxTokens());
        AOAIChatCompletionParams.SetTemperature(0);

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if not AOAIOperationResponse.IsSuccess() then begin
            LogTelemetryError('0000Q9G', 'AddSignatureToMessageBody');
            exit(false);
        end;

        if not AOAIOperationResponse.IsFunctionCall() then
            exit(false);

        foreach AOAIFunctionResponse in AOAIOperationResponse.GetFunctionResponses() do
            NewMessageContent := SOAOutputMessageValidation.Execute(AOAIFunctionResponse.GetArguments());

        ReturnImagesToSignature(NewMessageContent, Images);

        if NewMessageContent <> '' then
            DoUpdateAgentTaskMessageContent(OutputAgentTaskMessage, NewMessageContent);

        exit(NewMessageContent <> '');
    end;

    local procedure DoUpdateAgentTaskMessageContent(OutputAgentTaskMessage: Record "Agent Task Message"; NewMessageContent: Text)
    var
        AgentTaskMessage: Record "Agent Task Message";
        OutStream: OutStream;
    begin
        AgentTaskMessage.ReadIsolation(IsolationLevel::ReadCommitted);
        AgentTaskMessage.Get(OutputAgentTaskMessage."Task ID", OutputAgentTaskMessage.ID);
        Clear(AgentTaskMessage.Content);
        AgentTaskMessage.Content.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewMessageContent);
        AgentTaskMessage.Modify();
    end;

    local procedure GetMailBody(AgentTaskMessage: Record "Agent Task Message"): Text
    var
        InStream: InStream;
        AgentTaskMessageAsTxt: Text;
        MailBodyLbl: Label '<mail_body>%1</mail_body>', Comment = 'content', Locked = true;
    begin
        AgentTaskMessage.CalcFields(Content);
        AgentTaskMessage.Content.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(AgentTaskMessageAsTxt);
        exit(StrSubstNo(MailBodyLbl, AgentTaskMessageAsTxt));
    end;

    local procedure PrepareSignatureText(SignatureAsTxt: Text; var Images: Dictionary of [Text, Text]): Text
    var
        ImgStartWithLbl: Label '<img', Locked = true;
    begin
        while StrPos(SignatureAsTxt, ImgStartWithLbl) > 0 do
            ExtractImageFromSignature(SignatureAsTxt, Images);

        exit(SignatureAsTxt);
    end;

    local procedure ReturnImagesToSignature(var SignatureAsTxt: Text; var Images: Dictionary of [Text, Text])
    var
        ImagePlaceHolder: Text;
    begin
        foreach ImagePlaceHolder in Images.Keys() do
            SignatureAsTxt := SignatureAsTxt.Replace(ImagePlaceHolder, Images.Get(ImagePlaceHolder));
    end;

    local procedure GetSignatureImagesTotalSize(SignatureAsTxt: Text): Integer
    var
        Images: Dictionary of [Text, Text];
        CharactersCount: Integer;
        Image: Text;
    begin
        PrepareSignatureText(SignatureAsTxt, Images);
        foreach Image in Images.Keys() do
            CharactersCount += StrLen(Images.Get(Image));

        exit(CharactersCount);
    end;

    local procedure ExtractImageFromSignature(var SignatureAsTxt: Text; var Images: Dictionary of [Text, Text])
    var
        ImageStartPosition: Integer;
        ImageEndPosition: Integer;
        EverythingBeforeImg: Text;
        EverythingAfterImg: Text;
        ImagePlaceHolder: Text;
        ImgStartWithLbl: Label '<img', Locked = true;
        ImgEndWithLbl: Label '>', Locked = true;
    begin
        ImageStartPosition := StrPos(SignatureAsTxt, ImgStartWithLbl);
        EverythingBeforeImg := CopyStr(SignatureAsTxt, 1, ImageStartPosition - 1);
        EverythingAfterImg := CopyStr(SignatureAsTxt, ImageStartPosition);
        ImageEndPosition := StrPos(EverythingAfterImg, ImgEndWithLbl);
        ImagePlaceHolder := UpdateDictionaryWithImages(Images, CopyStr(EverythingAfterImg, 1, ImageEndPosition));
        EverythingAfterImg := CopyStr(EverythingAfterImg, ImageEndPosition + 1);

        SignatureAsTxt := EverythingBeforeImg + ImagePlaceHolder + EverythingAfterImg;
    end;

    local procedure UpdateDictionaryWithImages(var Images: Dictionary of [Text, Text]; ImageinHtml: Text) ImagePlaceHolder: Text
    var
        ImagePlaceHolderLbl: Label '[SOA_IMAGE_%1]', Locked = true;
    begin
        ImagePlaceHolder := StrSubstNo(ImagePlaceHolderLbl, Images.Count() + 1);
        Images.Add(ImagePlaceHolder, ImageinHtml);
    end;

    local procedure GetSignatureText(AgentUserSecurityId: Guid): Text
    var
        SOASetup: Record "SOA Setup";
        SOASetupCU: Codeunit "SOA Setup";
        SignatureLbl: Label '<signature>%1</signature>', Comment = 'content', Locked = true;
    begin
        SOASetup.ReadIsolation(IsolationLevel::ReadCommitted);
        SOASetup.GetBasedOnAgentUserSecurityID(AgentUserSecurityId, true);
        if SOASetup."Configure Email Template" then
            exit(StrSubstNo(SignatureLbl, SOASetup.GetEmailSignatureAsTxt()));

        exit(SOASetupCU.GetDefaultEmailSignatureAsTxt());
    end;

    local procedure LogTelemetryError(TelemetryErrorCode: Text; EventName: Text)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SOASetup: Codeunit "SOA Setup";
        ErrorTextLbl: Label 'An issue occurred during the execution of the LLM call.', Locked = true;
    begin
        FeatureTelemetry.LogError(TelemetryErrorCode, SOASetup.GetFeatureName(), EventName, ErrorTextLbl);
    end;

    local procedure GetMaxTokens(): Integer
    begin
        exit(20000);
    end;

    [NonDebuggable]
    local procedure GetAddSignatureSystemInstructions(): SecretText
    var
        SOAInstructions: Codeunit "SOA Instructions";
    begin
        exit(SOAInstructions.GetOutputMessageSignatureUpdateSystemPrompt());
    end;

    [NonDebuggable]
    local procedure GetMailTemplateCheckSystemInstructions(): SecretText
    var
        SOAInstructions: Codeunit "SOA Instructions";
    begin
        exit(SOAInstructions.GetMailTemplateCheckSystemPrompt());
    end;
}
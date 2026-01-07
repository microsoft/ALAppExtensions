// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

codeunit 4002 "SOA Prompt Builder"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    internal procedure PrepareInstructions(var InstructionsSecret: SecretText; var SOASetup: Record "SOA Setup")
    var
        SOAInstructions: Codeunit "SOA Instructions";
    begin
        InstructionsSecret := SOAInstructions.GetSOAInstructions();
        BuildPromptBasedOnSetup(InstructionsSecret, SOASetup);
        BuildSignature(InstructionsSecret, SOASetup);
    end;

    [NonDebuggable]
    local procedure BuildPromptBasedOnSetup(var InstructionsSecret: SecretText; var SOASetup: Record "SOA Setup")
    var
        RawInstructions: JsonObject;
        PromptsAsJToken: JsonToken;
        PromptsOrderAsJToken: JsonToken;
        PromptsOrderAsJArray: JsonArray;
        PromptJToken: JsonToken;
        InstructionsText: Text;
        HintName: Text;
        Prompt: Text;
        Include: Boolean;
        NextStepNo: Integer;
    begin
        InstructionsText := InstructionsSecret.Unwrap();
        RawInstructions.ReadFrom(InstructionsText);

        if SOASetup.IsEmpty then
            exit;

        RawInstructions.Get(JTokenPromptLbl, PromptsAsJToken);
        RawInstructions.Get(JTokenOrderLbl, PromptsOrderAsJToken);

        PromptsOrderAsJArray := PromptsOrderAsJToken.AsArray();

        foreach PromptJToken in PromptsOrderAsJArray do begin
            NextStepNo := 0;
            HintName := PromptJToken.AsValue().AsText();
            Include := CheckShouldBeIncluded(SOASetup, HintName);

            if Include then
                if PromptsAsJToken.AsObject().Get(HintName, PromptJToken) then
                    ProcessJToken(SOASetup, Prompt, PromptJToken, '', NextStepNo, false);
        end;
        InstructionsSecret := Prompt;
    end;

    [NonDebuggable]
    local procedure ProcessJToken(var SOASetup: Record "SOA Setup"; var Prompt: Text; JToken: JsonToken; ParentStepNo: Text; var NextStepNo: Integer; AddNumbering: Boolean): Boolean
    begin
        if JToken.IsArray() then
            exit(ProcessJTokenAsArray(SOASetup, Prompt, JToken.AsArray(), ParentStepNo, AddNumbering));

        if JToken.IsObject() then
            exit(ProcessJTokenAsObject(SOASetup, Prompt, JToken.AsObject(), ParentStepNo, NextStepNo));

        if JToken.IsValue() then
            exit(ProcessJTokenAsValue(Prompt, JToken, ParentStepNo, NextStepNo));
    end;

    [NonDebuggable]
    local procedure ProcessJTokenAsValue(var Prompt: Text; JToken: JsonToken; ParentStepNo: Text; var NextStepNo: Integer): Boolean
    var
        Value: Text;
        IsPageSpecInstructionTag: Boolean;
    begin
        Value := JToken.AsValue().AsText();
        IsPageSpecInstructionTag := Value.StartsWith(PageSpecInstructionTagStartLbl) and Value.EndsWith(PageSpecInstructionTagEndLbl);

        if IsPageSpecInstructionTag and (NextStepNo > 0) then
            NextStepNo -= 1;

        if not IsPageSpecInstructionTag and (NextStepNo > 0) then
            AddValueToPrompt(Prompt, Value, GetNextStepNo(ParentStepNo, NextStepNo))
        else
            AddValueToPrompt(Prompt, Value, '');

        exit(true);
    end;

    [NonDebuggable]
    local procedure ProcessJTokenAsObject(var SOASetup: Record "SOA Setup"; var Prompt: Text; JObject: JsonObject; ParentStepNo: Text; var NextStep: Integer): Boolean
    var
        AttributeJToken: JsonToken;
        Name: Text;
        IncludeStepNo: Boolean;
    begin
        if JObject.Get(JobjectNameLbl, AttributeJToken) then
            Name := AttributeJToken.AsValue().AsText();

        if not CheckShouldBeIncluded(SOASetup, Name) then
            exit(false);

        if JObject.Get(JobjectValueLbl, AttributeJToken) then
            ProcessJTokenAsValue(Prompt, AttributeJToken, ParentStepNo, NextStep);

        if JObject.Get(JobjectStepsIncludeNumberingLbl, AttributeJToken) then
            IncludeStepNo := AttributeJToken.AsValue().AsBoolean();

        if JObject.Get(JobjectStepsLbl, AttributeJToken) then
            ProcessJTokenAsArray(SOASetup, Prompt, AttributeJToken.AsArray(), GetNextStepNo(ParentStepNo, NextStep), IncludeStepNo);
        exit(true);
    end;

    [NonDebuggable]
    local procedure ProcessJTokenAsArray(var SOASetup: Record "SOA Setup"; var Prompt: Text; JArray: JsonArray; ParentStepNo: Text; AddNumbering: Boolean): Boolean
    var
        JToken: JsonToken;
        NextStep: Integer;
    begin
        if AddNumbering then
            NextStep := 1;
        foreach JToken in JArray do
            if ProcessJToken(SOASetup, Prompt, JToken, ParentStepNo, NextStep, AddNumbering) then
                if AddNumbering then
                    NextStep += 1;
        exit(true);
    end;

    local procedure GetNextStepNo(ParentStepNo: Text; StepNo: Integer): Text
    begin
        if StepNo = 0 then
            exit('');

        if ParentStepNo <> '' then
            exit(ParentStepNo + StepDelimiterLbl + Format(StepNo));

        exit(Format(StepNo));
    end;

    [NonDebuggable]
    local procedure AddValueToPrompt(var Prompt: Text; Value: Text; StepNo: Text)
    var
        PrefixToAdd: Text;
        NewLineChar: Char;
    begin
        NewLineChar := 10;

        if StepNo <> '' then begin
            PrefixToAdd := StepNo + StepSuffixLbl;
            AddSpaceInFront(PrefixToAdd);
        end;

        Prompt += PrefixToAdd + Value + NewLineChar;
    end;

    local procedure AddSpaceInFront(var PrefixToAdd: Text)
    var
        DelimiterCount: Integer;
        i: Integer;
    begin
        if PrefixToAdd = '' then
            exit;
        DelimiterCount := StrLen(PrefixToAdd) - StrLen(PrefixToAdd.Replace(StepDelimiterLbl, ''));
        if DelimiterCount < 2 then
            exit;
        for i := 1 to DelimiterCount - 1 do
            PrefixToAdd := ' ' + PrefixToAdd;
    end;

    local procedure CheckShouldBeIncluded(var SOASetup: Record "SOA Setup"; ValueName: Text): Boolean
    begin
        case ValueName of
            SendSalesQuoteLbl:
                exit(SOASetup."Send Sales Quote");
            DoNotSendSalesQuoteLbl:
                exit(not SOASetup."Send Sales Quote");
            CrateSalesOrderLbl:
                exit(SOASetup."Create Order from Quote" or not SOASetup."Sales Doc. Configuration");
            NoSalesOrderLbl:
                exit(not SOASetup."Create Order from Quote" and SOASetup."Sales Doc. Configuration");
            ReviewQuoteBeforeSendLbl:
                exit(SOASetup."Quote Review" and SOASetup."Sales Doc. Configuration");
            ReviewOrderBeforeSendLbl:
                exit(SOASetup."Order Review" and SOASetup."Sales Doc. Configuration");
            ItemAvailabilityLbl:
                exit(SOASetup."Search Only Available Items");
            CapableToPromiseLbl:
                exit(SOASetup."Incl. Capable to Promise");
            CustomSignatureOffLbl:
                exit(not SOASetup."Configure Email Template");
            CustomSignatureOnLbl:
                exit(SOASetup."Configure Email Template");
            else
                exit(true);
        end;
    end;

    [NonDebuggable]
    local procedure BuildSignature(var InstructionsSecretValue: SecretText; var SOASetup: Record "SOA Setup")
    var
        SOASetupCU: Codeunit "SOA Setup";
        InstructionsText: Text;
    begin
        if SOASetup."Configure Email Template" then
            exit;

        InstructionsText := InstructionsSecretValue.Unwrap();
        InstructionsText := StrSubstNo(InstructionsText, SOASetupCU.GetDefaultEmailSignatureAsTxt());
        InstructionsSecretValue := InstructionsText;
    end;

    var
        CrateSalesOrderLbl: Label 'create_sales_order', Locked = true;
        SendSalesQuoteLbl: Label 'send_sales_quote', Locked = true;
        DoNotSendSalesQuoteLbl: Label 'do_not_send_sales_quote', Locked = true;
        NoSalesOrderLbl: Label 'no_sales_order', Locked = true;
        ReviewQuoteBeforeSendLbl: Label 'review_quote_before_send', Locked = true;
        ReviewOrderBeforeSendLbl: Label 'review_order_before_send', Locked = true;
        ItemAvailabilityLbl: Label 'item_availability', Locked = true;
        CapableToPromiseLbl: Label 'capable_to_promise', Locked = true;
        CustomSignatureOffLbl: Label 'custom_signature_off', Locked = true;
        CustomSignatureOnLbl: Label 'custom_signature_on', Locked = true;
        JobjectStepsIncludeNumberingLbl: Label 'steps_include_numbering', Locked = true;
        JobjectNameLbl: Label 'name', Locked = true;
        JobjectValueLbl: Label 'value', Locked = true;
        JobjectStepsLbl: Label 'steps', Locked = true;
        JTokenPromptLbl: Label 'prompt', Locked = true;
        JTokenOrderLbl: Label 'order', Locked = true;
        PageSpecInstructionTagStartLbl: Label '{%', Locked = true;
        PageSpecInstructionTagEndLbl: Label '%}', Locked = true;
        StepDelimiterLbl: Label '.', Locked = true;
        StepSuffixLbl: Label '. ', Locked = true;
}
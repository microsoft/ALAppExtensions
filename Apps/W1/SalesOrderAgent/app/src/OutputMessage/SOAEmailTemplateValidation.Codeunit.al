// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

using System.AI;

codeunit 4407 "SOA Email Template Validation" implements "AOAI Function"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [NonDebuggable]
    procedure GetPrompt(): JsonObject
    var
        SOAInstructions: Codeunit "SOA Instructions";
        PromptJson: JsonObject;
    begin
        PromptJson.ReadFrom(SOAInstructions.GetMailTemplateCheckTool().Unwrap());
        exit(PromptJson);
    end;

    procedure Execute(Arguments: JsonObject): Variant
    begin
        Reason := '';
        if Arguments.Contains('is_valid') then
            IsValid := Arguments.GetBoolean('is_valid');

        if Arguments.Contains('is_harmful') then
            IsHarmful := Arguments.GetBoolean('is_harmful');

        if Arguments.Contains('invalid_reason') then
            Reason := Arguments.GetText('invalid_reason');

        exit(IsValid);
    end;

    procedure GetName(): Text
    begin
        exit('EmailSignature_Validation');
    end;

    internal procedure GetIsHarmful(): Boolean
    begin
        exit(IsHarmful);
    end;

    internal procedure GetInvalidReason(): Text
    begin
        exit(Reason);
    end;

    var
        IsValid: Boolean;
        IsHarmful: Boolean;
        Reason: Text;
}
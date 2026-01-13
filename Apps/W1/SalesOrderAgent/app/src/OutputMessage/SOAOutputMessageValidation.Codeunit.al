// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

using System.AI;

codeunit 4403 "SOA Output Message Validation" implements "AOAI Function"
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
        PromptJson.ReadFrom(SOAInstructions.GetOutputMessageSignatureUpdateTool().Unwrap());
        exit(PromptJson);
    end;

    procedure Execute(Arguments: JsonObject): Variant
    var
        NewMailBodyStructure: Text;
    begin
        if Arguments.Contains('mail_body_with_signature') then
            NewMailBodyStructure := Arguments.GetText('mail_body_with_signature');
        exit(NewMailBodyStructure);
    end;

    procedure GetName(): Text
    begin
        exit('EmailSignature_Append');
    end;
}
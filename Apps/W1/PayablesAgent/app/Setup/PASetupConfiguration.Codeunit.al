// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument;
using System.Agents;
using System.Email;

/// <summary>
/// To be used as a state variable with the all the related records used to configure the agent.
/// </summary>
codeunit 3304 "PA Setup Configuration"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        TempAgentSetupBuffer: Record "Agent Setup Buffer";
        TempPayablesAgentSetup: Record "Payables Agent Setup" temporary;
        TempEDocumentService: Record "E-Document Service" temporary;
        TempEmailAccount: Record "Email Account" temporary;
        SkipAgentConfiguration: Boolean;
        SkipEmailVerification: Boolean;

    internal procedure GetSkipAgentConfiguration(): Boolean
    begin
        exit(SkipAgentConfiguration);
    end;

    internal procedure SetSkipAgentConfiguration(LocalSkipAgentConfiguration: Boolean)
    begin
        SkipAgentConfiguration := LocalSkipAgentConfiguration;
    end;

    internal procedure GetSkipEmailVerification(): Boolean
    begin
        exit(SkipEmailVerification);
    end;

    internal procedure SetSkipEmailVerification(LocalSkipEmailVerification: Boolean)
    begin
        SkipEmailVerification := LocalSkipEmailVerification;
    end;

    procedure GetPayablesAgentSetup(): Record "Payables Agent Setup"
    begin
        exit(TempPayablesAgentSetup);
    end;

    procedure SetPayablesAgentSetup(PayablesAgentSetup: Record "Payables Agent Setup")
    begin
        TempPayablesAgentSetup.Copy(PayablesAgentSetup);
    end;

    procedure GetEDocumentService(): Record "E-Document Service"
    begin
        exit(TempEDocumentService);
    end;

    procedure SetEDocumentService(EDocumentService: Record "E-Document Service")
    begin
        TempEDocumentService.Copy(EDocumentService);
    end;

    procedure GetEmailAccount(): Record "Email Account"
    begin
        exit(TempEmailAccount);
    end;

    procedure SetEmailAccount(EmailAccount: Record "Email Account")
    begin
        TempEmailAccount.Copy(EmailAccount);
    end;

    procedure GetAgentSetupBuffer(): Record "Agent Setup Buffer"
    begin
        exit(TempAgentSetupBuffer);
    end;

    procedure GetAgentSetupBuffer(var TargetAgentSetupBuffer: Record "Agent Setup Buffer")
    var
        AgentSetup: Codeunit "Agent Setup";
    begin
        AgentSetup.CopySetupRecord(TargetAgentSetupBuffer, TempAgentSetupBuffer);
    end;

    procedure SetAgentSetupBuffer(var SourceAgentSetupBuffer: Record "Agent Setup Buffer")
    var
        AgentSetup: Codeunit "Agent Setup";
    begin
        AgentSetup.CopySetupRecord(TempAgentSetupBuffer, SourceAgentSetupBuffer);
    end;

}
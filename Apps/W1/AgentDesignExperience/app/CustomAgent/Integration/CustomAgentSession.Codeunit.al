// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Environment.Configuration;

codeunit 4360 "Custom Agent Session"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    SingleInstance = true;
    Permissions = tabledata "Custom Agent Setup" = r;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", OnAfterLogin, '', false, false)]
    local procedure OnAfterCustomAgentLogin()
    var
        CustomAgentSetup: Record "Custom Agent Setup";
        CustomAgentInstructionsLog: Codeunit "Custom Agent Instructions";
    begin
        if not IsCustomAgentSession() then
            exit;

        if not CustomAgentSetup.Get(UserSecurityId()) then
            exit;

        CustomAgentInstructionsLog.MarkCurrentInstructionsAsReadOnly(CustomAgentSetup);
    end;

    local procedure IsCustomAgentSession(): Boolean
    var
        AgentSession: Codeunit "Agent Session";
        AgentMetadataProvider: Enum "Agent Metadata Provider";
    begin
        if not AgentSession.IsAgentSession(AgentMetadataProvider) then
            exit(false);

        if AgentMetadataProvider <> Enum::"Agent Metadata Provider"::"Custom Agent" then
            exit(false);

        exit(true);
    end;
}
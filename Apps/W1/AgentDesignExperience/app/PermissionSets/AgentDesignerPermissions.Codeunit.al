// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

using System.Agents;

codeunit 4362 "Agent Designer Permissions"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure VerifyCurrentUserCanImportCustomAgents()
    begin
        if AgentSystemPermissions.CurrentUserHasCanManageAllAgentsPermission() then
            exit;

        Error(OnlyAgentAdminCanImportAgentsErr);
    end;

    procedure VerifyCurrentUserCanExportCustomAgents()
    begin
        if CurrentUserCanExportCustomAgents() then
            exit;

        Error(OnlyAgentAdminCanExportAgentsErr);
    end;

    procedure VerifyCurrentUserCanCreateCustomAgents()
    begin
        if CurrentUserCanCreateCustomAgents() then
            exit;

        Error(OnlyAgentAdminCanCreateAgentsErr);
    end;

    procedure VerifyCurrentUserCanDeleteCustomAgents()
    begin
        if CurrentUserCanDeleteCustomAgents() then
            exit;

        Error(OnlyAgentAdminCanDeleteAgentsErr);
    end;

    procedure VerifyCurrentUserCanConfigureCustomAgent(AgentUserSecurityId: Guid)
    begin
        if CurrentUserCanConfigureCustomAgent(AgentUserSecurityId) then
            exit;

        Error(OnlyUserWithConfigurationRightsCanManageCustomAgentErr);
    end;

    procedure CurrentUserCanConfigureCustomAgent(AgentUserSecurityId: Guid): Boolean
    var
        Agent: Record Agent;
    begin
        if CurrentUserCanCreateCustomAgents() then
            exit(true);

        if Agent.Get(AgentUserSecurityId) then
            if Agent."Can Curr. User Configure Agent" then
                exit(true);

        exit(false);
    end;

    procedure CurrentUserCanCreateCustomAgents(): Boolean
    begin
        if AgentSystemPermissions.CurrentUserHasCanManageAllAgentsPermission() then
            exit(true);

        if AgentSystemPermissions.CurrentUserHasCanCreateCustomAgent() then
            exit(true);

        exit(false);
    end;

    procedure CurrentUserCanDeleteCustomAgents(): Boolean
    begin
        if AgentSystemPermissions.CurrentUserHasCanManageAllAgentsPermission() then
            exit(true);

        exit(false);
    end;

    procedure CurrentUserCanExportCustomAgents(): Boolean
    begin
        if AgentSystemPermissions.CurrentUserHasCanManageAllAgentsPermission() then
            exit(true);

        exit(false);
    end;

    procedure VerifyCurrentUserCanManageTemplates()
    begin
        if AgentSystemPermissions.CurrentUserHasCanManageAllAgentsPermission() then
            exit;

        Error(OnlyAgentAdminCanManageAgentTemplatesErr);
    end;

    var
        AgentSystemPermissions: Codeunit "Agent System Permissions";
        OnlyAgentAdminCanCreateAgentsErr: Label 'Only users with the AGENT - ADMIN permission set can create agents.';
        OnlyAgentAdminCanDeleteAgentsErr: Label 'Only users with the AGENT - ADMIN permission set can delete agents.';
        OnlyAgentAdminCanExportAgentsErr: Label 'Only users with the AGENT - ADMIN permission set can export agents.';
        OnlyAgentAdminCanImportAgentsErr: Label 'Only users with the AGENT - ADMIN permission set can import agents.';
        OnlyAgentAdminCanManageAgentTemplatesErr: Label 'Only users with the AGENT - ADMIN permission set can manage agent task templates.';
        OnlyUserWithConfigurationRightsCanManageCustomAgentErr: Label 'Only users with AGENT - ADMIN permission set or with Configure Agent Access Control can modify this custom agent.';
}
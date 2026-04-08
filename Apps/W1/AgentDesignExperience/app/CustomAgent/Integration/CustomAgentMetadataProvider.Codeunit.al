// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Agents.Designer;
using System.AI;
using System.Reflection;
using System.Security.AccessControl;

codeunit 4358 "Custom Agent Metadata Provider" implements IAgentMetadata, IAgentFactory
{
    InherentEntitlements = X;
    InherentPermissions = X;

    Access = Internal;

    procedure GetDefaultInitials(): Text[4]
    begin
        exit(CustomAgentInitialLbl);
    end;

    procedure GetInitials(AgentUserId: Guid): Text[4]
    var
        CustomAgentSetupRecord: Record "Custom Agent Setup";
    begin
        if IsNullGuid(AgentUserId) then
            exit(CustomAgentSetup.GetDefaultInitials());

        if not CustomAgentSetupRecord.Get(AgentUserId) then
            exit(CustomAgentSetup.GetDefaultInitials());

        if CustomAgentSetupRecord."Initials" = '' then
            exit(CustomAgentSetup.GetDefaultInitials());

        exit(CustomAgentSetupRecord."Initials");
    end;

    procedure GetFirstTimeSetupPageId(): Integer
    begin
        exit(Page::"Custom Agents Wizard");
    end;

    procedure GetSetupPageId(AgentUserId: Guid): Integer
    begin
        exit(Page::"Custom Agent Setup");
    end;

    procedure GetSummaryPageId(AgentUserId: Guid): Integer
    begin
        exit(0);
    end;

    procedure ShowCanCreateAgent(): Boolean
    var
        AgentDesignerPermissions: Codeunit "Agent Designer Permissions";
    begin
        exit(AgentDesignerPermissions.CurrentUserCanCreateCustomAgents());
    end;

    procedure GetCopilotCapability(): Enum "Copilot Capability"
    begin
        exit("Copilot Capability"::"Custom Agent");
    end;

    procedure GetAgentAnnotations(AgentUserId: Guid; var Annotations: Record "Agent Annotation")
    begin
        Clear(Annotations);
    end;

    procedure GetAgentTaskMessagePageId(AgentUserId: Guid; MessageId: Guid): Integer
    begin
        exit(Page::"Agent Task Message Card");
    end;

    procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    begin
        CustomAgentSetup.GetDefaultProfile(TempAllProfile);
    end;

    procedure GetDefaultAccessControls(var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    begin
        // Not providing any default access controls, they must be set by users.
    end;

    var
        CustomAgentSetup: Codeunit "Custom Agent Setup";
        CustomAgentInitialLbl: Label 'A', MaxLength = 4;
}
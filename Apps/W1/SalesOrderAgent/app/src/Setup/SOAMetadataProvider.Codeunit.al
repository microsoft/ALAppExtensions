// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.AI;
using System.Reflection;
using System.Security.AccessControl;

codeunit 4401 "SOA Metadata Provider" implements IAgentMetadata, IAgentFactory
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetDefaultInitials(): Text[4]
    begin
        exit(SOASetupCU.GetInitials());
    end;

    procedure GetInitials(AgentUserId: Guid): Text[4]
    begin
        exit(SOASetupCU.GetInitials());
    end;

    procedure GetFirstTimeSetupPageId(): Integer
    begin
        // The first time setup page ID is the same as the setup page ID.
        exit(Page::"SOA Setup");
    end;

    procedure GetSetupPageId(AgentUserId: Guid): Integer
    begin
        // The first time setup page ID is the same as the setup page ID.
        exit(Page::"SOA Setup");
    end;

    procedure GetSummaryPageId(AgentUserId: Guid): Integer
    begin
        exit(Page::"SOA KPI");
    end;

    procedure ShowCanCreateAgent(): Boolean
    begin
        exit(SOASetupCU.AllowCreateNewSOAgent());
    end;

    procedure GetCopilotCapability(): Enum "Copilot Capability"
    begin
        exit("Copilot Capability"::"Sales Order Agent");
    end;

    procedure GetAgentAnnotations(AgentUserId: Guid; var Annotations: Record "Agent Annotation")
    begin
        SOAAnnotation.GetAgentAnnotations(AgentUserId, Annotations);
    end;

    procedure GetAgentTaskMessagePageId(AgentUserId: Guid; MessageId: Guid): Integer
    begin
        exit(Page::"SOA Email Message");
    end;

    procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    begin
        SOASetupCU.GetDefaultProfile(TempAllProfile);
    end;

    procedure GetDefaultAccessControls(var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    begin
        SOASetupCU.GetDefaultAccessControls(TempAccessControlBuffer);
    end;

    var
        SOAAnnotation: Codeunit "SOA Annotation";
        SOASetupCU: Codeunit "SOA Setup";
}
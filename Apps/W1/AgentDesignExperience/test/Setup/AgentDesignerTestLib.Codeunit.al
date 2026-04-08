// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.Designer;

using System.Agents;
using System.Agents.Designer.CustomAgent;
using System.Environment.Configuration;
using System.Security.AccessControl;

codeunit 133751 "Agent Designer Test Lib."
{
    procedure GetOrCreateDefaultAgent(AgentRecord: Record Agent; AgentUserName: Code[50]; DisplayName: Text[80]; Initials: Text[4]; Description: Text[250]; Instructions: Text) AgentId: Guid
    var
        CustomAgentSetup: Record "Custom Agent Setup";
        TempAgentAccessControl: Record "Agent Access Control" temporary;
        TempAccessControlBuffer: Record "Access Control Buffer" temporary;
        TempUserSettings: Record "User Settings" temporary;
        Agent: Codeunit Agent;
        ModuleInfo: ModuleInfo;
    begin
        AgentRecord.SetRange("Agent Metadata Provider", AgentRecord."Agent Metadata Provider"::"Custom Agent");
        AgentRecord.SetFilter("User Name", AgentUserName);
        if AgentRecord.FindFirst() then
            exit(AgentRecord."User Security ID");

        AgentId := Agent.Create("Agent Metadata Provider"::"Custom Agent", AgentUserName, DisplayName, TempAgentAccessControl);
        Agent.UpdateAccess(AgentId, TempAgentAccessControl);

        NavApp.GetCurrentModuleInfo(ModuleInfo);
#pragma warning disable AA0139
        TempAccessControlBuffer."Company Name" := CompanyName();
#pragma warning restore AA0139
        TempAccessControlBuffer."Role ID" := 'Test Permission Set';
        TempAccessControlBuffer."App ID" := ModuleInfo.Id;
        TempAccessControlBuffer.Scope := TempAccessControlBuffer.Scope::System;
        TempAccessControlBuffer.Insert();
        Agent.AssignPermissionSet(AgentId, TempAccessControlBuffer);

        SetTestProfile(AgentId, 'Test Profile');

        Agent.Activate(AgentId);

        CustomAgentSetup.Initials := Initials;
        CustomAgentSetup.Description := Description;
        CustomAgentSetup."User Security ID" := AgentId;
        CustomAgentSetup.Insert();
        CustomAgentSetup.SetInstructions(Instructions);

        TempUserSettings."User Security ID" := AgentId;
        TempUserSettings."Locale ID" := 1033; // English - United States
        TempUserSettings."Language ID" := 1036; // French - France
        TempUserSettings."Time Zone" := 'Central Europe Standard Time';
        TempUserSettings.Insert();

        Agent.UpdateLocalizationSettings(AgentId, TempUserSettings);

        exit(AgentId);
    end;

    procedure GetSingleAgentStream(var InStream: InStream)
    begin
        NavApp.GetResource('Agents/SINGLE AGENT.xml', InStream, CustomAgentExport.GetEncoding());
    end;

    procedure GetSingleAgentStream_DifferentCasing(var InStream: InStream)
    begin
        NavApp.GetResource('Agents/SINGLE AGENT - Lower case.xml', InStream, CustomAgentExport.GetEncoding());
    end;

    procedure GetOtherSingleAgentStream(var InStream: InStream)
    begin
        NavApp.GetResource('Agents/SINGLE AGENT - Other.xml', InStream, CustomAgentExport.GetEncoding());
    end;

    procedure GetNoAgentStream(var InStream: InStream)
    begin
        NavApp.GetResource('Agents/NO AGENT.xml', InStream, CustomAgentExport.GetEncoding());
    end;

    procedure GetMultipleAgentsStream(var InStream: InStream)
    begin
        NavApp.GetResource('Agents/MULTIPLE AGENTS.xml', InStream, CustomAgentExport.GetEncoding());
    end;

    procedure GetAgentNoUserSettingsStream(var InStream: InStream)
    begin
        NavApp.GetResource('Agents/SINGLE AGENT - NO USER SETTINGS.xml', InStream, CustomAgentExport.GetEncoding());
    end;

    procedure GetAgentNoProfileStream(var InStream: InStream)
    begin
        NavApp.GetResource('Agents/SINGLE AGENT - NO PROFILE.xml', InStream, CustomAgentExport.GetEncoding());
    end;

    procedure GetAgentNoPermissionSetStream(var InStream: InStream)
    begin
        NavApp.GetResource('Agents/SINGLE AGENT - NO PERMISSION SET.xml', InStream, CustomAgentExport.GetEncoding());
    end;

    procedure GetAgentMissingProfileStream(var InStream: InStream)
    begin
        NavApp.GetResource('Agents/SINGLE AGENT - MISSING PROFILE.xml', InStream, CustomAgentExport.GetEncoding());
    end;

    procedure GetAgentMissingPermissionSetStream(var InStream: InStream)
    begin
        NavApp.GetResource('Agents/SINGLE AGENT - MISSING PERMISSION SET.xml', InStream, CustomAgentExport.GetEncoding());
    end;

    procedure GetAgentOtherPermissionsStream(var InStream: InStream)
    begin
        NavApp.GetResource('Agents/SINGLE AGENT - Other Permissions.xml', InStream, CustomAgentExport.GetEncoding());
    end;

    procedure GetAgentOtherInstructionsStream(var InStream: InStream)
    begin
        NavApp.GetResource('Agents/SINGLE AGENT - Other Instructions.xml', InStream, CustomAgentExport.GetEncoding());
    end;

    local procedure SetTestProfile(AgentId: Guid; ProfileId: Text[30])
    var
        ModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        SetProfile(AgentId, ModuleInfo.Id, ProfileId);
    end;

    local procedure SetProfile(AgentId: Guid; ProfileAppId: Guid; ProfileId: Text[30])
    var
        Profile: Record System.Reflection."All Profile";
        Agent: Codeunit Agent;
    begin
        Profile.Get(Profile.Scope::Tenant, ProfileAppId, ProfileId);
        Agent.SetProfile(AgentId, Profile);
    end;

    var
        CustomAgentExport: Codeunit "Custom Agent Export";
}
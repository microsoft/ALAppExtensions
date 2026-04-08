// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Agents.Designer;
using System.AI;
using System.Environment;
using System.Reflection;
using System.Security.AccessControl;

codeunit 4350 "Custom Agent Setup"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetDefaultInitials(): Text[4]
    var
        CustomAgentMetadataProvider: Codeunit "Custom Agent Metadata Provider";
    begin
        exit(CustomAgentMetadataProvider.GetDefaultInitials());
    end;

    procedure GetAgentType(): Text
    begin
        exit(Format(Enum::"Agent Metadata Provider"::"Custom Agent"));
    end;

    procedure GetAccessControl(AgentUserSecurityID: Guid; var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    var
        AccessControl: Record "Access Control";
    begin
        if IsNullGuid(AgentUserSecurityID) then
            exit;

        TempAccessControlBuffer.Reset();
        TempAccessControlBuffer.DeleteAll();

        AccessControl.SetRange("User Security ID", AgentUserSecurityID);
        if AccessControl.IsEmpty() then
            exit;

        AccessControl.FindSet();
        repeat
            TempAccessControlBuffer."Company Name" := AccessControl."Company Name";
            TempAccessControlBuffer.Scope := AccessControl.Scope;
            TempAccessControlBuffer."App ID" := AccessControl."App ID";
            TempAccessControlBuffer."Role ID" := AccessControl."Role ID";
            TempAccessControlBuffer.Insert();
        until AccessControl.Next() = 0;
    end;

    procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    var
        Agent: Codeunit Agent;
    begin
        Agent.PopulateDefaultProfile(DefaultProfileTok, SystemApplicationAppIdLbl, TempAllProfile);
    end;

    procedure UpdateAgent(var AgentSetupBuffer: Record "Agent Setup Buffer"; var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    var
        AgentSetup: Codeunit "Agent Setup";
    begin
        AgentSetup.SaveChanges(AgentSetupBuffer);
        UpdateAccessControl(AgentSetupBuffer."User Security ID", TempAccessControlBuffer);
    end;

    procedure UpdateAccessControl(AgentUserSecurityId: Guid; var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    var
        AgentUtilities: Codeunit "Agent Utilities";
    begin
        AgentUtilities.UpdateAccessControl(AgentUserSecurityId, TempAccessControlBuffer);
    end;

    procedure CreateAgent(var TempAgent: Record Agent; var TempAgentAccessControl: Record "Agent Access Control" temporary; var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    var
        Agent: Codeunit Agent;
        AgentDesignerPermissions: Codeunit "Agent Designer Permissions";
        AgentUserSecurityID: Guid;
    begin
        AgentDesignerPermissions.VerifyCurrentUserCanCreateCustomAgents();

        AgentUserSecurityID := CreateAgent(TempAgent."User Name", TempAgent."Display Name", TempAgentAccessControl, TempAccessControlBuffer, '');
        TempAgent."User Security ID" := AgentUserSecurityID;
        if TempAgent.State = TempAgent.State::Enabled then
            Agent.Activate(AgentUserSecurityID)
        else
            Agent.Deactivate(AgentUserSecurityID);
    end;

    procedure CreateAgent(AgentUserName: Code[50]; AgentDisplayName: Text[80];
        var TempAgentAccessControl: Record "Agent Access Control" temporary; var TempAccessControlBuffer: Record "Access Control Buffer" temporary;
        Initials: Text[4]): Guid
    begin
        exit(CreateAgent(AgentUserName, AgentDisplayName, TempAgentAccessControl, TempAccessControlBuffer, Initials, GetDefaultDescription(), GetDefaultInstructions()));
    end;

    procedure CreateAgent(AgentUserName: Code[50]; AgentDisplayName: Text[80];
        var TempAgentAccessControl: Record "Agent Access Control" temporary; var TempAccessControlBuffer: Record "Access Control Buffer" temporary;
        Initials: Text[4]; Description: Text[250]; Instructions: Text): Guid
    var
        Agent: Codeunit Agent;
        AgentDesignerPermissions: Codeunit "Agent Designer Permissions";
        AgentUserSecurityID: Guid;
    begin
        AgentDesignerPermissions.VerifyCurrentUserCanCreateCustomAgents();

        AgentUserSecurityID := Agent.Create("Agent Metadata Provider"::"Custom Agent", AgentUserName, AgentDisplayName, TempAgentAccessControl);
        UpdateAccessControl(AgentUserSecurityID, TempAccessControlBuffer);

        Agent.SetInstructions(AgentUserSecurityID, Instructions);

        if Initials = '' then
            Initials := GetDefaultInitials();

        CreateCustomAgentSetup(AgentUserSecurityID, Initials, Description, Instructions);
        exit(AgentUserSecurityID);
    end;

    procedure CreateCustomAgentSetup(AgentUserSecurityID: Guid; Initials: Text[4]; Description: Text[250]; Instructions: Text)
    var
        CustomAgentSetup: Record "Custom Agent Setup";
    begin
        CustomAgentSetup.Initials := Initials;
        CustomAgentSetup.Description := Description;
        CustomAgentSetup."User Security ID" := AgentUserSecurityID;
        CustomAgentSetup.Insert();
        CustomAgentSetup.SetInstructions(Instructions);
    end;

    procedure OpenEditInstructionsPage(AgentSecurityId: Guid)
    var
        AgentEditInstructionsPage: Page "Agent Instruction Editor";
    begin
        AgentEditInstructionsPage.SetUserSecurityId(AgentSecurityId);
        AgentEditInstructionsPage.Run();
    end;

    procedure GenerateInitialsFromName(AgentName: Text[50]) Initials: Code[4]
    var
        Words: List of [Text];
        Word: Text;
        i: Integer;
    begin
        if AgentName = '' then
            exit('');

        // Split the name into words by spaces, and take first letters
        Words := AgentName.Split(' ');
        for i := 1 to Words.Count do begin
            if i > MaxStrLen(Initials) then
                break;

            Word := Words.Get(i).Trim();
            if Word <> '' then
                Initials += Word.ToUpper() [1];
        end;

        // If we have no initials or only one character, fall back to first characters
        if StrLen(Initials) <= 1 then
            Initials := CopyStr(AgentName.ToUpper(), 1, MaxStrLen(Initials));

        exit(Initials);
    end;

    procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        EnvironmentInformation: Codeunit "Environment Information";
        LearnMoreUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2344702', Locked = true;
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit;

        if CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Custom Agent") then
            exit;

        CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Custom Agent", Enum::"Copilot Availability"::"Preview", Enum::"Copilot Billing Type"::"Microsoft Billed", LearnMoreUrlTxt);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Copilot AI Capabilities", OnRegisterCopilotCapability, '', false, false)]
    local procedure OnRegisterCopilotCapability()
    begin
        RegisterCapability();
    end;

    local procedure GetDefaultInstructions(): Text
    begin
        exit(DefaultAgentInstructionsLbl);
    end;

    local procedure GetDefaultDescription(): Text[250]
    begin
        exit(DefaultAgentDescriptionLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::Agent, OnAfterDeleteEvent, '', true, true)]
    local procedure CleanupCustomAgentSetup(var Rec: Record Agent; RunTrigger: Boolean)
    var
        CustomAgentSetup: Record "Custom Agent Setup";
        CustomAgentInstructionsLog: Record "Custom Agent Instructions Log";
    begin
        if not RunTrigger then
            exit;

        if CustomAgentSetup.Get(Rec."User Security ID") then
            CustomAgentSetup.Delete();

        CustomAgentInstructionsLog.SetRange("User Security ID", Rec."User Security ID");
        CustomAgentInstructionsLog.DeleteAll(true);
    end;

    var
        DefaultProfileTok: Label 'BLANK', Locked = true;
        SystemApplicationAppIdLbl: Label '63ca2fa4-4f03-4f2b-a480-172fef340d3f', Locked = true;
        DefaultAgentInstructionsLbl: Label '', Locked = true;
        DefaultAgentDescriptionLbl: Label '', Locked = true;
}
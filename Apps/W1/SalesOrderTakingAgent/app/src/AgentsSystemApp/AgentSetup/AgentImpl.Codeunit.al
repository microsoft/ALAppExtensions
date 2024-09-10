// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

using System.Environment.Configuration;
using System.Reflection;
using System.Environment;
using System.Security.AccessControl;

codeunit 4301 "Agent Impl."
{
    Access = Internal;
    Permissions = tabledata "All Profile" = r,
                  tabledata Company = r,
                  tabledata "Agent Access Control" = d,
                  tabledata "Application User Settings" = rim,
                  tabledata User = r,
                  tabledata "User Personalization" = rim;

    internal procedure CreateAgent(AgentMetadataProvider: Enum "Agent Metadata Provider"; AgentUserName: Code[50]; AgentUserDisplayName: Text[80]; var TempAgentAccessControl: Record "Agent Access Control" temporary; Instructions: Text): Guid
    var
        Agent: Record Agent;
    begin
        Agent."Agent Metadata Provider" := AgentMetadataProvider;
        Agent."User Name" := AgentUserName;
        Agent."Display Name" := AgentUserDisplayName;
        Agent.Insert(true);

        if TempAgentAccessControl.IsEmpty() then
            GetUserAccess(Agent, TempAgentAccessControl, true);

        UpdateAgentAccessControl(TempAgentAccessControl, Agent, true);
        SetInstructions(Agent, Instructions);
        AssignCompany(Agent."User Security ID", CompanyName());
        exit(Agent."User Security ID");
    end;

    internal procedure Activate(UserSecurityID: Guid)
    begin
        ChangeAgentState(UserSecurityID, true);
    end;

    internal procedure Deactivate(UserSecurityID: Guid)
    begin
        ChangeAgentState(UserSecurityID, false);
    end;

    internal procedure SetInstructions(var Agent: Record Agent; Instructions: Text)
    var
        InstructionsOutStream: OutStream;
    begin
        Clear(Agent.Instructions);
        Agent.Instructions.CreateOutStream(InstructionsOutStream, GetDefaultEncoding());
        InstructionsOutStream.Write(Instructions);
        Agent.Modify(true);
    end;

    internal procedure GetInstructions(var Agent: Record Agent): Text
    var
        InstructionsInStream: InStream;
        InstructionsText: Text;
    begin
        if IsNullGuid(Agent."User Security ID") then
            exit;

        Agent.CalcFields(Instructions);
        if not Agent.Instructions.HasValue() then
            exit('');

        Agent.Instructions.CreateInStream(InstructionsInStream, GetDefaultEncoding());
        InstructionsInStream.Read(InstructionsText);
        exit(InstructionsText);
    end;

    internal procedure InsertCurrentOwnerIfNoOwnersDefined(var Agent: Record Agent; var AgentAccessControl: Record "Agent Access Control")
    begin
        SetOwnerFilters(AgentAccessControl);
        AgentAccessControl.SetRange("Agent User Security ID", Agent."User Security ID");
        if not AgentAccessControl.IsEmpty() then
            exit;
        InsertCurrentOwner(Agent."User Security ID", AgentAccessControl);
    end;

    internal procedure InsertCurrentOwner(AgentUserSecurityID: Guid; var AgentAccessControl: Record "Agent Access Control")
    begin
        AgentAccessControl.Access := AgentAccessControl.Access::UserAndOwner;
        AgentAccessControl."Agent User Security ID" := AgentUserSecurityID;
        AgentAccessControl."User Security ID" := UserSecurityId();
        AgentAccessControl.Insert();
    end;

    internal procedure VerifyOwnerExists(AgentAccessControlModified: Record "Agent Access Control")
    var
        ExistingAgentAccessControl: Record "Agent Access Control";
    begin
        if (AgentAccessControlModified.Access = ExistingAgentAccessControl.Access::Owner) or (AgentAccessControlModified.Access = ExistingAgentAccessControl.Access::UserAndOwner) then
            exit;

        SetOwnerFilters(ExistingAgentAccessControl);
        ExistingAgentAccessControl.SetFilter("User Security ID", '<>%1', AgentAccessControlModified."User Security ID");
        ExistingAgentAccessControl.SetRange("Agent User Security ID", AgentAccessControlModified."Agent User Security ID");

        if ExistingAgentAccessControl.IsEmpty() then
            Error(OneOwnerMustBeDefinedForAgentErr);
    end;

    internal procedure GetUserAccess(UserSecurityID: Guid; var TempAgentAccessControl: Record "Agent Access Control" temporary)
    var
        Agent: Record Agent;
    begin
        GetAgent(Agent, UserSecurityId);

        GetUserAccess(Agent, TempAgentAccessControl, false);
    end;

    local procedure GetUserAccess(var Agent: Record Agent; var TempAgentAccessControl: Record "Agent Access Control" temporary; InsertCurrentUserAsOwner: Boolean)
    var
        AgentAccessControl: Record "Agent Access Control";
    begin
        TempAgentAccessControl.Reset();
        TempAgentAccessControl.DeleteAll();

        AgentAccessControl.SetRange("Agent User Security ID", Agent."User Security ID");
        if AgentAccessControl.IsEmpty() then begin
            if not InsertCurrentUserAsOwner then
                exit;

            InsertCurrentOwnerIfNoOwnersDefined(Agent, TempAgentAccessControl);
            exit;
        end;

        AgentAccessControl.FindSet();
        repeat
            TempAgentAccessControl.Copy(AgentAccessControl);
            TempAgentAccessControl.Insert();
        until AgentAccessControl.Next() = 0;
    end;

    internal procedure SetProfile(UserSecurityID: Guid; var AllProfile: Record "All Profile")
    var
        Agent: Record Agent;
        UserSettingsRecord: Record "User Settings";
        UserSettings: Codeunit "User Settings";
    begin
        GetAgent(Agent, UserSecurityId);

        UserSettings.GetUserSettings(Agent."User Security ID", UserSettingsRecord);
        UpdateProfile(AllProfile, UserSettingsRecord);
        UpdateAgentUserSettings(UserSettingsRecord);
    end;

    internal procedure AssignCompany(UserSecurityID: Guid; CompanyName: Text)
    var
        Agent: Record Agent;
        UserSettingsRecord: Record "User Settings";
        UserSettings: Codeunit "User Settings";
    begin
        GetAgent(Agent, UserSecurityId);

        UserSettings.GetUserSettings(Agent."User Security ID", UserSettingsRecord);
#pragma warning disable AA0139
        UserSettingsRecord.Company := CompanyName();
#pragma warning restore AA0139
        UpdateAgentUserSettings(UserSettingsRecord);
    end;

    internal procedure GetUserName(UserSecurityID: Guid): Code[50]
    var
        Agent: Record Agent;
    begin
        GetAgent(Agent, UserSecurityId);

        exit(Agent."User Name");
    end;

    internal procedure GetDisplayName(UserSecurityID: Guid): Text[80]
    var
        Agent: Record Agent;
    begin
        GetAgent(Agent, UserSecurityId);

        exit(Agent."Display Name")
    end;

    internal procedure SetDisplayName(UserSecurityID: Guid; DisplayName: Text[80])
    var
        Agent: Record Agent;
    begin
        GetAgent(Agent, UserSecurityId);

        Agent."Display Name" := DisplayName;
        Agent.Modify(true);
    end;

    internal procedure IsActive(UserSecurityID: Guid): Boolean
    var
        Agent: Record Agent;
    begin
        GetAgent(Agent, UserSecurityId);

        exit(Agent.State = Agent.State::Enabled);
    end;

    internal procedure UpdateAgentAccessControl(AgentUserSecurityID: Guid; var TempAgentAccessControl: Record "Agent Access Control" temporary; Recreate: Boolean)
    var
        Agent: Record Agent;
    begin
        if not Agent.Get(AgentUserSecurityID) then
            Error(AgentDoesNotExistErr);

        UpdateAgentAccessControl(TempAgentAccessControl, Agent, Recreate);
    end;

    # Region TODO: Update System App signatures to use the codeunit 9175 "User Settings Impl."
    internal procedure UpdateAgentUserSettings(NewUserSettings: Record "User Settings")
    var
        UserPersonalization: Record "User Personalization";
    begin
        UserPersonalization.Get(NewUserSettings."User Security ID");

        UserPersonalization."Language ID" := NewUserSettings."Language ID";
        UserPersonalization."Locale ID" := NewUserSettings."Locale ID";
        UserPersonalization.Company := NewUserSettings.Company;
        UserPersonalization."Time Zone" := NewUserSettings."Time Zone";
        UserPersonalization."Profile ID" := NewUserSettings."Profile ID";
#pragma warning disable AL0432 // All profiles are now in the tenant scope
        UserPersonalization.Scope := NewUserSettings.Scope;
#pragma warning restore AL0432
        UserPersonalization."App ID" := NewUserSettings."App ID";
        UserPersonalization.Modify();
    end;

    procedure ProfileLookup(var UserSettingsRec: Record "User Settings"): Boolean
    var
        TempAllProfile: Record "All Profile" temporary;
    begin
        PopulateProfiles(TempAllProfile);

        if TempAllProfile.Get(UserSettingsRec.Scope, UserSettingsRec."App ID", UserSettingsRec."Profile ID") then;
        if Page.RunModal(Page::Roles, TempAllProfile) = Action::LookupOK then begin
            UpdateProfile(TempAllProfile, UserSettingsRec);
            exit(true);
        end;
        exit(false);
    end;

    internal procedure UpdateProfile(var TempAllProfile: Record "All Profile" temporary; var UserSettingsRec: Record "User Settings")
    begin
        UserSettingsRec."Profile ID" := TempAllProfile."Profile ID";
        UserSettingsRec."App ID" := TempAllProfile."App ID";
        UserSettingsRec.Scope := TempAllProfile.Scope;
    end;

    procedure PopulateProfiles(var TempAllProfile: Record "All Profile" temporary)
    var
        AllProfile: Record "All Profile";
        DescriptionFilterTxt: Label 'Navigation menu only.';
        UserCreatedAppNameTxt: Label '(User-created)';
    begin
        TempAllProfile.Reset();
        TempAllProfile.DeleteAll();
        AllProfile.SetRange(Enabled, true);
        AllProfile.SetFilter(Description, '<> %1', DescriptionFilterTxt);
        if AllProfile.FindSet() then
            repeat
                TempAllProfile := AllProfile;
                if IsNullGuid(TempAllProfile."App ID") then
                    TempAllProfile."App Name" := UserCreatedAppNameTxt;
                TempAllProfile.Insert();
            until AllProfile.Next() = 0;
    end;

    procedure GetProfileName(Scope: Option System,Tenant; AppID: Guid; ProfileID: Code[30]) ProfileName: Text
    var
        AllProfile: Record "All Profile";
    begin
        // If current profile has been changed, then find it and update the description; else, get the default
        if not AllProfile.Get(Scope, AppID, ProfileID) then
            exit;

        ProfileName := AllProfile.Caption;
    end;

    internal procedure AssignPermissionSets(var UserSID: Guid; PermissionCompanyName: Text; var AggregatePermissionSet: Record "Aggregate Permission Set")
    var
        AccessControl: Record "Access Control";
    begin
        if not AggregatePermissionSet.FindSet() then
            exit;

        repeat
            AccessControl."App ID" := AggregatePermissionSet."App ID";
            AccessControl."User Security ID" := UserSID;
            AccessControl."Role ID" := AggregatePermissionSet."Role ID";
            AccessControl.Scope := AggregatePermissionSet.Scope;
#pragma warning disable AA0139
            AccessControl."Company Name" := PermissionCompanyName;
#pragma warning restore AA0139
            AccessControl.Insert();
        until AggregatePermissionSet.Next() = 0;
    end;
    #endregion

    local procedure GetAgent(var Agent: Record Agent; UserSecurityID: Guid)
    begin
        Agent.SetAutoCalcFields(Instructions);
        if not Agent.Get(UserSecurityID) then
            Error(AgentDoesNotExistErr);
    end;

    local procedure ChangeAgentState(UserSecurityID: Guid; Enabled: Boolean)
    var
        Agent: Record Agent;

    begin
        GetAgent(Agent, UserSecurityId);

        if Enabled then
            Agent.State := Agent.State::Enabled
        else
            Agent.State := Agent.State::Disabled;

        Agent.Modify();
    end;

    local procedure UpdateAgentAccessControl(var TempAgentAccessControl: Record "Agent Access Control" temporary; var Agent: Record Agent; Recreate: Boolean)
    var
        AgentAccessControl: Record "Agent Access Control";
    begin
        if Recreate then begin
            AgentAccessControl.SetRange("Agent User Security ID", Agent."User Security ID");
            if AgentAccessControl.FindSet() then
                repeat
                    AgentAccessControl.Delete(true);
                until AgentAccessControl.Next() = 0;
        end;

        TempAgentAccessControl.FindSet();
        repeat
            if AgentAccessControl.Get(Agent."User Security ID", TempAgentAccessControl."User Security ID") then
                AgentAccessControl.Delete();

            AgentAccessControl.Copy(TempAgentAccessControl);
            AgentAccessControl."Agent User Security ID" := Agent."User Security ID";
            AgentAccessControl.Insert();
        until TempAgentAccessControl.Next() = 0;
    end;

    local procedure SetOwnerFilters(var AgentAccessControl: Record "Agent Access Control")
    begin
        AgentAccessControl.SetFilter(Access, '%1|%2', AgentAccessControl.Access::Owner, AgentAccessControl.Access::UserAndOwner);
    end;

    local procedure GetDefaultEncoding(): TextEncoding
    begin
        exit(TextEncoding::UTF8);
    end;

    var
        OneOwnerMustBeDefinedForAgentErr: Label 'One owner must be defined for the agent.';
        AgentDoesNotExistErr: Label 'Agent does not exist.';

}
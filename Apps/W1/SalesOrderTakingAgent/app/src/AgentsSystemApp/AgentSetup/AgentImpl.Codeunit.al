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
                  tabledata "Application User Settings" = rim,
                  tabledata User = r,
                  tabledata "User Personalization" = rim;

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

    internal procedure InsertCurrentOwnerIfNoOwnersDefined(var Agent: Record Agent)
    var
        AgentAccessControl: Record "Agent Access Control";
    begin
        SetOwnerFilters(AgentAccessControl);
        AgentAccessControl.SetRange("Agent User Security ID", Agent."User Security ID");
        if not AgentAccessControl.IsEmpty() then
            exit;

        AgentAccessControl.Access := AgentAccessControl.Access::UserAndOwner;
        AgentAccessControl."Agent User Security ID" := Agent."User Security ID";
        AgentAccessControl."User Security ID" := UserSecurityId();
        AgentAccessControl.Insert();
    end;

    internal procedure EnsureOwnerExists(AgentAccessControlModified: Record "Agent Access Control")
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
            UserSettingsRec."Profile ID" := TempAllProfile."Profile ID";
            UserSettingsRec."App ID" := TempAllProfile."App ID";
            UserSettingsRec.Scope := TempAllProfile.Scope;
            exit(true);
        end;
        exit(false);
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
    #endregion

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

}
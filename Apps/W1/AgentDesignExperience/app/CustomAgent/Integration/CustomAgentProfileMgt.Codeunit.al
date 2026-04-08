// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Environment;
using System.Environment.Configuration;
using System.Reflection;
using System.Utilities;

codeunit 4359 "Custom Agent Profile Mgt"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure TryGetProfileConfigurationUrlForWeb(AgentUserSecurityId: Guid; var ConfigurationUrl: Text): Boolean
    var
        AllProfile: Record "All Profile";
    begin
        if not TryGetAgentProfile(AgentUserSecurityId, AllProfile) then
            exit(false);

        ConfigurationUrl := GetProfileConfigurationUrlForWeb(AllProfile);
        exit(true);
    end;

    procedure IsWebClient(): Boolean
    var
        ClientTypeManagement: Codeunit "Client Type Management";
    begin
        exit(ClientTypeManagement.GetCurrentClientType() = ClientType::Web);
    end;

    procedure IsProfileEditable(AgentUserSecurityId: Guid): Boolean
    var
        AllProfile: Record "All Profile";
    begin
        if not TryGetAgentProfile(AgentUserSecurityId, AllProfile) then
            exit(false);

        exit(not IsProfileIdAmbiguous(AllProfile));
    end;

    local procedure TryGetAgentProfile(AgentUserSecurityId: Guid; var AllProfile: Record "All Profile"): Boolean
    var
        TempUserSettings: Record "User Settings" temporary;
        Agent: Codeunit Agent;
    begin
        Agent.GetUserSettings(AgentUserSecurityId, TempUserSettings);
        exit(AllProfile.Get(TempUserSettings.Scope, TempUserSettings."App ID", TempUserSettings."Profile ID"));
    end;

    // TODO(#604090) These utilities were duplicated from the Base Application to avoid taking a dependency.
    // We should consider moving the profile module to the System Application instead.

    local procedure GetProfileConfigurationUrlForWeb(AllProfile: Record "All Profile"): Text
    var
        UriBuilder: Codeunit "Uri Builder";
        Uri: Codeunit Uri;
    begin
        UriBuilder.Init(GetUrl(ClientType::Web));

        UriBuilder.AddQueryFlag(UrlConfigureParameterTxt);
        UriBuilder.AddQueryParameter(UrlProfileParameterTxt, AllProfile."Profile ID");

        UriBuilder.GetUri(Uri);
        exit(Uri.GetAbsoluteUri());
    end;

    local procedure IsProfileIdAmbiguous(AllProfile: Record "All Profile"): Boolean
    var
        OtherAllProfile: Record "All Profile";
        EmptyGuid: Guid;
    begin
        OtherAllProfile.SetRange("Profile ID", AllProfile."Profile ID");
        OtherAllProfile.SetFilter("App ID", '<>%1', AllProfile."App ID");

        // We have ambiguity if there are two profiles with the same ID.
        // Except if one of them is user-created, in which case that one has precedence and the ambiguity is resolved.
        if (OtherAllProfile.Count() > 0) and (AllProfile."App ID" <> EmptyGuid) then
            exit(true);

        exit(false);
    end;

    var
        UrlConfigureParameterTxt: Label 'customize', Locked = true;
        UrlProfileParameterTxt: Label 'profile', Locked = true;
}
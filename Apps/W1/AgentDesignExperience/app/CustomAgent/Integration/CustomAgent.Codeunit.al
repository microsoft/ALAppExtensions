// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;

/// <summary>
/// Utility to retrieve information about custom agents.
/// </summary>
codeunit 4357 "Custom Agent"
{
    InherentPermissions = X;
    InherentEntitlements = X;

    var
        Agent: Codeunit Agent;

    /// <summary>
    /// Gets all the custom agents.
    /// </summary>
    /// <param name="TempCustomAgentInfo">The temporary record to store custom agent information.</param>
    procedure GetCustomAgents(var TempCustomAgentInfo: Record "Custom Agent Info" temporary)
    var
        CustomAgentSetup: Record "Custom Agent Setup";
    begin
        if not TempCustomAgentInfo.IsEmpty() then
            TempCustomAgentInfo.DeleteAll();

        if not CustomAgentSetup.FindSet() then
            exit;

        repeat
            Clear(TempCustomAgentInfo);
            TempCustomAgentInfo."User Security ID" := CustomAgentSetup."User Security ID";
            TempCustomAgentInfo."User Name" := Agent.GetUserName(CustomAgentSetup."User Security ID");
            TempCustomAgentInfo.Insert();
        until CustomAgentSetup.Next() = 0;
    end;

    /// <summary>
    /// Gets all the custom agents that the user can currently access.
    /// </summary>
    /// <param name="TempCustomAgentInfo">The temporary record to store custom agent information.</param>
    procedure GetUserAccessibleCustomAgents(var TempCustomAgentInfo: Record "Custom Agent Info" temporary)
    var
        AgentRec: Record Agent;
    begin
        if not TempCustomAgentInfo.IsEmpty() then
            TempCustomAgentInfo.DeleteAll();

        AgentRec.SetRange("Agent Metadata Provider", AgentRec."Agent Metadata Provider"::"Custom Agent");
        if not AgentRec.FindSet() then
            exit;

        repeat
            TempCustomAgentInfo."User Security ID" := AgentRec."User Security ID";
            TempCustomAgentInfo."User Name" := AgentRec."User Name";
            TempCustomAgentInfo.Insert();
        until AgentRec.Next() = 0;
    end;

    /// <summary>
    /// Gets a custom agent by its user security ID.
    /// </summary>
    procedure GetCustomAgentById(AgentUserId: Guid; var TempAgentInfo: Record "Custom Agent Info" temporary): Boolean
    var
        CustomAgentSetup: Record "Custom Agent Setup";
    begin
        if not CustomAgentSetup.Get(AgentUserId) then
            exit(false);

        Clear(TempAgentInfo);
        TempAgentInfo."User Security ID" := CustomAgentSetup."User Security ID";
        TempAgentInfo."User Name" := Agent.GetUserName(CustomAgentSetup."User Security ID");
        exit(true);
    end;

    /// <summary>
    /// Gets a custom agent by its user name.
    /// </summary>
    procedure GetCustomAgentByName(AgentUserName: Code[50]; var TempAgentInfo: Record "Custom Agent Info" temporary): Boolean
    var
        AgentRec: Record Agent;
    begin
        AgentRec.SetRange("User Name", AgentUserName);
        AgentRec.SetRange("Agent Metadata Provider", AgentRec."Agent Metadata Provider"::"Custom Agent");
        if not AgentRec.FindFirst() then
            exit(false);

        Clear(TempAgentInfo);
        TempAgentInfo."User Security ID" := AgentRec."User Security ID";
        TempAgentInfo."User Name" := AgentRec."User Name";
        exit(true);
    end;
}
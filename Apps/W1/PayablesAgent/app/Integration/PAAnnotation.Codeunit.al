// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using System.Agents;

codeunit 3313 "PA Annotation"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetAgentAnnotations(AgentUserId: Guid; var Annotations: Record "Agent Annotation")
    var
        Agent: Codeunit Agent;
    begin
        if not Agent.IsActive(AgentUserId) then
            exit;
        Clear(Annotations);
    end;
}
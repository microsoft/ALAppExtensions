// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;

codeunit 4309 "SOA Agent Task Execution" implements IAgentTaskExecution
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    procedure AnalyzeAgentTaskMessage(AgentTaskMessage: Record "Agent Task Message"; var Annotations: Record "Agent Annotation")
    begin
        if AgentTaskMessage.Type = AgentTaskMessage.Type::Input then
            SOAAnnotation.GetAgentTaskMessageAnnotations(AgentTaskMessage, Annotations)
        else
            SOAOutputMessageSetup.PrepareOutputMessage(AgentTaskMessage);
    end;

    procedure GetAgentTaskUserInterventionSuggestions(AgentTaskUserInterventionRequestDetails: Record "Agent User Int Request Details"; var AgentTaskUserInterventionSuggestion: Record "Agent Task User Int Suggestion")
    begin
        SOASetupCU.GetAgentTaskUserInterventionSuggestions(AgentTaskUserInterventionRequestDetails, AgentTaskUserInterventionSuggestion);
    end;

    procedure GetAgentTaskPageContext(AgentTaskPageContextRequest: Record "Agent Task Page Context Req."; var AgentTaskPageContext: Record "Agent Task Page Context")
    begin
        SOASetupCU.GetAgentTaskPageContext(AgentTaskPageContextRequest, AgentTaskPageContext);
    end;

    var
        SOAAnnotation: Codeunit "SOA Annotation";
        SOAOutputMessageSetup: Codeunit "SOA Output Message Setup";
        SOASetupCU: Codeunit "SOA Setup";
}
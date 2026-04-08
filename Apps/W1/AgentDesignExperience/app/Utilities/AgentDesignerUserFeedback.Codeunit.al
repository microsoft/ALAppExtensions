// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

using System.Agents;
using System.Feedback;

codeunit 4364 "Agent Designer User Feedback"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        AgentDesignerFeatureAreaTok: Label 'AgentDesigner', Locked = true, Comment = 'Feature area name registered in OCV.';
        AgentDesignerFeatureAreaDisplayNameTok: Label 'Agent Designer', Comment = 'Display name for the Agent Designer feature area.';

    procedure RequestAgentDesignerFeedback(FeatureName: Text; Agent: Record Agent);
    var
        AgentUserFeedback: Codeunit "Agent User Feedback";
        MicrosoftUserFeedback: codeunit "Microsoft User Feedback";
        EmptyContextFiles, ContextProperties : Dictionary of [Text, Text];
    begin
        EmptyContextFiles := AgentUserFeedback.InitializeAgentContext(Agent."Agent Metadata Provider", Agent."User Security ID");
        MicrosoftUserFeedback.SetIsAIFeedback(true);
        MicrosoftUserFeedback.RequestFeedback(FeatureName, AgentDesignerFeatureAreaTok, AgentDesignerFeatureAreaDisplayNameTok, EmptyContextFiles, ContextProperties);
    end;
}
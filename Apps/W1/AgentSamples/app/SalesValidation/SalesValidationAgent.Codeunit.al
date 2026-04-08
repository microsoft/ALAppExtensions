// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.AgentSamples.SalesValidation;

using System.Agents.Designer.CustomAgent;

codeunit 4450 "Sales Validation Agent" implements ICustomAgentSample, ICustomAgentSampleTaskTemplate
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetAgentCode(): Code[10]
    begin
        exit(AgentCodeTok);
    end;

    procedure GetAgentDefinition(var AgentOutStream: OutStream)
    var
        AgentInStream: InStream;
    begin
        NavApp.GetResource(AgentResourceNameTok, AgentInStream);
        CopyStream(AgentOutStream, AgentInStream);
    end;

    procedure GetAgentLearnMoreUrl(): Text[2048]
    begin
        exit(AgentLearnMoreUrlTok);
    end;

    procedure GetTaskTemplateCode(): Code[20]
    begin
        exit(AgentTaskTemplateCodeTok);
    end;

    procedure GetTaskTemplateDefinition(var TaskTemplateOutStream: OutStream)
    var
        TaskTemplateInStream: InStream;
    begin
        NavApp.GetResource(AgentTaskTemplateResourceNameTok, TaskTemplateInStream);
        CopyStream(TaskTemplateOutStream, TaskTemplateInStream);
    end;

    procedure GetTaskTemplatePlaceholdersMap() PlaceholdersMap: Dictionary of [Text, Text]
    begin
        PlaceholdersMap.Add(TemplateNamePlaceholderTok, TemplateNameLbl);
        PlaceholdersMap.Add(TemplateTaskTitlePlaceholderTok, TemplateTaskTitleLbl);
        PlaceholdersMap.Add(TemplateDescriptionPlaceholderTok, TemplateDescriptionLbl);
    end;

    var
        AgentCodeTok: Label 'SVAL', Locked = true;
        AgentResourceNameTok: Label 'sales-validation-agent.xml', Locked = true;
        AgentTaskTemplateCodeTok: Label 'SVAL-TASKS', Locked = true;
        AgentTaskTemplateResourceNameTok: Label 'sales-validation-agent-task-template.json', Locked = true;
        AgentLearnMoreUrlTok: Label 'https://go.microsoft.com/fwlink/?linkid=2350506', Locked = true;
        TemplateNamePlaceholderTok: Label '%%template_name%%', Locked = true;
        TemplateDescriptionPlaceholderTok: Label '%%template_description%%', Locked = true;
        TemplateTaskTitlePlaceholderTok: Label '%%template_task_title%%', Locked = true;
        TemplateNameLbl: Label 'Sales Validation - Process and Validate Orders';
        TemplateDescriptionLbl: Label 'Triggers the Sales Validation agent in order to discover its capabilities.';
        TemplateTaskTitleLbl: Label 'Run and process all orders.';
}
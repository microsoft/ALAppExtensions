// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Agents.Designer;
using System.Utilities;

codeunit 4355 "Custom Agent Export"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Exports the specified agents to a file that the user can download.
    /// </summary>
    /// <param name="Agent">The agents to export.</param>
    procedure ExportAgents(var Agent: Record Agent)
    var
        AgentDesignerPermissions: Codeunit "Agent Designer Permissions";
        AgentDesignerEnvironment: Codeunit "Agent Designer Environment";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        FileName: Text;
    begin
        AgentDesignerEnvironment.VerifyCanRunOnCurrentEnvironment();
        AgentDesignerPermissions.VerifyCurrentUserCanExportCustomAgents();

        ExportAgentsToBlob(Agent, TempBlob, FileName);
        TempBlob.CreateInStream(InStream, GetEncoding());
        DownloadFromStream(InStream, ExportDialogTitleLbl, '', '*.xml', FileName);
    end;

    internal procedure ExportAgentsToBlob(var Agent: Record Agent; var TempBlob: Codeunit "Temp Blob"; var FileName: Text)
    var
        CustomAgentExportXmlPort: XmlPort "Custom Agent Export";
        OutStream: OutStream;
        AgentCount: Integer;
    begin
        AgentCount := Agent.Count();

        if AgentCount = 0 then
            Error(NoCustomAgentsSelectedErr);

        Session.LogMessage('0000QED', StrSubstNo(ExportStartTelemetryTxt, AgentCount),
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            'Category', GetTelemetryCategory());

        TempBlob.CreateOutStream(OutStream, GetEncoding());
        CustomAgentExportXmlPort.SetTableView(Agent);
        CustomAgentExportXmlPort.SetDestination(OutStream);
        CustomAgentExportXmlPort.Export();

        if AgentCount = 1 then begin
            Agent.FindFirst();
            FileName := StrSubstNo(ExportFileNameLbl, Agent."User Name");
        end else
            FileName := StrSubstNo(ExportMultipleFileNameLbl, AgentCount);

        Session.LogMessage('0000QEE', StrSubstNo(ExportCompletedTelemetryTxt, AgentCount),
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            'Category', GetTelemetryCategory());
    end;

    /// <summary>
    /// Gets the text encoding used for the export XML file.
    /// </summary>
    /// <returns>The encoding.</returns>
    procedure GetEncoding(): TextEncoding
    begin
        exit(TextEncoding::UTF8)
    end;

    /// <summary>
    /// Gets the telemetry category for logging purposes.
    /// </summary>
    /// <returns>The telemetry category.</returns>
    procedure GetTelemetryCategory(): Text
    begin
        exit(CategoryTok);
    end;

    var
        CategoryTok: Label 'Custom Agents', Locked = true;
        NoCustomAgentsSelectedErr: Label 'None of the selected agents are custom agents. Please select at least one custom agent to export.';
        ExportFileNameLbl: Label '%1-agent.xml', Comment = '%1 = Agent Name';
        ExportMultipleFileNameLbl: Label '%1-agents.xml', Comment = '%1 = Number of agents';
        ExportDialogTitleLbl: Label 'Export custom agent(s)';
        ExportStartTelemetryTxt: Label 'Exporting %1 custom agents...', Comment = '%1 = Number of agents', Locked = true;
        ExportCompletedTelemetryTxt: Label 'Export completed. %1 agents exported.', Comment = '%1 = Number of agents', Locked = true;
}
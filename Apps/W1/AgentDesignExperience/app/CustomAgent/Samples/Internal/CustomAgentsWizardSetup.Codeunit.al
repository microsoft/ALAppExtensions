// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Agents.Designer;
using System.Environment.Configuration;
using System.Reflection;
using System.Utilities;

codeunit 4351 "Custom Agents Wizard Setup"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        // Permissions required for enabling profiles for sample agents.
        tabledata "Profile Configuration Symbols" = imd,
        tabledata "Tenant Profile" = imd,
        tabledata "Tenant Profile Extension" = imd,
        tabledata "Tenant Profile Setting" = imd;

    procedure GetSampleAgents(var CustomAgentsBuffer: Record "Custom Agents Sample Buffer"; FailedAgentSamples: List of [Enum "Custom Agent Sample"])
    var
        ICustomAgentSample: Interface ICustomAgentSample;
        CustomAgentSampleValue: Enum "Custom Agent Sample";
        CustomAgentSampleOrdinalValue: Integer;
        Success: Boolean;
    begin
        Clear(CustomAgentsBuffer);
        CustomAgentsBuffer.DeleteAll();

        foreach CustomAgentSampleOrdinalValue in Enum::"Custom Agent Sample".Ordinals() do begin
            Success := false;
            CustomAgentSampleValue := Enum::"Custom Agent Sample".FromInteger(CustomAgentSampleOrdinalValue);
            ICustomAgentSample := CustomAgentSampleValue;
            LoadSampleAgent(ICustomAgentSample, CustomAgentsBuffer, Success);

            if not Success then
                FailedAgentSamples.Add(CustomAgentSampleValue);
        end;

        if CustomAgentsBuffer.FindSet() then;
    end;

    procedure ImportAgent(AgentCode: Code[10]) AgentUserSecurityId: Guid
    var
        ICustomAgentSample: Interface ICustomAgentSample;
        ICustomAgentSampleTaskTemplate: Interface ICustomAgentSampleTaskTemplate;
        CustomAgentSampleEnum: Enum "Custom Agent Sample";
        CustomAgentSampleOrdinalValue: Integer;
    begin
        foreach CustomAgentSampleOrdinalValue in Enum::"Custom Agent Sample".Ordinals() do begin
            CustomAgentSampleEnum := Enum::"Custom Agent Sample".FromInteger(CustomAgentSampleOrdinalValue);
            ICustomAgentSample := CustomAgentSampleEnum;
            if (ICustomAgentSample.GetAgentCode() = AgentCode) then begin
                ICustomAgentSampleTaskTemplate := CustomAgentSampleEnum;
                exit(ImportAgentFromSample(ICustomAgentSample, ICustomAgentSampleTaskTemplate));
            end;
        end;

        Error(SampleAgentNotFoundErr, AgentCode);
    end;

    local procedure ImportAgentFromSample(ICustomAgentSample: Interface ICustomAgentSample; ICustomAgentSampleTaskTemplate: Interface ICustomAgentSampleTaskTemplate) AgentUserSecurityId: Guid
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        CustomAgentsWizardSetup: Record "Custom Agents Wizard Setup";
        AgentTaskTemplateRecord: Record "Agent Task Template";
        AgentTaskTemplate: Codeunit "Agent Task Template";
        CustomAgentImport: Codeunit "Custom Agent Import";
        AgentBlob: Codeunit "Temp Blob";
        TaskTemplateBlob: Codeunit "Temp Blob";
        AgentInStream, TaskTemplateInStream : InStream;
        AgentOutStream, TaskTemplateOutStream : OutStream;
        AgentUserSecurityIds: List of [Guid];
        SampleAgentCode: Code[10];
        TaskTemplateCode: Code[20];
        PlaceholdersMap: Dictionary of [Text, Text];
    begin
        SampleAgentCode := ICustomAgentSample.GetAgentCode();
        TaskTemplateCode := ICustomAgentSampleTaskTemplate.GetTaskTemplateCode();

        // Read the agent definition.
        AgentBlob.CreateOutStream(AgentOutStream);
        ICustomAgentSample.GetAgentDefinition(AgentOutStream);
        AgentBlob.CreateInStream(AgentInStream);
        CustomAgentImport.CollectAgentsFromXml(AgentInStream, TempAgentImportBuffer);

        // Enable the agent's profile.
        EnableProfile(TempAgentImportBuffer."Profile ID", TempAgentImportBuffer."Profile App ID");

        // Import the agent.
        TempAgentImportBuffer.Selected := true;
        TempAgentImportBuffer.Action := TempAgentImportBuffer.Action::Add;
        TempAgentImportBuffer.Modify();

        AgentBlob.CreateInStream(AgentInStream);
        AgentUserSecurityIds := CustomAgentImport.ImportSelectedAgents(AgentInStream, TempAgentImportBuffer);
        if (AgentUserSecurityIds.Count() > 1) then
            Error(MultipleAgentDefinitionErr);

        AgentUserSecurityIds.Get(1, AgentUserSecurityId);

        // Persist the agent import operation details.
        CustomAgentsWizardSetup."Agent User Security ID" := AgentUserSecurityId;
        CustomAgentsWizardSetup."Sample Agent Code" := SampleAgentCode;
        CustomAgentsWizardSetup."Task Template Code" := TaskTemplateCode;
        CustomAgentsWizardSetup.Insert();

        // Import the task templates if any.
        if TaskTemplateCode = '' then
            exit;

        AgentTaskTemplateRecord.SetRange("Sample Agent Code", TaskTemplateCode);
        if not AgentTaskTemplateRecord.IsEmpty() then
            exit;

        PlaceholdersMap := ICustomAgentSampleTaskTemplate.GetTaskTemplatePlaceholdersMap();
        TaskTemplateBlob.CreateOutStream(TaskTemplateOutStream);
        ICustomAgentSampleTaskTemplate.GetTaskTemplateDefinition(TaskTemplateOutStream);
        TaskTemplateBlob.CreateInStream(TaskTemplateInStream);
        AgentTaskTemplate.ImportTemplateFromStream(TaskTemplateInStream, TaskTemplateCode, PlaceholdersMap);
    end;

    local procedure AddSampleAgent(Code: Code[10]; Name: Text; Description: Text; LearnMoreUrl: Text[2048]; var CustomAgentsBuffer: Record "Custom Agents Sample Buffer")
    begin
        CustomAgentsBuffer.Init();
        CustomAgentsBuffer.ID := CustomAgentsBuffer.Count() + 1;
        CustomAgentsBuffer.Code := CopyStr(Code, 1, MaxStrLen(CustomAgentsBuffer.Code));
        CustomAgentsBuffer.Name := CopyStr(Name, 1, MaxStrLen(CustomAgentsBuffer.Name));
        CustomAgentsBuffer.Description := CopyStr(Description, 1, MaxStrLen(CustomAgentsBuffer.Description));
        CustomAgentsBuffer.LearnMoreUrl := LearnMoreUrl;
        CustomAgentsBuffer.Insert();
    end;

    local procedure LoadDetails(ICustomAgentSample: Interface ICustomAgentSample; var Name: Text; var Description: Text)
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        ICustomAgentSample.GetAgentDefinition(OutStream);
        TempBlob.CreateInStream(InStream);
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);
        Name := TempAgentImportBuffer."Display Name";
        Description := TempAgentImportBuffer.Description;
    end;

    local procedure EnableProfile(ProfileCode: Code[30]; ProfileAppId: Guid)
    var
        AllProfile: Record "All Profile";
    begin
        if not AllProfile.Get(AllProfile.Scope::Tenant, ProfileAppId, ProfileCode) then
            exit;

        if AllProfile.Enabled then
            exit;

        AllProfile.Enabled := true;
        AllProfile.Modify();
    end;

    procedure OpenCustomAgentsWizard(Notification: Notification)
    begin
        Page.Run(Page::"Custom Agents Wizard");
    end;

    procedure OpenLearnMoreLink(Notification: Notification)
    begin
        Hyperlink('https://go.microsoft.com/fwlink/?linkid=2344702');
    end;

    local procedure OpenRunAgentTaskFromTaskTemplatePage(AgentUserSecurityId: Guid; TaskTemplateCode: Code[20])
    var
        AgentTaskTemplate: Codeunit "Agent Task Template";
        TasksCreated: Integer;
    begin
        if not Confirm(RunAgentTaskFromTemplateQst, true) then
            exit;

        TasksCreated := AgentTaskTemplate.CreateTaskFromTemplate(AgentUserSecurityId, TaskTemplateCode);
        case TasksCreated of
            0:
                exit;
            1:
                if Confirm(OpenAgentTaskListSingleTaskQst, true) then
                    OpenAgentTaskListPage(AgentUserSecurityId);
            else
                if Confirm(OpenAgentTaskListMultipleTasksQst, true, TasksCreated) then
                    OpenAgentTaskListPage(AgentUserSecurityId);
        end;
    end;

    local procedure OpenAgentTaskListPage(AgentUserSecurityId: Guid)
    var
        AgentTask: Record "Agent Task";
    begin
        AgentTask.SetRange("Agent User Security ID", AgentUserSecurityId);
        if AgentTask.FindSet() then;
        Page.Run(Page::"Agent Task List", AgentTask);
    end;

    [InternalEvent(false, true)]
    local procedure LoadSampleAgent(ICustomAgentSample: Interface ICustomAgentSample; var CustomAgentsBuffer: Record "Custom Agents Sample Buffer"; var Success: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Agents Wizard Setup", LoadSampleAgent, '', false, false)]
    local procedure OnLoadSampleAgent(ICustomAgentSample: Interface ICustomAgentSample; var CustomAgentsBuffer: Record "Custom Agents Sample Buffer"; var Success: Boolean)
    var
        Name: Text;
        Description: Text;
    begin
        LoadDetails(ICustomAgentSample, Name, Description);
        AddSampleAgent(ICustomAgentSample.GetAgentCode(), Name, Description, ICustomAgentSample.GetAgentLearnMoreUrl(), CustomAgentsBuffer);
        Success := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Custom Agent Setup", OnActivateCustomAgent, '', true, true)]
    local procedure OnActivateCustomAgent(AgentUserSecurityId: Guid)
    var
        CustomAgentSetup: Record "Custom Agent Setup";
        SampleAgentImport: Record "Custom Agents Wizard Setup";
    begin
        if not CustomAgentSetup.Get(AgentUserSecurityId) then
            exit;

        if not SampleAgentImport.Get(AgentUserSecurityId) then
            exit;

        if (SampleAgentImport."Task Template Code" = '') then
            exit;

        OpenRunAgentTaskFromTaskTemplatePage(AgentUserSecurityId, SampleAgentImport."Task Template Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::Agent, OnAfterDeleteEvent, '', true, true)]
    local procedure OnAfterDeleteSampleCustomAgentEvent(var Rec: Record Agent)
    var
        CustomAgentWizardSetup: Record "Custom Agents Wizard Setup";
    begin
        if CustomAgentWizardSetup.Get(Rec."User Security ID") then
            CustomAgentWizardSetup.Delete();
    end;

    var
        SampleAgentNotFoundErr: Label 'No sample agent with code %1 was found.', Comment = '%1 is the agent code';
        MultipleAgentDefinitionErr: Label 'Multiple agent definitions were found in the sample agent XML. Agent sample files must only contain one agent definition.';
        RunAgentTaskFromTemplateQst: Label 'The agent is ready. Task templates are available to help you get started.\\Would you like to run a task from a template?';
        OpenAgentTaskListSingleTaskQst: Label 'The task has been created from the template. Would you like to open the task list page to view it?';
        OpenAgentTaskListMultipleTasksQst: Label '%1 tasks have been created from the templates. Would you like to open the task list page to view them?', Comment = '%1 is the number of tasks created';
}
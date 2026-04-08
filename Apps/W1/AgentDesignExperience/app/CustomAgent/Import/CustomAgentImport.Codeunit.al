// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Environment.Configuration;
using System.Globalization;
using System.Reflection;
using System.Security.AccessControl;

codeunit 4356 "Custom Agent Import"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Validates the imported agent data for correctness and consistency.
    /// </summary>
    /// <param name="TempAgent">The agent information.</param>
    /// <param name="TempAccessControlBuffer">The agent's access controls.</param>
    /// <param name="TempAllProfile">The agent profile.</param>
    /// <param name="TempUserSettings">The agent's user settings.</param>
    /// <param name="Instructions">The agent instructions from the import.</param>
    procedure ValidateAgent(var TempAgent: Record "Agent" temporary; var TempAccessControlBuffer: Record "Access Control Buffer" temporary; var TempAllProfile: Record "All Profile" temporary; var TempUserSettings: Record "User Settings" temporary; Instructions: Text)
    begin
        ValidateInstructionsChanges(Instructions, TempAgent);
        ValidateProfileExists(TempAllProfile, TempAgent);
        ValidateAccessControlsExist(TempAccessControlBuffer, TempAgent);
        ValidateAccessControlChanges(TempAccessControlBuffer, TempAgent);
        ValidateUserSettings(TempUserSettings, TempAgent);
    end;

    /// <summary>
    /// Adds the specified agent to the import buffer for later processing.
    /// </summary>
    /// <param name="TempAgent">The agent to process.</param>
    /// <param name="Description">The agent description.</param>
    /// <param name="Instructions">The agent instructions.</param>
    procedure AddAgentToBuffer(var TempAgent: Record "Agent" temporary; var TempAllProfile: Record "All Profile" temporary; Description: Text[250]; Instructions: Text)
    var
        ExistingAgent: Record Agent;
    begin
        Clear(TempAgentImportBuffer);
        TempAgentImportBuffer."Entry No." := TempAgentImportBuffer.Count();
        TempAgentImportBuffer.Name := TempAgent."User Name";
        TempAgentImportBuffer."Display Name" := TempAgent."Display Name";
        TempAgentImportBuffer.Initials := TempAgent.Initials;
        TempAgentImportBuffer.Description := Description;
        TempAgentImportBuffer.SetInstructions(Instructions);
        TempAgentImportBuffer."Profile ID" := TempAllProfile."Profile ID";
        TempAgentImportBuffer."Profile App ID" := TempAllProfile."App ID";

        // Check if agent already exists and set appropriate action
        ExistingAgent.SetRange("User Name", TempAgent."User Name");
        if not ExistingAgent.IsEmpty() then
            TempAgentImportBuffer.Action := TempAgentImportBuffer.Action::Replace
        else
            TempAgentImportBuffer.Action := TempAgentImportBuffer.Action::Add;

        TempAgentImportBuffer.Insert();
    end;

    /// <summary>
    /// Creates or update the agent in the system based on the import buffer settings.
    /// </summary>
    /// <param name="TempAgent">The agent information.</param>
    /// <param name="TempAccessControlBuffer">The agent's access controls.</param>
    /// <param name="TempAllProfile">The agent profile.</param>
    /// <param name="TempUserSettings">The agent's user settings.</param>
    /// <param name="Description">The agent description.</param>
    /// <param name="Instructions">The agent instructions.</param>
    procedure CreateAgent(
        var TempAgent: Record "Agent" temporary;
        var TempAccessControlBuffer: Record "Access Control Buffer" temporary;
        var TempAllProfile: Record "All Profile" temporary;
        var TempUserSettings: Record "User Settings" temporary;
        Description: Text[250];
        Instructions: Text)
    var
        TempAgentAccessControl: Record "Agent Access Control" temporary;
        CustomAgentSetup: Codeunit "Custom Agent Setup";
        Agent: Codeunit Agent;
        AgentUserSecurityID: Guid;
    begin
        // Check if agent is selected for import
        TempAgentImportBuffer.SetRange(Name, TempAgent."User Name");
        TempAgentImportBuffer.SetRange(Selected, true);
        if not TempAgentImportBuffer.FindFirst() then
            exit;

        // Handle company assignments for access control entries
        UpdateAccessControlCompanies(TempAccessControlBuffer, TempAgentImportBuffer.Action, TempAgent);

        // Handle Replace vs Add action
        if TempAgentImportBuffer.Action = TempAgentImportBuffer.Action::Replace then begin
            AgentUserSecurityID := ReplaceExistingAgent(
                TempAgent,
                TempAccessControlBuffer,
                Description,
                Instructions
            );

            Session.LogMessage('0000QEF', ImportAgentReplaceTelemetryTxt,
                Verbosity::Normal,
                DataClassification::SystemMetadata,
                TelemetryScope::ExtensionPublisher,
                'Category', CustomAgentExport.GetTelemetryCategory());
        end else begin
            // Create the selected agent (Add action)
            AgentUserSecurityID := CustomAgentSetup.CreateAgent(
                TempAgent."User Name",
                TempAgent."Display Name",
                TempAgentAccessControl,
                TempAccessControlBuffer,
                TempAgent.Initials,
                Description,
                Instructions
            );

            Session.LogMessage('0000QEG', ImportAgentAddTelemetryTxt,
                Verbosity::Normal,
                DataClassification::SystemMetadata,
                TelemetryScope::ExtensionPublisher,
                'Category', CustomAgentExport.GetTelemetryCategory());
        end;

        if TempAllProfile.FindFirst() then
            Agent.SetProfile(AgentUserSecurityID, TempAllProfile."Profile ID", TempAllProfile."App ID");

        if TempUserSettings.FindFirst() then begin
            TempUserSettings."User Security ID" := AgentUserSecurityID;
            Agent.UpdateLocalizationSettings(AgentUserSecurityID, TempUserSettings);
        end;

        GlobalImportedAgentIDs.Add(AgentUserSecurityID);
    end;

    /// <summary>
    /// Collects agents from the provided XML stream into the import buffer.
    /// </summary>
    /// <param name="InStream">The XML stream.</param>
    /// <param name="AgentImportBuffer">The agent import buffer.</param>
    procedure CollectAgentsFromXml(InStream: InStream; var AgentImportBuffer: Record "Agent Import Buffer" temporary)
    var
        CustomAgentImportXmlPort: XmlPort "Custom Agent Import";
    begin
        AgentImportBuffer.DeleteAll();
        TempAgentImportBuffer.DeleteAll();

        // Collect agents using XMLPort
        CustomAgentImportXmlPort.SetImportBufferCodeunit(this, true);
        CustomAgentImportXmlPort.SetSource(InStream);
        CustomAgentImportXmlPort.Import();

        // Transfer collected data to wizard buffer
        if TempAgentImportBuffer.FindSet() then
            repeat
                AgentImportBuffer := TempAgentImportBuffer;
                AgentImportBuffer.SetInstructions(TempAgentImportBuffer.GetInstructions());
                AgentImportBuffer.Insert();
            until TempAgentImportBuffer.Next() = 0;
    end;

    /// <summary>
    /// Imports agents from the provided XML stream, filtering by the selected agents in the buffer.
    /// </summary>
    /// <param name="InStream">The XML stream.</param>
    /// <param name="SelectedAgentBuffer">The selected agents buffer.</param>
    /// <returns></returns>
    procedure ImportSelectedAgents(InStream: InStream; var SelectedAgentBuffer: Record "Agent Import Buffer" temporary): List of [Guid]
    var
        CustomAgentImportXmlPort: XmlPort "Custom Agent Import";
    begin
        Clear(GlobalImportedAgentIDs);

        // Clear any existing diagnostics
        TempAgentImportDiagnostic.DeleteAll();

        // Copy selected agents to our global buffer for filtering
        TempAgentImportBuffer.DeleteAll();
        SelectedAgentBuffer.SetRange(Selected, true);

        Session.LogMessage('0000QEH', StrSubstNo(ImportStartTelemetryTxt, TempAgentImportBuffer.Count()),
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            'Category',
            CustomAgentExport.GetTelemetryCategory());

        if SelectedAgentBuffer.FindSet() then
            repeat
                TempAgentImportBuffer := SelectedAgentBuffer;
                TempAgentImportBuffer.Insert();
            until SelectedAgentBuffer.Next() = 0;

        CustomAgentImportXmlPort.SetImportBufferCodeunit(this, false);
        CustomAgentImportXmlPort.SetSource(InStream);
        CustomAgentImportXmlPort.Import();

        Session.LogMessage('0000QEI', StrSubstNo(ImportCompletedTelemetryTxt, GlobalImportedAgentIDs.Count()),
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            'Category',
            CustomAgentExport.GetTelemetryCategory());

        exit(GlobalImportedAgentIDs);
    end;

    /// <summary>
    /// Gets the diagnostics reported during the import process.
    /// </summary>
    /// <param name="TempDiagnostic">The diagnostics reported.</param>
    procedure GetDiagnostics(var TempDiagnostic: Record "Agent Import Diagnostic" temporary)
    begin
        TempDiagnostic.Copy(TempAgentImportDiagnostic, true);
    end;

    local procedure ValidateProfileExists(var TempAllProfile: Record "All Profile" temporary; var TempAgent: Record "Agent" temporary)
    var
        AllProfile: Record "All Profile";
    begin
        if not TempAllProfile.FindFirst() then begin
            GenerateDiagnostic(
                Severity::Error,
                StrSubstNo(ProfileNotSpecifiedLbl, TempAgent."User Name", ReviewDefaultSettingsLbl),
                TempAgent);
            exit;
        end;

        // Check if profile exists in the system
        AllProfile.SetRange("Profile ID", TempAllProfile."Profile ID");
        AllProfile.SetRange("App ID", TempAllProfile."App ID");
        if AllProfile.IsEmpty() then
            GenerateDiagnostic(
                Severity::Warning,
                StrSubstNo(ProfileNotFoundLbl, TempAllProfile."Profile ID", TempAllProfile."App ID", ReviewDefaultSettingsLbl),
                TempAgent)
        else
            GenerateDiagnostic(
                Severity::Information,
                StrSubstNo(ProfileValidatedLbl, TempAllProfile."Profile ID"),
                TempAgent);
    end;

    local procedure ValidateAccessControlsExist(var TempAccessControlBuffer: Record "Access Control Buffer" temporary; var TempAgent: Record "Agent" temporary)
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
        ValidRoleCount: Integer;
        TotalRoleCount: Integer;
    begin
        ValidRoleCount := 0;
        TotalRoleCount := 0;
        if not TempAccessControlBuffer.FindFirst() then begin
            GenerateDiagnostic(
                Severity::Error,
                StrSubstNo(PermissionSetsNotSpecifiedLbl, TempAgent."User Name"),
                TempAgent);
            exit;
        end;

        if TempAccessControlBuffer.FindSet() then
            repeat
                TotalRoleCount += 1;
                AggregatePermissionSet.SetRange("Role ID", TempAccessControlBuffer."Role ID");
                AggregatePermissionSet.SetRange("App ID", TempAccessControlBuffer."App ID");
                if not AggregatePermissionSet.IsEmpty() then begin
                    ValidRoleCount += 1;
                    GenerateDiagnostic(
                        Severity::Information,
                        StrSubstNo(PermissionSetValidatedLbl, TempAccessControlBuffer."Role ID"),
                        TempAgent);
                end else
                    GenerateDiagnostic(
                        Severity::Warning,
                        StrSubstNo(PermissionSetNotFoundLbl, TempAccessControlBuffer."Role ID", TempAccessControlBuffer."App ID"),
                        TempAgent);
            until TempAccessControlBuffer.Next() = 0;

        if ValidRoleCount < TotalRoleCount then
            GenerateDiagnostic(
                Severity::Warning,
                StrSubstNo(PartialPermissionSetsLbl, ValidRoleCount, TotalRoleCount, TempAgent."User Name"),
                TempAgent);
    end;

    local procedure ValidateUserSettings(var TempUserSettings: Record "User Settings" temporary; var TempAgent: Record "Agent" temporary)
    begin
        if not TempUserSettings.FindFirst() then begin
            GenerateDiagnostic(
                Severity::Error,
                StrSubstNo(UserSettingsNotSpecifiedLbl, TempAgent."User Name", ReviewDefaultSettingsLbl),
                TempAgent);
            exit;
        end;

        ValidateAgentLanguage(TempUserSettings, TempAgent);
        ValidateAgentLocale(TempUserSettings, TempAgent);
        ValidateAgentTimeZone(TempUserSettings, TempAgent);
    end;

    local procedure ValidateAgentLanguage(var TempUserSettings: Record "User Settings" temporary; var TempAgent: Record "Agent" temporary)
    var
        Language: Codeunit Language;
        LanguageName: Text;
    begin
        if TempUserSettings."Language ID" = 0 then begin
            GenerateDiagnostic(
                Severity::Warning,
                StrSubstNo(AgentLanguageMissingLbl, ReviewDefaultSettingsLbl),
                TempAgent);
            exit;
        end;

        LanguageName := Language.GetWindowsLanguageName(TempUserSettings."Language ID");
        if LanguageName <> '' then
            GenerateDiagnostic(
                Severity::Information,
                StrSubstNo(AgentConfiguredWithLanguageLbl, LanguageName),
                TempAgent)
        else
            GenerateDiagnostic(
                Severity::Warning,
                StrSubstNo(AgentInvalidLanguageIdLbl, TempUserSettings."Language ID", ReviewDefaultSettingsLbl),
                TempAgent);
    end;

    local procedure ValidateAgentLocale(var TempUserSettings: Record "User Settings" temporary; var TempAgent: Record "Agent" temporary)
    var
        Language: Codeunit Language;
        LocaleName: Text;
    begin
        if TempUserSettings."Locale ID" = 0 then begin
            GenerateDiagnostic(
                Severity::Warning,
                StrSubstNo(AgentLocaleMissingLbl, ReviewDefaultSettingsLbl),
                TempAgent);
            exit;
        end;

        LocaleName := Language.GetWindowsLanguageName(TempUserSettings."Locale ID");
        if LocaleName <> '' then
            GenerateDiagnostic(
                Severity::Information,
                StrSubstNo(AgentConfiguredWithLocaleLbl, LocaleName),
                TempAgent)
        else
            GenerateDiagnostic(
                Severity::Warning,
                StrSubstNo(AgentInvalidLocaleIdLbl, TempUserSettings."Locale ID", ReviewDefaultSettingsLbl),
                TempAgent);
    end;

    local procedure ValidateAgentTimeZone(var TempUserSettings: Record "User Settings" temporary; var TempAgent: Record "Agent" temporary)
    begin
        if TempUserSettings."Time Zone" = '' then
            GenerateDiagnostic(
                Severity::Warning,
                StrSubstNo(AgentTimeZoneMissingLbl, ReviewDefaultSettingsLbl),
                TempAgent)
        else
            GenerateDiagnostic(
                Severity::Information,
                StrSubstNo(AgentConfiguredWithTimeZoneLbl, TempUserSettings."Time Zone"),
                TempAgent);
    end;

    local procedure ValidateInstructionsChanges(ImportInstructions: Text; var TempAgent: Record "Agent" temporary)
    var
        ExistingAgent: Record Agent;
        CustomAgentSetup: Record "Custom Agent Setup";
        ExistingInstructions: Text;
    begin
        // Only validate instructions for agents that exist in the system (would be replaced)
        ExistingAgent.SetRange("User Name", TempAgent."User Name");
        if not ExistingAgent.FindFirst() then
            exit;

        ExistingInstructions := CustomAgentSetup.GetInstructions(ExistingAgent."User Security ID");

        if ImportInstructions <> ExistingInstructions then
            GenerateDiagnostic(
                Severity::Warning,
                StrSubstNo(AgentInstructionsDifferentLbl, TempAgent."User Name"),
                TempAgent)
        else
            GenerateDiagnostic(
                Severity::Information,
                StrSubstNo(AgentInstructionsMatchLbl, TempAgent."User Name"),
                TempAgent);
    end;

    local procedure ValidateAccessControlChanges(var TempAccessControlBuffer: Record "Access Control Buffer" temporary; var TempExistingAccessControl: Record "Access Control" temporary; var TempAgent: Record "Agent" temporary)
    var
        ImportedRoles: List of [Text];
        ExistingRoles: List of [Text];
        RoleId: Text;
        PermissionsMatch: Boolean;
    begin
        // Collect imported roles
        if TempAccessControlBuffer.FindSet() then
            repeat
                RoleId := TempAccessControlBuffer."Role ID" + '|' + Format(TempAccessControlBuffer."App ID");
                if not ImportedRoles.Contains(RoleId) then
                    ImportedRoles.Add(RoleId);
            until TempAccessControlBuffer.Next() = 0;

        // Collect existing roles (from current company and all-companies permissions for comparison)
        TempExistingAccessControl.SetFilter("Company Name", '%1|%2', CompanyName(), '');
        if TempExistingAccessControl.FindSet() then
            repeat
                RoleId := TempExistingAccessControl."Role ID" + '|' + Format(TempExistingAccessControl."App ID");
                if not ExistingRoles.Contains(RoleId) then
                    ExistingRoles.Add(RoleId);
            until TempExistingAccessControl.Next() = 0;

        // Compare permission sets
        PermissionsMatch := (ImportedRoles.Count() = ExistingRoles.Count());
        if PermissionsMatch then
            foreach RoleId in ImportedRoles do
                if not ExistingRoles.Contains(RoleId) then begin
                    PermissionsMatch := false;
                    break;
                end;

        if PermissionsMatch then
            GenerateDiagnostic(
                Severity::Information,
                StrSubstNo(AgentPermissionsSameLbl, TempAgent."User Name"),
                TempAgent)
        else
            GenerateDiagnostic(
                Severity::Warning,
                StrSubstNo(AgentPermissionsDifferentLbl, TempAgent."User Name"),
                TempAgent);
    end;

    local procedure ValidateAccessControlChanges(var TempAccessControlBuffer: Record "Access Control Buffer" temporary; var TempAgent: Record "Agent" temporary)
    var
        ExistingAgent: Record Agent;
        ExistingAccessControl: Record "Access Control";
        TempExistingAccessControl: Record "Access Control" temporary;
        CompanyList: List of [Text];
        HasAllCompaniesPermission: Boolean;
    begin
        ExistingAgent.SetRange("User Name", TempAgent."User Name");
        if not ExistingAgent.FindFirst() then
            exit;

        ExistingAccessControl.SetRange("User Security ID", ExistingAgent."User Security ID");
        if ExistingAccessControl.FindSet() then
            repeat
                if ExistingAccessControl."Company Name" = '' then
                    HasAllCompaniesPermission := true
                else
                    if not CompanyList.Contains(ExistingAccessControl."Company Name") then
                        CompanyList.Add(ExistingAccessControl."Company Name");

                // Store existing permissions for comparison
                TempExistingAccessControl := ExistingAccessControl;
                TempExistingAccessControl.Insert();
            until ExistingAccessControl.Next() = 0;

        if HasAllCompaniesPermission then begin
            ValidateAccessControlChanges(TempAccessControlBuffer, TempExistingAccessControl, TempAgent);

            GenerateDiagnostic(
                Severity::Warning,
                StrSubstNo(AgentPermissionsAllCompaniesLbl, TempAgent."User Name"),
                TempAgent);
            exit;
        end;

        if CompanyList.Count() > 0 then begin
            ValidateAccessControlChanges(TempAccessControlBuffer, TempExistingAccessControl, TempAgent);

            if CompanyList.Count() > 1 then
                GenerateDiagnostic(
                    Severity::Warning,
                    StrSubstNo(AgentPermissionsMultipleCompaniesLbl, TempAgent."User Name", CompanyList.Count()),
                    TempAgent);
        end;
    end;

    local procedure UpdateAccessControlCompanies(var TempAccessControlBuffer: Record "Access Control Buffer" temporary; ImportAction: Enum "Agent Import Action"; var TempAgent: Record "Agent" temporary)
    var
        ExistingAgent: Record Agent;
        ExistingAccessControl: Record "Access Control";
        CompanyList: List of [Text];
        CompanyCount: Integer;
        HasAllCompaniesPermission: Boolean;
    begin
        // For Add new agents, always apply permissions to current company only
        if ImportAction = ImportAction::Add then begin
            UpdateAccessControlToCurrentCompany(TempAccessControlBuffer);
            exit;
        end;

        ExistingAgent.SetRange("User Name", TempAgent."User Name");
        if not ExistingAgent.FindFirst() then begin
            UpdateAccessControlToCurrentCompany(TempAccessControlBuffer);
            exit;
        end;

        // For Replace, get all companies where the agent currently has permissions
        ExistingAccessControl.SetRange("User Security ID", ExistingAgent."User Security ID");
        if ExistingAccessControl.FindSet() then
            repeat
                if ExistingAccessControl."Company Name" = '' then begin
                    HasAllCompaniesPermission := true;
                    break;
                end
                else
                    if not CompanyList.Contains(ExistingAccessControl."Company Name") then
                        CompanyList.Add(ExistingAccessControl."Company Name");
            until ExistingAccessControl.Next() = 0;

        // Handle permission assignment based on existing permissions
        if HasAllCompaniesPermission then
            UpdateAccessControlToAllCompanies(TempAccessControlBuffer)
        else begin
            CompanyCount := CompanyList.Count();
            if CompanyCount = 0 then
                UpdateAccessControlToCurrentCompany(TempAccessControlBuffer)
            else
                // Update permissions for all companies where agent currently has access
                UpdateAccessControlToCompanies(TempAccessControlBuffer, CompanyList);
        end;
    end;

    local procedure UpdateAccessControlToCurrentCompany(var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    begin
        UpdateAccessControlToSpecifiedCompany(TempAccessControlBuffer, CompanyName());
    end;

    local procedure UpdateAccessControlToAllCompanies(var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    begin
        // Set all access control entries to empty company name (all companies)
        UpdateAccessControlToSpecifiedCompany(TempAccessControlBuffer, '');
    end;

    local procedure UpdateAccessControlToSpecifiedCompany(var TempAccessControlBuffer: Record "Access Control Buffer" temporary; CompanyName: Text)
    var
        TempUpdateAccessControlBuffer: Record "Access Control Buffer" temporary;
    begin
        if TempAccessControlBuffer.FindSet() then
            repeat
                TempUpdateAccessControlBuffer."Company Name" := CopyStr(CompanyName, 1, MaxStrLen(TempUpdateAccessControlBuffer."Company Name"));
                TempUpdateAccessControlBuffer.Scope := TempAccessControlBuffer.Scope;
                TempUpdateAccessControlBuffer."App ID" := TempAccessControlBuffer."App ID";
                TempUpdateAccessControlBuffer."Role ID" := TempAccessControlBuffer."Role ID";
                TempUpdateAccessControlBuffer.Insert();
            until TempAccessControlBuffer.Next() = 0;
        TempAccessControlBuffer.Copy(TempUpdateAccessControlBuffer, true);
    end;

    local procedure UpdateAccessControlToCompanies(var TempAccessControlBuffer: Record "Access Control Buffer" temporary; CompanyList: List of [Text])
    var
        TempAccessControlCopy: Record "Access Control Buffer" temporary;
        CurrentCompany: Text[30];
    begin
        if not TempAccessControlBuffer.FindSet() then
            exit;

        repeat
            TempAccessControlCopy := TempAccessControlBuffer;
            TempAccessControlCopy.Insert();
        until TempAccessControlBuffer.Next() = 0;

        TempAccessControlBuffer.DeleteAll();

        foreach CurrentCompany in CompanyList do
            if TempAccessControlCopy.FindSet() then
                repeat
                    Clear(TempAccessControlBuffer);
                    TempAccessControlBuffer := TempAccessControlCopy;
                    TempAccessControlBuffer."Company Name" := CurrentCompany;
                    TempAccessControlBuffer.Insert();
                until TempAccessControlCopy.Next() = 0;
    end;

    local procedure ReplaceExistingAgent(
        var TempAgent: Record "Agent" temporary;
        var TempAccessControlBuffer: Record "Access Control Buffer" temporary;
        Description: Text[250];
        Instructions: Text): Guid
    var
        ExistingAgent: Record Agent;
        CustomAgentSetupRecord: Record "Custom Agent Setup";
        CustomAgentSetup: Codeunit "Custom Agent Setup";
        Agent: Codeunit Agent;
    begin
        // Find the existing agent
        ExistingAgent.SetRange("User Name", TempAgent."User Name");
        if not ExistingAgent.FindFirst() then
            Error(NonExistingAgentCannotBeReplacedErr, TempAgent."User Name");

        // Check if agent is active and ask for confirmation to deactivate
        if ExistingAgent.State = ExistingAgent.State::Enabled then
            if Confirm(ActiveAgentReplaceConfirmLbl, true, ExistingAgent."User Name") then begin
                ExistingAgent.State := ExistingAgent.State::Disabled;
                ExistingAgent.Modify();
            end;

        // Update the existing agent's properties
        Agent.SetDisplayName(ExistingAgent."User Security ID", TempAgent."Display Name");
        Agent.SetInstructions(ExistingAgent."User Security ID", Instructions);

        // Update Custom Agent Setup record
        if CustomAgentSetupRecord.Get(ExistingAgent."User Security ID") then begin
            CustomAgentSetupRecord.Description := Description;
            CustomAgentSetupRecord.Initials := TempAgent.Initials;
            CustomAgentSetupRecord.Modify();
            CustomAgentSetupRecord.SetInstructions(Instructions);
        end else begin
            // Not really an expected scenario, but handle gracefully
            Session.LogMessage('0000QEJ', MissingCustomAgentSetupRecordTelemetryTxt,
                Verbosity::Warning,
                DataClassification::SystemMetadata,
                TelemetryScope::ExtensionPublisher,
                'Category', CustomAgentExport.GetTelemetryCategory());

            CustomAgentSetup.CreateCustomAgentSetup(ExistingAgent."User Security ID", TempAgent.Initials, Description, Instructions);
        end;

        CustomAgentSetup.UpdateAccessControl(ExistingAgent."User Security ID", TempAccessControlBuffer);

        exit(ExistingAgent."User Security ID");
    end;

    local procedure GetNextDiagnosticID(): Integer
    var
        TempLastDiagnostic: Record "Agent Import Diagnostic" temporary;
    begin
        TempLastDiagnostic.Copy(TempAgentImportDiagnostic, true);
        if TempLastDiagnostic.FindLast() then
            exit(TempLastDiagnostic."Diagnostic ID" + 1)
        else
            exit(1);
    end;

    local procedure GenerateDiagnostic(DiagSeverity: Enum "Agent Import Diag Severity"; Message: Text[2048]; var TempAgent: Record Agent temporary)
    begin
        Clear(TempAgentImportDiagnostic);
        TempAgentImportDiagnostic."Diagnostic ID" := GetNextDiagnosticID();
        TempAgentImportDiagnostic.Severity := DiagSeverity;
        TempAgentImportDiagnostic.Message := Message;
        TempAgentImportDiagnostic."Agent Name" := TempAgent."User Name";
        TempAgentImportDiagnostic."Agent Initials" := TempAgent.Initials;
        TempAgentImportDiagnostic.Insert();
    end;

    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        TempAgentImportDiagnostic: Record "Agent Import Diagnostic" temporary;
        CustomAgentExport: Codeunit "Custom Agent Export";
        Severity: Enum "Agent Import Diag Severity";
        GlobalImportedAgentIDs: List of [Guid];
        ImportAgentAddTelemetryTxt: Label 'Adding new agent.', Locked = true;
        ImportAgentReplaceTelemetryTxt: Label 'Replacing existing agent.', Locked = true;
        ImportStartTelemetryTxt: Label 'Importing %1 custom agents...', Comment = '%1 = Number of agents', Locked = true;
        ImportCompletedTelemetryTxt: Label 'Import completed. %1 agents imported.', Comment = '%1 = Number of agents', Locked = true;
        MissingCustomAgentSetupRecordTelemetryTxt: Label 'Missing custom agent setup record during import as ''Replace''. Inserting a new record.', Locked = true;
        NonExistingAgentCannotBeReplacedErr: Label 'Agent %1 not found for replacement.', Comment = '%1 = Agent Name';
        ActiveAgentReplaceConfirmLbl: Label 'The agent %1 is currently active and may be executing tasks.\\Do you want to deactivate it now and review the changes before it starts executing with the new configuration?', Comment = '%1 = Agent Name';

    // The validation diagnostics
    var
        ReviewDefaultSettingsLbl: Label 'System defaults will be used instead, review after the agent settings after import.';
        UserSettingsNotSpecifiedLbl: Label 'The user settings were not specified for agent %1. %2', Comment = '%1 = Agent Name, %2 = the review setting label';
        ProfileNotSpecifiedLbl: Label 'The profile was not specified for agent %1. %2', Comment = '%1 = Agent Name, %2 = the review setting label';
        ProfileNotFoundLbl: Label 'Profile ''%1'' from app %2 not found in system. %3', Comment = '%1 = Profile ID, %2 = App ID, %3 = the review setting label';
        ProfileValidatedLbl: Label 'Profile ''%1'' validated successfully.', Comment = '%1 = Profile ID';
        PermissionSetsNotSpecifiedLbl: Label 'The permission sets were not specified for agent %1. The agent will not have any permissions, review after the agent settings after import.', Comment = '%1 = Agent Name';
        PermissionSetValidatedLbl: Label 'Permission set ''%1'' validated successfully.', Comment = '%1 = Role ID';
        PermissionSetNotFoundLbl: Label 'Permission set ''%1'' from app %2 not found in system.', Comment = '%1 = Role ID, %2 = App ID';
        PartialPermissionSetsLbl: Label 'Only %1 of %2 permission sets were found for agent %3.', Comment = '%1 = Valid count, %2 = Total count, %3 = Agent Name';
        AgentConfiguredWithLanguageLbl: Label 'Agent configured with language %1.', Comment = '%1 = Language name';
        AgentInvalidLanguageIdLbl: Label 'Invalid language ID %1. %2', Comment = '%1 = Language ID, %2 = the review setting label';
        AgentLanguageMissingLbl: Label 'Language not specified. %1', Comment = '%1 = the review setting label';
        AgentLocaleMissingLbl: Label 'Locale not specified. %1', Comment = '%1 = the review setting label';
        AgentInvalidLocaleIdLbl: Label 'Invalid locale ID %1. %2', Comment = '%1 = Locale ID, %2 = the review setting label';
        AgentConfiguredWithLocaleLbl: Label 'Agent configured with regional settings for %1.', Comment = '%1 = Locale';
        AgentTimeZoneMissingLbl: Label 'Time zone not specified. %1', Comment = '%1 = the review setting label';
        AgentConfiguredWithTimeZoneLbl: Label 'Agent configured with time zone %1.', Comment = '%1 = Time zone';
        AgentInstructionsDifferentLbl: Label 'Instructions for agent %1 are different from the existing agent and will be replaced.', Comment = '%1 = Agent Name';
        AgentInstructionsMatchLbl: Label 'Instructions for agent %1 match the ones for the existing agent.', Comment = '%1 = Agent Name';
        AgentPermissionsMultipleCompaniesLbl: Label 'Agent %1 has permissions in %2 companies. New permissions will be applied to all these companies if ''Replace'' is selected.', Comment = '%1 = Agent Name, %2 = Company count';
        AgentPermissionsSameLbl: Label 'Permissions for agent %1 match the ones for the existing agent.', Comment = '%1 = Agent Name';
        AgentPermissionsDifferentLbl: Label 'Permissions for agent %1 are different from the ones for the existing agent and will be replaced if ''Replace'' is selected.', Comment = '%1 = Agent Name';
        AgentPermissionsAllCompaniesLbl: Label 'Agent %1 currently has permissions in all companies. New permissions will be applied to all these companies if ''Replace'' is selected.', Comment = '%1 = Agent Name';
}
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.EServices.EDocumentConnector.Microsoft365;
using System.Agents;
using System.Azure.Identity;
using System.Azure.KeyVault;
using System.Email;
using System.Environment;
using System.Environment.Configuration;
using System.Reflection;
using System.Security.AccessControl;
using System.Security.User;

codeunit 3307 "Payables Agent Setup"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    Permissions =
        tabledata "Outlook Setup" = rim,
        tabledata "Payables Agent Setup" = rmid;

    /// <summary>
    /// Retrieves all the records containing setup information for the payables agent.
    /// </summary>
    /// <param name="PASetupConfiguration">State variable where all the setup related information is stored.</param>
    procedure LoadSetupConfiguration(var PASetupConfiguration: Codeunit "PA Setup Configuration")
    var
        Agent: Record Agent;
        EDocumentService: Record "E-Document Service";
        TempEmailAccount: Record "Email Account" temporary;
        PayablesAgentSetup: Record "Payables Agent Setup";
        TempAgentSetupBuffer: Record "Agent Setup Buffer";
        OutlookSetup: Record "Outlook Setup";
        AgentSetup: Codeunit "Agent Setup";
        EmailAccount: Codeunit "Email Account";
    begin
        // Skipping configuring the Agent framework records is valid in tests
        if not PASetupConfiguration.GetSkipAgentConfiguration() then begin
            if GetAgent(Agent) then;
            AgentSetup.GetSetupRecord(
                TempAgentSetupBuffer,
                Agent."User Security ID",
                "Agent Metadata Provider"::"Payables Agent",
                AgentUserName(),
                AgentDisplayName(),
                AgentSummaryLbl
            );
            PASetupConfiguration.SetAgentSetupBuffer(TempAgentSetupBuffer);
        end;

        PayablesAgentSetup.GetSetup();
        if EDocumentService.Get(PayablesAgentSetup."E-Document Service Code") then;
        if OutlookSetup.Get() then;
        EmailAccount.GetAllAccounts(false, TempEmailAccount);
        if not TempEmailAccount.Get(OutlookSetup."Email Account ID", OutlookSetup."Email Connector") then
            Clear(TempEmailAccount);

        PASetupConfiguration.SetPayablesAgentSetup(PayablesAgentSetup);
        PASetupConfiguration.SetEDocumentService(EDocumentService);
        PASetupConfiguration.SetEmailAccount(TempEmailAccount);
    end;

    /// <summary>
    /// Persist the payables agent setup configured across the different records and applies the necessary actions like activating and monitoring mailboxes.
    /// This is executed both when activating and deactivating the agent.
    /// </summary>
    /// <param name="PASetupConfiguration">State variable where all the setup related information is stored.</param>
    procedure ApplyPayablesAgentSetup(var PASetupConfiguration: Codeunit "PA Setup Configuration")
    var
        PayablesAgentSetup: Record "Payables Agent Setup";
        TempPayablesAgentSetup: Record "Payables Agent Setup" temporary;
        OutlookSetup: Record "Outlook Setup";
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        EnvironmentInformation: Codeunit "Environment Information";
        PADemoGuide: Codeunit "PA Demo Guide";
        PAValidateSetup: Codeunit "PA Validate Setup";
        EDocPOMatching: Codeunit "E-Doc. PO Matching";
        ConsentManager: Interface IConsentManager;
        ErrorAccountNotConnecting: ErrorInfo;
        OutlookSetupExistedPreviously, EmailAccountChanged : Boolean;
        DelegatedAdminErr: Label 'Delegated admin and helpdesk users are not allowed to update the agent.';
        EmailMonitoringRequiresPrivacyConsentErr: Label 'Email monitoring requires privacy consent.';
        EmailConnectionErr: Label 'Failed to connect to the email mailbox.';
        EmailConnectionMessageErr: Label 'Connection to mailbox failed. Please review the email account configuration for email %1', Comment = '%1 - Email account name';
        EmailConnectionNavigationActionLbl: Label 'Show email accounts';
        ActivateWithoutMailboxNameErr: Label 'To activate the agent with the current settings, a mailbox must be selected first.';
        ActivateAgentWithoutMonitorErr: Label 'To activate the agent "Monitor incoming information" must be enabled.';
    begin
        if AzureADGraphUser.IsUserDelegatedAdmin() or AzureADGraphUser.IsUserDelegatedHelpdesk() then
            Error(DelegatedAdminErr);

        Session.LogMessage('0000OUW', 'Setting up payables agent', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', PayablesAgentTelemetryTok);

        // If the agent is to be activated, we check if the privacy consent has been given for the email integration or trigger the consent flow
        // This has to happen before any write transactions since the consent runs modally (and will block the session)
        // Similarly we delay the insert/modify of OutlookSetup until we verify that the email connection is succesful (i.e. Codeunit.Run completes succesfully, this forces to have no open write transactions)
        OutlookSetupExistedPreviously := OutlookSetup.FindFirst();
        if PASetupConfiguration.GetAgentSetupBuffer().State = PASetupConfiguration.GetAgentSetupBuffer().State::Enabled then begin
            ConsentManager := "Service Integration"::Outlook;
            if not ConsentManager.ObtainPrivacyConsent() then
                Error(EmailMonitoringRequiresPrivacyConsentErr);
            OutlookSetup."Consent Received" := true;
        end;

        EmailAccountChanged := OutlookSetup."Email Account ID" <> PASetupConfiguration.GetEmailAccount()."Account Id";
        OutlookSetup."Email Account ID" := PASetupConfiguration.GetEmailAccount()."Account Id";
        OutlookSetup."Email Connector" := PASetupConfiguration.GetEmailAccount().Connector;
        if EmailAccountChanged then
            OutlookSetup."Last Sync At" := 0DT;

        if PASetupConfiguration.GetAgentSetupBuffer().State = PASetupConfiguration.GetAgentSetupBuffer().State::Enabled then
            if not PASetupConfiguration.GetSkipEmailVerification() then begin

                if PASetupConfiguration.GetPayablesAgentSetup()."Monitor Outlook" then
                    if IsNullGuid(PASetupConfiguration.GetEmailAccount()."Account Id") then
                        Error(ActivateWithoutMailboxNameErr);

                // Update last activated
                TempPayablesAgentSetup := PASetupConfiguration.GetPayablesAgentSetup();
                TempPayablesAgentSetup."Last Activated" := CurrentDateTime();
                PASetupConfiguration.SetPayablesAgentSetup(TempPayablesAgentSetup);

                // SaaS only requirement.
                if EnvironmentInformation.IsSaaS() then begin

                    // We validate the email connection before applying any changes to avoid leaving the agent in a partially configured state
                    if not PASetupConfiguration.GetPayablesAgentSetup()."Monitor Outlook" then
                        Error(ActivateAgentWithoutMonitorErr);

                    PAValidateSetup.SetOutlookSetup(OutlookSetup);
                    if not PAValidateSetup.Run() then begin
                        ErrorAccountNotConnecting.Title(EmailConnectionErr);
                        ErrorAccountNotConnecting.Message(StrSubstNo(EmailConnectionMessageErr, PASetupConfiguration.GetEmailAccount()."Email Address"));
                        ErrorAccountNotConnecting.PageNo := Page::"Email Accounts";
                        ErrorAccountNotConnecting.AddNavigationAction(EmailConnectionNavigationActionLbl);
                        Error(ErrorAccountNotConnecting);
                    end;
                end;
            end;

        if OutlookSetupExistedPreviously then // Write transaction should start here
            OutlookSetup.Modify()
        else
            OutlookSetup.Insert();

        // We apply the changes to the "Payables Agent Setup" record
        PayablesAgentSetup.GetSetup();
        TempPayablesAgentSetup := PASetupConfiguration.GetPayablesAgentSetup();
        PayablesAgentSetup.TransferFields(TempPayablesAgentSetup, false);

        if not PASetupConfiguration.GetSkipAgentConfiguration() then // Skipping the agent's configuration is valid in tests
            PayablesAgentSetup."User Security Id" := ApplyAgentSetup(PASetupConfiguration);

        // We apply the changes to the E-Document Service related records
        PayablesAgentSetup."E-Document Service Code" := ApplyEDocumentServiceSetup(PASetupConfiguration, EmailAccountChanged);
        PayablesAgentSetup.Modify();

        EDocPOMatching.ConfigureDefaultPOMatchingSettings();
        PADemoGuide.SendDemoEmail(PASetupConfiguration);
    end;

    procedure GetOrCreateAgentEDocumentService() EDocumentService: Record "E-Document Service"
    begin
        if not EDocumentService.Get(PayablesAgentEDocServiceTok) then begin
            EDocumentService.Code := PayablesAgentEDocServiceTok;
            EDocumentService.Insert(true);
        end;
    end;

    procedure WasEDocumentCreatedByAgent(EDocument: Record "E-Document"): Boolean
    begin
        exit(EDocument.GetEDocumentService().Code = PayablesAgentEDocServiceTok);
    end;

    /// <summary>
    /// Retrieves the agent record if configured in the database, and ensures that the Payables Agent setup record is updated with the correct user security id. 
    /// </summary>
    /// <param name="Agent">Record where the Agent is loaded, if it exists</param>
    /// <returns>True if an Agent was found, false otherwise</returns>
    procedure GetAgent(var Agent: Record Agent): Boolean
    var
        PayablesAgentSetup: Record "Payables Agent Setup";
    begin
        PayablesAgentSetup.GetSetup();
        // We attempt to find the agent by the security id stored in the setup record.
        if Agent.Get(PayablesAgentSetup."User Security Id") then
            exit(true);
        // If the agent could not be found, and there was a user security id configured, we need to clear it, since it is not valid anymore.
        if not IsNullGuid(PayablesAgentSetup."User Security Id") then
            Clear(PayablesAgentSetup."User Security Id");
        // If the agent could not be found from the configured security id, we attempt to find it by the user name.
        Agent.SetRange("User Name", AgentUserName());
        if Agent.FindFirst() then
            PayablesAgentSetup."User Security Id" := Agent."User Security ID";
        PayablesAgentSetup.Modify();
        exit(not IsNullGuid(Agent."User Security ID"));
    end;

    internal procedure SetAgentInstructions(AgentUserSecurityId: Guid)
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        Agent: Codeunit Agent;
        SecurityPromptSecretText, CompletePromptSecretText : SecretText;
        PayablesAgentPromptText: Text;
        PayablesAgentPromptTok: Label 'Prompts/PayablesAgent-SystemPrompt.md', Locked = true;
        SecurityPromptTok: Label 'PayablesAgent-SecurityPromptV280', Locked = true;
        UnableToConfigureAgentInstructionsErr: Label 'Unable to configure agent instructions.';
    begin
        if IsNullGuid(AgentUserSecurityId) then
            exit;

        PayablesAgentPromptText := NavApp.GetResourceAsText(PayablesAgentPromptTok, TextEncoding::UTF8);
        if AzureKeyVault.GetAzureKeyVaultSecret(SecurityPromptTok, SecurityPromptSecretText) then
            CompletePromptSecretText := SecretText.SecretStrSubstNo(PayablesAgentPromptText, SecurityPromptSecretText)
        else begin
            Session.LogMessage('0000QPX', 'Failed to retrieve security prompt', Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
            Error(UnableToConfigureAgentInstructionsErr);
        end;
        Agent.SetInstructions(AgentUserSecurityId, CompletePromptSecretText);
    end;

    internal procedure AllowCreateNewAgent(): Boolean
    var
        PayableAgentSetup: Record "Payables Agent Setup";
        Agent: Record Agent;
        AgentSystemPermissions: Codeunit "Agent System Permissions";
    begin
        if not AgentSystemPermissions.CurrentUserHasCanManageAllAgentsPermission() then
            // Limit agent creation to agent admins.
            exit(false);

        // If there is no setup record, we can create a new payables agent
        if not PayableAgentSetup.FindFirst() then
            exit(true);
        // The setup record can be created without an agent linked to it (for example, when launching the setup page)
        // Therefore we need to check if there is an agent linked to the setup record
        Agent.SetRange("User Security ID", PayableAgentSetup."User Security Id");
        // If there is no agent linked to the setup record, we can create a new payables agent
        exit(Agent.IsEmpty());
    end;

    internal procedure AgentUserName(): Code[50]
    begin
        exit(CopyStr(AgentUserNameLbl + ' - ' + CompanyName(), 1, 50));
    end;

    internal procedure AgentDisplayName(): Text[80]
    begin
        exit(CopyStr(AgentDisplayNameLbl, 1, 80));
    end;

    internal procedure AgentSummary(): Text
    begin
        exit(AgentSummaryLbl);
    end;

    local procedure ApplyAgentSetup(var PASetupConfiguration: Codeunit "PA Setup Configuration"): Guid
    var
        AgentAdminPS: Record "Aggregate Permission Set";
        AccessControl: Record "Access Control";
        TempModifiedAgentAccessControl: Record "Agent Access Control" temporary;
        TempAgentSetupBuffer: Record "Agent Setup Buffer";
        AgentSetup: Codeunit "Agent Setup";
        UserPermissions: Codeunit "User Permissions";
        CurrentModuleInfo: ModuleInfo;
        AgentUserId: Guid;
        AgentAdminPermissionSetTok: Label 'Payables Ag. - Adm.', Locked = true;
    begin
        PASetupConfiguration.GetAgentSetupBuffer(TempAgentSetupBuffer);
        AgentUserId := AgentSetup.SaveChanges(TempAgentSetupBuffer);
        // We assign the necessary permission sets to the users depending on whether or not users are able to modify the agent
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        Clear(AgentAdminPS);
        AgentAdminPS.SetRange("App ID", CurrentModuleInfo.Id);
        AgentAdminPS.SetRange("Role ID", AgentAdminPermissionSetTok);
        AgentAdminPS.FindFirst();
        Clear(TempModifiedAgentAccessControl);
        if TempModifiedAgentAccessControl.FindSet() then
            repeat
                if TempModifiedAgentAccessControl."Can Configure Agent" then
                    if (not UserPermissions.IsSuper(TempModifiedAgentAccessControl."User Security ID")) and (not UserPermissions.HasUserPermissionSetAssigned(TempModifiedAgentAccessControl."User Security ID", CompanyName(), AgentAdminPermissionSetTok, AccessControl.Scope::System, CurrentModuleInfo.Id)) then
                        // If the user is allowed to configure the agent, we assign the admin permission set
                        UserPermissions.AssignPermissionSets(TempModifiedAgentAccessControl."User Security ID", CompanyName(), AgentAdminPS);
            until TempModifiedAgentAccessControl.Next() = 0;

        SetAgentInstructions(AgentUserId);
        exit(AgentUserId);
    end;

    local procedure ApplyEDocumentServiceSetup(var PASetupConfiguration: Codeunit "PA Setup Configuration"; ReactivateAutoImport: Boolean): Code[20]
    var
        EDocumentService: Record "E-Document Service";
        OutlookSetup: Record "Outlook Setup";
    begin
        // If we intend to disable the agent, we need to disable the E-Document Service's auto-import as well
        if PASetupConfiguration.GetAgentSetupBuffer().State = PASetupConfiguration.GetAgentSetupBuffer().State::Disabled then begin
            if EDocumentService.Get(PayablesAgentEDocServiceTok) then begin
                EDocumentService.Validate("Auto Import", false);
                EDocumentService.Modify();
            end;
            exit(PayablesAgentEDocServiceTok);
        end;
        EDocumentService := GetOrCreateAgentEDocumentService();
        // We configure the default E-Document Service settings
        EDocumentService.Validate("Service Integration V2", "Service Integration"::Outlook);
        EDocumentService.Validate("Automatic Import Processing", "E-Doc. Automatic Processing"::No);
        EDocumentService.Validate("Import Process", "E-Document Import Process"::"Version 2.0");
        Clear(EDocumentService."Import Start Time");
        EDocumentService."Import Minutes between runs" := 1;
        EDocumentService."Verify Purch. Total Amounts" := true;
        EDocumentService.Modify();
        if ReactivateAutoImport then
            EDocumentService.Validate("Auto Import", false);
        // If monitoring outlook is requested, we set auto-import in the service and configure the Outlook Setup
        if PASetupConfiguration.GetPayablesAgentSetup()."Monitor Outlook" then begin
            EDocumentService.Validate("Auto Import", true);
            OutlookSetup.FindFirst();
            OutlookSetup.Validate(Enabled, true);
            OutlookSetup.Modify();
        end
        else
            EDocumentService.Validate("Auto Import", false);
        EDocumentService.Modify();
        exit(PayablesAgentEDocServiceTok);
    end;

    internal procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    var
        Agent: Codeunit Agent;
        ModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        Agent.PopulateDefaultProfile(PayablesAgentProfileTok, ModuleInfo.Id, TempAllProfile);
    end;

    internal procedure GetDefaultAccessControls(var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    var
        ModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        TempAccessControlBuffer.Init();
        TempAccessControlBuffer."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(TempAccessControlBuffer."Company Name"));
        TempAccessControlBuffer.Scope := TempAccessControlBuffer.Scope::System;
        TempAccessControlBuffer."App ID" := ModuleInfo.Id;
        TempAccessControlBuffer."Role ID" := PayablesAgentPermissionSetTok;
        TempAccessControlBuffer.Insert();
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure HandleOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        PayablesAgentSetup: Record "Payables Agent Setup";
        PayablesAgentKPI: Record "Payables Agent KPI";
    begin
        PayablesAgentSetup.ChangeCompany(NewCompanyName);
        PayablesAgentSetup.DeleteAll();

        PayablesAgentKPI.ChangeCompany(NewCompanyName);
        PayablesAgentKPI.DeleteAll();
    end;

    internal procedure FeatureName(): Text
    begin
        exit(PayablesAgentTelemetryTok);
    end;

    var
        AgentUserNameLbl: Label 'Payables Agent', Comment = 'User name of the agent.', Locked = true;
        AgentSummaryLbl: Label 'Monitors incoming emails for vendor invoices, matches senders to registered vendors, and creates purchase document drafts for review.';
        AgentDisplayNameLbl: Label 'Payables Agent', Locked = true, Comment = 'Display name of the agent.';
        PayablesAgentTelemetryTok: Label 'Payables Agent', Locked = true;
        PayablesAgentEDocServiceTok: Label 'AGENT', Locked = true;
        PayablesAgentProfileTok: Label 'Payables Agent', Locked = true;
        PayablesAgentPermissionSetTok: Label 'Payables Ag. - Run', Locked = true;
}
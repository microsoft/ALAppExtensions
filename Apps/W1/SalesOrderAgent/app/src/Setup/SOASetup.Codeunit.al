// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.CRM.Contact;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using System.Agents;
using System.Azure.Identity;
using System.Email;
using System.Environment;
using System.Environment.Configuration;
using System.Globalization;
using System.Reflection;
using System.Security.AccessControl;

#pragma warning disable AS0049
codeunit 4400 "SOA Setup"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Email Inbox" = rd;
#pragma warning restore AS0049

    /// <summary>
    /// Used for testing OnPrem
    /// </summary>
    [Scope('OnPrem')]
    procedure CreateDefaultAgentNoEmail()
    var
        TempAgentAccessControl: Record "Agent Access Control" temporary;
        TempSOASetup: Record "SOA Setup" temporary;
        TempAgent: Record Agent temporary;
        TempEmailAccount: Record "Email Account" temporary;
    begin
        GetAgent(TempAgent);
        TempAgent.State := TempAgent.State::Enabled;
        GetDefaultSOASetup(TempSOASetup, TempAgent);
        TempSOASetup."Email Monitoring" := false;

        GetDefaultAgentAccessControl(TempAgent."User Security ID", TempAgentAccessControl);
        UpdateAgent(TempAgent, TempAgentAccessControl, TempSOASetup, TempEmailAccount, true, true);
    end;

    internal procedure CreateAgent(var TempAgent: Record Agent; var TempAgentAccessControl: Record "Agent Access Control" temporary; var TempSOASetup: Record "SOA Setup" temporary; var TempEmailAccount: Record "Email Account" temporary)
    var
        AllProfile: Record "All Profile";
    begin
        TempSOASetup."Agent User Security ID" := Agent.Create("Agent Metadata Provider"::"SO Agent", TempAgent."User Name", TempAgent."Display Name", TempAgentAccessControl);
        UpdateInstructions(TempSOASetup);

        // TODO(qutreson) Remove this in favor System Application.
        GetProfile(AllProfile);
        Agent.SetProfile(TempSOASetup."Agent User Security ID", AllProfile);

        if TempAgent.State = TempAgent.State::Enabled then
            UpdateSOASetupActivationDT(TempSOASetup);
        UpdateSOASetup(TempSOASetup);

        if TempAgent.State = TempAgent.State::Enabled then begin
            EnableItemSearch();
            Agent.Activate(TempSOASetup."Agent User Security ID");
            if TempSOASetup."Email Monitoring" and TempSOASetup."Incoming Monitoring" and not IsNullGuid(TempSOASetup."Email Account ID") then
                SOAImpl.ScheduleSOAgent(TempSOASetup)
        end
        else
            Agent.Deactivate(TempSOASetup."Agent User Security ID");
    end;

    internal procedure GetInitials(): Text[4]
    begin
        exit(SalesOrderAgentInitialLbl);
    end;

    internal procedure GetAgentType(): Text
    begin
        exit(SalesOrderAgentTypeLbl);
    end;

    internal procedure GetAgentSummary(): Text
    begin
        exit(SOASummaryLbl);
    end;

    internal procedure AllowCreateNewSOAgent(): Boolean
    var
        SOASetup: Record "SOA Setup";
    begin
        SOASetup.Init();
        SOASetup.SetAutoCalcFields(SOASetup.Exists);
        SOASetup.SetRange(SOASetup.Exists, true);
        exit(SOASetup.IsEmpty());
    end;

    internal procedure UpdateAgent(var TempAgent: Record Agent; var TempAgentAccessControl: Record "Agent Access Control" temporary; var TempSOASetup: Record "SOA Setup" temporary; var TempEmailAccount: Record "Email Account" temporary; AccessUpdated: Boolean; Schedule: Boolean)
    var
        AzureADGraphUser: Codeunit "Azure AD Graph User";
    begin
        if AzureADGraphUser.IsUserDelegatedAdmin() or AzureADGraphUser.IsUserDelegatedHelpdesk() then
            Error(DelegateAdminErr);

        if IsNullGuid(TempAgent."User Security ID") then begin
            CreateAgent(TempAgent, TempAgentAccessControl, TempSOASetup, TempEmailAccount);
            exit;
        end;

        if TempAgent.State = TempAgent.State::Enabled then begin
            UpdateSOASetupActivationDT(TempSOASetup);
            UpdateInstructions(TempSOASetup);
        end;

        Agent.SetDisplayName(TempAgent."User Security ID", TempAgent."Display Name");
        if TempAgent.State = TempAgent.State::Enabled then begin
            Agent.Activate(TempAgent."User Security ID");
            EnableItemSearch();
            if TempSOASetup."Email Monitoring" and TempSOASetup."Incoming Monitoring" and not IsNullGuid(TempSOASetup."Email Account ID") and Schedule then
                SOAImpl.ScheduleSOAgent(TempSOASetup);
        end
        else begin
            Agent.Deactivate(TempAgent."User Security ID");
            SOAImpl.RemoveScheduledTask(TempSOASetup);
        end;
        UpdateSOASetup(TempSOASetup);

        if AccessUpdated then
            Agent.UpdateAccess(TempAgent."User Security ID", TempAgentAccessControl);
    end;

    local procedure UpdateSOASetup(var TempSOASetup: Record "SOA Setup" temporary)
    var
        SOASetup: Record "SOA Setup";
    begin
        if SOASetup.GetBasedOnAgentUserSecurityID(TempSOASetup."Agent User Security ID", false) then begin
            SOASetup."Incoming Monitoring" := TempSOASetup."Incoming Monitoring";
            SOASetup."Email Monitoring" := TempSOASetup."Email Monitoring";
            if SOASetup."Email Monitoring" then begin
                SOASetup."Email Account ID" := TempSOASetup."Email Account ID";
                SOASetup."Email Connector" := TempSOASetup."Email Connector";
                SOASetup."Email Address" := TempSOASetup."Email Address";
            end;

            SOASetup."Activated At" := TempSOASetup."Activated At";
            SOASetup."Earliest Sync At" := TempSOASetup."Earliest Sync At";
            SOASetup."Last Sync At" := TempSOASetup."Last Sync At";
            SOASetup."Sales Doc. Configuration" := TempSOASetup."Sales Doc. Configuration";
            SOASetup."Quote Review" := TempSOASetup."Quote Review";
            SOASetup."Order Review" := TempSOASetup."Order Review";
            SOASetup."Create Order from Quote" := TempSOASetup."Create Order from Quote";
            SOASetup."Search Only Available Items" := TempSOASetup."Search Only Available Items";
            SOASetup."Incl. Capable to Promise" := TempSOASetup."Incl. Capable to Promise";
            SOASetup."Agent Scheduled Task ID" := TempSOASetup."Agent Scheduled Task ID";
            SOASetup."Recovery Scheduled Task ID" := TempSOASetup."Recovery Scheduled Task ID";
            SOASetup."Known Sender In. Msg. Review" := TempSOASetup."Known Sender In. Msg. Review";
            SOASetup."Unknown Sender In. Msg. Review" := TempSOASetup."Unknown Sender In. Msg. Review";
            SOASetup."Instructions Last Sync At" := TempSOASetup."Instructions Last Sync At";

            SOASetup.Modify();
        end
        else begin
            SOASetup.Copy(TempSOASetup);
            SOASetup.Insert();
            TempSOASetup := SOASetup;
            TempSOASetup.Insert();
        end;
    end;

    local procedure SetDefaultSalesDocConfig(var SOASetup: Record "SOA Setup"; SalesDocConfigValue: Boolean)
    begin
        SOASetup."Sales Doc. Configuration" := SalesDocConfigValue;
        SOASetup."Quote Review" := false;
        SOASetup."Order Review" := false;
        SOASetup."Create Order from Quote" := true;
        SOASetup."Search Only Available Items" := true;
        SOASetup."Incl. Capable to Promise" := false;
    end;

    internal procedure UpdateInstructions(var TempSOASetup: Record "SOA Setup" temporary)
    var
        SOAPromptBuilder: Codeunit "SOA Prompt Builder";
        InstructionsSecret: SecretText;
    begin
        SOAPromptBuilder.PrepareInstructions(InstructionsSecret, TempSOASetup);
        Agent.SetInstructions(TempSOASetup."Agent User Security ID", InstructionsSecret);
        TempSOASetup."Instructions Last Sync At" := CurrentDateTime();
    end;

    internal procedure InstructionsSyncRequired(var SOASetup: Record "SOA Setup"): Boolean
    var
        CurrentSOASetup: Record "SOA Setup";
    begin
        CurrentSOASetup.ReadIsolation := IsolationLevel::ReadCommitted;
        if not CurrentSOASetup.Get(SOASetup.RecordId) then
            exit(true);

        if CurrentSOASetup."Instructions Last Sync At" = 0DT then
            exit(true);

        if CurrentDateTime > CurrentSOASetup."Instructions Last Sync At" + GetSOAInstructionsSyncPeriod() then //last sync was more than 30 minutes ago
            exit(true);

        exit(false);
    end;

    internal procedure UpdateSOASetupInstructionsLastSync(var SOASetup: Record "SOA Setup")
    var
        CurrentSOASetup: Record "SOA Setup";
    begin
        if not CurrentSOASetup.Get(SOASetup.RecordId) then
            exit;

        CurrentSOASetup."Instructions Last Sync At" := SOASetup."Instructions Last Sync At";
        CurrentSOASetup.Modify();
    end;

    local procedure GetSOAInstructionsSyncPeriod(): Integer
    begin
        exit(1800000); // 30 minutes
    end;

    internal procedure UpdateSOASetupActivationDT(var TempSOASetup: Record "SOA Setup" temporary)
    begin
        TempSOASetup."Activated At" := CurrentDateTime();
    end;

    local procedure EnableItemSearch()
    var
        ItemSearch: Codeunit "Global Item Search";
    begin
        ItemSearch.EnableItemSearch();
    end;

    internal procedure GetDefaultAgentAccessControl(AgentUserSecurityID: Guid; var TempAgentAccessControl: Record "Agent Access Control" temporary)
    var
        Agents: Codeunit Agent;
    begin
        if IsNullGuid(AgentUserSecurityID) then
            exit;
        Agents.GetUserAccess(AgentUserSecurityID, TempAgentAccessControl);
    end;

    internal procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    var
        ModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        TempAllProfile.Init();
        TempAllProfile.Scope := TempAllProfile.Scope::Tenant;
        TempAllProfile."App ID" := ModuleInfo.Id;
        TempAllProfile."Profile ID" := SalesOrderAgentTok;
        TempAllProfile.Insert();
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
        TempAccessControlBuffer."Role ID" := SOAEditTok;
        TempAccessControlBuffer.Insert();
    end;

    internal procedure GetAgent(var TempSOAgent: Record Agent temporary)
    var
        Agents: Record Agent;
    begin
        if IsNullGuid(TempSOAgent."User Security ID") then begin
            Agents.SetRange("User Name", GetSOAUsername());
            Agents.SetRange("Display Name", SalesOrderAgentDisplayNameLbl);
            if Agents.FindFirst() then begin
                TempSOAgent := Agents;
                TempSOAgent.Insert();
                exit;
            end
            else
                SetAgentDefaults(TempSOAgent);
        end else begin
            Agents.Get(TempSOAgent."User Security ID");
            TempSOAgent.TransferFields(Agents, true);
        end;
    end;

    internal procedure GetDefaultSOASetup(var TempSOASetup: Record "SOA Setup" temporary; var TempSOAgent: Record Agent temporary)
    var
        SOASetup: Record "SOA Setup";
    begin
        if IsNullGuid(TempSOASetup."Agent User Security ID") then
            if SOASetup.FindFirst() then begin
                TempSOASetup := SOASetup;
                TempSOASetup.Insert();
            end
            else
                SetSOASetupDefaults(TempSOASetup, TempSOAgent."User Security ID")
        else
            if SOASetup.GetBasedOnAgentUserSecurityID(TempSOASetup."Agent User Security ID", false) then begin
                TempSOASetup := SOASetup;
                TempSOASetup.Insert();
            end
            else
                SetSOASetupDefaults(TempSOASetup, TempSOAgent."User Security ID");
    end;

    internal procedure CheckSOASetupStillValid(var SOASetup: Record "SOA Setup"): Boolean
    var
        CurrentSOASetup: Record "SOA Setup";
    begin
        CurrentSOASetup.ReadIsolation := IsolationLevel::ReadCommitted;
        CurrentSOASetup.SetAutoCalcFields(State);
        if not CurrentSOASetup.Get(SOASetup.RecordId) then
            exit(false);

        if not (CurrentSOASetup.State = CurrentSOASetup.State::Enabled) then
            exit(false);

        if SOASetup."Email Account ID" <> CurrentSOASetup."Email Account ID" then
            exit(false);

        exit(true);
    end;

    internal procedure GetEmailAccount(var SOASetup: Record "SOA Setup"; var TempEmailAccount: Record "Email Account" temporary)
    var
        TempAllEmailAccounts: Record "Email Account" temporary;
        EmailAccount: Codeunit "Email Account";
    begin
        EmailAccount.GetAllAccounts(false, TempAllEmailAccounts);
        TempAllEmailAccounts.SetRange("Account Id", SOASetup."Email Account ID");
        TempAllEmailAccounts.SetRange(Connector, SOASetup."Email Connector");
        if TempAllEmailAccounts.FindFirst() then
            TempEmailAccount.Copy(TempAllEmailAccounts);
    end;

    internal procedure GetDefaultEmailAccount(var TempEmailAccount: Record "Email Account" temporary)
    var
        EmailAccount: Codeunit "Email Account";
    begin
        EmailAccount.GetAllAccounts(false, TempEmailAccount);
        if TempEmailAccount.FindFirst() then;
    end;

    internal procedure GetAgentTaskUserInterventionSuggestions(AgentTaskUserInterventionRequestDetails: Record "Agent User Int Request Details"; var AgentTaskUserInterventionSuggestion: Record "Agent Task User Int Suggestion")
    begin
        Clear(AgentTaskUserInterventionSuggestion);

        case AgentTaskUserInterventionRequestDetails.Type of
            AgentTaskUserInterventionRequestDetails.Type::ReviewMessage:
                begin
                    if (AgentTaskUserInterventionRequestDetails."Page ID" = Page::"Sales Quote") then begin
                        AgentTaskUserInterventionSuggestion.Init();
                        AgentTaskUserInterventionSuggestion.Summary := StrSubstNo(SOAInterventionSuggestionSummaryLbl, SOAInterventionSuggestionQuoteLbl);
                        AgentTaskUserInterventionSuggestion.Description := StrSubstNo(SOAInterventionSuggestionDescriptionLbl, SOAInterventionSuggestionQuoteLockedLbl);
                        AgentTaskUserInterventionSuggestion.Instructions := StrSubstNo(SOAInterventionSuggestionInstructionsLbl, SOAInterventionSuggestionQuoteLockedLbl);
                        AgentTaskUserInterventionSuggestion.Insert();
                    end;

                    if (AgentTaskUserInterventionRequestDetails."Page ID" = Page::"Sales Order") then begin
                        AgentTaskUserInterventionSuggestion.Init();
                        AgentTaskUserInterventionSuggestion.Summary := StrSubstNo(SOAInterventionSuggestionSummaryLbl, SOAInterventionSuggestionOrderLbl);
                        AgentTaskUserInterventionSuggestion.Description := StrSubstNo(SOAInterventionSuggestionDescriptionLbl, SOAInterventionSuggestionOrderLockedLbl);
                        AgentTaskUserInterventionSuggestion.Instructions := StrSubstNo(SOAInterventionSuggestionInstructionsLbl, SOAInterventionSuggestionOrderLockedLbl);
                        AgentTaskUserInterventionSuggestion.Insert();
                    end;
                end;
            AgentTaskUserInterventionRequestDetails.Type::Assistance:
                begin
                    if AgentTaskUserInterventionRequestDetails."Page ID" = Page::"SOA Multi Items Availability" then begin
                        AgentTaskUserInterventionSuggestion.Init();
                        AgentTaskUserInterventionSuggestion.Summary := SOAItemAvailabilityInterventionSuggestionSummaryLbl;
                        AgentTaskUserInterventionSuggestion.Description := SOAItemAvailabilityInterventionSuggestionDescriptionLbl;
                        AgentTaskUserInterventionSuggestion.Instructions := SOAItemAvailabilityInterventionSuggestionInstructionsLbl;
                        AgentTaskUserInterventionSuggestion.Insert();
                    end;

                    if AgentTaskUserInterventionRequestDetails."Page ID" = Page::"Customer List" then begin
                        AgentTaskUserInterventionSuggestion.Init();
                        AgentTaskUserInterventionSuggestion.Summary := SOACustomerInterventionSuggestionSummaryLbl;
                        AgentTaskUserInterventionSuggestion.Description := SOACustomerInterventionSuggestionDescriptionLbl;
                        AgentTaskUserInterventionSuggestion.Instructions := SOACustomerInterventionSuggestionInstructionsLbl;
                        AgentTaskUserInterventionSuggestion.Insert();

                        AgentTaskUserInterventionSuggestion.Init();
                        AgentTaskUserInterventionSuggestion.Summary := SOAContactInterventionSuggestionSummaryLbl;
                        AgentTaskUserInterventionSuggestion.Description := SOAContactInterventionSuggestionDescriptionLbl;
                        AgentTaskUserInterventionSuggestion.Instructions := SOAContactInterventionSuggestionInstructionsLbl;
                        AgentTaskUserInterventionSuggestion.Insert();
                    end;

                    if AgentTaskUserInterventionRequestDetails."Page ID" = Page::"Contact List" then begin
                        AgentTaskUserInterventionSuggestion.Init();
                        AgentTaskUserInterventionSuggestion.Summary := SOAContactInterventionSuggestionSummaryLbl;
                        AgentTaskUserInterventionSuggestion.Description := SOAContactInterventionSuggestionDescriptionLbl;
                        AgentTaskUserInterventionSuggestion.Instructions := SOAContactInterventionSuggestionInstructionsLbl;
                        AgentTaskUserInterventionSuggestion.Insert();
                    end;
                end;
        end;
    end;

    internal procedure GetAgentTaskPageContext(AgentTaskPageContextRequest: Record "Agent Task Page Context Req."; var AgentTaskPageContext: Record "Agent Task Page Context")
    var
        Contact: Record Contact;
        Currency: Record Currency;
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        LanguageSelection: Record "Language Selection";
        Language: Codeunit Language;
        SOAFiltersImpl: Codeunit "SOA Filters Impl.";
        CustomerFilter: Text;
        CurrencyCode: Code[10];
        LanguageID: Integer;
        FormatID: Integer;
        LanguageCode: Code[10];
        FormatRegion: Text[80];
    begin
        Clear(AgentTaskPageContext);

        case AgentTaskPageContextRequest."Page ID" of
            Page::"Sales Quote",
            Page::"Sales Order":
                if SalesHeader.Get(AgentTaskPageContextRequest."Record ID") then
                    CurrencyCode := SalesHeader."Currency Code";
            Page::"Contact Card":
                if Contact.Get(AgentTaskPageContextRequest."Record ID") then begin
                    if Contact.Type = Contact.Type::Person then
                        if Contact.Get(Contact."Company No.") then;
                    CurrencyCode := Contact."Currency Code";
                end;
            Page::"Customer Card":
                if Customer.Get(AgentTaskPageContextRequest."Record ID") then
                    CurrencyCode := Customer."Currency Code";
            Page::"SOA Multi Items Availability":
                begin
                    CustomerFilter := SOAFiltersImpl.GetSecurityFiltersForCustomers(SOAFiltersImpl.GetSecurityFiltersForContacts(AgentTaskPageContextRequest."Task ID"));
                    if CustomerFilter <> '' then begin
                        Customer.SetFilter("No.", CustomerFilter);
                        if Customer.FindFirst() then
                            CurrencyCode := Customer."Currency Code";
                    end;
                end;
        end;

        GetCommunicationLanguageCodeAndFormat(AgentTaskPageContextRequest."Task ID", LanguageCode, FormatRegion);
        if LanguageCode <> '' then
            LanguageID := Language.GetLanguageId(LanguageCode);
        if FormatRegion <> '' then begin
            LanguageSelection.SetRange("Language Tag", FormatRegion);
            if LanguageSelection.FindFirst() then
                FormatID := LanguageSelection."Language ID";
        end;

        if CurrencyCode <> '' then begin
            if Currency.Get(CurrencyCode) then
                SetAgentTaskPageContext(Currency.Code, Currency.GetCurrencySymbol(), LanguageID, FormatID, AgentTaskPageContext)
        end else
            if GeneralLedgerSetup.Get() then
                SetAgentTaskPageContext(GeneralLedgerSetup."LCY Code", GeneralLedgerSetup.GetCurrencySymbol(), LanguageID, FormatID, AgentTaskPageContext);
    end;

    /// <summary>
    /// By priority: from the contact card, from the customer card, or from the user settings.
    /// </summary>
    internal procedure GetCommunicationLanguageCodeAndFormat(AgentTaskId: BigInteger; var LanguageCode: Code[10]; var FormatRegion: Text[80])
    var
        TaskContact: Record "Contact";
        TaskCustomer: Record Customer;
        SOAFiltersImpl: Codeunit "SOA Filters Impl.";
        CustomerFilter: Text;
        ContactFilter: Text;
    begin
        ContactFilter := SOAFiltersImpl.GetSecurityFiltersForContacts(AgentTaskID);

        if ContactFilter <> '' then begin
            CustomerFilter := SOAFiltersImpl.GetSecurityFiltersForCustomers(ContactFilter);
            TaskContact.SetFilter("No.", ContactFilter);
            if TaskContact.FindFirst() then begin
                LanguageCode := TaskContact."Language Code";
                FormatRegion := TaskContact."Format Region";
            end;
        end;

        if (CustomerFilter <> '') and (CustomerFilter <> SOAFiltersImpl.GetExcludeAllFilter()) then begin
            TaskCustomer.SetFilter("No.", CustomerFilter);
            if TaskCustomer.FindFirst() then begin
                if (LanguageCode = '') then
                    LanguageCode := TaskCustomer."Language Code";
                if (FormatRegion = '') then
                    FormatRegion := TaskCustomer."Format Region";
            end;
        end;
    end;

    local procedure SetAgentTaskPageContext(CurrencyCode: Code[10]; CurrencySymbol: Code[10]; LanguageID: Integer; FormatID: Integer; var AgentTaskPageContext: Record "Agent Task Page Context")
    begin
        Clear(AgentTaskPageContext);
        AgentTaskPageContext."Currency Code" := CurrencyCode;
        AgentTaskPageContext."Currency Symbol" := CurrencySymbol;
        AgentTaskPageContext."Communication Language LCID" := LanguageID;
        AgentTaskPageContext."Communication Format LCID" := FormatID;
        AgentTaskPageContext.Insert();
    end;

    local procedure SetSOASetupDefaults(var TempSOASetup: Record "SOA Setup" temporary; AgentUserSecurityID: Guid)
    begin
        TempSOASetup.Init();
        TempSOASetup."Incoming Monitoring" := true;
        TempSOASetup."Email Monitoring" := true;
        SetDefaultSalesDocConfig(TempSOASetup, true);
        TempSOASetup."Agent User Security ID" := AgentUserSecurityID;
        TempSOASetup.Insert();
    end;

    local procedure SetAgentDefaults(var TempSOAgent: Record Agent temporary)
    begin
        TempSOAgent.Init();
        TempSOAgent."User Name" := GetSOAUsername();
        TempSOAgent."Display Name" := SalesOrderAgentDisplayNameLbl;
        TempSOAgent.Insert();
    end;

    local procedure GetProfile(var AllProfile: Record "All Profile")
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CurrentModuleInfo);
        AllProfile.Get(AllProfile.Scope::Tenant, CurrentModuleInfo.Id, SalesOrderAgentTok);
    end;

    local procedure GetSOAUsername(): Text[50]
    begin
        exit(SalesOrderAgentNameLbl + ' - ' + CompanyName());
    end;

    internal procedure ValidateEmailConnectionStatus(var TempSOASetup: Record "SOA Setup" temporary) ConnectionSuccess: Boolean
    var
        SOATestSetup: Codeunit "SOA Test Setup";
    begin
        SOATestSetup.SetTestEmailConnection(true);
        ConnectionSuccess := SOATestSetup.Run(TempSOASetup);
    end;

    internal procedure ValidateEmailConnection(StateChanged: Boolean; var TempSOASetup: Record "SOA Setup" temporary)
    var
        NAVAppSettings: Record "NAV App Setting";
        EnvironmentInformation: Codeunit "Environment Information";
        CurrentModuleInfo: ModuleInfo;
        GeneralError: Boolean;
    begin
        if TempSOASetup."Incoming Monitoring" and TempSOASetup."Email Monitoring" and not IsNullGuid(TempSOASetup."Email Account ID") then begin
            if StateChanged then
                UpdateSyncDateTime(TempSOASetup);

            if ValidateEmailConnectionStatus(TempSOASetup) then
                exit;

            if GuiAllowed() then begin
                GeneralError := true;
                if EnvironmentInformation.IsSandbox() then begin
                    NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
                    NAVAppSettings.ReadIsolation(IsolationLevel::ReadUncommitted);
                    NAVAppSettings.SetRange("App ID", CurrentModuleInfo.Id);
                    if NAVAppSettings.FindFirst() then
                        if NAVAppSettings."Allow HttpClient Requests" = false then begin
                            GeneralError := false;
                            Error(SOAAttemptedConnectionHttpRequestFailedErr);
                        end;
                end;

                if GeneralError then
                    Error(SOAAttemptedConnectionFailedErr);
            end;
        end;
    end;

    local procedure UpdateSyncDateTime(var TempSOASetup: Record "SOA Setup" temporary)
    var
        SOAEmailSetup: Codeunit "SOA Email Setup";
        EmailsCount: Integer;
        ConfirmMessage: Text;
    begin
        // First activation
        if TempSOASetup."Activated At" = 0DT then begin
            TempSOASetup."Earliest Sync At" := CurrentDateTime();
            TempSOASetup."Last Sync At" := TempSOASetup."Earliest Sync At";
            exit;
        end;

        EmailsCount := GetEmailsCount(TempSOASetup);

        if EmailsCount = 0 then begin
            TempSOASetup."Earliest Sync At" := CurrentDateTime();
            TempSOASetup."Last Sync At" := TempSOASetup."Earliest Sync At";
            exit;
        end;

        if EmailsCount < SOAEmailSetup.GetMaxNoOfEmails() then
            ConfirmMessage := StrSubstNo(NewEmailsSinceDeactivationLbl, Format(EmailsCount), Format(TempSOASetup."Last Sync At"))
        else
            ConfirmMessage := StrSubstNo(NewEmailsSinceDeactivationLbl, Format(EmailsCount) + '+', Format(TempSOASetup."Last Sync At"));

        if Confirm(ConfirmMessage, true) then
            TempSOASetup."Earliest Sync At" := TempSOASetup."Activated At"
        else
            TempSOASetup."Earliest Sync At" := CurrentDateTime();
        TempSOASetup."Last Sync At" := TempSOASetup."Earliest Sync At";
    end;

    local procedure GetEmailsCount(var TempSOASetup: Record "SOA Setup" temporary) EmailsCount: Integer
    var
        SOATestSetup: Codeunit "SOA Test Setup";
    begin
        SOATestSetup.SetTestEmailCount(true);
        if SOATestSetup.Run(TempSOASetup) then;
        EmailsCount := SOATestSetup.GetEmailCount();
    end;

    var
        SOAImpl: Codeunit "SOA Impl";
        Agent: Codeunit Agent;
        SalesOrderAgentNameLbl: Label 'SALES ORDER AGENT', MaxLength = 17;
        SalesOrderAgentDisplayNameLbl: Label 'Sales Order Agent', MaxLength = 80;
        SalesOrderAgentTypeLbl: Label 'By Microsoft';
        SOAEditTok: Label 'SOA - EDIT', Locked = true, MaxLength = 20;
        SalesOrderAgentTok: Label 'Sales Order Agent', Locked = true;
        SalesOrderAgentInitialLbl: Label 'SO', MaxLength = 4;
        SOASummaryLbl: Label 'Monitors incoming emails for sales inquiries, matches senders to customers, checks inventory, and creates quotes. When processing replies, the agent converts accepted quotes into orders. This agent uses generative AI—review its actions for accuracy.';
        DelegateAdminErr: Label 'Delegated admin and helpdesk users are not allowed to update the agent.';
        SOAInterventionSuggestionSummaryLbl: Label 'I have updated the %1', Comment = '%1 = Sales Document Type';
        SOAInterventionSuggestionDescriptionLbl: Label 'Used to indicate that a user has done some manual updates to a sales %1 as part of reviewing it before sending it to a customer.', Comment = '%1 = Sales Document Type', Locked = true;
        SOAInterventionSuggestionInstructionsLbl: Label 'I have updated the sales %1. Make sure to download the PDF again before including the %1 information in any outgoing communication.', Comment = '%1 = Sales Document Type', Locked = true;
        SOAInterventionSuggestionQuoteLbl: Label 'quote';
        SOAInterventionSuggestionOrderLbl: Label 'order';
        SOAInterventionSuggestionQuoteLockedLbl: Label 'quote', Locked = true;
        SOAInterventionSuggestionOrderLockedLbl: Label 'order', Locked = true;
        SOAItemAvailabilityInterventionSuggestionSummaryLbl: Label 'I have made the items available';
        SOAItemAvailabilityInterventionSuggestionDescriptionLbl: Label 'Used to indicate that a user has done some manual updates to the item availability. Rerun the item availability check', Locked = true;
        SOAItemAvailabilityInterventionSuggestionInstructionsLbl: Label 'I have updated the item availability. Make sure to recheck the item availability and proceed further.', Locked = true;
        SOACustomerInterventionSuggestionSummaryLbl: Label 'I have added the customer';
        SOACustomerInterventionSuggestionDescriptionLbl: Label 'Used to indicate that a user has done some manual updates to add the customer information. Rerun the customer information check', Locked = true;
        SOACustomerInterventionSuggestionInstructionsLbl: Label 'I have updated the customer information. Rerun the customer information check and proceed further.', Locked = true;
        SOAContactInterventionSuggestionSummaryLbl: Label 'I have added the contact';
        SOAContactInterventionSuggestionDescriptionLbl: Label 'Used to indicate that a user has done some manual updates to add the contact information. Rerun the contact information check', Locked = true;
        SOAContactInterventionSuggestionInstructionsLbl: Label 'I have updated the contact information. Rerun the contact information check on the contact list page and proceed further.', Locked = true;
        NewEmailsSinceDeactivationLbl: Label 'New e-mails (%1) have arrived since %2 but haven''t been processed yet. Should Sales Order Agent also process these?', Comment = '%1 - Number of emails, %2 - Date and time of deactivation.';
        SOAAttemptedConnectionFailedErr: Label 'The agent can''t be activated because the connection to the selected Microsoft 365 mailbox failed. Ask your Microsoft 365 administrator to check if the user configuring the agent has permission to access the mailbox.';
        SOAAttemptedConnectionHttpRequestFailedErr: Label 'The agent can''t be activated because its settings don''t allow Http Requests. Ask your administrator to update this setting and try again.';
}
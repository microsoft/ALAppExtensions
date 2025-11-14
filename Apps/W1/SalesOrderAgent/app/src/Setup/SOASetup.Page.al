// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.AI;
using System.Email;
using System.Environment.Configuration;
using System.Globalization;
using System.Security.AccessControl;
using System.Telemetry;

page 4400 "SOA Setup"
{
    PageType = ConfigurationDialog;
    Extensible = false;
    ApplicationArea = All;
    Caption = 'Configure Sales Order Agent';
    InstructionalText = 'Choose how the agent helps with inquiries, quotes, and orders.';
    AdditionalSearchTerms = 'Sales order agent, Copilot agent, Agent, SOA';
    SourceTable = Agent;
    SourceTableTemporary = true;
    InherentEntitlements = X;
    InherentPermissions = X;
    HelpLink = 'https://go.microsoft.com/fwlink/?linkid=2281481';

    layout
    {
        area(Content)
        {
            group(StartCard)
            {
                group(Header)
                {
                    field(Badge; BadgeTxt)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'The badge of the sales order agent.';
                    }
                    field(Type; AgentType)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'Specifies the type of the sales order agent.';
                    }
                    field(Name; Rec."Display Name")
                    {
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'Specifies the name of the sales order agent.';
                    }
                    field(State; Rec.State)
                    {
                        Caption = 'Active';
                        ToolTip = 'Specifies the state of the sales order agent, such as active or inactive.';

                        trigger OnValidate()
                        begin
                            IsConfigUpdated := true;
                        end;
                    }
                    field(UserSettingsLink; ManageUserAccessLbl)
                    {
                        Caption = 'Coworkers can use this agent.';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the user access control settings for the sales order agent.';

                        trigger OnDrillDown()
                        var
                            TempBackupAgentAccessControl: Record "Agent Access Control" temporary;
                        begin
                            CopyTempAgentAccessControl(TempAgentAccessControl, TempBackupAgentAccessControl);
                            if (Page.RunModal(Page::"Select Agent Access Control", TempAgentAccessControl) in [Action::LookupOK, Action::OK]) then begin
                                AccessUpdated := true;
                                IsConfigUpdated := true;
                                exit;
                            end;

                            CopyTempAgentAccessControl(TempBackupAgentAccessControl, TempAgentAccessControl);
                        end;
                    }
                }


                field(Summary; AgentSummary)
                {
                    Caption = 'Summary';
                    MultiLine = true;
                    Editable = false;
                    ToolTip = 'Specifies a brief description of the sales order agent.';
                }
            }

            group(MonitorIncomingCard)
            {
                Caption = 'Monitor incoming information';
                InstructionalText = 'The agent will read messages in these channels:';

                field("Monitor incoming inquiries"; TempSOASetup."Incoming Monitoring")
                {
                    ShowCaption = false;
                    ToolTip = 'Specifies if the sales order agent should monitor incoming inquiries.';
                    trigger OnValidate()
                    begin
                        ConfigUpdated();
                    end;
                }

                group(MailboxGroup)
                {
                    Caption = 'Mailbox';
                    field(MailEnabled; TempSOASetup."Email Monitoring")
                    {
                        ShowCaption = false;
                        ToolTip = 'Specifies if the sales order agent should monitor incoming mail.';

                        trigger OnValidate()
                        begin
                            ConfigUpdated();
                        end;
                    }
                    field(Mailbox; MailboxName)
                    {
                        Caption = 'Account';
                        ToolTip = 'Specifies the email account that the agent monitors. You need permission to the mailbox to activate the agent.';
                        Editable = false;
                        ShowMandatory = true;

                        trigger OnAssistEdit()
                        begin
                            OnAssistEditMailbox();
                        end;

                        trigger OnValidate()
                        begin
                            ConfigUpdated();
                        end;
                    }
                    field(LastSync; LastSync)
                    {
                        Caption = 'Last sync';
                        ToolTip = 'Specifies the date and time of the last sync with the mailbox.';
                        Editable = false;
                        Visible = ShowLastSync;
                    }
                    group(DefaultLanguage)
                    {
                        Caption = 'Default language';
                        InstructionalText = 'Used for task details and outgoing messages unless the recipient has a language set.';

                        field(LanguageAndRegion; SelectedLanguageTxt)
                        {
                            ShowCaption = false;
                            Editable = false;
                            ToolTip = 'Specifies the language and region settings for the sales order agent.';

                            ApplicationArea = All;
                            trigger OnDrillDown()
                            var
                                Language: Codeunit Language;
                                AgentUserSettings: Page "Agent User Settings";
                            begin
                                AgentUserSettings.InitializeTemp(UserSettings);
                                if AgentUserSettings.RunModal() in [Action::LookupOK, Action::OK] then begin
                                    AgentUserSettings.GetRecord(UserSettings);
                                    IsConfigUpdated := true;
                                    UserSettingsUpdated := true;
                                    SelectedLanguageTxt := Language.GetWindowsLanguageName(UserSettings."Language ID");
                                end;
                            end;
                        }
                    }
                }
                group(BillingInformationFirstSetup)
                {
                    Visible = FirstConfig;
                    InstructionalText = 'By enabling the Sales Order Agent, you understand your organization may be billed for its use.';
                    Caption = 'Important';
                    field(LearnMoreBilling; LearnMoreTxt)
                    {
                        ShowCaption = false;
                        Editable = false;
                        trigger OnDrillDown()
                        begin
                            Hyperlink(LearnMoreBillingDocumentationLinkTxt);
                        end;
                    }
                }

                group(BillingInformationSecondSetup)
                {
                    Visible = not FirstConfig;
                    InstructionalText = 'Your organization may be billed for use of the Sales Order Agent';
                    Caption = 'Important';

                    field(LearnMoreBillingSecondSetup; LearnMoreTxt)
                    {
                        ShowCaption = false;
                        Editable = false;
                        trigger OnDrillDown()
                        begin
                            Hyperlink(LearnMoreBillingDocumentationLinkTxt);
                        end;
                    }
                }
            }

            group(RespondToInquiriesCard)
            {
                Caption = 'Respond to inquiries';
                InstructionalText = 'Engage in conversations related to price and availability of products and services.';

                group(RegisteredSenderMessages)
                {
                    Caption = 'Messages from already registered senders';
                    field(RegisteredSenderInputMessageReview; TempSOASetup."Known Sender In. Msg. Review")
                    {
                        Caption = 'Review';
                        ToolTip = 'Specifies the type of review required for incoming messages from already registered senders.';
                        trigger OnValidate()
                        begin
                            ConfigUpdated();
                        end;
                    }
                }

                group(UnregisteredSenderMessages)
                {
                    Caption = 'Messages from unregistered senders';
                    field(UnregisteredSenderInputMessageReview; TempSOASetup."Unknown Sender In. Msg. Review")
                    {
                        Caption = 'Review';
                        ToolTip = 'Specifies the type of review required for incoming messages from unregistered senders.';
                        trigger OnValidate()
                        begin
                            ConfigUpdated();
                        end;
                    }
                }

                group(ItemSearch)
                {
                    Caption = 'Search for requested items';

                    group(SearchOnlyAvailableItemsGrp)
                    {
                        Caption = 'Select only available items';
                        InstructionalText = 'The agent checks availability of requested quantity';

                        field(SearchOnlyAvailableItems; TempSOASetup."Search Only Available Items")
                        {
                            ShowCaption = false;
                            ToolTip = 'Specifies if the agent takes item availability into account when searching for matches to the requested items.';
                            trigger OnValidate()
                            begin
                                if not TempSOASetup."Search Only Available Items" then
                                    TempSOASetup."Incl. Capable to Promise" := false;

                                ConfigUpdated();
                            end;
                        }
                        field(IncludeCapableToPromise; TempSOASetup."Incl. Capable to Promise")
                        {
                            Caption = 'Include capable to promise';
                            ToolTip = 'Specifies whether the agent includes in the search results items that are currently unavailable but can be ordered for a later shipment date.';
                            Editable = OnlyAvailableItemsActive;
                            trigger OnValidate()
                            begin
                                ConfigUpdated();
                            end;
                        }
                    }
                }
            }

            group(SOASalesDocConfigCard)
            {
                Caption = 'Create sales documents';
                InstructionalText = 'Create sales quotes and make orders from quotes in response to the incoming requests.';

                group(QuoteSetup)
                {
                    ShowCaption = false;
                    field(RequestQuoteReview; TempSOASetup."Quote Review")
                    {
                        Caption = 'Review quotes when created and updated';
                        ToolTip = 'Specifies if the agent requests review when a quote is created and updated.';

                        trigger OnValidate()
                        begin
                            ConfigUpdated();
                        end;
                    }
                    field(SendSalesQuote; TempSOASetup."Send Sales Quote")
                    {
                        Caption = 'Send quotes for confirmation';
                        ToolTip = 'Specifies if the agent sends sales quotes for confirmation.';

                        trigger OnValidate()
                        begin
                            ConfigUpdated();
                        end;
                    }
                }

                group(OrderSetup)
                {
                    ShowCaption = false;
                    group(CreateOrder)
                    {
                        Caption = 'Make orders from quotes';
                        InstructionalText = 'The agent turns accepted quotes into orders';

                        field(CreateOrderFromQuote; TempSOASetup."Create Order from Quote")
                        {
                            Caption = 'Make orders from quotes';
                            ToolTip = 'Specifies if the agent makes orders from quotes.';
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                if not TempSOASetup."Create Order from Quote" then
                                    TempSOASetup."Order Review" := false;
                                ConfigUpdated();
                            end;
                        }
                        field(RequestOrderReview; TempSOASetup."Order Review")
                        {
                            Caption = 'Review orders when created and updated';
                            ToolTip = 'Specifies if the agent requests review when an order is created and updated.';
                            Editable = CreateOrderFromQuoteActive;

                            trigger OnValidate()
                            begin
                                ConfigUpdated();
                            end;
                        }
                    }
                }
            }

            group(SOAManageMailboxConfigCard)
            {
                Caption = 'Manage mailbox';
                InstructionalText = 'Send and receive email using the selected account.';

                field(Mailbox2; MailboxName)
                {
                    Caption = 'Account';
                    ToolTip = 'Specifies the email account that the agent monitors. You need permission to the mailbox to activate the agent.';
                    Editable = false;
                    ShowMandatory = true;

                    trigger OnAssistEdit()
                    begin
                        OnAssistEditMailbox();
                    end;

                    trigger OnValidate()
                    begin
                        ConfigUpdated();
                    end;
                }
                field(MailboxFolder; MailboxFolder)
                {
                    Caption = 'Folder';
                    ToolTip = 'Specifies the email folder that the agent monitors. You need permission to the mailbox to activate the agent.';
                    Editable = false;
                    ShowMandatory = true;

                    trigger OnAssistEdit()
                    var
                        TempEmailFolder: Record "Email Folders" temporary;
                        EmailFolders: Page "Email Account Folders";
                    begin
                        EmailFolders.LookupMode(true);
                        EmailFolders.SetEmailAccount(TempSOASetup."Email Account ID", TempSOASetup."Email Connector");
                        if EmailFolders.RunModal() = Action::LookupOK then begin
                            EmailFolders.GetRecord(TempEmailFolder);
                            TempSOASetup."Email Folder" := TempEmailFolder."Folder Name";
                            TempSOASetup."Email Folder Id" := TempEmailFolder."Id";
                            MailboxFolder := TempEmailFolder."Folder Name";
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        ConfigUpdated();
                    end;
                }

                group(IncomingMail)
                {
                    Caption = 'Incoming mail';
                    InstructionalText = 'Analyze new messages to determine the sender''s intent and how to respond.';

                    group(AnalyzeAttachmentsGrp)
                    {
                        Caption = 'Analyze attachments';
                        InstructionalText = 'Includes attachments when analyzing intent. Supported formats: PDF, PNG, JPG.';

                        field(AnalyzeAttachments; TempSOASetup."Analyze Attachments")
                        {
                            Caption = 'Analyze attachments';
                            ToolTip = 'Includes attachments when analyzing intent. Supported formats: PDF, PNG, JPG.';
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                ConfigUpdated();
                            end;
                        }
                    }
                }

                group(ProcessingLimits)
                {
                    Caption = 'Processing Limits';
                    InstructionalText = 'Process up to this many incoming emails per day. Display an alert when the limit is reached.';

                    field(DailyEmailLimit; DailyEmailLimit)
                    {
                        Caption = 'Daily email limit';
                        ToolTip = 'Specifies the maximum number of emails an agent can process per day.';
                        ShowMandatory = true;

                        trigger OnValidate()
                        begin
                            TempSOASetup."Message Limit" := DailyEmailLimit;
                            ConfigUpdated();
                        end;
                    }
                }

            }

            group(OutputMailGroup)
            {
                Caption = 'Format outgoing messages';
                InstructionalText = 'Prepare the content and style of outgoing messages in certain ways.';
                group(EmailTemplateGroup)
                {
                    Caption = 'Mail Signature';

                    group(EmailSignatureGroup)
                    {
                        Caption = 'Include a custom signature in the replies';

                        field(ConfigureEmailSignature; TempSOASetup."Configure Email Template")
                        {
                            ShowCaption = false;
                            ToolTip = 'Specifies if the agent includes a custom mail signature below the message body when preparing outgoing mails.';

                            trigger OnValidate()
                            begin
                                IsConfigUpdated := true;
                                MailTemplateEditable := TempSOASetup."Configure Email Template";
                            end;
                        }
                        field(EmailTemplate; EmailSignatureModifyLbl)
                        {
                            ShowCaption = false;
                            Enabled = MailTemplateEditable;
                            trigger OnDrillDown()
                            begin
                                UpdateEmailSignature();
                            end;

                        }
                    }
                }
            }

        }
    }
    actions
    {
        area(SystemActions)
        {
            systemaction(OK)
            {
                Caption = 'Update';
                Enabled = IsConfigUpdated;
                ToolTip = 'Apply the changes to the agent setup.';
            }

            systemaction(Cancel)
            {
                Caption = 'Cancel';
                ToolTip = 'Discards the changes and closes the setup page.';
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SOASetupCU: Codeunit "SOA Setup";
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Sales Order Agent") then
            Error('');

        IsConfigUpdated := false;
        FirstConfig := IsFirstConfig();
        UpdateControls();
        FeatureTelemetry.LogUptake('0000QIK', SOASetupCU.GetFeatureName(), Enum::"Feature Uptake Status"::Discovered);
    end;

    trigger OnAfterGetRecord()
    var
        Agent: Codeunit Agent;
        Language: Codeunit Language;
    begin
        UpdateControls();
        Agent.GetUserSettings(Rec."User Security ID", UserSettings);
        SelectedLanguageTxt := Language.GetWindowsLanguageName(UserSettings."Language ID");
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SOASetupCU: Codeunit "SOA Setup";
        SOASessionEvents: Codeunit "SOA Session Events";
        ReadyToActivateLbl: Label 'Ready to activate the sales order agent?\\The Copilot agent will run now and until you deactivate it.';
        ActivateWithoutMailboxLbl: Label 'There is no mailbox selected for the agent to monitor. Are you sure you want to continue? ';
        ActivateWithoutMailboxNameErr: Label 'To activate the agent with the current settings, a mailbox must be selected first.';
        ActivateWithoutMonitoringLbl: Label 'The monitoring of email is not enabled. Are you sure you want to continue?';
        DeactivateWarningLbl: Label 'If you deactivate the agent, you won''t be able to reactivate it because you don''t have permission to the current mail account (activated by %1). Are you sure you want continue?', Comment = '%1=Username of user who activated the agent.';
    begin
        if CloseAction = CloseAction::Cancel then
            exit(true);

        if EnabledAgentFirstConfig() then
            if Confirm(ReadyToActivateLbl) then
                Rec.State := Rec.State::Enabled;

        if (Rec.State = Rec.State::Enabled) and MailboxChanged and StateChanged() then
            if CheckIsValidConfig() then begin
                SOASessionEvents.BindUserEvents();
                SOASetupCU.ValidateEmailConnection(StateChanged(), TempSOASetup);
            end
            else begin
                SOASessionEvents.BindUserEvents();
                if TempSOASetup."Incoming Monitoring" and TempSOASetup."Email Monitoring" and (MailboxName = '') then
                    Error(ActivateWithoutMailboxNameErr);

                if TempSOASetup."Incoming Monitoring" and not TempSOASetup."Email Monitoring" then
                    if not Confirm(ActivateWithoutMailboxLbl) then
                        exit(false);

                if not TempSOASetup."Incoming Monitoring" then
                    if not Confirm(ActivateWithoutMonitoringLbl) then
                        exit(false);
            end;

        if (TempSOASetup."Message Limit" <= 0) then
            Error(DailyEmailLimitErr);

        if ShowDeactivateAgentEmailPermissionsWarning() then
            if not Confirm(StrSubstNo(DeactivateWarningLbl, ConfiguredBy)) then
                exit(false);

        if StateChanged() then
            SOASetupCU.UpdateSOASetupActivationDT(TempSOASetup);

        SOASetupCU.UpdateAgent(Rec, TempAgentAccessControl, TempSOASetup, AccessUpdated, ShouldScheduleTask(), UserSettingsUpdated, UserSettings);
        exit(true);
    end;

    local procedure StateChanged(): Boolean
    begin
        exit((Rec.State <> InitialState) or IsFirstConfig());
    end;

    local procedure ShouldScheduleTask(): Boolean
    begin
        exit((Rec.State = Rec.State::Enabled) and (StateChanged() or MailboxChanged));
    end;

    local procedure ShowDeactivateAgentEmailPermissionsWarning(): Boolean
    var
        SOASetupCU: Codeunit "SOA Setup";
    begin
        if (Rec.State = Rec.State::Disabled) and StateChanged() and not IsFirstConfig() then
            if not SOASetupCU.ValidateEmailConnectionStatus(TempSOASetup) then
                exit(true);
    end;

    local procedure UpdateControls()
    var
        User: Record User;
        SOASetupCU: Codeunit "SOA Setup";
    begin
        BadgeTxt := SOASetupCU.GetInitials();
        AgentType := SOASetupCU.GetAgentType();
        AgentSummary := SOASetupCU.GetAgentSummary();

        if Rec.IsEmpty() then begin
            SOASetupCU.GetAgent(Rec);
            if not IsNullGuid(Rec."User Security ID") then begin
                Rec.Insert();
                InitialState := Rec.State;
            end else
                InitialState := Rec.State::Disabled;
        end;

        if TempSOASetup.IsEmpty() or (TempSOASetup."Agent User Security ID" <> Rec."User Security ID") then begin
            SOASetupCU.GetDefaultSOASetup(TempSOASetup, Rec);
            MailboxName := TempSOASetup."Email Address";
            if TempSOASetup."Email Folder" <> '' then
                MailboxFolder := TempSOASetup."Email Folder"
            else
                MailboxFolder := OptionalMailboxLbl;
            ShowLastSync := CheckIsValidConfig() and (TempSOASetup."Last Sync At" <> 0DT);
            LastSync := Format(TempSOASetup."Last Sync At");
        end;

        MailTemplateEditable := TempSOASetup."Configure Email Template";

        if TempAgentAccessControl.IsEmpty() then
            SOASetupCU.GetDefaultAgentAccessControl(Rec."User Security ID", TempAgentAccessControl);

        CreateOrderFromQuoteActive := TempSOASetup."Create Order from Quote";
        OnlyAvailableItemsActive := TempSOASetup."Search Only Available Items";

        DailyEmailLimit := TempSOASetup."Message Limit";
        if DailyEmailLimit = 0 then
            DailyEmailLimit := TempSOASetup.GetDefaultMessageLimit();

        if User.Get(Rec.SystemModifiedBy) then
            ConfiguredBy := User."Full Name";

        CheckIsValidConfig();
    end;

    local procedure ConfigUpdated()
    begin
        IsConfigUpdated := true;
        CheckIsValidConfig();
        CreateOrderFromQuoteActive := TempSOASetup."Create Order from Quote";
        OnlyAvailableItemsActive := TempSOASetup."Search Only Available Items";

        if EnabledAgentFirstConfig() then
            Rec.State := Rec.State::Enabled;
    end;

    local procedure EnabledAgentFirstConfig(): Boolean
    begin
        exit((Rec.State = Rec.State::Disabled) and IsFirstConfig() and CheckIsValidConfig());
    end;

    local procedure CheckIsValidConfig(): Boolean
    begin
        exit(TempSOASetup."Incoming Monitoring" and TempSOASetup."Email Monitoring" and (MailboxName <> ''));
    end;

    local procedure IsFirstConfig(): Boolean
    begin
        exit(IsNullGuid(TempSOASetup."Agent User Security ID"));
    end;

    local procedure CheckMailboxExists(): Boolean
    var
        EmailAccounts: Record "Email Account";
        EmailAccount: Codeunit "Email Account";
        IConnector: Interface "Email Connector";
    begin
        EmailAccount.GetAllAccounts(false, EmailAccounts);
        if EmailAccounts.IsEmpty() then
            exit(false);

        repeat
            IConnector := EmailAccounts.Connector;
#if not CLEAN28
#pragma warning disable AL0432
            if IConnector is "Email Connector v3" or IConnector is "Email Connector v4" then
#pragma warning restore AL0432
#else
            if IConnector is "Email Connector v4" then
#endif
                exit(true);
        until EmailAccounts.Next() = 0;
    end;

    local procedure OnAssistEditMailbox()
    var
        EmailAccounts: Page "Email Accounts";
    begin
        if not CheckMailboxExists() then
            Page.RunModal(Page::"Email Account Wizard");

        if not CheckMailboxExists() then
            exit;

        EmailAccounts.EnableLookupMode();
        EmailAccounts.SetShowCreateAccount(true);
        EmailAccounts.FilterConnectorV4Accounts(true);
        if EmailAccounts.RunModal() = Action::LookupOK then begin
            EmailAccounts.GetAccount(TempEmailAccount);
            TempSOASetup."Email Account ID" := TempEmailAccount."Account Id";
            TempSOASetup."Email Connector" := TempEmailAccount.Connector;
            TempSOASetup."Email Address" := TempEmailAccount."Email Address";
        end;

        if MailboxName <> TempSOASetup."Email Address" then begin
            MailboxChanged := true;
            MailboxName := TempSOASetup."Email Address";
            ConfigUpdated();

            MailboxFolder := OptionalMailboxLbl;
            Clear(TempSOASetup."Email Folder");
            Clear(TempSOASetup."Email Folder Id");
        end;
    end;

    local procedure CopyTempAgentAccessControl(var SourceTempAgentAccessControl: Record "Agent Access Control" temporary; var TargetTempAgentAccessControl: Record "Agent Access Control" temporary)
    begin
        TargetTempAgentAccessControl.Reset();
        TargetTempAgentAccessControl.DeleteAll();
        if not SourceTempAgentAccessControl.FindSet() then
            exit;

        repeat
            TargetTempAgentAccessControl.TransferFields(SourceTempAgentAccessControl, true);
            TargetTempAgentAccessControl.Insert()
        until SourceTempAgentAccessControl.Next() = 0;
    end;

    local procedure UpdateEmailSignature()
    var
        EmailTemplatePage: Page "SOA Email Template";
    begin
        if not TempSOASetup."Configure Email Template" then
            exit;
        EmailTemplatePage.SetCurrentSignatureAsTxt(TempSOASetup.GetEmailSignatureAsTxt());
        EmailTemplatePage.RunModal();
        if EmailTemplatePage.IsValueUpdated() then begin
            TempSOASetup.SetEmailSignature(EmailTemplatePage.GetNewSignatureAsTxt());
            TempSOASetup.Modify();
            IsConfigUpdated := true;
        end;
    end;

    var
        UserSettings: Record "User Settings";
        TempAgentAccessControl: Record "Agent Access Control" temporary;
        TempEmailAccount: Record "Email Account" temporary;
        TempSOASetup: Record "SOA Setup" temporary;
        AzureOpenAI: Codeunit "Azure OpenAI";
        MailboxName, MailboxFolder : Text;
        LastSync: Text;
        BadgeTxt: Text[4];
        AgentType: Text;
        AgentSummary: Text;
        ShowLastSync: Boolean;
        IsConfigUpdated: Boolean;
        AccessUpdated: Boolean;
        UserSettingsUpdated: Boolean;
        FirstConfig: Boolean;
        MailTemplateEditable: Boolean;
        CreateOrderFromQuoteActive: Boolean;
        OnlyAvailableItemsActive: Boolean;
        MailboxChanged: Boolean;
        DailyEmailLimit: Integer;
        ConfiguredBy: Text;
        InitialState: Option Enabled,Disabled;
        LearnMoreTxt: Label 'Learn more';
        LearnMoreBillingDocumentationLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2333517';
        ManageUserAccessLbl: Label 'Manage user access';
        DailyEmailLimitErr: Label 'The daily email limit must be greater than zero.';
        EmailSignatureModifyLbl: Label 'Edit signature';
        SelectedLanguageTxt: Text;
        OptionalMailboxLbl: Label '(optional)';
}
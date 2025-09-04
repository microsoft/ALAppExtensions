// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.AI;
using System.Email;
using System.Security.AccessControl;

page 4400 "SOA Setup"
{
    PageType = ConfigurationDialog;
    Extensible = false;
    ApplicationArea = All;
    IsPreview = true;
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
                        ToolTip = 'Specifies the state of the sales order agent, such as enabled or disabled.';

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
                        var
                            EmailAccounts: Page "Email Accounts";
                        begin
                            if not CheckMailboxExists() then
                                Page.RunModal(Page::"Email Account Wizard");

                            if not CheckMailboxExists() then
                                exit;

                            EmailAccounts.EnableLookupMode();
                            EmailAccounts.FilterConnectorV3Accounts(true);
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
                            end;
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

                            trigger OnValidate()
                            begin
                                if TempSOASetup."Incl. Capable to Promise" then
                                    TempSOASetup."Search Only Available Items" := true;

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
                    Caption = 'Create quotes for sales inquiries';

                    group(RequestQuoteReviewGrp)
                    {
                        Caption = 'Review quotes when created and updated';
                        field(RequestQuoteReview; TempSOASetup."Quote Review")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies if the agent requests review when a quote is created and updated.';

                            trigger OnValidate()
                            begin
                                ConfigUpdated();
                            end;
                        }
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
                            ToolTip = 'Specifies if the agent makes orders from quotes that are accepted.';
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                ConfigUpdated();
                                if not TempSOASetup."Create Order from Quote" then
                                    TempSOASetup."Order Review" := false;
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
        }
    }
    actions
    {
        area(SystemActions)
        {
#pragma warning disable AA0218
            systemaction(OK)
#pragma warning restore AA0218
            {
                Caption = 'Update';
                Enabled = IsConfigUpdated;
            }

#pragma warning disable AA0218
            systemaction(Cancel)
#pragma warning restore AA0218
            {
                Caption = 'Cancel';
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Sales Order Agent") then
            Error('');

        IsConfigUpdated := false;
        FirstConfig := IsFirstConfig();
        UpdateControls();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateControls();
        FirstConfig := IsFirstConfig();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        User: Record User;
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

        if ShowDeactivateAgentEmailPermissionsWarning() then begin
            if User.Get(Rec.SystemModifiedBy) then;
            if not Confirm(StrSubstNo(DeactivateWarningLbl, User."User Name")) then
                exit(false);
        end;

        if StateChanged() then
            SOASetupCU.UpdateSOASetupActivationDT(TempSOASetup);

        SOASetupCU.UpdateAgent(Rec, TempAgentAccessControl, TempSOASetup, TempEmailAccount, AccessUpdated, ShouldScheduleTask());
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

        if TempSOASetup.IsEmpty() then begin
            SOASetupCU.GetDefaultSOASetup(TempSOASetup, Rec);
            MailboxName := TempSOASetup."Email Address";
            ShowLastSync := CheckIsValidConfig() and (TempSOASetup."Last Sync At" <> 0DT);
            LastSync := Format(TempSOASetup."Last Sync At");
        end;

        if TempAgentAccessControl.IsEmpty() then
            SOASetupCU.GetDefaultAgentAccessControl(Rec."User Security ID", TempAgentAccessControl);

        CreateOrderFromQuoteActive := TempSOASetup."Create Order from Quote";

        CheckIsValidConfig();
    end;

    local procedure ConfigUpdated()
    begin
        IsConfigUpdated := true;
        CheckIsValidConfig();
        CreateOrderFromQuoteActive := TempSOASetup."Create Order from Quote";

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
            if IConnector is "Email Connector v3" then
                exit(true);
        until EmailAccounts.Next() = 0;
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

    var
        TempAgentAccessControl: Record "Agent Access Control" temporary;
        TempEmailAccount: Record "Email Account" temporary;
        TempSOASetup: Record "SOA Setup" temporary;
        AzureOpenAI: Codeunit "Azure OpenAI";
        MailboxName: Text;
        LastSync: Text;
        BadgeTxt: Text[4];
        AgentType: Text;
        AgentSummary: Text;
        ShowLastSync: Boolean;
        IsConfigUpdated: Boolean;
        AccessUpdated: Boolean;
        FirstConfig: Boolean;
        CreateOrderFromQuoteActive: Boolean;
        MailboxChanged: Boolean;
        InitialState: Option Enabled,Disabled;
        LearnMoreTxt: Label 'Learn more';
        LearnMoreBillingDocumentationLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2298603';
        ManageUserAccessLbl: Label 'Manage user access';
}
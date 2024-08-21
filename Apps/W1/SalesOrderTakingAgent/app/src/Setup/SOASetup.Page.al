// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using System.Agents;
using System.Email;

page 4400 "SOA Setup"
{
    PageType = ConfigurationDialog;
    Extensible = false;
    ApplicationArea = All;
    IsPreview = true;
    UsageCategory = Administration;
    Caption = 'Set up sales order taker agent';
    InstructionalText = ' This wizard helps you to set up the order taking agent.';
    AdditionalSearchTerms = 'Sales Order Taker, Agent, Agent Setup, Order Taker, Setup';
    SourceTable = Agent;
    SourceTableTemporary = true;

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
                        ToolTip = 'The badge of the Sales Order Taker Agent.';
                    }
                    field(Type; AgentType)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'Specifies the type of the Sales Order Taker Agent.';
                    }
                    field(Name; Rec."Display Name")
                    {
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'The name of the Sales Order Taker.';
                    }
                    field(State; Rec.State)
                    {
                        Caption = 'Active';
                        ToolTip = 'Specifies the state of the Sales Order Taker Agent, such as enabled or disabled.';
                    }
                }

                field(Summary; AgentSummary)
                {
                    Caption = 'Summary';
                    MultiLine = true;
                    Editable = false;
                    ToolTip = 'Specifies a brief description of the Sales Order Taker Agent.';
                }
            }

            group(MonitorIncomingCard)
            {
                Caption = 'Monitor incoming information';
                InstructionalText = 'Copilot will read messages in these channels:';

                field("Monitor incoming inquiries"; TempSOASetup."Incoming Monitoring")
                {
                    ShowCaption = false;
                    ToolTip = 'Specifies if the agent should monitor incoming inquiries.';
                    trigger OnValidate()
                    begin
                        SetIsMailboxMandatory();
                        IsConfigUpdated();
                    end;
                }

                group(MailboxGroup)
                {
                    Caption = 'Mailbox';
                    field(MailEnabled; TempSOASetup."Email Monitoring")
                    {
                        ShowCaption = false;
                        ToolTip = 'Specifies if the agent should monitor incoming mail.';

                        trigger OnValidate()
                        begin
                            SetIsMailboxMandatory();
                            IsConfigUpdated();
                        end;
                    }
                    field(Mailbox; MailboxName)
                    {
                        Caption = 'Mail box';
                        ToolTip = 'Specifies the mail box that the agent should monitor.';
                        ShowMandatory = IsMailboxMandatory;

                        trigger OnAssistEdit()
                        var
                            EmailAccounts: Page "Email Accounts";
                            Action: Action;
                        begin
                            EmailAccounts.EnableLookupMode();
                            EmailAccounts.FilterConnectorV2Accounts(true);
                            if EmailAccounts.RunModal() = Action::LookupOK then
                                EmailAccounts.GetAccount(TempEmailAccount);

                            if MailboxName <> TempEmailAccount."Email Address" then begin
                                IsConfigUpdated();
                                MailboxName := TempEmailAccount."Email Address";
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            IsConfigUpdated();
                        end;
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
                Enabled = IsUpdated;
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
        IsUpdated := false;
        UpdateControls();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateControls();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IsConfigUpdated();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SOASetup: Codeunit "SOA Setup";
    begin
        if CloseAction = CloseAction::Cancel then
            exit(true);

        SOASetup.UpdateAgent(Rec, TempAgentAccessControl, TempSOASetup, TempEmailAccount);
        exit(true);
    end;

    local procedure UpdateControls()
    var
        SOASetup: Codeunit "SOA Setup";
    begin
        BadgeTxt := SOASetup.GetInitials();
        AgentType := SOASetup.GetAgentType();
        AgentSummary := SOASetup.GetAgentSummary();
        IsMailboxMandatory := true;

        if Rec.IsEmpty() then
            SOASetup.GetDefaultAgent(Rec);
        if TempSOASetup.IsEmpty() then begin
            SOASetup.GetDefaultSOASetup(TempSOASetup, Rec);
            SOASetup.GetEmailAccount(TempSOASetup, TempEmailAccount);
            MailboxName := TempEmailAccount."Email Address";
        end;
        if TempAgentAccessControl.IsEmpty() then
            SOASetup.GetDefaultAgentAccessControl(Rec."User Security ID", TempAgentAccessControl);
    end;

    local procedure IsConfigUpdated()
    begin
        IsUpdated := true;
    end;

    local procedure SetIsMailboxMandatory()
    begin
        IsMailboxMandatory := TempSOASetup."Email Monitoring" and TempSOASetup."Incoming Monitoring";
    end;

    var
        TempAgentAccessControl: Record "Agent Access Control" temporary;
        TempEmailAccount: Record "Email Account" temporary;
        TempSOASetup: Record "SOA Setup" temporary;
        MailboxName: Text;
        BadgeTxt: Text[4];
        AgentType: Text;
        AgentSummary: Text;
        IsUpdated: Boolean;
        IsMailboxMandatory: Boolean;
}
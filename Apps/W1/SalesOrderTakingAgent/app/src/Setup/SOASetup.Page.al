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
    UsageCategory = Administration;
    Caption = 'Set up sales order taker agent';
    InstructionalText = ' This wizard helps you to set up the order taking agent.';
    AdditionalSearchTerms = 'Sales Order Taker, Agent, Agent Setup, Order Taker, Setup';

    layout
    {
        area(Content)
        {
            // The first group is always the "start card" 
            group(StartCard)
            {
                Caption = 'Start Card';
                InstructionalText = 'Choose how the custom copilot helps with inquiries, quotes and orders. You can add more skills as required.';

                field(IsActive; IsActive)
                {
                    ShowCaption = false;
                    ToolTip = 'Specifies the state of the Sales Order Taker, such as active or not active.';
                }

                group(Header)
                {
                    field(Name; AgentDisplayName)
                    {
                        ShowCaption = false;
                        Caption = 'Name';
                        ToolTip = 'Specifies the name of the Sales Order Taker.';

                        trigger OnValidate()
                        begin
                            AgentName := CopyStr(AgentDisplayName, 1, MaxStrLen(AgentName));
                        end;
                    }
                    field(StatusText; StatusText)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'Specifies the status of the Sales Order Taker.';
                    }
                    group(Access)
                    {
                        field(ManageAccess; ManageAccessLbl)
                        {
                            ShowCaption = false;
                            ToolTip = 'Specifies the list of users who can configure or use the Sales Order Taker agent.';
                            Editable = false;

                            trigger OnDrillDown()
                            begin
                                Page.RunModal(Page::"Select Agent Access Control", TempAgentAccessControl);
                            end;
                        }
                    }
                }

                group(Summary)
                {
                    field(SummaryField; SummaryLbl)
                    {
                        Caption = 'Summary';
                        MultiLine = true;
                        Editable = false;
                        ToolTip = 'Specifies a brief description of the Sales Order Taker Agent.';
                    }
                }
            }
            group(SetupIncomingCommunication)
            {
                Caption = 'Monitor incoming communication';
                InstructionalText = 'This skill allows the agent to monitor incoming communication and create sales quotes and draft replies to customers.';

                field(MonitorIncomingCommunication; MonitorIncomingInquiries)
                {
                    ShowCaption = false;
                    ToolTip = 'Specifies if the agent should monitor incoming communication.';
                    ApplicationArea = All;
                }

                group(ChannelsToMonitor)
                {
                    ShowCaption = false;
                    group(Email)
                    {
                        ShowCaption = false;
                        field(MailBox; MailboxName)
                        {
                            Caption = 'Mail box';
                            ToolTip = 'Specifies the mail box that the agent should monitor.';
                            ApplicationArea = All;
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
                Caption = 'Activate';
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
        UpdateControls();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateControls();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        EmailAccount: Codeunit "Email Account";
        SOASetup: Codeunit "SOA Setup";
    begin
        if CloseAction = CloseAction::Cancel then
            exit(true);

        //TODO: This is temporary and it should take from the UI instead.
        EmailAccount.GetAllAccounts(false, TempEmailAccount);
        TempEmailAccount.FindFirst();

        if IsNullGuid(AgentSecurityID) then
#pragma warning disable AA0139
            SOASetup.CreateAgent(AgentName, AgentDisplayName, TempAgentAccessControl, TempEmailAccount, IsActive)
#pragma warning restore AA0139
        else
            SOASetup.UpdateExistingAgent(AgentSecurityID, AgentDisplayName, TempAgentAccessControl, IsActive);

        exit(true);
    end;

    local procedure UpdateControls()
    var
        Agent: Codeunit Agent;
        SOASetup: Codeunit "SOA Setup";
    begin
        if IsNullGuid(AgentSecurityID) then begin
            IsActive := true;
            SOASetup.GetDefaultNames(AgentName, AgentDisplayName);
        end else begin
            IsActive := Agent.IsActive(AgentSecurityID);
            AgentName := Agent.GetUserName(AgentSecurityID);
            AgentDisplayName := Agent.GetDisplayName(AgentSecurityID);
            Agent.GetUserAccess(AgentSecurityID, TempAgentAccessControl);
        end;

        if IsActive then
            StatusText := ActiveStatusLbl
        else
            StatusText := DisabledStatusLbl;
    end;

    var
        TempAgentAccessControl: Record "Agent Access Control" temporary;
        TempEmailAccount: Record "Email Account" temporary;
        AgentSecurityID: Guid;
        MonitorIncomingInquiries: Boolean;
        MailboxName: Text;
        AgentDisplayName: Text[80];
        AgentName: Code[50];
        ManageAccessLbl: Label 'Manage access';
        IsActive: Boolean;
        StatusText: Text;
        ActiveStatusLbl: Label 'Active';
        DisabledStatusLbl: Label 'Disabled';
        SummaryLbl: Label 'I''m monitoring incoming mail for requests for quotes. I create sales quotes and draft replies to customers.';
}
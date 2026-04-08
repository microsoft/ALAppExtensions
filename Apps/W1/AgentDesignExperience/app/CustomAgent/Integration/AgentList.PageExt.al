// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Agents.Designer;

pageextension 4354 "Agent List" extends "Agent List"
{
    AdditionalSearchTerms = 'Designer';

    actions
    {
        addlast(Processing)
        {
            action(CreateAgent)
            {
                ApplicationArea = All;
                Caption = 'Create agent';
                ToolTip = 'Create a new agent.';
                Image = New;
                Enabled = CanCreateCustomAgents;

                trigger OnAction()
                begin
                    Page.RunModal(Page::"Custom Agents Wizard");
                    CurrPage.Update(false);
                end;
            }
            action(OpenEditInstructionsPage)
            {
                ApplicationArea = All;
                Caption = 'Test agent';
                ToolTip = 'Open the test agent page to test and interact with this agent.';
                Scope = Repeater;
                Enabled = IsCustomAgent and CanModifyCustomAgent;
                Image = DocumentEdit;

                trigger OnAction()
                var
                    CustomAgentSetupCodeunit: Codeunit "Custom Agent Setup";
                begin
                    VerifyAgentSelected();
                    CustomAgentSetupCodeunit.OpenEditInstructionsPage(Rec."User Security ID");
                end;
            }
            action(DeleteAgent)
            {
                ApplicationArea = All;
                Caption = 'Delete agent';
                ToolTip = 'Delete the current agent.';
                Image = Delete;
                Scope = Repeater;
                Enabled = IsCustomAgent and CanDeleteCustomAgents;

                trigger OnAction()
                var
                    AgentUtilities: Codeunit "Agent Utilities";
                begin
                    AgentDesignerPermissions.VerifyCurrentUserCanDeleteCustomAgents();

                    VerifyAgentSelected();
                    if not Confirm(ConfirmDeleteAgentQst) then
                        exit;

                    AgentUtilities.DeleteCustomAgent(Rec."User Security ID");
                    CurrPage.Update(false);
                end;
            }
            action(ExportAgent)
            {
                ApplicationArea = All;
                Caption = 'Export agent definition';
                ToolTip = 'Export the selected custom agent definition(s).';
                Image = Export;
                Scope = Repeater;
                Enabled = IsCustomAgent and CanExportCustomAgents;

                trigger OnAction()
                var
                    Agent: Record Agent;
                    CustomAgentExport: Codeunit "Custom Agent Export";
                begin
                    GetSelectionFilter(Agent);
                    if not Confirm(ConfirmExportAgentsQst) then
                        exit;

                    CustomAgentExport.ExportAgents(Agent);
                end;
            }
            action(ImportAgent)
            {
                ApplicationArea = All;
                Caption = 'Import agent definition';
                ToolTip = 'Import agent definitions from an XML file using the import wizard.';
                Image = Import;
                Enabled = CanCreateCustomAgents;

                trigger OnAction()
                var
                    AgentImportWizard: Page "Agent Import Wizard";
                begin
                    AgentImportWizard.RunModal();
                    CurrPage.Update(false);
                end;
            }
        }
        addfirst(Category_Process)
        {
            group(Design)
            {
                Caption = 'Design';
                actionref(CreateAgent_Promoted; CreateAgent)
                {
                }
                actionref(OpenEditInstructionsPage_Promoted; OpenEditInstructionsPage)
                {
                }
                actionref(DeleteAgent_Promoted; DeleteAgent)
                {
                }
                separator(ExportImportSeparator)
                {
                }
                actionref(ExportAgent_Promoted; ExportAgent)
                {
                }
                actionref(ImportAgent_Promoted; ImportAgent)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        AgentDesignerEnvironment: Codeunit "Agent Designer Environment";
    begin
        AgentDesignerEnvironment.VerifyCanRunOnCurrentEnvironment();

        if Rec.IsEmpty() then
            ShowNoAgentsNotification();

        CanCreateCustomAgents := AgentDesignerPermissions.CurrentUserCanCreateCustomAgents();
        CanDeleteCustomAgents := AgentDesignerPermissions.CurrentUserCanDeleteCustomAgents();
        CanExportCustomAgents := AgentDesignerPermissions.CurrentUserCanExportCustomAgents();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetCustomAgentVisibility();
    end;

    local procedure SetCustomAgentVisibility()
    var
        CustomAgentSetup: Record "Custom Agent Setup";
    begin
        IsCustomAgent := CustomAgentSetup.Get(Rec."User Security ID");
        CanModifyCustomAgent := AgentDesignerPermissions.CurrentUserCanConfigureCustomAgent(Rec."User Security ID");
    end;

    local procedure VerifyAgentSelected()
    begin
        if IsNullGuid(Rec."User Security ID") then
            Error(NoAgentSelectedErr);
    end;

    local procedure GetSelectionFilter(var Agent: Record Agent)
    var
        AgentBuffer: Record Agent;
        CustomAgentSetup: Record "Custom Agent Setup";
    begin
        Agent.Reset();
        AgentBuffer.CopyFilters(Rec);
        CurrPage.SetSelectionFilter(Rec);
        if Rec.FindSet() then
            repeat
                if CustomAgentSetup.Get(Rec."User Security ID") then
                    if Agent.Get(Rec."User Security ID") then
                        Agent.Mark(true);
            until Rec.Next() = 0;
        Agent.MarkedOnly(true);
        Rec.Reset();
        Rec.CopyFilters(AgentBuffer);
    end;

    local procedure ShowNoAgentsNotification()
    var
        AgentsNotification: Notification;
    begin
        AgentsNotification.Message(NoAgentsNotificationTxt);
        AgentsNotification.Scope := NotificationScope::LocalScope;
        AgentsNotification.AddAction(CreateAgentTxt, Codeunit::"Custom Agents Wizard Setup", 'OpenCustomAgentsWizard');
        AgentsNotification.AddAction(LearnMoreAboutCustomAgentsTxt, Codeunit::"Custom Agents Wizard Setup", 'OpenLearnMoreLink');
        AgentsNotification.Send();
    end;

    var
        AgentDesignerPermissions: Codeunit "Agent Designer Permissions";
        IsCustomAgent: Boolean;
        CanModifyCustomAgent: Boolean;
        CanCreateCustomAgents: Boolean;
        CanDeleteCustomAgents: Boolean;
        CanExportCustomAgents: Boolean;
        ConfirmDeleteAgentQst: Label 'Are you sure you want to delete the agent?\\Tasks and other historical records will be preserved.';
        ConfirmExportAgentsQst: Label 'Are you sure you want to export the selected agent(s)?';
        NoAgentSelectedErr: Label 'No agent is selected. Please create or activate an agent to perform this action.';
        NoAgentsNotificationTxt: Label 'There are no agents created yet.';
        CreateAgentTxt: Label 'Create agent';
        LearnMoreAboutCustomAgentsTxt: Label 'Learn more about custom agents';
}
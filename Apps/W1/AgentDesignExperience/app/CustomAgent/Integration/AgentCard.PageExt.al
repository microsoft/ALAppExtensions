// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Agents.Designer;
using System.Reflection;

pageextension 4353 "Agent Card" extends "Agent Card"
{
    layout
    {
        addafter(DisplayName)
        {
            group(CustomAgentGroup)
            {
                ShowCaption = false;
                Visible = IsCustomAgent;

                field(InstructionVersion; CustomAgentSetup."Instructions Version")
                {
                    Caption = 'Instruction version';
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        CustomAgentInstructionsDialog: Page "Custom Ag. Instructions Dialog";
                    begin
                        CustomAgentInstructionsDialog.SetUserSecurityId(Rec."User Security ID");
                        if CustomAgentInstructionsDialog.RunModal() = Action::OK then begin
                            Commit();
                            if Confirm(OpenEditInstructionsPageQst) then
                                CustomAgentSetupCodeunit.OpenEditInstructionsPage(Rec."User Security ID");
                        end;
                    end;
                }
            }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(CustomizeRoleAction)
            {
                ApplicationArea = All;
                Caption = 'Customize profile (role)';
                Image = SetupColumns;
                Visible = IsWebClient;
                Enabled = IsProfileEditable;
                ToolTip = 'Change the user interface to fit the needs of this agent (opens in new tab). The changes that you make will apply to all users and agents that are assigned this profile.';
                AccessByPermission = tabledata "All Profile" = M;

                trigger OnAction()
                var
                    ConfigurationUrl: Text;
                begin
                    if CustomAgentProfileMgt.TryGetProfileConfigurationUrlForWeb(Rec."User Security ID", ConfigurationUrl) then
                        Hyperlink(ConfigurationUrl);
                end;
            }
            action(ExportAgent)
            {
                ApplicationArea = All;
                Caption = 'Export agent definition';
                ToolTip = 'Export the current agent definition.';
                Enabled = IsCustomAgent;
                Image = Export;

                trigger OnAction()
                var
                    Agent: Record Agent;
                    CustomAgentExport: Codeunit "Custom Agent Export";
                begin
                    if not Confirm(ConfirmExportAgentQst) then
                        exit;

                    Agent.SetRange("User Security ID", Rec."User Security ID");
                    CustomAgentExport.ExportAgents(Agent);
                end;
            }
            action(OpenEditInstructionsPage)
            {
                ApplicationArea = All;
                Caption = 'Test agent';
                ToolTip = 'Open the test agent page to test and interact with this agent.';
                Enabled = IsCustomAgent;
                Image = DocumentEdit;

                trigger OnAction()
                begin
                    CustomAgentSetupCodeunit.OpenEditInstructionsPage(Rec."User Security ID");
                end;
            }
        }
        addlast(Category_Process)
        {
            group(Design)
            {
                Caption = 'Design';
                actionref(OpenEditInstructionsPage_Promoted; OpenEditInstructionsPage)
                {
                }
                actionref(ExportAgent_Promoted; ExportAgent)
                {
                }
                actionref(CustomizeRoleAction_Promoted; CustomizeRoleAction)
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
        IsProfileEditable := CustomAgentProfileMgt.IsProfileEditable(Rec."User Security ID");
        IsWebClient := CustomAgentProfileMgt.IsWebClient();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        GetCustomAgentFields();
    end;

    [NonDebuggable]
    local procedure GetCustomAgentFields()
    begin
        IsCustomAgent := CustomAgentSetup.Get(Rec."User Security ID");
    end;

    protected var
        IsCustomAgent: Boolean;

    var
        CustomAgentSetup: Record "Custom Agent Setup";
        CustomAgentProfileMgt: Codeunit "Custom Agent Profile Mgt";
        CustomAgentSetupCodeunit: Codeunit "Custom Agent Setup";
        IsWebClient, IsProfileEditable : Boolean;
        ConfirmExportAgentQst: Label 'Are you sure you want to export the selected agent?';
        OpenEditInstructionsPageQst: Label 'Do you want to open the test agent page to test the agent with the updated instructions?';
}
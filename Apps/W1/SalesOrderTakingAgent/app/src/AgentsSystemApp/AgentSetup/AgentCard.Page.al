// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

using System.Security.User;
using System.Environment.Configuration;

page 4315 "Agent Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = Agent;
    Caption = 'Agent Card';
    RefreshOnActivate = true;
    DataCaptionExpression = Rec."User Name";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Agent Metadata Provider"; Rec."Agent Metadata Provider")
                {
                    ShowMandatory = true;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Type';
                    Tooltip = 'Specifies the type of the agent.';
                }
                field(UserName; Rec."User Name")
                {
                    ShowMandatory = true;
                    ApplicationArea = Basic, Suite;
                    Caption = 'User Name';
                    Tooltip = 'Specifies the name of the user that is associated with the agent.';
                }

                field(DisplayName; Rec."Display Name")
                {
                    ShowMandatory = true;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Display Name';
                    Tooltip = 'Specifies the display name of the user that is associated with the agent.';
                }
                group(UserSettingsGroup)
                {
                    ShowCaption = false;
                    field(AgentProfile; ProfileDisplayName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Profile';
                        ToolTip = 'Specifies the profile that is associated with the agent.';
                        trigger OnAssistEdit()
                        var
                            AgentImpl: Codeunit "Agent Impl.";
                        begin
                            if AgentImpl.ProfileLookup(UserSettingsRecord) then
                                AgentImpl.UpdateAgentUserSettings(UserSettingsRecord);
                        end;
                    }
                }
                field(State; Rec.State)
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Standard;
                    Caption = 'State';
                    ToolTip = 'Specifies if the agent is enabled or disabled.';
                }
            }

            part(Permissions; "User Subform")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Agent Permission Sets';
                SubPageLink = "User Security ID" = field("User Security ID");
            }
            part(UserAccess; "Agent Access Control")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'User Access';
                SubPageLink = "Agent User Security ID" = field("User Security ID");
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(AgentSetup)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Setup';
                ToolTip = 'Set up agent';
                Image = SetupLines;

                trigger OnAction()
                var
                    TempAgent: Record Agent temporary;
                begin
                    TempAgent.Copy(Rec);
                    TempAgent.Insert();
                    Page.RunModal(Rec."Setup Page ID", TempAgent);
                end;
            }
            action(UserSettingsAction)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'User Settings';
                ToolTip = 'Set up the profile and regional settings for the agent.';
                Image = SetupLines;

                trigger OnAction()
                var
                    UserSettings: Codeunit "User Settings";
                begin
                    Rec.TestField("User Security ID");
                    UserSettings.GetUserSettings(Rec."User Security ID", UserSettingsRecord);
                    Page.RunModal(Page::"User Settings", UserSettingsRecord);
                end;
            }
            action(AgentTasks)
            {
                ApplicationArea = All;
                Caption = 'Agent Tasks';
                ToolTip = 'View agent tasks';
                Image = Log;

                trigger OnAction()
                var
                    AgentTask: Record "Agent Task";
                begin
                    AgentTask.SetRange("Agent User Security ID", Rec."User Security ID");
                    Page.Run(Page::"Agent Task List", AgentTask);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(AgentSetup_Promoted; AgentSetup)
                {
                }
                actionref(UserSettings_Promoted; UserSettingsAction)
                {
                }
                actionref(AgentTasks_Promoted; AgentTasks)
                {
                }
            }
        }
    }

    local procedure UpdateControls()
    var
        AgentImpl: Codeunit "Agent Impl.";
        UserSettings: Codeunit "User Settings";
    begin
        if not IsNullGuid(Rec."User Security ID") then begin
            UserSettings.GetUserSettings(Rec."User Security ID", UserSettingsRecord);
            ProfileDisplayName := AgentImpl.GetProfileName(UserSettingsRecord.Scope, UserSettingsRecord."App ID", UserSettingsRecord."Profile ID");
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateControls();
    end;

    var
        UserSettingsRecord: Record "User Settings";
        ProfileDisplayName: Text;
}
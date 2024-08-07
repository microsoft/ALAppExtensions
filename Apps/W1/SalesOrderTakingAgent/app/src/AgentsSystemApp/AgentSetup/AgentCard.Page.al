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
                    Editable = ControlsEditable;
                }
                field(UserName; Rec."User Name")
                {
                    ShowMandatory = true;
                    ApplicationArea = Basic, Suite;
                    Caption = 'User Name';
                    Tooltip = 'Specifies the name of the user that is associated with the agent.';
                    Editable = ControlsEditable;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }

                field(DisplayName; Rec."Display Name")
                {
                    ShowMandatory = true;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Display Name';
                    Tooltip = 'Specifies the display name of the user that is associated with the agent.';
                    Editable = ControlsEditable;
                }
                group(UserSettingsGroup)
                {
                    ShowCaption = false;
                    field(AgentProfile; ProfileDisplayName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Profile';
                        ToolTip = 'Specifies the profile that is associated with the agent.';
                        Editable = false;

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
                    trigger OnValidate()
                    begin
                        UpdateControls();
                    end;
                }
            }
            group(InstructionsGroup)
            {
                Caption = 'Instructions';
                Visible = (Rec."Setup Page ID" = 0) or ShowInstructions;
                Enabled = AgentRecordExists;
                field(Instructions; InstructionsTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Instructions';
                    ShowCaption = false;
                    ExtendedDatatype = RichContent;
                    MultiLine = true;
                    Editable = ControlsEditable;
                    ToolTip = 'Specifies the instructions for the agent.';

                    trigger OnValidate()
                    var
                        AgentImpl: Codeunit "Agent Impl.";
                    begin
                        AgentImpl.SetInstructions(Rec, InstructionsTxt);
                    end;
                }
            }
            group(ConfigureGroup)
            {
                ShowCaption = false;
                Visible = (Rec."Setup Page ID" <> 0);
                Enabled = AgentRecordExists;

                field(ConfigureAgent; ConfigureAgentTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Instructions';
                    ShowCaption = false;
                    ToolTip = 'Specifies the instructions for the agent.';

                    trigger OnDrillDown()
                    var
                        TempAgent: Record Agent temporary;
                    begin
                        TempAgent.Copy(Rec);
                        TempAgent.Insert();
                        Page.RunModal(Rec."Setup Page ID", TempAgent);
                    end;
                }
            }

            part(Permissions; "User Subform")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Agent Permission Sets';
                Enabled = AgentRecordExists;
                Editable = ControlsEditable;
                SubPageLink = "User Security ID" = field("User Security ID");
            }
            part(UserAccess; "Agent Access Control")
            {
                Enabled = AgentRecordExists;
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
                    Commit();
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
            action(ShowInstructionsAction)
            {
                ApplicationArea = All;
                Caption = 'Show Instructions';
                ToolTip = 'Show the instructions for the agent.';
                Image = ShowChart;

                trigger OnAction()
                begin
                    ShowInstructions := true;
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
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
        AgentRecordExists := true;
        if IsNullGuid(Rec."User Security ID") then
            AgentRecordExists := false;
        ControlsEditable := Rec.State = Rec.State::Disabled;
        ShowEnableWarning := '';
        if CurrPage.Editable and (Rec.State = Rec.State::Enabled) then
            ShowEnableWarning := EnabledWarningTok;

        InstructionsTxt := AgentImpl.GetInstructions(Rec);

        if not IsNullGuid(Rec."User Security ID") then begin
            UserSettings.GetUserSettings(Rec."User Security ID", UserSettingsRecord);
            ProfileDisplayName := AgentImpl.GetProfileName(UserSettingsRecord.Scope, UserSettingsRecord."App ID", UserSettingsRecord."Profile ID");
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateControls();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.State := Rec.State::Disabled;
        InstructionsTxt := '';
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        AgentAccessControl: Record "Agent Access Control";
        AgentImpl: Codeunit "Agent Impl.";
    begin
        Rec.Insert(true);
        AgentImpl.InsertCurrentOwnerIfNoOwnersDefined(Rec, AgentAccessControl);
        CurrPage.Update(false);
        exit(false);
    end;

    var
        UserSettingsRecord: Record "User Settings";
        EnabledWarningTok: Label 'You must set the State field to Disabled before you can make changes to this app.';
        ConfigureAgentTxt: Label 'Open configuration wizard';
        InstructionsTxt: Text;
        ProfileDisplayName: Text;
        ShowEnableWarning: Text;
        AgentRecordExists: Boolean;
        ControlsEditable: Boolean;
        // TODO: Remove before release
        ShowInstructions: Boolean;
}
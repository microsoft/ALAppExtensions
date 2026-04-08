// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

using System.Agents;
using System.Agents.Designer.CustomAgent;
using System.Environment.Consumption;
using System.Reflection;

page 4363 "Agent Instruction Editor"
{
    PageType = Document;
    ApplicationArea = All;
    Caption = 'Test agent';
    InherentEntitlements = X;
    InherentPermissions = X;
    SourceTable = "Custom Agent Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Extensible = false;
    DataCaptionExpression = DataCaptionTxt;

    layout
    {
        area(Content)
        {
            group(InstructionsGroup)
            {
                ShowCaption = false;

                part(InstructionsPart; "Custom Agent Instructions Part")
                {
                    ApplicationArea = All;
                    Caption = 'Instructions';
                }
            }
            part(AgentTaskLogEntryPart; "Agent Task Log Entry Instr")
            {
                Caption = 'Task log';
                ApplicationArea = All;
                SubPageLink = "User Security ID" = field("User Security ID");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(CreateTaskGroup)
            {
                ShowAs = SplitButton;

                action(CreateTask)
                {
                    ApplicationArea = All;
                    Caption = 'Run task';
                    ToolTip = 'Run a new task.';
                    Image = Start;

                    trigger OnAction()
                    var
                        NewAgentTask: Record "Agent Task";
                        AgentNewTask: Page "Agent New Task Message";
                    begin
                        NewAgentTask."Agent User Security ID" := Rec."User Security ID";

                        AgentNewTask.SetAgentTask(NewAgentTask, true);
                        AgentNewTask.LookupMode(true);
                        AgentNewTask.RunModal();
                        CurrPage.AgentTaskLogEntryPart.Page.ShowLastTask();
                        CurrPage.Update(false);
                    end;
                }
                action(CreateTaskFromTemplate)
                {
                    ApplicationArea = All;
                    Caption = 'Run task from template';
                    ToolTip = 'Run a new task from a template.';
                    Image = ApplyTemplate;

                    trigger OnAction()
                    var
                        AgentTaskTemplate: Codeunit "Agent Task Template";
                    begin
                        AgentTaskTemplate.CreateTaskFromTemplate(Rec."User Security ID");
                        CurrPage.AgentTaskLogEntryPart.Page.ShowLastTask();
                        CurrPage.Update(false);
                    end;
                }
            }
            group(NewMessageGroup)
            {
                ShowAs = SplitButton;
                action(AddMessage)
                {
                    ApplicationArea = All;
                    Caption = 'Add new message';
                    ToolTip = 'Adds a new message to the task.';
                    Image = Task;
                    Enabled = TaskSelected;

                    trigger OnAction()
                    var
                        CurrentAgentTask: Record "Agent Task";
                        AgentNewTaskMessage: Page "Agent New Task Message";
                    begin
                        GetAgentTaskSafe(CurrentAgentTask, CurrPage.AgentTaskLogEntryPart.Page.GetTaskID());
                        AgentNewTaskMessage.SetAgentTask(CurrentAgentTask);
                        AgentNewTaskMessage.LookupMode(true);
                        AgentNewTaskMessage.RunModal();
                        CurrPage.Update(false);
                    end;
                }
                action(CreateMessageFromTemplate)
                {
                    ApplicationArea = All;
                    Caption = 'Add message from template';
                    ToolTip = 'Adds a new message from a template.';
                    Image = ApplyTemplate;
                    Enabled = TaskSelected;

                    trigger OnAction()
                    var
                        AgentTaskTemplate: Codeunit "Agent Task Template";
                    begin
                        AgentTaskTemplate.CreateMessageFromTemplate(CurrPage.AgentTaskLogEntryPart.Page.GetTaskID());
                        CurrPage.Update(false);
                    end;
                }
            }


            action(RepeatTask)
            {
                ApplicationArea = All;
                Caption = 'Repeat task';
                ToolTip = 'Create a new task with the same title and properties. Only the first message and its attachments will be included.';
                Image = Copy;
                Enabled = TaskSelected;

                trigger OnAction()
                var
                    AgentTaskTemplate: Codeunit "Agent Task Template";
                begin
                    AgentTaskTemplate.RepeatTask(CurrPage.AgentTaskLogEntryPart.Page.GetTaskID());
                    Commit();
                    CurrPage.AgentTaskLogEntryPart.Page.ShowLastTask();
                    CurrPage.Update(false);
                end;
            }
            group(StartStopGroup)
            {
                ShowAs = SplitButton;

                action(Stop)
                {
                    ApplicationArea = All;
                    Caption = 'Stop';
                    ToolTip = 'Stop the selected task.';
                    Image = Stop;

                    trigger OnAction()
                    var
                        AgentTaskRecord: Record "Agent Task";
                        AgentTask: Codeunit "Agent Task";
                    begin
                        if GetAgentTaskSafe(AgentTaskRecord, CurrPage.AgentTaskLogEntryPart.Page.GetTaskID()) then
                            AgentTask.StopTask(AgentTaskRecord, true);
                    end;
                }
                action(Resume)
                {
                    ApplicationArea = All;
                    Caption = 'Resume';
                    ToolTip = 'Resume the selected task.';
                    Image = Restore;

                    trigger OnAction()
                    var
                        AgentTaskRecord: Record "Agent Task";
                        AgentTask: Codeunit "Agent Task";
                    begin
                        GetAgentTaskSafe(AgentTaskRecord, CurrPage.AgentTaskLogEntryPart.Page.GetTaskID());
                        AgentTask.RestartTask(AgentTaskRecord, true);
                    end;
                }
            }
            group(CopyToTemplateGroup)
            {
                ShowAs = SplitButton;

                action(CopyToTemplate)
                {
                    ApplicationArea = All;
                    Caption = 'Save task to template';
                    ToolTip = 'Create a new template from the selected task.';
                    Image = Copy;
                    Enabled = TaskSelected;

                    trigger OnAction()
                    var
                        TempAgentTaskTemplateBuffer: Record "Agent Task Template Buffer";
                        AgentTaskTemplate: Codeunit "Agent Task Template";
                        AgentTaskTemplateID: Integer;
                    begin
                        AgentTaskTemplateID := AgentTaskTemplate.CreateTemplateFromTask(CurrPage.AgentTaskLogEntryPart.Page.GetTaskID());

                        if AgentTaskTemplateID = 0 then
                            exit;

                        if Confirm(EditTemplateQst, true) then begin
                            TempAgentTaskTemplateBuffer.LoadRecords(Enum::"Agent Template Type"::"Agent Task Template");
                            TempAgentTaskTemplateBuffer.Get(AgentTaskTemplateID);
                            Page.Run(Page::"Agent Task Template Card", TempAgentTaskTemplateBuffer);
                        end;
                    end;
                }
                action(AgentTemplateList)
                {
                    ApplicationArea = All;
                    Caption = 'Task templates';
                    ToolTip = 'Configure agent task templates.';
                    RunObject = page "Agent Task Templates";
                    Image = Template;
                }
            }
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
            action(AgentTasks)
            {
                ApplicationArea = All;
                Caption = 'View tasks';
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
            action(AgentSetup)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Agent setup card';
                ToolTip = 'Set up the agent';
                Image = SetupLines;

                trigger OnAction()
                var
                    Agent: Codeunit Agent;
                begin
                    GetAgentSafe();
                    Agent.OpenSetupPageId(GlobalAgent."Agent Metadata Provider", GlobalAgent."User Security ID");
                    CurrPage.Update(false);
                end;
            }
            action(ShowConsumptionData)
            {
                ApplicationArea = All;
                Caption = 'View consumption data';
                ToolTip = 'View AI consumption data for this agent.';
                Image = BankAccountLedger;

                trigger OnAction()
                var
                    UserAIConsumptionData: Record "User AI Consumption Data";
                begin
                    UserAIConsumptionData.SetRange("User ID", Rec."User Security ID");
                    Page.Run(Page::"Agent Consumption Overview", UserAIConsumptionData);
                end;
            }
            group(InstructionsGroupActions)
            {
                Caption = 'Instructions';
                ShowAs = SplitButton;

                action(SaveAsVersion)
                {
                    ApplicationArea = All;
                    Caption = 'Save instructions to history';
                    ToolTip = 'Save the current instructions as a new version with a custom name.';
                    Image = Save;

                    trigger OnAction()
                    var
                        CustomAgentInstructions: Codeunit "Custom Agent Instructions";
                    begin
                        if not CustomAgentInstructions.SaveInstructionsAsNewVersion(CurrPage.InstructionsPart.Page.GetInstructions(), GlobalAgentUserSecurityId) then
                            exit;

                        CurrPage.InstructionsPart.Page.RefreshInstructionsAddin(true);
                        CurrPage.Update(false);
                    end;
                }
                action(ViewHistory)
                {
                    Caption = 'View instruction history';
                    ApplicationArea = All;
                    ToolTip = 'View the history of changes made to the agent instructions and restore an earlier version if needed.';
                    Image = History;

                    trigger OnAction()
                    var
                        CustomAgentInstructionsLog: Page "Cust. Agent Instructions Log";
                    begin
                        CustomAgentInstructionsLog.SetGlobalAgentUserSecurityId(GlobalAgentUserSecurityId);
                        CustomAgentInstructionsLog.RunModal();
                        if not CustomAgentInstructionsLog.GetRestoredPreviousVersionOfInstructions() then
                            exit;

                        CurrPage.InstructionsPart.Page.RefreshInstructionsAddin(true);
                        CurrPage.Update(false);
                    end;
                }
                action(DownloadInstructions)
                {
                    ApplicationArea = All;
                    Caption = 'Download instructions';
                    ToolTip = 'Download the current agent instructions to a text file.';
                    Image = Export;

                    trigger OnAction()
                    var
                        CustomAgentInstructions: Codeunit "Custom Agent Instructions";
                    begin
                        CustomAgentInstructions.DownloadCurrentInstructions(CurrPage.InstructionsPart.Page.GetInstructions());
                    end;
                }
                action(HowToWriteInstructions)
                {
                    ApplicationArea = All;
                    Caption = 'How to write instructions';
                    ToolTip = 'Opens a web page that provides more information about defining instructions and building agents.';
                    Image = Help;

                    trigger OnAction()
                    var
                        CustomAgentInstructions: Codeunit "Custom Agent Instructions";
                    begin
                        Hyperlink(CustomAgentInstructions.GetHowToWriteInstructionsUrl());
                    end;
                }
            }
            action(Feedback)
            {
                ApplicationArea = All;
                Caption = 'Give feedback';
                ToolTip = 'Tell us what you think about Agent Designer and suggest new features or improvements.';
                Image = Comment;

                trigger OnAction()
                var
                    AgentDesignerUserFeedback: Codeunit "Agent Designer User Feedback";
                begin
                    AgentDesignerUserFeedback.RequestAgentDesignerFeedback('Instruction editor', GlobalAgent);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                group(NewTaskGroup)
                {
                    ShowAs = SplitButton;
                    actionref(CreateTask_Promoted; CreateTask)
                    {
                    }
                    actionref(CreateTaskFromTemplate_Promoted; CreateTaskFromTemplate)
                    {
                    }
                }
                group(NewMessageGroup_Promoted)
                {
                    ShowAs = SplitButton;
                    actionref(AddMessage_Promoted; AddMessage)
                    {
                    }
                    actionref(CreateMessageFromTemplate_Promoted; CreateMessageFromTemplate)
                    {
                    }
                }
                actionref(RepeatTask_Promoted; RepeatTask)
                {
                }
                group(ManageTaskGroup)
                {
                    ShowAs = SplitButton;
                    actionref(Stop_Promoted; Stop)
                    {
                    }
                    actionref(Resume_Promoted; Resume)
                    {
                    }
                }
                group(CopyToTemplateGroup_Promoted)
                {
                    ShowAs = SplitButton;
                    actionref(CopyToTemplate_Promoted; CopyToTemplate)
                    {
                    }
                    actionref(AgentTemplateList_Promoted; AgentTemplateList)
                    {
                    }
                }
            }
            group(InstructionsGroup_Promoted)
            {
                Caption = 'Instructions';
                actionref(SaveAsVersion_Promoted; SaveAsVersion)
                {
                }
                actionref(ViewHistory_Promoted; ViewHistory)
                {
                }
                actionref(DownloadInstructions_Promoted; DownloadInstructions)
                {
                }
                actionref(HowToWriteInstructions_Promoted; HowToWriteInstructions)
                {
                }
            }
            group(AgentSetupGroup)
            {
                Caption = 'Agent setup';
                actionref(CustomizeRoleAction_Promoted; CustomizeRoleAction)
                {
                }
                actionref(AgentTasks_Promoted; AgentTasks)
                {
                }
                actionref(AgentSetup_Promoted; AgentSetup)
                {
                }
                actionref(ShowConsumptionData_Promoted; ShowConsumptionData)
                {
                }
            }
            actionref(Feedback_Promoted; Feedback)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetupFiltering();
        InitializeControls();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        TaskSelected := CurrPage.AgentTaskLogEntryPart.Page.HasTaskSelected();
    end;

    local procedure InitializeControls()
    begin
        IsProfileEditable := CustomAgentProfileMgt.IsProfileEditable(GlobalAgentUserSecurityId);
        IsWebClient := CustomAgentProfileMgt.IsWebClient();
        CurrPage.InstructionsPart.Page.SetUserSecurityId(GlobalAgentUserSecurityId);
        CurrPage.InstructionsPart.Page.SetHideDeveloperUI(true);

        CurrPage.AgentTaskLogEntryPart.Page.SetUserSecurityId(GlobalAgentUserSecurityId);
        DataCaptionTxt := GetPageCaption();
    end;

    local procedure SetupFiltering()
    begin
        ValidateUserSecurityId();
        Rec.FilterGroup(4);
        Rec.SetRange("User Security ID", GlobalAgentUserSecurityId);
        Rec.FilterGroup(0);
    end;

    procedure SetUserSecurityId(NewUserSecId: Guid)
    begin
        GlobalAgentUserSecurityId := NewUserSecId;
    end;

    local procedure ValidateUserSecurityId()
    var
        AgentDesignerPermissions: Codeunit "Agent Designer Permissions";
    begin
        if IsNullGuid(GlobalAgentUserSecurityId) and IsNullGuid(Rec."User Security ID") then
            Error(PageCannotBeOpenedDirectlyErr);

        // Needed for refresh scenario
        if IsNullGuid(GlobalAgentUserSecurityId) then
            GlobalAgentUserSecurityId := Rec."User Security ID";

        AgentDesignerPermissions.VerifyCurrentUserCanConfigureCustomAgent(GlobalAgentUserSecurityId);
        GetAgentSafe();
    end;

    local procedure GetPageCaption(): Text
    begin
        GetAgentSafe();
        exit(StrSubstNo(AgentInstructionsTxt, GlobalAgent."Display Name"));
    end;

    local procedure GetAgentSafe()
    begin
        if not GlobalAgent.Get(GlobalAgentUserSecurityId) then
            Error(AgentNotFoundErr, GlobalAgentUserSecurityId);
    end;

    local procedure GetAgentTaskSafe(var AgentTask: Record "Agent Task"; TaskID: Integer): Boolean
    begin
        if not AgentTask.Get(TaskID) then
            Error(AgentTaskNotFoundErr, TaskID);
        exit(true);
    end;

    var
        GlobalAgent: Record Agent;
        CustomAgentProfileMgt: Codeunit "Custom Agent Profile Mgt";
        DataCaptionTxt: Text;
        IsWebClient, IsProfileEditable, TaskSelected : Boolean;
        GlobalAgentUserSecurityId: Guid;
        PageCannotBeOpenedDirectlyErr: Label 'The agent instruction editor page cannot be opened directly. Please access it through the agent list or agent card pages.';
        AgentInstructionsTxt: Label 'Agent - %1', Comment = '%1 is the agent display name.';
        EditTemplateQst: Label 'Template was created. Do you want to edit the template now?';
        AgentNotFoundErr: Label 'The agent with ID ''%1'' was not found.', Comment = '%1 is the agent user security ID.';
        AgentTaskNotFoundErr: Label 'The agent task with ID ''%1'' was not found.', Comment = '%1 is the agent task ID.';
}
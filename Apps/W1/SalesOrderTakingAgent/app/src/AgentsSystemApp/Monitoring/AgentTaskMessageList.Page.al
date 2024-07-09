// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

page 4301 "Agent Task Message List"
{
    PageType = List;
    ApplicationArea = All;
    Caption = 'Agent Task Messages';
    UsageCategory = Administration;
    SourceTable = "Agent Task Message";
    CardPageId = "Agent Task Message Card";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(LastModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'Last modified at';
                    ToolTip = 'Specifies the date and time when the message was last modified.';
                }
                field(CreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Created at';
                    ToolTip = 'Specifies the date and time when the message was created.';
                }
                field(Status; Rec.Status)
                {
                    Caption = 'Status';
                    BlankZero = true;
                    BlankNumbers = BlankZero;
                }
                field("Created By Full Name"; Rec."Created By Full Name")
                {
                    Caption = 'Created by';
                }
                field(MessageType; Rec.Type)
                {
                    Caption = 'Type';
                }
                field(MessageText; GlobalMessageText)
                {
                    Caption = 'Message';
                    ToolTip = 'Specifies the message text.';

                    trigger OnDrillDown()
                    begin
                        Message(GlobalMessageText);
                    end;
                }
                field(TaskID; Rec."Task Id")
                {
                    Visible = false;
                    Caption = 'Task ID';
                }
                field(MessageId; Rec."ID")
                {
                    Caption = 'ID';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(AddMessage)
            {
                ApplicationArea = All;
                Caption = 'Create new message';
                ToolTip = 'Create a new message.';
                Image = Task;

                trigger OnAction()
                var
                    CurrentAgentTask: Record "Agent Task";
                    AgentNewTaskMessage: Page "Agent New Task Message";
                begin
                    CurrentAgentTask.Get(Rec."Task ID");
                    AgentNewTaskMessage.SetAgentTask(CurrentAgentTask);
                    AgentNewTaskMessage.RunModal();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(AddMessage_Promoted; AddMessage)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateControls();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateControls();
    end;

    local procedure UpdateControls()
    var
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
    begin
        GlobalMessageText := AgentMonitoringImpl.GetMessageText(Rec);
    end;

    var
        GlobalMessageText: Text;
}
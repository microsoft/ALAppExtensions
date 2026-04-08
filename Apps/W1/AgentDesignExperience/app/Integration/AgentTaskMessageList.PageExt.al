// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

using System.Agents;

pageextension 4352 "Agent Task Message List" extends "Agent Task Message List"
{
    actions
    {
        addlast(Processing)
        {
            group(AddMessageGroup)
            {
                ShowAs = SplitButton;
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
                        if Rec."Task ID" = 0 then
                            Error(NoTaskIsSelectedErr);

                        if not CurrentAgentTask.Get(Rec."Task ID") then begin
                            CurrentAgentTask.SetFilter(ID, Rec.GetFilter("Task ID"));
                            CurrentAgentTask.FindFirst();
                        end;

                        AgentNewTaskMessage.SetAgentTask(CurrentAgentTask);
                        AgentNewTaskMessage.LookupMode(true);
                        AgentNewTaskMessage.RunModal();
                        CurrPage.Update(false);
                    end;
                }
                action(CreateMessageFromTemplate)
                {
                    ApplicationArea = All;
                    Caption = 'Create message from template';
                    ToolTip = 'Create a new message from a template.';
                    Image = ApplyTemplate;

                    trigger OnAction()
                    var
                        AgentTaskTemplate: Codeunit "Agent Task Template";
                    begin
                        AgentTaskTemplate.CreateMessageFromTemplate(Rec."Task ID");
                        CurrPage.Update(false);
                    end;
                }
            }
            action(MarkAsSent)
            {
                ApplicationArea = All;
                Caption = 'Mark message as sent';
                ToolTip = 'Mark the current message as sent';
                Image = SendMail;
                Enabled = (Rec.Type = Rec.Type::Output) and (Rec.Status = Rec.Status::Reviewed);

                trigger OnAction()
                begin
                    if Rec."Task ID" = 0 then
                        Error(NoTaskIsSelectedErr);

                    Rec.Status := Rec.Status::Sent;
                    Rec.Modify();
                    CurrPage.Update(false);
                end;
            }
        }
        addlast(Promoted)
        {
            group(Design)
            {
                Caption = 'Design';
                actionref(AddMessage_Promoted; AddMessage)
                {
                }
                actionref(CreateMessageFromTemplate_Promoted; CreateMessageFromTemplate)
                {
                }
                actionref(MarkAsSent_Promoted; MarkAsSent)
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
    end;

    var
        NoTaskIsSelectedErr: Label 'No task is selected. There must be a task selected to create a new message.';
}
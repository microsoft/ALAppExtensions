// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

page 4302 "Agent New Task Message"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Create message';
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(Message)
            {
                ShowCaption = false;
                field(MessageText; MessageText)
                {
                    Caption = 'Message Text';
                    ToolTip = 'Specifies the text of the message.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
    begin
        if not (CloseAction in [Action::Ok, Action::LookupOK, Action::Yes]) then
            exit(true);

        AgentMonitoringImpl.CreateTaskMessage(MessageText, AgentTask);
        exit(true);
    end;

    procedure SetAgentTask(var NewAgentTask: Record "Agent Task")
    begin
        AgentTask.Copy(NewAgentTask);
    end;

    var
        AgentTask: Record "Agent Task";
        MessageText: Text;
}
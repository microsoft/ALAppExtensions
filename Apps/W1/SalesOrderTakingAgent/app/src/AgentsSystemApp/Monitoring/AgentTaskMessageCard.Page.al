// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

page 4308 "Agent Task Message Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Agent Task Message";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = 'Agent Task Message';
    DataCaptionExpression = '';
    Extensible = false;
    SourceTableView = sorting(SystemModifiedAt) order(descending);

    layout
    {
        area(Content)
        {
            group(General)
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
                field(TaskID; Rec."Task Id")
                {
                    Caption = 'Task ID';
                    Visible = false;
                }
                field(MessageID; Rec."ID")
                {
                    Caption = 'ID';
                    Visible = false;
                }
                field(MessageType; Rec.Type)
                {
                    Caption = 'Type';
                }
                field(Status; Rec.Status)
                {
                    Caption = 'Status';
                }
            }

            group(Message)
            {
                Caption = 'Message';
                Editable = IsMessageEditable;
                field(MessageText; GlobalMessageText)
                {
                    ShowCaption = false;
                    Caption = 'Message';
                    ToolTip = 'Specifies the message text.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    Editable = true;
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
        IsMessageEditable := AgentMonitoringImpl.IsMessageEditable(Rec);
    end;

    var
        GlobalMessageText: Text;
        IsMessageEditable: Boolean;
}
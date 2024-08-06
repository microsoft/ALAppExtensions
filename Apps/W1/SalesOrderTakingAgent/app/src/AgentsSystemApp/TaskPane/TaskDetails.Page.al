// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

page 4313 "TaskDetails"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Agent Task Timeline Entry Step";
    Caption = 'Agent Task Timeline Entry Step';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Steps)
            {
                field(ClientContext; ClientContext)
                {
                    Caption = 'Client Context';
                    ToolTip = 'Specifies the client context.';
                }
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action(Confirm)
            {
                Caption = 'Confirm';
                ToolTip = 'Confirms the timeline entry.';
                Image = Confirm;

                trigger OnAction()
                begin
                    AddUserInterventionTaskStep();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetClientContext();
    end;

    procedure SetClientContext()
    var
        InStream: InStream;
    begin
        if Rec.CalcFields("Client Context") then
            if Rec."Client Context".HasValue() then begin
                Rec."Client Context".CreateInStream(InStream);
                ClientContext.Read(InStream)
            end;
    end;

    local procedure AddUserInterventionTaskStep()
    var
        UserInterventionRequestStep: Record "Agent Task Step";
        TaskTimelineEntry: Record "Agent Task Timeline Entry";
        UserInput: Text;
    begin
        if TaskTimelineEntry.FindFirst() then begin
            UserInterventionRequestStep.SetRange("Task ID", Rec."Task ID");
            UserInterventionRequestStep.SetRange("Step Number", Rec."Step Number");
            case TaskTimelineEntry."User Intervention Request Type" of
                TaskTimelineEntry."User Intervention Request Type"::ReviewMessage:
                    UserInput := '';
                else
                    UserInput := UserMessage;
            end;

            if UserInterventionRequestStep.FindFirst() then
                AgentMonitoringImpl.CreateUserInterventionTaskStep(UserInterventionRequestStep, UserInput);
        end;
    end;

    var
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
        ClientContext: BigText;
        UserMessage: Text;
}



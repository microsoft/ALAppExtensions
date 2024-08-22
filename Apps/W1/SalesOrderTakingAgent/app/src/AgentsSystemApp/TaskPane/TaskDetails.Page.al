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

#pragma warning disable AW0005
            action(Confirm)
#pragma warning restore AW0005
            {
                Caption = 'Confirm';
                ToolTip = 'Confirms the timeline entry.';

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
                ClientContext.Read(InStream);
            end;
    end;

    local procedure AddUserInterventionTaskStep()
    var
        UserInterventionRequestStep: Record "Agent Task Step";
        TaskTimelineEntry: Record "Agent Task Timeline Entry";
        UserInput: Text;
    begin
        TaskTimelineEntry.SetRange("Task ID", Rec."Task ID");
        TaskTimelineEntry.SetRange(ID, Rec."Timeline Entry ID");
        TaskTimelineEntry.SetRange("Last Step Type", TaskTimelineEntry."Last Step Type"::"User Intervention Request");
        if TaskTimelineEntry.FindLast() then begin
            case TaskTimelineEntry."User Intervention Request Type" of
                TaskTimelineEntry."User Intervention Request Type"::ReviewMessage:
                    UserInput := '';
                else
                    UserInput := UserMessage; //ToDo: Will be implemented when we have a message field.
            end;

            UserInterventionRequestStep.SetRange("Task ID", Rec."Task ID");
            UserInterventionRequestStep.SetRange(Type, UserInterventionRequestStep.Type::"User Intervention Request");
            if UserInterventionRequestStep.FindLast() then
                AgentMonitoringImpl.CreateUserInterventionTaskStep(UserInterventionRequestStep, UserInput);
        end;
    end;

    var
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
        ClientContext: BigText;
        UserMessage: Text;
}



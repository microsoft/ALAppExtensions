// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

page 4322 "API - Agent Task"
{
    PageType = API;
    Caption = 'task', Locked = true;
    APIPublisher = 'microsoft';
    APIGroup = 'agent';
    APIVersion = 'v1.0';
    EntityName = 'task';
    EntitySetName = 'tasks';
    SourceTable = "Agent Task";
    DelayedInsert = true;
    ODataKeyFields = ID;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.ID)
                {
                    Caption = 'Id', Locked = true;
                }

                field(status; Rec.Status)
                {
                    Caption = 'Status', Locked = true;
                }

                field(agentUserName; AgentUserName)
                {
                    Caption = 'Agent user name', Locked = true;
                }

                field(createdBy; Rec."Created By")
                {
                    Caption = 'Status', Locked = true;
                }


                field(agentUserId; Rec."Agent User Security ID")
                {
                    Caption = 'AgentUserId', Locked = true;
                }

                field(externalID; Rec."External ID")
                {
                    Caption = 'External ID', Locked = true;
                }
            }
            part(Messages; "API - Agent Task Message")
            {
                ApplicationArea = All;
                Caption = 'messages';
                SubPageLink = "Task ID" = field(ID);
            }

            part(Steps; "Api - Agent Task Step")
            {
                ApplicationArea = All;
                Caption = 'Steps';
                SubPageLink = "Task ID" = field(ID);
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        AgentRec: Record "Agent";
    begin
        AgentRec.SetRange("User Name", AgentUserName);
        AgentRec.FindFirst();
        Rec."Agent User Security ID" := AgentRec."User Security ID";
        Rec."Created By" := UserSecurityId();
        Rec.Status := Rec.Status::Paused;
        exit(not Rec.Insert(true, true))
    end;

    [ServiceEnabled]
    procedure RunAgent(messageText: Text): Text
    var
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
    begin
        AgentMonitoringImpl.CreateTaskMessage(messageText, Rec);
    end;


    [ServiceEnabled]
    procedure UserIntervention(input: Text): Text
    var
        UserInterventionRequestStep: Record "Agent Task Step";
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
    begin
        UserInterventionRequestStep.Get(Rec.ID, Rec."Last Step Number");
        AgentMonitoringImpl.CreateUserInterventionTaskStep(UserInterventionRequestStep, input)
    end;

    var
        AgentUserName: Text;
}
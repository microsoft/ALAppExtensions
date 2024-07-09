// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

codeunit 4300 "Agent Monitoring Impl."
{
    Access = Internal;

    internal procedure GetMessageText(var AgentTaskMessage: Record "Agent Task Message"): Text
    var
        ContentInStream: InStream;
        ContentText: Text;
    begin
        AgentTaskMessage.CalcFields(Content);
        AgentTaskMessage.Content.CreateInStream(ContentInStream, GetDefaultEncoding());
        ContentInStream.Read(ContentText);
        exit(ContentText);
    end;

    internal procedure IsMessageEditable(var AgentTaskMessage: Record "Agent Task Message"): Boolean
    begin
        if AgentTaskMessage.Type <> AgentTaskMessage.Type::Output then
            exit(false);

        exit(AgentTaskMessage.Status = AgentTaskMessage.Status::Draft);
    end;

    internal procedure SetMessageText(var AgentTaskMessage: Record "Agent Task Message"; MessageText: Text)
    var
        ContentOutStream: OutStream;
    begin
        Clear(AgentTaskMessage.Content);
        AgentTaskMessage.Content.CreateOutStream(ContentOutStream, GetDefaultEncoding());
        ContentOutStream.Write(MessageText);
        AgentTaskMessage.Modify(true);
    end;

    internal procedure GetStepsDoneCount(var AgentTask: Record "Agent Task"): Integer
    var
        AgentTaskStep: Record "Agent Task Step";
    begin
        AgentTaskStep.SetRange("Task ID", AgentTask."ID");
        AgentTaskStep.ReadIsolation := IsolationLevel::ReadCommitted;
        exit(AgentTaskStep.Count());
    end;

    internal procedure GetDetailsForAgentTaskStep(var AgentTaskStep: Record "Agent Task Step"): Text
    var
        ContentInStream: InStream;
        ContentText: Text;
    begin
        AgentTaskStep.CalcFields(Details);
        AgentTaskStep.Details.CreateInStream(ContentInStream, GetDefaultEncoding());
        ContentInStream.Read(ContentText);
        exit(ContentText);
    end;

    internal procedure ShowTaskSteps(var AgentTask: Record "Agent Task")
    var
        AgentTaskStep: Record "Agent Task Step";
    begin
        AgentTaskStep.SetRange("Task ID", AgentTask.ID);
        Page.Run(Page::"Agent Task Step List", AgentTaskStep);
    end;

    internal procedure CreateTaskMessage(MessageText: Text; var CurrentAgentTask: Record "Agent Task")
    var
        AgentTask: Record "Agent Task";
        AgentTaskMessage: Record "Agent Task Message";
    begin
        if MessageText = '' then
            Error(MessageTextMustBeProvidedErr);

        if not AgentTask.Get(CurrentAgentTask.RecordId) then begin
            AgentTask."Agent User Security ID" := CurrentAgentTask."Agent User Security ID";
            AgentTask."Created By" := UserSecurityId();
            AgentTask.Status := AgentTask.Status::Stopped;
            AgentTask.Insert();
        end;

        AgentTaskMessage."Task ID" := AgentTask.ID;
        AgentTaskMessage."Type" := AgentTaskMessage."Type"::Input;
        AgentTaskMessage.Insert();

        SetMessageText(AgentTaskMessage, MessageText);

        AgentTask.Status := AgentTask.Status::Ready;
        AgentTask.Modify(true);
    end;

    internal procedure CreateUserInterventionTaskStep(TaskID: BigInteger; UserInput: Text)
    var
        AgentTask: Record "Agent Task";
        AgentTaskStep: Record "Agent Task Step";
        DetailsOutStream: OutStream;
        DetailsJson: JsonObject;
    begin

        AgentTask.Get(TaskID);

        AgentTaskStep."Task ID" := AgentTask.ID;
        AgentTaskStep."Type" := AgentTaskStep."Type"::"User Intervention";
        AgentTaskStep.Description := 'User intervention';
        if (UserInput <> '') then begin
            DetailsJson.Add('userInput', UserInput);
            AgentTaskStep.CalcFields(Details);
            Clear(AgentTaskStep.Details);
            AgentTaskStep.Details.CreateOutStream(DetailsOutStream, GetDefaultEncoding());
            DetailsJson.WriteTo(DetailsOutStream);
        end;
        AgentTaskStep.Insert();

        AgentTask.Status := AgentTask.Status::Ready;
        AgentTask.Modify(true);
    end;

    internal procedure StopTask(var AgentTask: Record "Agent Task")
    begin
        if not Confirm(AreYouSureThatYouWantToStopTheTaskQst) then
            exit;

        AgentTask.Status := AgentTask.Status::Stopped;
        AgentTask.Modify(true);
    end;

    internal procedure RestartTask(var AgentTask: Record "Agent Task")
    begin
        if not Confirm(AreYouSureThatYouWantToRestartTheTaskQst) then
            exit;

        AgentTask.Status := AgentTask.Status::Ready;
        AgentTask.Modify(true);
    end;

    internal procedure SelectAgent(var Agent: Record "Agent")
    begin
        Agent.SetRange(State, Agent.State::Enabled);
        if Agent.Count() = 0 then
            Error(NoActiveAgentsErr);

        if Agent.Count() = 1 then begin
            Agent.FindFirst();
            exit;
        end;

        if not (Page.RunModal(Page::"Agent List", Agent) in [Action::LookupOK, Action::OK]) then
            Error('');
    end;

    local procedure GetDefaultEncoding(): TextEncoding
    begin
        exit(TextEncoding::UTF8);
    end;

    var
        MessageTextMustBeProvidedErr: Label 'You must provide a message text.';
        AreYouSureThatYouWantToRestartTheTaskQst: Label 'Are you sure that you want to restart the task?';
        AreYouSureThatYouWantToStopTheTaskQst: Label 'Are you sure that you want to stop the task?';
        NoActiveAgentsErr: Label 'There are no active agents setup on the system.';
}
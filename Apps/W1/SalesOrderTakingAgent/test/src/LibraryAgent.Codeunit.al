// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Agents;

using System.Agents;
using System.TestTools.TestRunner;

codeunit 135392 "Library Agent"
{
    procedure CreateTask(MessageText: Text; var AgentTask: Record "Agent Task"; var Agent: Record Agent)
    var
        AgentTaskMessage: Record "Agent Task Message";
    begin
        AgentTask."Agent User Security ID" := Agent."User Security ID";
        AgentTask."Created By" := UserSecurityId();
        AgentTask.Status := AgentTask.Status::Paused;
        AgentTask.Insert();

        AgentTaskMessage."Task ID" := AgentTask.ID;
        AgentTaskMessage."Type" := AgentTaskMessage."Type"::Input;

        AgentTaskMessage.Insert();

        SetMessageText(AgentTaskMessage, MessageText);

        AgentTask.Status := AgentTask.Status::Ready;
        AgentTask.Modify(true);
    end;

    procedure DeactivateTasks()
    var
        AgentTask: Record "Agent Task";
    begin
        AgentTask.ReadIsolation := IsolationLevel::ReadCommitted;
        AgentTask.SetFilter(Status, '<>%1', AgentTask.Status::Paused);
        if not AgentTask.Findset() then
            exit;

        repeat
            AgentTask.Status := AgentTask.Status::Paused;
            AgentTask.Modify(true);
        until AgentTask.Next() = 0;

        Commit();
    end;

    procedure WriteAgentTaskToOutput(var AgentTask: Record "Agent Task"; var AgentTaskTestOutput: Codeunit "Test Output Json")
    var
        AgentMessagesTestOutput: Codeunit "Test Output Json";
        AgentStepsTestOutput: Codeunit "Test Output Json";
    begin
        AgentTaskTestOutput.Add('id', Format(AgentTask.ID, 0, 9));
        AgentTaskTestOutput.Add('status', Format(AgentTask.Status, 0, 9));
        AgentTaskTestOutput.Add('lastStepNumber', AgentTask."Last Step Number");
        AgentTaskTestOutput.Add('lastStepTimestamp', AgentTask."Last Step Timestamp");

        AgentMessagesTestOutput := AgentTaskTestOutput.AddArray('messages');
        AddMessagesToOutput(AgentTask, AgentMessagesTestOutput);

        AgentStepsTestOutput := AgentTaskTestOutput.AddArray('steps');
        AddStepsToOutput(AgentTask, AgentStepsTestOutput);
    end;

    local procedure AddMessagesToOutput(var AgentTask: Record "Agent Task"; var AgentMessagesTestOutput: Codeunit "Test Output Json")
    var
        AgentTaskMessage: Record "Agent Task Message";
        SingleMessageTestOutput: Codeunit "Test Output Json";
    begin
        AgentTaskMessage.SetRange("Task ID", AgentTask.ID);
        if AgentTaskMessage.FindSet() then
            repeat
                SingleMessageTestOutput := AgentMessagesTestOutput.Add('{}');
                SingleMessageTestOutput.Add('id', Format(AgentTaskMessage.ID, 0, 4));
                SingleMessageTestOutput.Add('type', AgentTaskMessage."Type");
                SingleMessageTestOutput.Add('status', AgentTaskMessage.Status);
                SingleMessageTestOutput.Add('content', GetMessageText(AgentTaskMessage));
                SingleMessageTestOutput.Add('createdDateTime', AgentTaskMessage.SystemCreatedAt);
            until AgentTaskMessage.Next() = 0;
    end;

    local procedure AddStepsToOutput(var AgentTask: Record "Agent Task"; var AgentStepsTestOutput: Codeunit "Test Output Json")
    var
        AgentTaskStep: Record "Agent Task Step";
        SingleStepTestOutput: Codeunit "Test Output Json";
    begin
        AgentTaskStep.SetRange("Task ID", AgentTask.ID);
        if AgentTaskStep.FindSet() then
            repeat
                SingleStepTestOutput := AgentStepsTestOutput.Add('{}');
                SingleStepTestOutput.Add('stepNumber', AgentTaskStep."Step Number");
                SingleStepTestOutput.Add('type', Format(AgentTaskStep.Type));
                SingleStepTestOutput.Add('description', AgentTaskStep.Description);
                SingleStepTestOutput.Add('details', GetDetailsForAgentTaskStep(AgentTaskStep));
                SingleStepTestOutput.Add('createdDateTime', AgentTaskStep.SystemCreatedAt);
            until AgentTaskStep.Next() = 0;
    end;


    internal procedure SetMessageText(var AgentTaskMessage: Record "Agent Task Message"; MessageText: Text)
    var
        ContentOutStream: OutStream;
    begin
        AgentTaskMessage.Content.CreateOutStream(ContentOutStream, GetDefaultEncoding());
        ContentOutStream.Write(MessageText);
        AgentTaskMessage.Modify(true);
    end;

    internal procedure WaitForAgentTaskToComplete(var AgentTask: Record "Agent Task"): Boolean
    var
        WaitTime: Duration;
    begin
        while (IsAgentRunning(AgentTask) and (WaitTime < GetAgentTaskTimeout()))
        do begin
            Sleep(500);
            WaitTime += 500;
            SelectLatestVersion();
            AgentTask.Find();
        end;

        exit((AgentTask.Status = AgentTask.Status::Paused) or (AgentTask.Status = AgentTask.Status::"Pending User Intervention"));
    end;

    internal procedure ContinueTask(var AgentTask: Record "Agent Task"): Boolean
    begin
        exit(ContinueTask(AgentTask, ContinueTaskTok));
    end;

    internal procedure ContinueTask(var AgentTask: Record "Agent Task"; UserInput: Text): Boolean
    var
        UserInterventionRequestStep: Record "Agent Task Step";
    begin
        UserInterventionRequestStep.Get(AgentTask.ID, AgentTask."Last Step Number");
        CreateUserInterventionTaskStep(UserInterventionRequestStep, UserInput);
        Commit();
        Sleep(500);
        AgentTask.Find();
        exit(WaitForAgentTaskToComplete(AgentTask));
    end;

    local procedure GetAgentTaskTimeout(): Duration
    begin
        // 30 minutes
        exit(30 * 60 * 1000);
    end;

    #region TODO Move to Internal and expose via library
    internal procedure CreateUserInterventionTaskStep(UserInterventionRequestStep: Record "Agent Task Step"; UserInput: Text)
    var
        AgentTask: Record "Agent Task";
        AgentTaskStep: Record "Agent Task Step";
        DetailsOutStream: OutStream;
        DetailsJson: JsonObject;
    begin
        AgentTask.Get(UserInterventionRequestStep."Task ID");

        AgentTaskStep."Task ID" := AgentTask.ID;
        AgentTaskStep."Type" := AgentTaskStep."Type"::"User Intervention";
        AgentTaskStep.Description := UserInterventionLbl;
        DetailsJson.Add(InterventionRequestStepNumberTok, UserInterventionRequestStep."Step Number");
        if (UserInput <> '') then
            DetailsJson.Add(UserInputTok, UserInput);
        AgentTaskStep.CalcFields(Details);
        Clear(AgentTaskStep.Details);
        AgentTaskStep.Details.CreateOutStream(DetailsOutStream, GetDefaultEncoding());
        DetailsJson.WriteTo(DetailsOutStream);
        AgentTaskStep.Insert();
    end;

    local procedure GetDefaultEncoding(): TextEncoding
    begin
        exit(TextEncoding::UTF8);
    end;

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

    internal procedure GetAgentInstructions(var Agent: Record Agent): Text
    var
        InstructionsInStream: InStream;
        InstructionsText: Text;
    begin
        if IsNullGuid(Agent."User Security ID") then
            exit;

        Agent.CalcFields(Instructions);
        if not Agent.Instructions.HasValue() then
            exit('');

        Agent.Instructions.CreateInStream(InstructionsInStream, GetDefaultEncoding());
        InstructionsInStream.Read(InstructionsText);
        exit(InstructionsText);
    end;

    local procedure IsAgentRunning(var AgentTask: Record "Agent Task"): Boolean
    begin
        exit((AgentTask.Status = AgentTask.Status::Ready) or
        (AgentTask.Status = AgentTask.Status::Scheduled) or
        (AgentTask.Status = AgentTask.Status::Running));
    end;
    #endregion

    var
        UserInterventionLbl: Label 'User Intervention', Locked = true;
        InterventionRequestStepNumberTok: Label 'interventionRequestStepNumber', Locked = true;
        UserInputTok: Label 'userInput', Locked = true;
        ContinueTaskTok: Label 'Continue Task', Locked = true;
}
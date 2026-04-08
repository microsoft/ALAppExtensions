// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.Designer.AgentSamples.SalesValidation;

using System.Agents;
using System.Agents.Designer.CustomAgent;
using System.TestLibraries.Agents;
using System.TestLibraries.Utilities;
using System.TestTools.AITestToolkit;
using System.TestTools.TestRunner;

codeunit 133744 "Sample Agents Utilities"
{
    Access = Internal;

    /// <summary>
    /// Enables an instance of the specified sample agent.
    /// This can import a new agent based on the sample if it hasn't been enabled before,
    /// or return the existing agent user security ID if it has already been created.
    /// </summary>
    /// <param name="CustomAgentSample">The sample agent.</param>
    /// <returns>The agent user security ID.</returns>
    procedure EnableSampleAgent(CustomAgentSample: Enum "Custom Agent Sample"): Guid
    begin
        exit(GetOrActivateSampleAgent(CustomAgentSample));
    end;

    /// <summary>
    /// Invokes the agent to run the task and wait until the task is completed or requiring some user intervention.
    /// </summary>
    /// <param name="AgentUserSecurityId">The agent user security ID.</param>
    /// <param name="AgentTask">The agent task.</param>
    /// <param name="TaskTitle">The title of the task.</param>
    /// <param name="From">The sender of the message.</param>
    /// <param name="Message">The message content.</param>
    /// <param name="TaskSuccessful">The result of the task.</param>
    /// <param name="ErrorReason">The reason for error, if any.</param>
    procedure InvokeAgentAndWaitTaskToComplete(AgentUserSecurityId: Guid; var AgentTask: Record "Agent Task"; TaskTitle: Text; From: Text; Message: Text; var TaskSuccessful: Boolean; var ErrorReason: Text)
    begin
        TaskSuccessful := InvokeAgentAndWaitTaskToComplete(AgentUserSecurityId, AgentTask, TaskTitle, From, Message);
        if not TaskSuccessful then
            ErrorReason := 'The agent task did not complete successfully in time. The task might have timed out before it finished.';
    end;

    /// <summary>
    /// Finalize the agent turn and assess whether it was successful or not.
    /// </summary>
    /// <param name="AgentTask">The agent task.</param>
    /// <param name="TaskSuccessful">Indicates if the task was successful.</param>
    /// <param name="ErrorReason">The reason for any error that occurred.</param>
    procedure FinalizeTurn(var AgentTask: Record "Agent Task"; TaskSuccessful: Boolean; ErrorReason: Text)
    begin
        WriteTestOutput(AgentTask, TaskSuccessful, ErrorReason);
        Commit();
        Assert.IsTrue(TaskSuccessful, ErrorReason);
    end;

    /// <summary>
    /// Gets the text encoding.
    /// </summary>
    /// <returns>The text encoding used.</returns>
    procedure GetTextEncoding(): TextEncoding
    begin
        exit(TextEncoding::UTF8);
    end;

    local procedure InvokeAgentAndWaitTaskToComplete(AgentUserSecurityId: Guid; var AgentTask: Record "Agent Task"; TaskTitle: Text; From: Text; Message: Text): Boolean
    var
        AgentTaskBuilder: Codeunit "Agent Task Builder";
        AgentTaskMessageBuilder: Codeunit "Agent Task Message Builder";
    begin
#pragma warning disable AA0139
        AgentTaskMessageBuilder.Initialize(From, Message);
#pragma warning restore AA0139

        if IsNullGuid(AgentTask."Agent User Security ID") then begin
#pragma warning disable AA0139
            AgentTaskBuilder.Initialize(AgentUserSecurityId, TaskTitle);
#pragma warning restore AA0139
            AgentTaskBuilder.AddTaskMessage(AgentTaskMessageBuilder);
            exit(LibraryAgent.CreateTaskAndWait(AgentTaskBuilder, AgentTask));
        end;

        AgentTaskMessageBuilder.SetAgentTask(AgentTask);
        exit(LibraryAgent.CreateMessageAndWait(AgentTaskMessageBuilder, AgentTask));
    end;

    local procedure WriteTestOutput(var AgentTask: Record "Agent Task"; TaskSuccessful: Boolean; ErrorReason: Text)
    var
        AgentOutputText: Codeunit "Test Output Json";
        TestJsonObject: JsonObject;
        ContextText, QuestionText, AnswerText : Text;
    begin
        AgentOutputText.Initialize();
        LibraryAgent.WriteTaskToOutput(AgentTask, AgentOutputText);

        TestJsonObject.ReadFrom('{}');
        TestJsonObject.Add('success', TaskSuccessful);
        TestJsonObject.Add('error_reason', ErrorReason);
        TestJsonObject.Add('taskDetails', AgentOutputText.AsJsonToken());
        TestJsonObject.WriteTo(AnswerText);

        ContextText := AITTestContext.GetContext().ToText();
        QuestionText := AITTestContext.GetQuestion().ToText();
        AITTestContext.SetTestOutput(ContextText, QuestionText, AnswerText);
    end;

    local procedure GetOrActivateSampleAgent(CustomAgentSample: Enum "Custom Agent Sample") AgentUserSecurityId: Guid
    var
        CustomAgentsWizardSetupRecord: Record "Custom Agents Wizard Setup";
        CustomAgentsWizardSetup: Codeunit "Custom Agents Wizard Setup";
        Agent: Codeunit Agent;
        ICustomAgentSample: Interface ICustomAgentSample;
    begin
        ICustomAgentSample := CustomAgentSample;

        CustomAgentsWizardSetupRecord.SetRange("Sample Agent Code", ICustomAgentSample.GetAgentCode());
        if CustomAgentsWizardSetupRecord.FindFirst() then
            AgentUserSecurityId := CustomAgentsWizardSetupRecord."Agent User Security ID"
        else
            AgentUserSecurityId := CustomAgentsWizardSetup.ImportAgent(ICustomAgentSample.GetAgentCode());

        Agent.Activate(AgentUserSecurityId);
        exit(AgentUserSecurityId);
    end;

    var
        Assert: Codeunit "Library Assert";
        LibraryAgent: Codeunit "Library - Agent";
        AITTestContext: Codeunit "AIT Test Context";
}
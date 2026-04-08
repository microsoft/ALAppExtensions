// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.Designer.AgentSamples.SalesValidation;

using System.Agents;
using System.Agents.Designer.CustomAgent;
using System.TestLibraries.Agents;
using System.TestTools.AITestToolkit;

codeunit 133743 "SVA Accuracy Auto Cont. Test"
{
    Subtype = Test;
    TestType = AITest;
    TestPermissions = Disabled;

    local procedure Initialize()
    begin
        if Initialized then
            exit;

        AgentUserSecurityId := SampleAgentUtilities.EnableSampleAgent(Enum::"Custom Agent Sample"::"Sales Validation");
        Initialized := true;
    end;

    [Test]
    procedure TestAccuracyWithAutoContinue()
    var
        AgentTask: Record "Agent Task";
        TestContext: Codeunit "AIT Test Context";
        ExpectedReleasedOrders, ExpectedNonReleasedOrders : List of [Code[20]];
        TaskSuccessful, DataUpdatedSuccessfully : Boolean;
        ErrorReason: Text;
        NextTurnExist: Boolean;
        From, Message : Text;
        AgentStatusErr: Label 'The agent task did not complete successfully. Task status: %1.', Comment = '%1 = task status';
        AgentErr: Label '%1 - Task ID: %2, Turn: %3', Comment = '%1 = Agent error, %2 = Agent Task ID, %3 = turn number';
    begin
        // Arrange
        Initialize();
        NextTurnExist := true;

        while NextTurnExist do begin

            // Prepare test data
            InitializeTestData(ExpectedReleasedOrders, ExpectedNonReleasedOrders, From, Message);

            // Act
            SampleAgentUtilities.InvokeAgentAndWaitTaskToComplete(AgentUserSecurityId, AgentTask, Message, From, Message, TaskSuccessful, ErrorReason);

            // Auto-continue: Handle multiple intervention requests until agent completes
            if TaskSuccessful then
                while (AgentTask.Status = AgentTask.Status::Paused) and AgentTask."Needs Attention" do
                    TaskSuccessful := LibraryAgent.ContinueTaskAndWait(AgentTask);

            // Assert
            if TaskSuccessful then
                DataUpdatedSuccessfully := SVAUtilities.ValidateSalesOrderRelease(ExpectedReleasedOrders, ExpectedNonReleasedOrders, ErrorReason)
            else
                ErrorReason := ErrorReason + '-' + StrSubstNo(AgentStatusErr, AgentTask.Status);

            if not (TaskSuccessful and DataUpdatedSuccessfully) then
                ErrorReason := StrSubstNo(AgentErr, ErrorReason, AgentTask.ID, TestContext.GetCurrentTurn());

            SampleAgentUtilities.FinalizeTurn(AgentTask, TaskSuccessful and DataUpdatedSuccessfully, ErrorReason);

            // Prepare next turn
            NextTurnExist := TestContext.NextTurn();
        end;
    end;

    local procedure InitializeTestData(var ExpectedReleasedOrders: List of [Code[20]]; var ExpectedNonReleasedOrders: List of [Code[20]]; var From: Text; var Message: Text)
    begin
        SVAUtilities.GetFromAndMessageFromTestData(From, Message);
        SVAUtilities.CreateSalesOrderTestData(ExpectedReleasedOrders, ExpectedNonReleasedOrders);
        Commit();
    end;

    var
        LibraryAgent: Codeunit "Library - Agent";
        SampleAgentUtilities: Codeunit "Sample Agents Utilities";
        SVAUtilities: Codeunit "SVA Utilities";
        AgentUserSecurityId: Guid;
        Initialized: Boolean;
}
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.Designer.AgentSamples.SalesValidation;

using System.Agents;
using System.Agents.Designer.CustomAgent;
using System.TestLibraries.Agents;

codeunit 133740 "SVA Accuracy Test"
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
    procedure TestAccuracy()
    var
        AgentTask: Record "Agent Task";
        ExpectedReleasedOrders, ExpectedNonReleasedOrders : List of [Code[20]];
        TaskSuccessful, DataUpdatedSuccessfully : Boolean;
        ErrorReason: Text;
        From, Message : Text;
        AgentStatusErr: Label 'The agent task did not complete successfully. Task status: %1.', Comment = '%1 = task status';
        AgentErr: Label '%1 - Task ID: %2', Comment = '%1 = Agent error, %2 = Agent Task ID';
    begin
        // Arrange
        Initialize();

        InitializeTestData(ExpectedReleasedOrders, ExpectedNonReleasedOrders, From, Message);

        // Act
        SampleAgentUtilities.InvokeAgentAndWaitTaskToComplete(AgentUserSecurityId, AgentTask, Message, From, Message, TaskSuccessful, ErrorReason);

        // Handle intervention requests (continue if paused and needs attention)
        if TaskSuccessful then
            if (AgentTask.Status = AgentTask.Status::Paused) and AgentTask."Needs Attention" then
                TaskSuccessful := LibraryAgent.ContinueTaskAndWait(AgentTask, 'Continue');

        // Assert
        if TaskSuccessful then
            DataUpdatedSuccessfully := SVAUtilities.ValidateSalesOrderRelease(ExpectedReleasedOrders, ExpectedNonReleasedOrders, ErrorReason)
        else
            ErrorReason := ErrorReason + '-' + StrSubstNo(AgentStatusErr, AgentTask.Status);

        if not (TaskSuccessful and DataUpdatedSuccessfully) then
            ErrorReason := StrSubstNo(AgentErr, ErrorReason, AgentTask.ID);

        SampleAgentUtilities.FinalizeTurn(AgentTask, TaskSuccessful and DataUpdatedSuccessfully, ErrorReason);
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
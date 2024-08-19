// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Agents.SalesOrderTakerAgent;

using Microsoft.Sales.Document;
using Microsoft.Inventory.Item;
using System.Agents;
using System.TestLibraries.Utilities;
using System.TestLibraries.Agents;
using System.TestLibraries.Agents.SalesOrderTakerAgent;

codeunit 133500 "SOA Create Quote E2E Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    local procedure Initialize()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.DeleteAll(true);
        LibraryAgent.DeactivateTasks();

        if this.Initialized then
            exit;

        LibrarySOAAgent.CreateItems();
        LibrarySOAAgent.CreateContacts();
        LibrarySOAAgent.EnableOrderTakerAgent();

        Commit();
        this.Initialized := true;
    end;

    [Test]
    procedure TestCreateSalesQuoteFromEmail()
    var
        AgentTask: Record "Agent Task";
        TaskSuccessful: Boolean;
    begin
        // Arrange
        this.Initialize();

        // Act
        TaskSuccessful := LibrarySOAAgent.InvokeOrderTakerAgentAndWait(AgentTask);

        // Approve email
        if AgentTask.Status = AgentTask.Status::"Pending User Intervention" then
            TaskSuccessful := LibraryAgent.ContinueTask(AgentTask);

        // Approve quote creation
        if AgentTask.Status = AgentTask.Status::"Pending User Intervention" then
            TaskSuccessful := LibraryAgent.ContinueTask(AgentTask);

        // Assert
        LibrarySOAAgent.WriteTestOutput(AgentTask);
        Commit();
        Assert.AreEqual(true, TaskSuccessful, 'The agent task did not complete successfully. Task status: ' + Format(AgentTask.Status, 0, 9));
        Assert.IsTrue(LibrarySOAAgent.VerifyDataCreated(), 'Agent did not create the data correctly. Compare expected to actual output.');
    end;

    [ModalPageHandler]
    procedure HandleAdjustInventoryDialog(var AdjustInventory: TestPage "Adjust Inventory")
    begin
        AdjustInventory.NewInventory.SetValue(this.LibraryVariableStorage.DequeueDecimal());
    end;

    var
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibrarySOAAgent: Codeunit "Library - SOA Agent";
        Assert: Codeunit "Library Assert";
        LibraryAgent: Codeunit "Library Agent";
        Initialized: Boolean;
}
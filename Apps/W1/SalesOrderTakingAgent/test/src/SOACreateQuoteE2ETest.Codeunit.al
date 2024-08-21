// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Agents.SalesOrderTakerAgent;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
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
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.DeleteAll(false);
        LibraryAgent.DeactivateTasks();

        LibrarySOAAgent.UpdateInventorySetup(this.CurrentItemNo, false);

        if this.Initialized then
            exit;

        LibrarySOAAgent.CreateItems();
        LibrarySOAAgent.CreateCustomers();
        LibrarySOAAgent.CreateContacts();
        LibrarySOAAgent.EnableOrderTakerAgent();

        Commit();
        this.Initialized := true;
    end;

    local procedure Restore()
    begin
        LibrarySOAAgent.UpdateInventorySetup(CurrentItemNo, true);
    end;

    [Test]
    [HandlerFunctions('HandleAdjustInventoryDialog,SelectCustomerTemplateHandler')]
    procedure TestCreateSalesQuoteFromEmail()
    var
        AgentTask: Record "Agent Task";
        TaskSuccessful: Boolean;
        AgentErr: Label '%1 Task ID: %2', Comment = '%1 = Agent error, %2 = Agent Task ID';
        ErrorReason: Text;
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
        Restore();

        Assert.AreEqual(true, TaskSuccessful, 'The agent task did not complete successfully. Task status: ' + Format(AgentTask.Status) + '. Task ID: ' + Format(AgentTask.ID));
        Assert.IsTrue(LibrarySOAAgent.VerifyDataCreated(AgentTask, ErrorReason), StrSubstNo(AgentErr, ErrorReason, AgentTask.ID));
    end;

    [ModalPageHandler]
    procedure HandleAdjustInventoryDialog(var AdjustInventory: TestPage "Adjust Inventory")
    begin
        AdjustInventory.NewInventory.SetValue(5);
    end;

    [ModalPageHandler]
    procedure SelectCustomerTemplateHandler(var SelectCustomerTemplList: TestPage "Select Customer Templ. List")
    var
    begin
        SelectCustomerTemplList.GoToKey('CUSTOMER COMPANY');
        SelectCustomerTemplList.OK().Invoke();
    end;

    var
        //LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibrarySOAAgent: Codeunit "Library - SOA Agent";
        Assert: Codeunit "Library Assert";
        LibraryAgent: Codeunit "Library Agent";
        CurrentItemNo: Code[20];
        Initialized: Boolean;
}
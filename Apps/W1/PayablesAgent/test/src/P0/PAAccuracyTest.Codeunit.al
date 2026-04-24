// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using Microsoft.Agent.PayablesAgent;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.EServices.EDocumentConnector.Microsoft365;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using System.Agents;
using System.TestLibraries.Agents;
using System.TestTools.AITestToolkit;

// Notes: Don't delete, for reference only
// AI.GetTestInput(); // entire input block for current test in tests  (same for multi and single turn)
// AITestContext.GetTestSetup(); // multi: 'test_setup' in the current turn, single: 'test_setup' in the current test
// AITestContext.GetInput(); // entire input block for current test in tests  (same for multi and single turn)
// AITestContext.GetExpectedData(); // multi: 'expected data'  inside the current turn, single: 'expected data' in the current test
// AITestContext.GetContext(); // 'context' inside the turn 


codeunit 133703 "PA Accuracy Test"
{
    Subtype = Test;
    TestType = AITest;
    TestPermissions = Disabled;
    Access = Internal;

    local procedure Initialize()
    var
        OutlookSetup: Record "Outlook Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PostedPurchaseHeader: Record "Purch. Inv. Header";
        EDocument: Record "E-Document";
        GLAccount: Record "G/L Account";
        Vendor: Record Vendor;
        VendorTemplate: Record "Vendor Templ.";
        VATPostingSetup: Record "VAT Posting Setup";
        VendorPostingGroup: Record "Vendor Posting Group";
        EDocVendorAssignHistory: Record "E-Doc. Vendor Assign. History";
        LibraryPurchase: Codeunit "Library - Purchase";
        CreatedGLAccountsNos, CreatedVendorNos : List of [Code[20]];
    begin
        if not OutlookSetup.FindFirst() then begin
            OutlookSetup.Validate("Consent Received", true);
            OutlookSetup.Insert();
        end else begin
            OutlookSetup.Validate("Consent Received", true);
            OutlookSetup.Modify();
        end;

        LibraryAgent.StopAllTasks();
        GLAccount.DeleteAll(false);
        Vendor.DeleteAll(false);
        VendorTemplate.DeleteAll(false);
        EDocVendorAssignHistory.DeleteAll(false);

        LibraryPayablesAgent.CreateVATPostingGroups(VATPostingSetup);
        CreatedVendorNos := LibraryPayablesAgent.CreateVendors(VATPostingSetup);
        CreatedGLAccountsNos := LibraryPayablesAgent.CreateGLAccounts(VATPostingSetup);
        LibraryPayablesAgent.CreateGLAccountMapping(CreatedGLAccountsNos, CreatedVendorNos);
        LibraryPurchase.CreateVendorPostingGroup(VendorPostingGroup);

        Vendor.FindLast();
        VendorTemplate.Init();
        VendorTemplate.Code := 'DEFAULT';
        VendorTemplate."Gen. Bus. Posting Group" := Vendor."Gen. Bus. Posting Group";
        VendorTemplate."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        VendorTemplate."Vendor Posting Group" := VendorPostingGroup.Code;
        VendorTemplate.Insert();

        LibraryPayablesAgent.EnablePayableAgent();
        PostedPurchaseHeader.DeleteAll(false);
        PurchaseLine.DeleteAll(false);
        PurchaseHeader.DeleteAll(false);

        if EDocument.FindSet() then
            repeat
                EDocument.CleanupDocument();
                EDocument.Delete(false);
            until EDocument.Next() = 0;
    end;

    [Test]
    procedure TestAccuracyCreatePurchaseInvoice()
    var
        PayablesAgentSetup: Record "Payables Agent Setup";
        AgentTask: Record "Agent Task";
        AgentTaskTimelineStep: Record "Agent Task Timeline Step";
        AITTestContext: Codeunit "AIT Test Context";
        ErrorReason: Text;
        TaskSuccessful, DataCreatedSuccessfully : Boolean;
        AgentStatusErr: Label 'The agent task did not complete successfully. Task status: %1. Task ID: %2. Turn: %3', Comment = '%1 = task status, %2 = task id, %3 = turn number';
        AgentErr: Label '%1 Task ID: %2', Comment = '%1 = Agent error, %2 = Agent Task ID';
        TimelineDetails: Text;
        TimelineStepDetailsTxt: Label '[Title: %1, Description: %2, Primary Page ID: %3] ', Comment = '%1 - Title, %2 - Description, %3 - Primary Page ID', Locked = true;
        AgentFinishedWrongPageErr: Label 'The agent ended in the wrong page %1, expected %2. Timeline steps: %3', Locked = true;
    begin
        Initialize();
        PayablesAgentSetup.GetSetup();

        // Tests scenarios run by this test:

        // 1. Sunshine. User intervention for new inbound e-document + user intervention for finalization
        // 2. Sunshine. User intervention for new inbound e-document +  user intervention missing item no + user intervention for finalization

        if LibraryPayablesAgent.GenerateEDocAndInvokeAgent(AgentTask) then begin
            // Approve new inbound e-document
            if PayablesAgentSetup."Review Incoming Invoice" then
                if (AgentTask.Status = AgentTask.Status::Paused) and AgentTask."Needs Attention" then begin
                    if not LibraryPayablesAgent.CheckAgentTaskContinue(AgentTask, ErrorReason) then begin
                        FinalizeTurn(AgentTask, ErrorReason = '', true, ErrorReason);
                        exit;
                    end;

                    TaskSuccessful := LibraryAgent.ContinueTaskAndWait(AgentTask);
                end;

            TaskSuccessful := LibraryPayablesAgent.VerifyAndApproveIntervention(AgentTask, ErrorReason);
        end
        else begin
            TaskSuccessful := false;
            ErrorReason := 'The agent task did not complete successfully in time. The task might have timed out before it finished. ';
        end;

        if TaskSuccessful then begin
            // Assert
            DataCreatedSuccessfully := LibraryPayablesAgent.VerifyDataCreated(ErrorReason);
            AgentTaskTimelineStep.SetRange("Task ID", AgentTask.ID);
            if AgentTaskTimelineStep.FindSet() then
                repeat
                    TimelineDetails += StrSubstNo(TimelineStepDetailsTxt, AgentTaskTimelineStep.Title, AgentTaskTimelineStep.Description, AgentTaskTimelineStep."Primary Page ID");
                until AgentTaskTimelineStep.Next() = 0;
            AgentTaskTimelineStep.SetFilter("Primary Page ID", '<>%1', 0);
            AgentTaskTimelineStep.FindLast();
            if AgentTaskTimelineStep."Primary Page ID" <> Page::"Purchase Invoice" then begin
                ErrorReason := StrSubstNo(AgentFinishedWrongPageErr, AgentTaskTimelineStep."Primary Page ID", Page::"Purchase Invoice", TimelineDetails);
                DataCreatedSuccessfully := false;
            end;
            if not DataCreatedSuccessfully then
                ErrorReason := StrSubstNo(AgentErr, ErrorReason, AgentTask.ID);
            if not TaskSuccessful then
                ErrorReason := ErrorReason + '-' + StrSubstNo(AgentStatusErr, AgentTask.Status, AgentTask.ID, AITTestContext.GetCurrentTurn());
        end
        else
            ErrorReason := StrSubstNo(AgentErr, ErrorReason, AgentTask.ID);

        FinalizeTurn(AgentTask, TaskSuccessful, DataCreatedSuccessfully, ErrorReason);
    end;

    local procedure FinalizeTurn(var AgentTask: Record "Agent Task"; TaskSuccessful: Boolean; DataCreatedSuccessfully: Boolean; ErrorReason: Text)
    var
        AgentTaskFailedLbl: Label 'The agent task did not complete successfully. Task status: %1. Task ID: %2. Error Reason: %3', Comment = '%1 = task status, %2 = task id, %3 = error reason';
        DataWasNotCreatedSuccesfullyLbl: Label 'The agent task did not create the data successfully. Task status: %1. Task ID: %2. Error Reason: %3', Comment = '%1 = task status, %2 = task id, %3 = error reason';
    begin
        LibraryPayablesAgent.WriteTestOutput(AgentTask, TaskSuccessful and DataCreatedSuccessfully, ErrorReason);

        Commit();

        Assert.IsTrue(TaskSuccessful, StrSubstNo(AgentTaskFailedLbl, AgentTask.Status, AgentTask.ID, ErrorReason));
        Assert.IsTrue(DataCreatedSuccessfully, StrSubstNo(DataWasNotCreatedSuccesfullyLbl, AgentTask.Status, AgentTask.ID, ErrorReason));
    end;

    var
        LibraryAgent: Codeunit "Library - Agent";
        LibraryPayablesAgent: Codeunit "Library - Payables Agent";
        Assert: Codeunit Assert;

}

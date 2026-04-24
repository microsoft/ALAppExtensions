// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using Microsoft.eServices.EDocument;
using Microsoft.EServices.EDocumentConnector.Microsoft365;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using System.Agents;
using System.TestLibraries.Agents;
codeunit 133702 "PA UPIA Additional Instruction"
{
    Subtype = Test;
    TestType = AITest;
    TestPermissions = Disabled;
    Access = Internal;
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    var
        LibraryAgent: Codeunit "Library - Agent";
        LibraryPayablesAgent: Codeunit "Library - Payables Agent";
        Initialized: Boolean;
        HarmName, HarmAddress : Text;
    local procedure DeleteTables()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PostedPurchaseHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        EDocument: Record "E-Document";
        OutlookSetup: Record "Outlook Setup";
        Vendor: Record Vendor;
        AgentUserSecurityID: Guid;
    begin
        PostedPurchaseHeader.DeleteAll(false);
        PurchInvLine.DeleteAll(false);
        AgentUserSecurityID := LibraryPayablesAgent.GetAgentUserSecurityID();
        PurchaseLine.SetRange(SystemCreatedBy, AgentUserSecurityID);
        PurchaseLine.DeleteAll(false);
        PurchaseHeader.SetRange(SystemCreatedBy, AgentUserSecurityID);
        PurchaseHeader.DeleteAll(false);
        Vendor.DeleteAll(false);
        // Cleanup e-document data
        if EDocument.FindSet() then
            repeat
                EDocument.CleanupDocument();
                EDocument.Delete(false);
            until EDocument.Next() = 0;
        if not OutlookSetup.FindFirst() then begin
            OutlookSetup.Validate("Consent Received", true);
            OutlookSetup.Insert();
        end else begin
            OutlookSetup.Validate("Consent Received", true);
            OutlookSetup.Modify();
        end;
    end;

    local procedure Initialize()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PostedPurchaseHeader: Record "Purch. Inv. Header";
        EDocument: Record "E-Document";
        GLAccount: Record "G/L Account";
        Vendor: Record Vendor;
        VendorTemplate: Record "Vendor Templ.";
        VATPostingSetup: Record "VAT Posting Setup";
        VendorPostingGroup: Record "Vendor Posting Group";
        LibraryPurchase: Codeunit "Library - Purchase";
        CreatedGLAccountsNos, CreatedVendorNos : List of [Code[20]];
    begin
        // Step 1: Delete existing data
        DeleteTables();
        // Step 2: Deactivate tasks and create vendors
        LibraryAgent.StopAllTasks();
        GLAccount.DeleteAll(false);
        Vendor.DeleteAll(false);
        VendorTemplate.DeleteAll(false);
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
        PostedPurchaseHeader.DeleteAll(false);
        PurchaseLine.DeleteAll(false);
        PurchaseHeader.DeleteAll(false);
        if EDocument.FindSet() then
            repeat
                EDocument.CleanupDocument();
                EDocument.Delete(false);
            until EDocument.Next() = 0;
        // Enable the agent
        LibraryPayablesAgent.EnablePayableAgent();
        if Initialized then
            exit;
        Initialized := true;
    end;

    [Test]
    procedure HarmsTest_UPIA_AdditionalInstructions()
    var
        AgentTask: Record "Agent Task";
        ErrorReason: Text;
    begin
        Initialize();
        LibraryPayablesAgent.GenerateEDocAndInvokeAgent(AgentTask);
        // Approve new inbound e-document
        if (AgentTask.Status = AgentTask.Status::Paused) and AgentTask."Needs Attention" then begin
            if not LibraryPayablesAgent.CheckAgentTaskContinue(AgentTask, ErrorReason) then begin
                FinalizeTurn(AgentTask, ErrorReason = '', true, ErrorReason);
                exit;
            end;
            LibraryAgent.ContinueTaskAndWait(AgentTask);
        end;

        LibraryPayablesAgent.VerifyAndApproveIntervention(AgentTask, ErrorReason);
        LibraryPayablesAgent.WriteTestOutputForAdditionalInstructionsHarm(AgentTask);
    end;

    local procedure FinalizeTurn(var AgentTask: Record "Agent Task"; TaskSuccessful: Boolean; DataCreatedSuccessfully: Boolean; ErrorReason: Text)
    begin
        LibraryPayablesAgent.WriteTestOutput(AgentTask, TaskSuccessful and DataCreatedSuccessfully, ErrorReason);
        Commit();
    end;
}

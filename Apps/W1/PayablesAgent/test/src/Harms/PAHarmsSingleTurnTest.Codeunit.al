// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using Microsoft.eServices.EDocument;
using Microsoft.EServices.EDocumentConnector.Microsoft365;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using System.Agents;
using System.TestLibraries.Agents;
using System.TestTools.AITestToolkit;
using System.Utilities;

codeunit 133705 "PA Harms Single Turn Test"
{
    Subtype = Test;
    TestType = AITest;
    TestPermissions = Disabled;
    Access = Internal;
    SingleInstance = true;

    var
        LibraryAgent: Codeunit "Library - Agent";
        LibraryPayablesAgent: Codeunit "Library - Payables Agent";
        Initialized: Boolean;

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
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // Step 1: Delete existing data
        DeleteTables();

        // Step 2: Deactivate tasks and create vendors
        LibraryAgent.StopAllTasks();
        LibraryPayablesAgent.CreateVATPostingGroups(VATPostingSetup);
        LibraryPayablesAgent.CreateVendors(VATPostingSetup);

        if Initialized then
            exit;

        // Create test data for the scenario
        LibraryPayablesAgent.CreateGLAccounts(VATPostingSetup);

        // Enable the agent
        LibraryPayablesAgent.EnablePayableAgent();

        Initialized := true;
    end;


    [Test]
    procedure TestHarmInPDFVendorName()
    var
        Vendor: Record Vendor;
        EDocument: Record "E-Document";
        AgentTask: Record "Agent Task";
        TempBlob: Codeunit "Temp Blob";
        EDocImport: Codeunit "E-Doc. Import";
        AITTestContext: Codeunit "AIT Test Context";
        FileInStream: InStream;
        HarmAttackSentence, VendorName, VendorAddress : Text;
        ElementFound: Boolean;
    begin
        // Notes on test
        // Idea with the test is that a malicious outside actor could send a PDF with a harmful vendor name or address, but still match a vendor based on VAT number.
        // The test will create a PDF with a harmful vendor name and address, and then run the agent to see if it processes it accordingly.

        // Arrange
        Initialize();

        // Act - Prepare harm
        AITTestContext.GetInput().ElementExists('question', ElementFound);
        if ElementFound then
            HarmAttackSentence := AITTestContext.GetInput().Element('question').ToText();

        VendorName := CopyStr(HarmAttackSentence, 1, 100);
        VendorAddress := CopyStr(HarmAttackSentence, 101, 100);

        // Create PDF file
        TempBlob := LibraryPayablesAgent.CreateInvoiceWithHarmInVendor(VendorName, VendorAddress, true, Vendor);
        TempBlob.CreateInStream(FileInStream);

        LibraryPayablesAgent.CreateEDocumentFromPDF(EDocument, FileInStream);
        EDocImport.ProcessAutomaticallyIncomingEDocument(EDocument);
        Commit(); // Necessary to lose the lock on the Agent Task (created within the OnAfterProcessIncomingEDocument event)

        // Invoke the agent 
        AgentTask.SetRange("External ID", Format(EDocument."Entry No"));
        AgentTask.FindFirst();
        LibraryAgent.WaitForTaskToComplete(AgentTask);

        // Approve new inbound e-document
        if (AgentTask.Status = AgentTask.Status::Paused) and AgentTask."Needs Attention" then
            LibraryAgent.ContinueTaskAndWait(AgentTask);

        // Assert
        // Nothing. AI Foundry automated harms validation is run on the output


        // Write output
        LibraryPayablesAgent.WriteTestOutputForVendorHarm(AgentTask, VendorName, VendorAddress);
        Commit();
    end;
}

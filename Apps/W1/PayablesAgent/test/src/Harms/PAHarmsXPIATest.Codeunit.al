// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using Microsoft.Agent.PayablesAgent;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.EServices.EDocumentConnector.Microsoft365;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using System.Agents;
using System.TestLibraries.Agents;
using System.TestTools.AITestToolkit;
using System.Utilities;

codeunit 133706 "PA Harms XPIA Test" implements IVendorProvider
{
    Subtype = Test;
    TestType = AITest;
    TestPermissions = Disabled;
    Access = Internal;
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    var
        GlobalVendor: Record Vendor;
        AITTestContext: Codeunit "AIT Test Context";
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
    procedure TestHarmXPIA()
    var
        AgentTask: Record "Agent Task";
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        PayablesAgentSetup: Record "Payables Agent Setup";
        TempBlob: Codeunit "Temp Blob";
        EDocImport: Codeunit "E-Doc. Import";
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

        // RUN E-DOC without agent
        PayablesAgentSetup.GetSetup();
        EDocumentService.Get(PayablesAgentSetup."E-Document Service Code");

        EDocumentService.Rename('NOAGENT');

        LibraryPayablesAgent.CreateEDocumentFromPDF(EDocument);
        EDocImport.ProcessAutomaticallyIncomingEDocument(EDocument);

        EDocumentService.Rename('AGENT');

        // Create PDF file
        Clear(GlobalVendor);
        TempBlob := LibraryPayablesAgent.CreateInvoiceWithHarmInVendor(VendorName, VendorAddress, true, GlobalVendor);
        TempBlob.CreateInStream(FileInStream);

        LibraryPayablesAgent.CreateEDocumentFromPDF(EDocument, FileInStream);
        EDocument."Structure Data Impl." := Enum::"Structure Received E-Doc."::"ADI XPIA";
        EDocument."Read into Draft Impl." := Enum::"E-Doc. Read into Draft"::"ADI XPIA";
#pragma warning disable AA0139
        EDocument."Receiving Company Name" := VendorName;
        EDocument."Receiving Company Address" := VendorAddress;
#pragma warning restore AA0139
        EDocument.Modify();

        LibraryPayablesAgent.ProcessEDocument(EDocument, EDocumentService.GetDefaultImportParameters());
        Commit(); // Necessary to lose the lock on the Agent Task (created within the OnAfterProcessIncomingEDocument event)

        // Invoke agent task
        LibraryPayablesAgent.InvokeAgent(EDocument, AgentTask);

        // Approve new inbound e-document
        if (AgentTask.Status = AgentTask.Status::Paused) and AgentTask."Needs Attention" then
            LibraryAgent.ContinueTaskAndWait(AgentTask);

        // Write output
        LibraryPayablesAgent.WriteTestOutputForVendorHarm(AgentTask, VendorName, VendorAddress);
        Commit();
    end;

    procedure GetVendor(EDocument: Record "E-Document") Vendor: Record Vendor
    begin
        Vendor.Name := CopyStr(EDocument."Receiving Company Name", 1, MaxStrLen(Vendor.Name));
        Vendor."Address" := CopyStr(EDocument."Receiving Company Address", 1, MaxStrLen(Vendor."Address"));
        exit(Vendor);
    end;

}

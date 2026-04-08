// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using Microsoft.Agent.PayablesAgent;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import;
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
using System.Utilities;


codeunit 133709 "PA Search Vendor Hist Test"
{
    Access = Internal;
    Subtype = Test;
    SingleInstance = true;
    TestType = AITest;
    TestPermissions = Disabled;


    var
        LibraryAgent: Codeunit "Library - Agent";
        LibraryPayablesAgent: Codeunit "Library - Payables Agent";
        Assert: Codeunit Assert;
        Initialized: Boolean;

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
        PayablesAgentSetup: Record "Payables Agent Setup";
        EDocumentService: Record "E-Document Service";
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

        LibraryPayablesAgent.EnablePayableAgent();

        if EDocument.FindSet() then
            repeat
                EDocument.CleanupDocument();
                EDocument.Delete(false);
            until EDocument.Next() = 0;

        PayablesAgentSetup.GetSetup();
        PayablesAgentSetup."Review Incoming Invoice" := false;
        PayablesAgentSetup.Modify();

        PostedPurchaseHeader.DeleteAll(false);
        PurchaseLine.DeleteAll(false);
        PurchaseHeader.DeleteAll(false);

        Commit();
        if Initialized then
            exit;

        Initialized := true;

        GLAccount.DeleteAll(false);
        Vendor.DeleteAll(false);
        VendorTemplate.DeleteAll(false);
        EDocVendorAssignHistory.DeleteAll(false);

        LibraryPayablesAgent.CreateVATPostingGroups(VATPostingSetup);
        CreatedVendorNos := LibraryPayablesAgent.CreateVendors(VATPostingSetup);
        LibraryPayablesAgent.CreateVendorMatchHistory(CreatedVendorNos);
        CreatedGLAccountsNos := LibraryPayablesAgent.CreateGLAccounts(VATPostingSetup);
        LibraryPayablesAgent.CreateGLAccountMapping(CreatedGLAccountsNos, CreatedVendorNos);
        LibraryPurchase.CreateVendorPostingGroup(VendorPostingGroup);

        if Vendor.FindLast() then begin
            VendorTemplate.Init();
            VendorTemplate.Code := 'DEFAULT';
            VendorTemplate."Gen. Bus. Posting Group" := Vendor."Gen. Bus. Posting Group";
            VendorTemplate."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
            VendorTemplate."Vendor Posting Group" := VendorPostingGroup.Code;
            VendorTemplate.Insert();
        end;

        LibraryPayablesAgent.EnablePayableAgent();
        EDocumentService.Get(PayablesAgentSetup."E-Document Service Code");

        // Force that no vendor is found by AL
        EDocumentService."Processing Customizations" := Enum::"E-Doc. Proc. Customizations"::NoVendor;
        EDocumentService.Modify();

        if EDocument.FindSet() then
            repeat
                EDocument.CleanupDocument();
                EDocument.Delete(false);
            until EDocument.Next() = 0;

        Commit();
    end;


    /// <summary>
    /// Scenario that that no vendor exists based on vendor list lookup with name and address.
    /// </summary>
    [Test]
    procedure TestAccuracySearchForVendorUsingHistory()
    var
        EDocument: Record "E-Document";
        PayablesAgentSetup: Record "Payables Agent Setup";
        AgentTask: Record "Agent Task";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        TempVendor: Record Vendor temporary;
        TempUserInterventionRequest: Record "Agent User Int Request Details" temporary;
        TempUserInterventionAnnotation: Record "Agent Annotation" temporary;
        TempUserInterventionSuggestion: Record "Agent Task User Int Suggestion" temporary;
        AITTestContext: Codeunit "AIT Test Context";
        TempBlob: Codeunit "Temp Blob";
        ErrorReason: Text;
        DataCreatedSuccessfully: Boolean;
        FileInStream: InStream;
        Message: Text;
    begin
        Initialize();
        PayablesAgentSetup.GetSetup();

        TempVendor.Name := CopyStr(AITTestContext.GetInput().Element('vendor_name').ToText(), 1, 100);
        TempVendor.Address := CopyStr(AITTestContext.GetInput().Element('vendor_address').ToText(), 1, 100);

        TempBlob := LibraryPayablesAgent.CreateDefaultInvoice('PA-INV-Standard.yaml', 'INV-001', TempVendor);
        TempBlob.CreateInStream(FileInStream);
        LibraryPayablesAgent.CreateEDocumentFromPDF(EDocument, FileInStream);

        LibraryPayablesAgent.ProcessEDocument(EDocument, EDocImportParameters);
        LibraryPayablesAgent.InvokeAgent(EDocument, AgentTask);

        if PayablesAgentSetup."Review Incoming Invoice" then
            LibraryAgent.ContinueTaskAndWait(AgentTask);

        LibraryAgent.GetLastUserInterventionRequestDetails(AgentTask, TempUserInterventionRequest, TempUserInterventionAnnotation, TempUserInterventionSuggestion);
        Message := TempUserInterventionRequest.Type = TempUserInterventionRequest.Type::Assistance ?
            TempUserInterventionAnnotation.Message :
            TempUserInterventionRequest.Message;

        // Approve finalize task
        LibraryAgent.ContinueTaskAndWait(AgentTask);

        DataCreatedSuccessfully := LibraryPayablesAgent.VerifyPurchaseInvoiceCreated(ErrorReason);
        DataCreatedSuccessfully := DataCreatedSuccessfully and LibraryPayablesAgent.VerifyVendor(ErrorReason);
        FinalizeTurn(AgentTask, DataCreatedSuccessfully, ErrorReason);
        exit;
    end;

    local procedure FinalizeTurn(var AgentTask: Record "Agent Task"; DataCreatedSuccessfully: Boolean; ErrorReason: Text)
    var
        DataWasNotCreatedSuccessfullyLbl: Label 'The agent task did not create the data successfully. Task status: %1. Task ID: %2. Error Reason: %3', Comment = '%1 = task status, %2 = task id, %3 = error reason';
    begin
        LibraryPayablesAgent.WriteTestOutput(AgentTask, DataCreatedSuccessfully, ErrorReason);

        Commit();

        Assert.IsTrue(DataCreatedSuccessfully, StrSubstNo(DataWasNotCreatedSuccessfullyLbl, AgentTask.Status, AgentTask.ID, ErrorReason));
    end;


}

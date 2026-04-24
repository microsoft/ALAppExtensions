// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Agents.PayablesAgent;

using Microsoft.Agent.PayablesAgent;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using System.Agents;
using System.TestLibraries.Agents;
using System.TestTools.AITestToolkit;
using System.TestTools.TestRunner;

codeunit 133721 "PA Order Match Test"
{
    Subtype = Test;
    TestType = AITest;
    TestPermissions = Disabled;
    Access = Internal;

    var
        MainVendor: Record Vendor;
        LibraryPayablesAgent: Codeunit "Library - Payables Agent";

    [Test]
    /// <summary>
    /// The scope of the test is to verify that the agent correctly matched to the right purchase order lines, it doesn't verify finalization or invoice creation.
    /// </summary>
    procedure TestOrderMatching()
    var
        AgentTask: Record "Agent Task";
        LibraryAgent: Codeunit "Library - Agent";
        ErrorReason: Text;
    begin
        LibraryPayablesAgent.EnablePayableAgent();

        // [GIVEN] Orders are created in the system, an E-Document is generated and the Payables Agent is invoked to process it
        PrepareOrderMatchingTestSetupData();
        if not LibraryPayablesAgent.GenerateEDocAndInvokeAgent(AgentTask) then begin
            MarkTestAsFailed(AgentTask, 'Failed to generate the e-document and invoke the agent.');
            exit;
        end;

        // [GIVEN] The user accepts to continue the task 
        if not LibraryPayablesAgent.CheckAgentTaskContinue(AgentTask, ErrorReason) then
            MarkTestAsFailed(AgentTask, ErrorReason);

        // [WHEN] The agent does the processing
        if not LibraryAgent.ContinueTaskAndWait(AgentTask) then begin
            MarkTestAsFailed(AgentTask, 'Failed to continue the agent task.');
            exit;
        end;

        // [THEN] Verify that the order line matching is as expected
        if not VerifyPurchaseOrdersMatches(AgentTask, ErrorReason) then
            MarkTestAsFailed(AgentTask, ErrorReason);

        LibraryPayablesAgent.WriteTestOutput(AgentTask, true, ''); // Mark test as passed
    end;

    local procedure PrepareOrderMatchingTestSetupData()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        TestInputJson, TestInputJsonSegment : Codeunit "Test Input Json";
        AITTestContext: Codeunit "AIT Test Context";
        CreatedVendorsNos, CreatedGLAccountsNos : List of [Code[20]];
    begin
        CleanSetupData();
        TestInputJson := LibraryPayablesAgent.GetTestSetup();
        TestInputJsonSegment := TestInputJson.Element('vendorsToCreate');
        LibraryPayablesAgent.CreateVATPostingGroups(VATPostingSetup);
        CreatedVendorsNos := LibraryPayablesAgent.CreateVendors(VATPostingSetup, TestInputJsonSegment);
        MainVendor.Get(CreatedVendorsNos.Get(1));
        TestInputJsonSegment := TestInputJson.Element('glAccountsToCreate');
        CreatedGLAccountsNos := LibraryPayablesAgent.CreateGLAccounts(VATPostingSetup, TestInputJsonSegment);
        LibraryPayablesAgent.CreatePurchaseOrders(AITTestContext.GetInput().Element('purchaseOrdersToCreate'), MainVendor, CreatedGLAccountsNos.Get(1));
    end;

    local procedure CleanSetupData()
    var
        GLAccount: Record "G/L Account";
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        GLAccount.DeleteAll(false);
        Vendor.DeleteAll(false);
        PurchaseHeader.DeleteAll(false);
        PurchaseLine.DeleteAll(false);
    end;

    local procedure VerifyPurchaseOrdersMatches(AgentTask: Record "Agent Task"; var ErrorReason: Text): Boolean
    var
        AITTestContext: Codeunit "AIT Test Context";
        LineMatchesDefined, NoLineMatchesDefined : Boolean;
    begin
        AITTestContext.GetExpectedData().ElementExists('orderLineMatches', LineMatchesDefined);
        AITTestContext.GetExpectedData().ElementExists('noOrderLineMatches', NoLineMatchesDefined);

        if NoLineMatchesDefined then
            exit(VerifyNoOrderLineMatches(AgentTask, ErrorReason));

        if LineMatchesDefined then
            exit(VerifyOrderLineMatches(AgentTask, ErrorReason));

        Error('Neither orderLineMatches nor noOrderLineMatches defined in the expected data. Verify the definition of the test scenario.');
    end;

    local procedure VerifyNoOrderLineMatches(AgentTask: Record "Agent Task"; var ErrorReason: Text): Boolean
    var
        EDocument: Record "E-Document";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocPurchaseLinePOMatch: Record "E-Doc. Purchase Line PO Match";
        PayablesAgent: Codeunit "Payables Agent";
    begin
        EDocument := PayablesAgent.GetEDocumentForAgentTask(AgentTask.ID);
        if EDocument."Entry No" = 0 then begin
            ErrorReason := 'No EDocument found for the given Agent Task ID ' + Format(AgentTask.ID) + '.';
            exit(false);
        end;
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        if EDocumentPurchaseLine.FindSet() then
            repeat
                EDocPurchaseLinePOMatch.SetRange("E-Doc. Purchase Line SystemId", EDocumentPurchaseLine."SystemId");
                if not EDocPurchaseLinePOMatch.IsEmpty() then begin
                    ErrorReason := 'Unexpected match found for e-document line with index ' + Format(EDocumentPurchaseLine."Created at Index") + '.';
                    exit(false);
                end;
            until EDocumentPurchaseLine.Next() = 0;
        exit(true);
    end;

    local procedure VerifyOrderLineMatches(AgentTask: Record "Agent Task"; var ErrorReason: Text): Boolean
    var
        EDocument: Record "E-Document";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine, ExpectedPurchaseLine : Record "Purchase Line";
        EDocPurchaseLinePOMatch: Record "E-Doc. Purchase Line PO Match";
        AITTestContext: Codeunit "AIT Test Context";
        PayablesAgent: Codeunit "Payables Agent";
        ExpectedMatches: Dictionary of [Guid, Guid];
        OrderLineMatches: JsonArray;
        JsonToken: JsonToken;
        JsonObject: JsonObject;
        ExpectedPurchaseOrderIndex, ExpectedPurchaseLineIndex, ExpectedEDocLineIndex, i : Integer;
        ExpectedPurchaseLineSystemId: Guid;
    begin
        // Note: there are two kinds of errors used throughout this procedure:
        // - Error: used when the test scenario is incorrectly defined or the test setup failed to create the expected data (test-developer error)
        // - ErrorReason + exit(false): used when the agent didn't behave as expected (test-failure expected to be reported and aggregated by the test framework)

        EDocument := PayablesAgent.GetEDocumentForAgentTask(AgentTask.ID);
        if EDocument."Entry No" = 0 then begin
            ErrorReason := 'No EDocument found for the given Agent Task ID ' + Format(AgentTask.ID) + '.';
            exit(false);
        end;

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        i := 1;
        if EDocumentPurchaseLine.FindSet() then
            repeat
                EDocumentPurchaseLine."Created at Index" := i;
                EDocumentPurchaseLine.Modify();
                i += 1;
            until EDocumentPurchaseLine.Next() = 0;

        OrderLineMatches := AITTestContext.GetExpectedData().Element('orderLineMatches').AsJsonToken().AsArray();
        // We verify that each expected match exists in the system
        foreach JsonToken in OrderLineMatches do begin
            JsonObject := JsonToken.AsObject();
            if not JsonObject.Contains('invoiceLineIndex') then
                Error('Expected invoiceLineIndex in orderLineMatches, verify the test scenario.');
            if not JsonObject.Contains('purchaseOrderLineIndex') then
                Error('Expected purchaseOrderLineIndex in orderLineMatches, verify the test scenario.');
            if not JsonObject.Contains('purchaseOrderIndex') then
                Error('Expected purchaseOrderIndex in orderLineMatches, verify the test scenario.');

            ExpectedEDocLineIndex := JsonObject.GetInteger('invoiceLineIndex');
            ExpectedPurchaseLineIndex := JsonObject.GetInteger('purchaseOrderLineIndex');
            ExpectedPurchaseOrderIndex := JsonObject.GetInteger('purchaseOrderIndex');

            PurchaseHeader.SetRange("Created at Index", ExpectedPurchaseOrderIndex);
            PurchaseHeader.SetRange("Document Type", Enum::"Purchase Document Type"::Order);
            if not PurchaseHeader.FindFirst() then
                Error('Purchase order not found for the expected purchase order index %1. It should have been created during test setup. Verify the test scenario.', Format(ExpectedPurchaseOrderIndex));
            PurchaseLine.SetRange("Document Type", Enum::"Purchase Document Type"::Order);
            PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
            PurchaseLine.SetRange("Created at Index", ExpectedPurchaseLineIndex);
            if not PurchaseLine.FindFirst() then
                Error('Purchase line not found for the expected purchase line index %1 in purchase order %2. It should have been created during test setup. Verify the test scenario.', Format(ExpectedPurchaseLineIndex), PurchaseHeader."No.");

            EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
            EDocumentPurchaseLine.SetRange("Created at Index", ExpectedEDocLineIndex);
            if not EDocumentPurchaseLine.FindFirst() then begin
                ErrorReason := 'E-Document purchase line not found for the expected e-document line index ' + Format(ExpectedEDocLineIndex) + '. OCRing the invoice should have created it.';
                exit(false);
            end;

            EDocPurchaseLinePOMatch.SetRange("E-Doc. Purchase Line SystemId", EDocumentPurchaseLine."SystemId");
            EDocPurchaseLinePOMatch.SetRange("Purchase Line SystemId", PurchaseLine."SystemId");
            if EDocPurchaseLinePOMatch.IsEmpty() then begin
                ErrorReason := 'No match found between e-document line index ' + Format(ExpectedEDocLineIndex) + ' and purchase order line index ' + Format(ExpectedPurchaseLineIndex) + ' in purchase order index ' + Format(ExpectedPurchaseOrderIndex) + '.';
                exit(false);
            end;
            ExpectedMatches.Add(EDocumentPurchaseLine."SystemId", PurchaseLine."SystemId");
        end;
        // Now we verify that there are no unexpected matches
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        if EDocumentPurchaseLine.FindSet() then
            repeat
                EDocPurchaseLinePOMatch.SetRange("E-Doc. Purchase Line SystemId", EDocumentPurchaseLine."SystemId");
                if EDocPurchaseLinePOMatch.FindSet() then
                    repeat
                        if not PurchaseLine.GetBySystemId(EDocPurchaseLinePOMatch."Purchase Line SystemId") then begin
                            ErrorReason := 'Purchase line with System ID ' + Format(EDocPurchaseLinePOMatch."Purchase Line SystemId") + ' not found, although it was matched. This should not happen.';
                            exit(false);
                        end;
                        if not ExpectedMatches.ContainsKey(EDocumentPurchaseLine."SystemId") then begin
                            ErrorReason := 'Unexpected match found between e-document line index ' + Format(EDocumentPurchaseLine."Created at Index") + ' and purchase line index ' + Format(PurchaseLine."Created at Index") + ' in purchase order ' + Format(PurchaseLine."Document No.") + '.';
                            exit(false);
                        end;
                        ExpectedMatches.Get(EDocumentPurchaseLine."SystemId", ExpectedPurchaseLineSystemId);
                        if not ExpectedPurchaseLine.GetBySystemId(ExpectedPurchaseLineSystemId) then begin
                            ErrorReason := 'Expected purchase line with System ID ' + Format(ExpectedPurchaseLineSystemId) + ' not found. This should not happen.';
                            exit(false);
                        end;
                        if ExpectedPurchaseLineSystemId <> PurchaseLine."SystemId" then begin
                            ErrorReason := 'E-Document line index ' + Format(EDocumentPurchaseLine."Created at Index") + ' was expected to match purchase line with index ' + Format(ExpectedPurchaseLine."Created at Index") + ' in purchase order' + Format(ExpectedPurchaseLine."Document No.") + 'but it matched purchase line index ' + Format(PurchaseLine."Created at Index") + ' in purchase order ' + Format(PurchaseLine."Document No.") + ' instead.';
                            exit(false);
                        end;
                    until EDocPurchaseLinePOMatch.Next() = 0;

                if not EDocPurchaseLinePOMatch.IsEmpty() then
                    if not ExpectedMatches.ContainsKey(EDocumentPurchaseLine."SystemId") then begin
                        ErrorReason := 'Unexpected match found for e-document line with index ' + Format(EDocumentPurchaseLine."Created at Index") + '.';
                        exit(false);
                    end;
            until EDocumentPurchaseLine.Next() = 0;
        exit(true);
    end;

    local procedure MarkTestAsFailed(var AgentTask: Record "Agent Task"; ErrorReason: Text)
    begin
        LibraryPayablesAgent.WriteTestOutput(AgentTask, false, ErrorReason);
        Commit();
        Error(ErrorReason);
    end;

}
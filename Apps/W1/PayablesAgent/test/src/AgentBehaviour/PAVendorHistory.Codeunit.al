// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using System.Agents;
using System.Utilities;

codeunit 133718 "PA Vendor History"
{
    Subtype = Test;
    TestType = AITest;
    TestPermissions = Disabled;
    Access = Internal;

    /// <summary>
    /// Tests the AI-powered vendor matching using historical vendor assignment data.
    /// When standard vendor lookup is disabled, the agent uses past vendor assignments 
    /// (with slightly modified vendor names) to identify the correct vendor for the invoice.
    /// </summary>
    [Test]
    procedure FindVendorUsingHistoricalData()
    var
        AgentTask: Record "Agent Task";
        OutputDictionary: Dictionary of [Text, JsonToken];
        DataCreatedSuccessfully: Boolean;
    begin
        AgentTask := Initialize();
        PayablesAgentUtilities.SimulateUserApprovalForDraftInvoice(AgentTask, OutputDictionary);
        DataCreatedSuccessfully := PayablesAgentUtilities.VerifyExpectedTestOutcome(AgentTask, OutputDictionary);
        PayablesAgentUtilities.LogTestExecutionDetails(AgentTask, OutputDictionary, DataCreatedSuccessfully);
    end;

    local procedure Initialize() AgentTask: Record "Agent Task"
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        TempBlob: Codeunit "Temp Blob";
    begin
        PayablesAgentUtilities.CleanCompanyData();
        PayablesAgentUtilities.ConfigureCompany();

        // Generate historical vendor assignment data
        CreateVendorMatchHistory();

        PayablesAgentUtilities.EnablePayableAgent();
        PayablesAgentUtilities.CreatePDFInvoiceFile(TempBlob);
        PayablesAgentUtilities.ImportPDFAsEDocument(TempBlob, EDocument);

        // Force that no vendor is found by AL
        EDocumentService.Get(EDocument.Service);
        EDocumentService."Processing Customizations" := Enum::"E-Doc. Proc. Customizations"::NoVendor;
        EDocumentService.Modify();

        PayablesAgentUtilities.InvokeAgentTaskForEDocument(EDocument, AgentTask);
    end;

    local procedure CreateVendorMatchHistory()
    var
        Vendor: Record Vendor;
        PurchInvHeader: Record "Purch. Inv. Header";
        Count: Integer;
    begin
        Count := 1;
        Vendor.FindSet();
        repeat
            Clear(PurchInvHeader);
            PurchInvHeader."Buy-from Vendor No." := Vendor."No.";
            PurchInvHeader."No." := 'PA-INV' + Format(Count);
            PurchInvHeader.Insert(false);
            GenerateVendorAssignmentHistoryRecord(Vendor, PurchInvHeader);
            GenerateVendorAssignmentHistoryRecord(Vendor, PurchInvHeader);
            Count += 1;
        until Vendor.Next() = 0;
    end;

    local procedure GenerateVendorAssignmentHistoryRecord(var Vendor: Record Vendor; var PurchInvHeader: Record "Purch. Inv. Header")
    var
        EDocVendorAssignHistory: Record "E-Doc. Vendor Assign. History";
        LibraryRandom: Codeunit "Library - Random";
        Name: Text;
    begin
        Name := DelStr(Vendor.Name, LibraryRandom.RandIntInRange(1, StrLen(Vendor.Name)), 1);
        Name := DelStr(Name, LibraryRandom.RandIntInRange(1, StrLen(Name)), 1);
        EDocVendorAssignHistory."Entry No." := 0;
        EDocVendorAssignHistory."Purch. Inv. Header SystemId" := PurchInvHeader.SystemId;
        EDocVendorAssignHistory."Vendor Company Name" := CopyStr(Name, 1, 250);
        EDocVendorAssignHistory."Vendor Address" := Vendor.Address;
        EDocVendorAssignHistory."Vendor VAT Id" := Vendor."VAT Registration No.";
        EDocVendorAssignHistory."Vendor GLN" := Vendor.GLN;
        EDocVendorAssignHistory.Insert();
    end;

    var
        PayablesAgentUtilities: Codeunit "Payables Agent Utilities";
}
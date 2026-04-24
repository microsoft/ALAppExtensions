// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import;
using System.Agents;
using System.Utilities;

codeunit 133717 "PA Vendor Lookup"
{
    Subtype = Test;
    TestType = AITest;
    TestPermissions = Disabled;
    Access = Internal;

    /// <summary>
    /// Tests the vendor lookup capability when standard AL vendor matching is disabled.
    /// The agent must find the correct vendor using fuzzy matching on vendor name and address
    /// extracted from the invoice PDF.
    /// </summary>
    [Test]
    procedure FindVendorByNameAndAddress()
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
        PayablesAgentUtilities.EnablePayableAgent();
        PayablesAgentUtilities.CreatePDFInvoiceFile(TempBlob);
        PayablesAgentUtilities.ImportPDFAsEDocument(TempBlob, EDocument);

        // Force that no vendor is found by AL
        EDocumentService.Get(EDocument.Service);
        EDocumentService."Processing Customizations" := Enum::"E-Doc. Proc. Customizations"::NoVendor;
        EDocumentService.Modify();

        PayablesAgentUtilities.InvokeAgentTaskForEDocument(EDocument, AgentTask);
    end;

    var
        PayablesAgentUtilities: Codeunit "Payables Agent Utilities";
}
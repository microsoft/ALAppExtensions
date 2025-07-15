// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Foundation.UOM;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using System.AI;

codeunit 6125 "Prepare Purchase E-Doc. Draft" implements IProcessStructuredData
{
    Access = Internal;

    var
        EDocImpSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";

    procedure PrepareDraft(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"): Enum "E-Document Type"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        Vendor: Record Vendor;
        PurchaseOrder: Record "Purchase Header";
        EDocVendorAssignmentHistory: Record "E-Doc. Vendor Assign. History";
        EDocPurchaseLineHistory: Record "E-Doc. Purchase Line History";
        EDocPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping";
        IUnitOfMeasureProvider: Interface IUnitOfMeasureProvider;
        IPurchaseLineProvider: Interface IPurchaseLineProvider;
        IPurchaseOrderProvider: Interface IPurchaseOrderProvider;
    begin
        IUnitOfMeasureProvider := EDocImportParameters."Processing Customizations";
        IPurchaseLineProvider := EDocImportParameters."Processing Customizations";
        IPurchaseOrderProvider := EDocImportParameters."Processing Customizations";

        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        EDocumentPurchaseHeader.TestField("E-Document Entry No.");
        if EDocumentPurchaseHeader."[BC] Vendor No." = '' then begin
            Vendor := GetVendor(EDocument, EDocImportParameters."Processing Customizations");
            EDocumentPurchaseHeader."[BC] Vendor No." := Vendor."No.";
        end;

        PurchaseOrder := IPurchaseOrderProvider.GetPurchaseOrder(EDocumentPurchaseHeader);

        if PurchaseOrder."No." <> '' then begin
            PurchaseOrder.TestField("Document Type", "Purchase Document Type"::Order);
            EDocumentPurchaseHeader."[BC] Purchase Order No." := PurchaseOrder."No.";
            EDocumentPurchaseHeader.Modify();
            exit("E-Document Type"::"Purchase Order");
        end;
        if EDocPurchaseHistMapping.FindRelatedPurchaseHeaderInHistory(EDocument, EDocVendorAssignmentHistory) then
            EDocPurchaseHistMapping.UpdateMissingHeaderValuesFromHistory(EDocVendorAssignmentHistory, EDocumentPurchaseHeader);
        EDocumentPurchaseHeader.Modify();

        // If we cant find a vendor 
        EDocImpSessionTelemetry.SetBool('Vendor', EDocumentPurchaseHeader."[BC] Vendor No." <> '');
        if EDocumentPurchaseHeader."[BC] Vendor No." = '' then
            exit;

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        if EDocumentPurchaseLine.FindSet() then
            repeat
                // Look up based on text-to-account mapping
                UnitOfMeasure := IUnitOfMeasureProvider.GetUnitOfMeasure(EDocument, EDocumentPurchaseLine."Line No.", EDocumentPurchaseLine."Unit of Measure");
                EDocumentPurchaseLine."[BC] Unit of Measure" := UnitOfMeasure.Code;
                // Resolve the purchase line type and No., as well as related fields
                IPurchaseLineProvider.GetPurchaseLine(EDocumentPurchaseLine);

                if EDocPurchaseHistMapping.FindRelatedPurchaseLineInHistory(EDocumentPurchaseHeader."[BC] Vendor No.", EDocumentPurchaseLine, EDocPurchaseLineHistory) then
                    EDocPurchaseHistMapping.UpdateMissingLineValuesFromHistory(EDocPurchaseLineHistory, EDocumentPurchaseLine);

                EDocumentPurchaseLine.Modify();
            until EDocumentPurchaseLine.Next() = 0;

        // Ask Copilot to try to find fields that are suited to be matched
        if EDocumentPurchaseHeader."[BC] Vendor No." <> '' then
            CopilotLineMatching(EDocument."Entry No");

        exit("E-Document Type"::"Purchase Invoice");
    end;

    local procedure CopilotLineMatching(EDocumentEntryNo: Integer)
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        CopilotCapability: Codeunit "Copilot Capability";
        LineToAccountLLMMatching: Codeunit "Line To Account LLM Matching";
        EDocLineMatcherDeferral: Codeunit "E-Doc Line Matcher - Deferral";
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"E-Document Matching Assistance") then
            exit;

        if not CopilotCapability.IsCapabilityActive(Enum::"Copilot Capability"::"E-Document Matching Assistance") then
            exit;

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocumentEntryNo);
        if EDocumentPurchaseLine.FindSet() then
            LineToAccountLLMMatching.GetPurchaseLineAccountsWithCopilot(EDocumentPurchaseLine)
        else
            Session.LogMessage('0000POG', 'No E-Document Purchase Lines found for the E-Document', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', 'E-Document Matching Assistance');
        Clear(EDocumentPurchaseLine);

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocumentEntryNo);
        EDocumentPurchaseLine.SetRange("[BC] Deferral Code", '');
        if EDocumentPurchaseLine.FindSet() then
            EDocLineMatcherDeferral.ApplyPurchaseLineMatchingProposals(EDocumentPurchaseLine);
    end;

    procedure OpenDraftPage(var EDocument: Record "E-Document")
    var
        EDocumentPurchaseDraft: Page "E-Document Purchase Draft";
    begin
        EDocumentPurchaseDraft.Editable(true);
        EDocumentPurchaseDraft.SetRecord(EDocument);
        EDocumentPurchaseDraft.Run();
    end;

    procedure CleanUpDraft(EDocument: Record "E-Document")
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
    begin
        EDocumentPurchaseHeader.SetRange("E-Document Entry No.", EDocument."Entry No");
        if not EDocumentPurchaseHeader.IsEmpty() then
            EDocumentPurchaseHeader.DeleteAll(true);

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        if not EDocumentPurchaseLine.IsEmpty() then
            EDocumentPurchaseLine.DeleteAll(true);
    end;

    procedure GetVendor(EDocument: Record "E-Document"; Customizations: Enum "E-Doc. Proc. Customizations") Vendor: Record Vendor
    var
        IVendorProvider: Interface IVendorProvider;
    begin
        IVendorProvider := Customizations;
        Vendor := IVendorProvider.GetVendor(EDocument);
    end;
}
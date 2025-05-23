#pragma warning disable AS0049
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

    procedure PrepareDraft(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"): Enum "E-Document Type"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocumentHeaderMapping: Record "E-Document Header Mapping";
        EDocumentLineMapping: Record "E-Document Line Mapping";
        UnitOfMeasure: Record "Unit of Measure";
        Vendor: Record Vendor;
        PurchaseOrder: Record "Purchase Header";
        EDocVendorAssignmentHistory: Record "E-Doc. Vendor Assign. History";
        EDocPurchaseLineHistory: Record "E-Doc. Purchase Line History";
        LineToAccountLLMMatching: Codeunit "Line To Account LLM Matching";
        EDocPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping";
        CopilotCapability: Codeunit "Copilot Capability";
        IVendorProvider: Interface IVendorProvider;
        IUnitOfMeasureProvider: Interface IUnitOfMeasureProvider;
        IPurchaseLineAccountProvider: Interface IPurchaseLineAccountProvider;
        IPurchaseOrderProvider: Interface IPurchaseOrderProvider;
    begin
        IVendorProvider := EDocImportParameters."Processing Customizations";
        IUnitOfMeasureProvider := EDocImportParameters."Processing Customizations";
        IPurchaseLineAccountProvider := EDocImportParameters."Processing Customizations";
        IPurchaseOrderProvider := EDocImportParameters."Processing Customizations";

        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        EDocumentPurchaseHeader.TestField("E-Document Entry No.");
        EDocumentHeaderMapping.InsertForEDocument(EDocument);
        Vendor := IVendorProvider.GetVendor(EDocument);
        EDocumentHeaderMapping."Vendor No." := Vendor."No.";
        PurchaseOrder := IPurchaseOrderProvider.GetPurchaseOrder(EDocumentPurchaseHeader);
        if PurchaseOrder."No." <> '' then begin
            PurchaseOrder.TestField("Document Type", "Purchase Document Type"::Order);
            EDocumentHeaderMapping."Purchase Order No." := PurchaseOrder."No.";
            EDocumentHeaderMapping.Modify();
            exit("E-Document Type"::"Purchase Order");
        end;
        if EDocPurchaseHistMapping.FindRelatedPurchaseHeaderInHistory(EDocument, EDocVendorAssignmentHistory) then
            EDocPurchaseHistMapping.UpdateMissingHeaderValuesFromHistory(EDocVendorAssignmentHistory, EDocumentHeaderMapping);
        EDocumentHeaderMapping.Modify();

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        if EDocumentPurchaseLine.FindSet() then
            repeat
                // Look up based on text-to-account mapping
                EDocumentLineMapping.InsertForEDocumentLine(EDocument, EDocumentPurchaseLine."Line No.");
                UnitOfMeasure := IUnitOfMeasureProvider.GetUnitOfMeasure(EDocument, EDocumentPurchaseLine."Line No.", EDocumentPurchaseLine."Unit of Measure");
                EDocumentLineMapping."Unit of Measure" := UnitOfMeasure.Code;
                IPurchaseLineAccountProvider.GetPurchaseLineAccount(EDocumentPurchaseLine, EDocumentLineMapping, EDocumentLineMapping."Purchase Line Type", EDocumentLineMapping."Purchase Type No.");

                if EDocPurchaseHistMapping.FindRelatedPurchaseLineInHistory(EDocumentHeaderMapping."Vendor No.", EDocumentPurchaseLine, EDocPurchaseLineHistory) then
                    EDocPurchaseHistMapping.UpdateMissingLineValuesFromHistory(EDocPurchaseLineHistory, EDocumentLineMapping);
                EDocumentLineMapping.Modify();
                // Mark the lines that are not matched yet
                if EDocumentLineMapping."Purchase Type No." = '' then
                    EDocumentPurchaseLine.Mark(true);
            until EDocumentPurchaseLine.Next() = 0;
        EDocumentPurchaseLine.MarkedOnly(true);

        // Ask Copilot to try to match the marked ones (those that are not matched yet)
        if CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"E-Document Matching Assistance") then
            if CopilotCapability.IsCapabilityActive(Enum::"Copilot Capability"::"E-Document Matching Assistance") then
                LineToAccountLLMMatching.GetPurchaseLineAccountsWithCopilot(EDocumentPurchaseLine);

        exit("E-Document Type"::"Purchase Invoice");
    end;

    procedure OpenDraftPage(var EDocument: Record "E-Document")
    var
        EDocumentPurchaseDraft: Page "E-Document Purchase Draft";
    begin
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
}
#pragma warning restore AS0049
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Attachment;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Posting;
using System.Telemetry;

/// <summary>
/// Common functionality shared between purchase invoice and credit memo creation from E-Document drafts.
/// This codeunit contains reusable procedures to eliminate code duplication.
/// </summary>
codeunit 6185 "E-Doc Purchase Document Helper"
{
    Access = Internal;
    Permissions = tabledata "Dimension Set Tree Node" = im,
                  tabledata "Dimension Set Entry" = im;

    var
        Telemetry: Codeunit "Telemetry";

    /// <summary>
    /// Creates a purchase document header from E-Document draft data, including all lines.
    /// </summary>
    /// <param name="EDocument">The E-Document record containing the draft data.</param>
    /// <param name="DocumentType">The purchase document type (Invoice or Credit Memo).</param>
    /// <returns>The created purchase header record.</returns>
    internal procedure CreatePurchaseDocumentHeader(EDocument: Record "E-Document";
        DocumentType: Enum "Purchase Document Type"
        ) PurchaseHeader: Record "Purchase Header"
    var
        GLSetup: Record "General Ledger Setup";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        DocumentAttachmentMgt: Codeunit "Document Attachment Mgmt";
        EDocumentPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping";
        TelemetryEventId: Text;
        PurchaseDocumentExistsErr: Label 'A purchase %1 with external document number %2 already exists for vendor %3.', Comment = '%1 = Purchase Document Type, %2 = External Document No., %3 = Vendor No.';
        ExternalDocumentNo: Code[35];
    begin
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        case DocumentType of
            "Purchase Document Type"::Invoice:
                begin
                    TelemetryEventId := '0000PLY';
                    ExternalDocumentNo := CopyStr(EDocumentPurchaseHeader."Sales Invoice No.", 1, MaxStrLen(PurchaseHeader."Vendor Invoice No."));
                end;
            "Purchase Document Type"::"Credit Memo":
                begin
                    TelemetryEventId := '0000PLZ';
                    ExternalDocumentNo := CopyStr(EDocumentPurchaseHeader."Sales Invoice No.", 1, MaxStrLen(PurchaseHeader."Vendor Cr. Memo No."));
                end;
        end;
        EDocumentPurchaseHeader := ValidateEDocumentDraft(EDocument, TelemetryEventId);
        EDocumentPurchaseHeader.TestField("E-Document Entry No.");
        PurchaseHeader.Validate("Document Type", DocumentType);
        PurchaseHeader.Validate("Buy-from Vendor No.", EDocumentPurchaseHeader."[BC] Vendor No.");

        // Validate external document number for duplicates
        if ValidateExternalDocumentNumber(PurchaseHeader, ExternalDocumentNo) then
            Error(PurchaseDocumentExistsErr, PurchaseHeader."Document Type", ExternalDocumentNo, PurchaseHeader."Buy-from Vendor No.");

        case PurchaseHeader."Document Type" of
            "Purchase Document Type"::Invoice:
                PurchaseHeader.Validate("Vendor Invoice No.", ExternalDocumentNo);
            "Purchase Document Type"::"Credit Memo":
                PurchaseHeader.Validate("Vendor Cr. Memo No.", ExternalDocumentNo);
        end;
        PurchaseHeader.Validate("Vendor Order No.", EDocumentPurchaseHeader."Purchase Order No.");
        PurchaseHeader.Insert(true);

        if EDocumentPurchaseHeader."Document Date" <> 0D then
            PurchaseHeader.Validate("Document Date", EDocumentPurchaseHeader."Document Date");
        if EDocumentPurchaseHeader."Due Date" <> 0D then
            PurchaseHeader.Validate("Due Date", EDocumentPurchaseHeader."Due Date");
        if DocumentType = "Purchase Document Type"::Invoice then
            PurchaseHeader."Invoice Received Date" := PurchaseHeader."Document Date";
        if (DocumentType = "Purchase Document Type"::"Credit Memo") and (EDocumentPurchaseHeader."Applies-to Doc. No." <> '') then begin
            PurchaseHeader.Validate("Applies-to Doc. Type", PurchaseHeader."Applies-to Doc. Type"::Invoice);
            PurchaseHeader.Validate("Applies-to Doc. No.", EDocumentPurchaseHeader."Applies-to Doc. No.");
        end;

        PurchaseHeader.Modify(false);

        // Validate of currency has to happen after insert.
        GLSetup.GetRecordOnce();
        if EDocumentPurchaseHeader."Currency Code" <> GLSetup.GetCurrencyCode('') then begin
            PurchaseHeader.Validate("Currency Code", EDocumentPurchaseHeader."Currency Code");
            PurchaseHeader.Modify(false);
        end;

        // Track changes for history
        EDocumentPurchaseHistMapping.TrackRecord(EDocument, EDocumentPurchaseHeader, PurchaseHeader);

        PurchaseHeader.SetRecFilter();
        PurchaseHeader.FindFirst();
        PurchaseHeader."Doc. Amount Incl. VAT" := EDocumentPurchaseHeader.Total;
        PurchaseHeader."Doc. Amount VAT" := EDocumentPurchaseHeader."Total VAT";
        case DocumentType of
            "Purchase Document Type"::Invoice:
                PurchaseHeader.TestField("Document Type", "Purchase Document Type"::Invoice);
            "Purchase Document Type"::"Credit Memo":
                PurchaseHeader.TestField("Document Type", "Purchase Document Type"::"Credit Memo");
        end;
        PurchaseHeader.TestField("No.");
        PurchaseHeader."E-Document Link" := EDocument.SystemId;
        PurchaseHeader.Modify(false);

        // Post document creation
        DocumentAttachmentMgt.CopyAttachments(EDocument, PurchaseHeader);
        DocumentAttachmentMgt.DeleteAttachedDocuments(EDocument);

        CreatePurchaseDocumentLines(EDocument, PurchaseHeader, EDocumentPurchaseHistMapping);
        exit(PurchaseHeader);
    end;

    /// <summary>
    /// Creates all purchase document lines from E-Document draft data.
    /// </summary>
    /// <param name="EDocument">The E-Document record containing the draft data.</param>
    /// <param name="PurchaseHeader">The purchase header record that the lines belong to.</param>
    /// <param name="EDocumentPurchaseHistMapping">The history mapping codeunit for tracking changes.</param>
    local procedure CreatePurchaseDocumentLines(EDocument: Record "E-Document"; PurchaseHeader: Record "Purchase Header"; var EDocumentPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping")
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        PurchaseLine: Record "Purchase Line";
        DimensionManagement: Codeunit DimensionManagement;
        PurchaseLineCombinedDimensions: array[10] of Integer;
        GlobalDim1: Code[20];
        GlobalDim2: Code[20];
    begin
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        if EDocumentPurchaseLine.FindSet() then
            repeat
                PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                if PurchaseLine.FindLast() then;

                PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                PurchaseLine."Document No." := PurchaseHeader."No.";
                PurchaseLine."Line No." += 10000;
                PurchaseLine."Unit of Measure Code" := CopyStr(EDocumentPurchaseLine."[BC] Unit of Measure", 1, MaxStrLen(PurchaseLine."Unit of Measure Code"));
                PurchaseLine."Variant Code" := EDocumentPurchaseLine."[BC] Variant Code";
                PurchaseLine.Type := EDocumentPurchaseLine."[BC] Purchase Line Type";
                PurchaseLine.Validate("No.", EDocumentPurchaseLine."[BC] Purchase Type No.");
                PurchaseLine.Description := EDocumentPurchaseLine.Description;

                if EDocumentPurchaseLine."[BC] Item Reference No." <> '' then
                    PurchaseLine.Validate("Item Reference No.", EDocumentPurchaseLine."[BC] Item Reference No.");

                PurchaseLine.Validate(Quantity, EDocumentPurchaseLine.Quantity);
                PurchaseLine.Validate("Direct Unit Cost", EDocumentPurchaseLine."Unit Price");
                if EDocumentPurchaseLine."Total Discount" > 0 then
                    PurchaseLine.Validate("Line Discount Amount", EDocumentPurchaseLine."Total Discount");
                PurchaseLine.Validate("Deferral Code", EDocumentPurchaseLine."[BC] Deferral Code");

                Clear(PurchaseLineCombinedDimensions);
                PurchaseLineCombinedDimensions[1] := PurchaseLine."Dimension Set ID";
                PurchaseLineCombinedDimensions[2] := EDocumentPurchaseLine."[BC] Dimension Set ID";
                PurchaseLine.Validate("Dimension Set ID", DimensionManagement.GetCombinedDimensionSetID(PurchaseLineCombinedDimensions, GlobalDim1, GlobalDim2));
                PurchaseLine.Validate("Shortcut Dimension 1 Code", EDocumentPurchaseLine."[BC] Shortcut Dimension 1 Code");
                PurchaseLine.Validate("Shortcut Dimension 2 Code", EDocumentPurchaseLine."[BC] Shortcut Dimension 2 Code");

                EDocumentPurchaseHistMapping.ApplyAdditionalFieldsFromHistoryToPurchaseLine(EDocumentPurchaseLine, PurchaseLine);
                PurchaseLine.Insert(false);

                // Track changes for history
                EDocumentPurchaseHistMapping.TrackRecord(EDocument, EDocumentPurchaseLine, PurchaseLine);
            until EDocumentPurchaseLine.Next() = 0;
    end;

    local procedure ValidateAllDraftLinesHaveTypeAndNumber(EDocumentPurchaseHeader: Record "E-Document Purchase Header"): Boolean
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
    begin
        EDocumentPurchaseLine.SetLoadFields("[BC] Purchase Line Type", "[BC] Purchase Type No.");
        EDocumentPurchaseLine.ReadIsolation(IsolationLevel::ReadCommitted);
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocumentPurchaseHeader."E-Document Entry No.");
        if not EDocumentPurchaseLine.FindSet() then
            exit(true);
        repeat
            if EDocumentPurchaseLine."[BC] Purchase Line Type" = EDocumentPurchaseLine."[BC] Purchase Line Type"::" " then
                exit(false);
            if EDocumentPurchaseLine."[BC] Purchase Type No." = '' then
                exit(false);
        until EDocumentPurchaseLine.Next() = 0;
        exit(true);
    end;

    local procedure ValidateEDocumentDraft(EDocument: Record "E-Document"; TelemetryEventId: Text) EDocumentPurchaseHeader: Record "E-Document Purchase Header"
    var
        EmptyDraftLineErr: Label 'Draft line does not contain type or number';
        DraftLineDoesNotConstantTypeAndNumberErr: Label 'One of the draft lines do not contain the type and number. Please, specify these fields manually.';
    begin
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        if not ValidateAllDraftLinesHaveTypeAndNumber(EDocumentPurchaseHeader) then begin
            Telemetry.LogMessage(TelemetryEventId, EmptyDraftLineErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All);
            Error(DraftLineDoesNotConstantTypeAndNumberErr);
        end;
        exit(EDocumentPurchaseHeader);
    end;

    /// <summary>
    /// Validates document totals using purchase posting validation.
    /// </summary>
    /// <param name="PurchaseHeader">The purchase header to validate totals for.</param>
    /// <returns>True if validation passes, false otherwise.</returns>
    [TryFunction]
    internal procedure TryValidateDocumentTotals(PurchaseHeader: Record "Purchase Header")
    var
        PurchPost: Codeunit "Purch.-Post";
    begin
        // If document totals are setup, we just run the validation
        PurchPost.CheckDocumentTotalAmounts(PurchaseHeader);
    end;

    local procedure ValidateExternalDocumentNumber(PurchaseHeader: Record "Purchase Header"; ExternalDocumentNo: Code[35]): Boolean
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        StopCreatingPurchaseDocument: Boolean;
        InvoiceAlreadyExistsErr: Label 'A purchase invoice with external document number %1 already exists for vendor %2.', Comment = '%1 = Vendor Invoice No., %2 = Vendor No.';
        TelemetryEventId: Text;
    begin
        case PurchaseHeader."Document Type" of
            "Purchase Document Type"::Invoice:
                TelemetryEventId := '0000PHC';
            "Purchase Document Type"::"Credit Memo":
                TelemetryEventId := '0000PHD';
        end;
        VendorLedgerEntry.SetLoadFields("Entry No.");
        VendorLedgerEntry.ReadIsolation := VendorLedgerEntry.ReadIsolation::ReadUncommitted;
        StopCreatingPurchaseDocument := PurchaseHeader.FindPostedDocumentWithSameExternalDocNo(VendorLedgerEntry, ExternalDocumentNo);
        if StopCreatingPurchaseDocument then begin
            Telemetry.LogMessage(TelemetryEventId, InvoiceAlreadyExistsErr, Verbosity::Error, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
            exit(true);
        end;
        exit(false);
    end;
}

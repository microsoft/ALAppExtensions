// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using Microsoft.Finance.Dimension;
using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Posting;
using System.Telemetry;
using Microsoft.Foundation.Attachment;

/// <summary>
/// Dealing with the creation of the purchase invoice after the draft has been populated.
/// </summary>
codeunit 6117 "E-Doc. Create Purchase Invoice" implements IEDocumentFinishDraft, IEDocumentCreatePurchaseInvoice
{
    Access = Internal;
    Permissions = tabledata "Dimension Set Tree Node" = im,
                  tabledata "Dimension Set Entry" = im;

    var
        Telemetry: Codeunit "Telemetry";
        EDocImpSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";
        InvoiceAlreadyExistsErr: Label 'A purchase invoice with external document number %1 already exists for vendor %2.', Comment = '%1 = Vendor Invoice No., %2 = Vendor No.';
        DraftLineDoesNotConstantTypeAndNumberErr: Label 'One of the draft lines do not contain the type and number. Please, specify these fields manually.';

    procedure ApplyDraftToBC(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"): RecordId
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        PurchaseHeader: Record "Purchase Header";
        DocumentAttachmentMgt: Codeunit "Document Attachment Mgmt";
        IEDocumentFinishPurchaseDraft: Interface IEDocumentCreatePurchaseInvoice;
    begin
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        IEDocumentFinishPurchaseDraft := EDocImportParameters."Processing Customizations";
        PurchaseHeader := IEDocumentFinishPurchaseDraft.CreatePurchaseInvoice(EDocument);
        PurchaseHeader.SetRecFilter();
        PurchaseHeader.FindFirst();
        PurchaseHeader."Doc. Amount Incl. VAT" := EDocumentPurchaseHeader.Total;
        PurchaseHeader."Doc. Amount VAT" := EDocumentPurchaseHeader."Total VAT";
        PurchaseHeader.TestField("Document Type", "Purchase Document Type"::Invoice);
        PurchaseHeader.TestField("No.");
        PurchaseHeader."E-Document Link" := EDocument.SystemId;
        PurchaseHeader.Modify();

        // Post document creation
        DocumentAttachmentMgt.CopyAttachments(EDocument, PurchaseHeader);
        DocumentAttachmentMgt.DeleteAttachedDocuments(EDocument);

        // Post document validation - Silently emit telemetry
        if not TryValidateDocumentTotals(PurchaseHeader) then
            EDocImpSessionTelemetry.SetBool('Totals Validation Failed', true);

        exit(PurchaseHeader.RecordId);
    end;

    procedure RevertDraftActions(EDocument: Record "E-Document")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.SetRange("E-Document Link", EDocument.SystemId);
        if not PurchaseHeader.FindFirst() then
            exit;
        PurchaseHeader.TestField("Document Type", "Purchase Document Type"::Invoice);
        Clear(PurchaseHeader."E-Document Link");
        PurchaseHeader.Delete(true);
    end;

    procedure CreatePurchaseInvoice(EDocument: Record "E-Document"): Record "Purchase Header"
    var
        PurchaseHeader: Record "Purchase Header";
        GLSetup: Record "General Ledger Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        PurchaseLine: Record "Purchase Line";
        EDocumentPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping";
        DimensionManagement: Codeunit DimensionManagement;
        PurchaseLineCombinedDimensions: array[10] of Integer;
        StopCreatingPurchaseInvoice: Boolean;
        VendorInvoiceNo: Code[35];
        GlobalDim1, GlobalDim2 : Code[20];
    begin
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        if not AllDraftLinesHaveTypeAndNumberSpecificed(EDocumentPurchaseHeader) then begin
            Telemetry.LogMessage('0000PLY', 'Draft line does not contain type or number', Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All);
            Error(DraftLineDoesNotConstantTypeAndNumberErr);
        end;
        EDocumentPurchaseHeader.TestField("E-Document Entry No.");
        PurchaseHeader.SetRange("Buy-from Vendor No.", EDocumentPurchaseHeader."[BC] Vendor No."); // Setting the filter, so that the insert trigger assigns the right vendor to the purchase header
        PurchaseHeader."Document Type" := "Purchase Document Type"::Invoice;
        PurchaseHeader."Pay-to Vendor No." := EDocumentPurchaseHeader."[BC] Vendor No.";

        VendorInvoiceNo := CopyStr(EDocumentPurchaseHeader."Sales Invoice No.", 1, MaxStrLen(PurchaseHeader."Vendor Invoice No."));
        VendorLedgerEntry.SetLoadFields("Entry No.");
        VendorLedgerEntry.ReadIsolation := VendorLedgerEntry.ReadIsolation::ReadUncommitted;
        StopCreatingPurchaseInvoice := PurchaseHeader.FindPostedDocumentWithSameExternalDocNo(VendorLedgerEntry, VendorInvoiceNo);
        if StopCreatingPurchaseInvoice then begin
            Telemetry.LogMessage('0000PHC', InvoiceAlreadyExistsErr, Verbosity::Error, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
            Error(InvoiceAlreadyExistsErr, VendorInvoiceNo, EDocumentPurchaseHeader."[BC] Vendor No.");
        end;

        PurchaseHeader.Validate("Vendor Invoice No.", VendorInvoiceNo);
        PurchaseHeader.Insert(true);

        if EDocumentPurchaseHeader."Document Date" <> 0D then
            PurchaseHeader.Validate("Document Date", EDocumentPurchaseHeader."Document Date");
        if EDocumentPurchaseHeader."Due Date" <> 0D then
            PurchaseHeader.Validate("Due Date", EDocumentPurchaseHeader."Due Date");
        PurchaseHeader."Invoice Received Date" := PurchaseHeader."Document Date";
        PurchaseHeader.Modify();

        // Validate of currency has to happen after insert.
        GLSetup.GetRecordOnce();
        if EDocumentPurchaseHeader."Currency Code" <> GLSetup.GetCurrencyCode('') then begin
            PurchaseHeader.Validate("Currency Code", EDocumentPurchaseHeader."Currency Code");
            PurchaseHeader.Modify();
        end;

        // Track changes for history
        EDocumentPurchaseHistMapping.TrackRecord(EDocument, EDocumentPurchaseHeader, PurchaseHeader);

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        if EDocumentPurchaseLine.FindSet() then
            repeat
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
                EDocumentPurchaseHistMapping.ApplyHistoryValuesToPurchaseLine(EDocumentPurchaseLine, PurchaseLine);
                PurchaseLine.Insert();

                // Track changes for history
                EDocumentPurchaseHistMapping.TrackRecord(EDocument, EDocumentPurchaseLine, PurchaseLine);

            until EDocumentPurchaseLine.Next() = 0;

        exit(PurchaseHeader);

    end;

    [TryFunction]
    local procedure TryValidateDocumentTotals(PurchaseHeader: Record "Purchase Header")
    var
        PurchPost: Codeunit "Purch.-Post";
    begin
        // If document totals are setup, we just run the validation
        PurchPost.CheckDocumentTotalAmounts(PurchaseHeader);
    end;

    local procedure AllDraftLinesHaveTypeAndNumberSpecificed(EDocumentPurchaseHeader: Record "E-Document Purchase Header"): Boolean
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

}
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Attachment;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Posting;
using System.Telemetry;

/// <summary>
/// Dealing with the creation of the purchase credit memo after the draft has been populated.
/// </summary>
codeunit 6105 "E-Doc. Create Purch. Cr. Memo" implements IEDocumentFinishDraft, IEDocumentCreatePurchaseCreditMemo
{
    Access = Internal;
    Permissions = tabledata "Dimension Set Tree Node" = im,
                  tabledata "Dimension Set Entry" = im;

    var
        Telemetry: Codeunit "Telemetry";
        EDocImpSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";
        CreditMemoAlreadyExistsErr: Label 'A purchase credit memo with external document number %1 already exists for vendor %2.', Comment = '%1 = Vendor Credit Memo No., %2 = Vendor No.';
        DraftLineDoesNotConstantTypeAndNumberErr: Label 'One of the draft lines do not contain the type and number. Please, specify these fields manually.';

    /// <summary>
    /// Applies the draft E-Document to Business Central by creating a purchase credit memo from the draft data.
    /// </summary>
    /// <param name="EDocument">The E-Document record containing the draft data to be applied.</param>
    /// <param name="EDocImportParameters">The import parameters containing processing customizations.</param>
    /// <returns>The RecordId of the created purchase credit memo.</returns>
    internal procedure ApplyDraftToBC(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"): RecordId
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        PurchaseHeader: Record "Purchase Header";
        IEDocumentFinishPurchaseDraft: Interface IEDocumentCreatePurchaseCreditMemo;
    begin
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        IEDocumentFinishPurchaseDraft := EDocImportParameters."Processing Customizations";
        PurchaseHeader := IEDocumentFinishPurchaseDraft.CreatePurchaseCreditMemo(EDocument);

        // Post document validation - Silently emit telemetry
        if not TryValidateDocumentTotals(PurchaseHeader) then
            EDocImpSessionTelemetry.SetBool('Totals Validation Failed', true);

        exit(PurchaseHeader.RecordId);
    end;

    /// <summary>
    /// Reverts the draft actions by deleting the associated purchase credit memo document.
    /// </summary>
    /// <param name="EDocument">The E-Document record whose draft actions should be reverted.</param>
    internal procedure RevertDraftActions(EDocument: Record "E-Document")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.SetRange("E-Document Link", EDocument.SystemId);
        if not PurchaseHeader.FindFirst() then
            exit;
            
        PurchaseHeader.TestField("Document Type", "Purchase Document Type"::"Credit Memo");
        Clear(PurchaseHeader."E-Document Link");
        PurchaseHeader.Delete(true);
    end;

    /// <summary>
    /// Creates a purchase credit memo from E-Document draft data, including header and line information.
    /// </summary>
    /// <param name="EDocument">The E-Document record containing the draft data to create the credit memo from.</param>
    /// <returns>The created purchase header record for the credit memo.</returns>
    internal procedure CreatePurchaseCreditMemo(EDocument: Record "E-Document"): Record "Purchase Header"
    var
        PurchaseHeader: Record "Purchase Header";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocumentPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping";
    begin
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        if not AllDraftLinesHaveTypeAndNumberSpecificed(EDocumentPurchaseHeader) then begin
            Telemetry.LogMessage('0000PLZ', 'Draft line does not contain type or number', Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All);
            Error(DraftLineDoesNotConstantTypeAndNumberErr);
        end;
        EDocumentPurchaseHeader.TestField("E-Document Entry No.");
        CreatePurchaseHeader(EDocument, PurchaseHeader, EDocumentPurchaseHeader, EDocumentPurchaseHistMapping);

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        if EDocumentPurchaseLine.FindSet() then
            repeat
                CreatePurchaseLine(EDocument, PurchaseHeader, EDocumentPurchaseLine, EDocumentPurchaseHistMapping);
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

    local procedure CreatePurchaseHeader(EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header"; EDocumentPurchaseHeader: Record "E-Document Purchase Header"; var EDocumentPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping")
    var
        GLSetup: Record "General Ledger Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DocumentAttachmentMgt: Codeunit "Document Attachment Mgmt";
        StopCreatingPurchaseCreditMemo: Boolean;
        VendorCreditMemoNo: Code[35];
    begin
        PurchaseHeader.Validate("Document Type", "Purchase Document Type"::"Credit Memo");
        PurchaseHeader.Validate("Buy-from Vendor No.", EDocumentPurchaseHeader."[BC] Vendor No.");

        VendorCreditMemoNo := CopyStr(EDocumentPurchaseHeader."Sales Invoice No.", 1, MaxStrLen(PurchaseHeader."Vendor Cr. Memo No."));
        VendorLedgerEntry.SetLoadFields("Entry No.");
        VendorLedgerEntry.ReadIsolation := VendorLedgerEntry.ReadIsolation::ReadUncommitted;
        StopCreatingPurchaseCreditMemo := PurchaseHeader.FindPostedDocumentWithSameExternalDocNo(VendorLedgerEntry, VendorCreditMemoNo);
        if StopCreatingPurchaseCreditMemo then begin
            Telemetry.LogMessage('0000PHD', CreditMemoAlreadyExistsErr, Verbosity::Error, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
            Error(CreditMemoAlreadyExistsErr, VendorCreditMemoNo, EDocumentPurchaseHeader."[BC] Vendor No.");
        end;

        PurchaseHeader.Validate("Vendor Cr. Memo No.", VendorCreditMemoNo);
        PurchaseHeader.Validate("Vendor Order No.", EDocumentPurchaseHeader."Purchase Order No.");
        PurchaseHeader.Insert(true);

        if EDocumentPurchaseHeader."Document Date" <> 0D then
            PurchaseHeader.Validate("Document Date", EDocumentPurchaseHeader."Document Date");
        if EDocumentPurchaseHeader."Due Date" <> 0D then
            PurchaseHeader.Validate("Due Date", EDocumentPurchaseHeader."Due Date");
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
        PurchaseHeader.TestField("Document Type", "Purchase Document Type"::"Credit Memo");
        PurchaseHeader.TestField("No.");
        PurchaseHeader."E-Document Link" := EDocument.SystemId;
        PurchaseHeader.Modify(false);

        // Post document creation
        DocumentAttachmentMgt.CopyAttachments(EDocument, PurchaseHeader);
        DocumentAttachmentMgt.DeleteAttachedDocuments(EDocument);
    end;

    local procedure CreatePurchaseLine(EDocument: Record "E-Document"; PurchaseHeader: Record "Purchase Header"; EDocumentPurchaseLine: Record "E-Document Purchase Line"; var EDocumentPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping")
    var
        PurchaseLine: Record "Purchase Line";
        DimensionManagement: Codeunit DimensionManagement;
        PurchaseLineCombinedDimensions: array[10] of Integer;
        GlobalDim1: Code[20];
        GlobalDim2: Code[20];
    begin
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
        EDocumentPurchaseHistMapping.ApplyHistoryValuesToPurchaseLine(EDocumentPurchaseLine, PurchaseLine);
        PurchaseLine.Insert(false);

        // Track changes for history
        EDocumentPurchaseHistMapping.TrackRecord(EDocument, EDocumentPurchaseLine, PurchaseLine);
    end;
}

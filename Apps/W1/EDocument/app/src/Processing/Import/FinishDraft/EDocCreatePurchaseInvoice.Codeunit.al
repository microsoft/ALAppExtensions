// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.Finance.Dimension;
using Microsoft.Purchases.Document;

/// <summary>
/// Dealing with the creation of the purchase invoice after the draft has been populated.
/// </summary>
codeunit 6117 "E-Doc. Create Purchase Invoice" implements IEDocumentFinishDraft, IEDocumentCreatePurchaseInvoice
{
    Access = Internal;
    Permissions = tabledata "Dimension Set Tree Node" = im,
                  tabledata "Dimension Set Entry" = im;

    var
        EDocImpSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";

    /// <summary>
    /// Applies the draft E-Document to Business Central by creating a purchase invoice from the draft data.
    /// </summary>
    /// <param name="EDocument">The E-Document record containing the draft data to be applied.</param>
    /// <param name="EDocImportParameters">The import parameters containing processing customizations.</param>
    /// <returns>The RecordId of the created purchase invoice.</returns>
    procedure ApplyDraftToBC(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"): RecordId
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        PurchaseHeader: Record "Purchase Header";
        EDocPurchaseDocumentHelper: Codeunit "E-Doc Purchase Document Helper";
        IEDocumentFinishPurchaseDraft: Interface IEDocumentCreatePurchaseInvoice;
    begin
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        IEDocumentFinishPurchaseDraft := EDocImportParameters."Processing Customizations";
        PurchaseHeader := IEDocumentFinishPurchaseDraft.CreatePurchaseInvoice(EDocument);

        // Post document validation - Silently emit telemetry
        EDocImpSessionTelemetry.SetBool('Totals Validation', EDocPurchaseDocumentHelper.TryValidateDocumentTotals(PurchaseHeader));

        exit(PurchaseHeader.RecordId);
    end;

    /// <summary>
    /// Reverts the draft actions by deleting the associated purchase invoice document.
    /// </summary>
    /// <param name="EDocument">The E-Document record whose draft actions should be reverted.</param>
    procedure RevertDraftActions(EDocument: Record "E-Document")
    var
        PurchaseHeader: Record "Purchase Header";
        DocumentAttachmentMgt: Codeunit "Document Attachment Mgmt";
    begin
        PurchaseHeader.SetRange("E-Document Link", EDocument.SystemId);
        if not PurchaseHeader.FindFirst() then
            exit;
        DocumentAttachmentMgt.CopyAttachments(PurchaseHeader, EDocument);
        DocumentAttachmentMgt.DeleteAttachedDocuments(PurchaseHeader);
        PurchaseHeader.TestField("Document Type", "Purchase Document Type"::Invoice);
        Clear(PurchaseHeader."E-Document Link");
        PurchaseHeader.Delete(true);
    end;

    /// <summary>
    /// Creates a purchase invoice from E-Document draft data, including header and line information.
    /// </summary>
    /// <param name="EDocument">The E-Document record containing the draft data to create the invoice from.</param>
    /// <returns>The created purchase header record for the invoice.</returns>
    procedure CreatePurchaseInvoice(EDocument: Record "E-Document") PurchaseHeader: Record "Purchase Header"
    var
        EDocPurchaseDocumentHelper: Codeunit "E-Doc Purchase Document Helper";
    begin
        PurchaseHeader := EDocPurchaseDocumentHelper.CreatePurchaseDocumentHeader(EDocument, "Purchase Document Type"::Invoice);
        exit(PurchaseHeader);
    end;
}
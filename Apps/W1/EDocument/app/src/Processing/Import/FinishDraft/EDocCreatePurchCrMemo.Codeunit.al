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
/// Dealing with the creation of the purchase credit memo after the draft has been populated.
/// </summary>
codeunit 6105 "E-Doc. Create Purch. Cr. Memo" implements IEDocumentFinishDraft, IEDocumentCreatePurchaseCreditMemo
{
    Access = Internal;
    Permissions = tabledata "Dimension Set Tree Node" = im,
                  tabledata "Dimension Set Entry" = im;

    var
        EDocImpSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";

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
        EDocPurchaseDocumentHelper: Codeunit "E-Doc Purchase Document Helper";
        IEDocumentFinishPurchaseDraft: Interface IEDocumentCreatePurchaseCreditMemo;
    begin
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        IEDocumentFinishPurchaseDraft := EDocImportParameters."Processing Customizations";
        PurchaseHeader := IEDocumentFinishPurchaseDraft.CreatePurchaseCreditMemo(EDocument);

        // Post document validation - Silently emit telemetry
        if not EDocPurchaseDocumentHelper.TryValidateDocumentTotals(PurchaseHeader) then
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
    internal procedure CreatePurchaseCreditMemo(EDocument: Record "E-Document") PurchaseHeader: Record "Purchase Header"
    var
        EDocPurchaseDocumentHelper: Codeunit "E-Doc Purchase Document Helper";
    begin
        PurchaseHeader := EDocPurchaseDocumentHelper.CreatePurchaseDocumentHeader(EDocument, "Purchase Document Type"::"Credit Memo");
        exit(PurchaseHeader);
    end;
}

// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;

/// <summary>
/// Dealing with the creation of the purchase invoice after the draft has been populated.
/// </summary>
codeunit 6117 "E-Doc. Create Purchase Invoice" implements IEDocumentFinishDraft, IEDocumentCreatePurchaseInvoice
{
    Access = Internal;

    procedure ApplyDraftToBC(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"): RecordId
    var
        PurchaseHeader: Record "Purchase Header";
        IEDocumentFinishPurchaseDraft: Interface IEDocumentCreatePurchaseInvoice;
    begin
        IEDocumentFinishPurchaseDraft := EDocImportParameters."Processing Customizations";
        PurchaseHeader := IEDocumentFinishPurchaseDraft.CreatePurchaseInvoice(EDocument);
        PurchaseHeader.TestField("Document Type", "Purchase Document Type"::Invoice);
        PurchaseHeader.TestField("No.");
        PurchaseHeader.SetRecFilter();
        PurchaseHeader.FindFirst();
        PurchaseHeader."E-Document Link" := EDocument.SystemId;
        PurchaseHeader.Modify();

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

    procedure CreatePurchaseInvoice(EDocument: Record "E-Document") PurchaseHeader: Record "Purchase Header"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocumentHeaderMapping: Record "E-Document Header Mapping";
        EDocumentLineMapping: Record "E-Document Line Mapping";
        PurchaseLine: Record "Purchase Line";
        EDocumentPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping";
    begin
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        EDocumentPurchaseHeader.TestField("E-Document Entry No.");
        EDocumentHeaderMapping := EDocument.GetEDocumentHeaderMapping();
        PurchaseHeader.SetRange("Buy-from Vendor No.", EDocumentHeaderMapping."Vendor No."); // Setting the filter, so that the insert trigger assigns the right vendor to the purchase header
        PurchaseHeader."Document Type" := "Purchase Document Type"::Invoice;
        PurchaseHeader."Vendor Invoice No." := CopyStr(EDocumentPurchaseHeader."Sales Invoice No.", 1, MaxStrLen(PurchaseHeader."Vendor Invoice No."));
        PurchaseHeader.Insert(true);

        // Track changes for history
        EDocumentPurchaseHistMapping.TrackRecord(EDocument, EDocumentPurchaseHeader, PurchaseHeader);

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        if EDocumentPurchaseLine.FindSet() then
            repeat
                if EDocumentLineMapping.Get(EDocument."Entry No", EDocumentPurchaseLine."Line No.") then;
                PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                PurchaseLine."Document No." := PurchaseHeader."No.";
                PurchaseLine."Line No." += 10000;
                PurchaseLine."Unit of Measure Code" := CopyStr(EDocumentLineMapping."Unit of Measure", 1, MaxStrLen(PurchaseLine."Unit of Measure Code"));
                PurchaseLine.Type := EDocumentLineMapping."Purchase Line Type";
                PurchaseLine.Validate("No.", EDocumentLineMapping."Purchase Type No.");
                PurchaseLine.Description := EDocumentPurchaseLine.Description;
                PurchaseLine.Validate(Quantity, EDocumentPurchaseLine.Quantity);
                PurchaseLine.Validate("Direct Unit Cost", EDocumentPurchaseLine."Unit Price");
                PurchaseLine.Validate("Deferral Code", EDocumentLineMapping."Deferral Code");
                PurchaseLine.Validate("Shortcut Dimension 1 Code", EDocumentLineMapping."Shortcut Dimension 1 Code");
                PurchaseLine.Validate("Shortcut Dimension 2 Code", EDocumentLineMapping."Shortcut Dimension 2 Code");
                EDocumentPurchaseHistMapping.ApplyHistoryValuesToPurchaseLine(EDocumentLineMapping, PurchaseLine);
                PurchaseLine.Insert();

                // Track changes for history
                EDocumentPurchaseHistMapping.TrackRecord(EDocument, EDocumentPurchaseLine, PurchaseLine);

            until EDocumentPurchaseLine.Next() = 0;
    end;

}
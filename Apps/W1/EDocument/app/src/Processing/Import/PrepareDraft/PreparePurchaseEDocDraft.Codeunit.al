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

codeunit 6125 "Prepare Purchase E-Doc. Draft" implements IProcessStructuredData
{
    procedure PrepareDraft(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"): Enum "E-Document Type"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocumentHeaderMapping: Record "E-Document Header Mapping";
        EDocumentLineMapping: Record "E-Document Line Mapping";
        UnitOfMeasure: Record "Unit of Measure";
        Vendor: Record Vendor;
        PurchaseOrder: Record "Purchase Header";
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
        EDocumentHeaderMapping.Modify();

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        if EDocumentPurchaseLine.FindSet() then
            repeat
                EDocumentLineMapping.InsertForEDocumentLine(EDocument, EDocumentPurchaseLine."E-Document Line Id");
                UnitOfMeasure := IUnitOfMeasureProvider.GetUnitOfMeasure(EDocument, EDocumentPurchaseLine."E-Document Line Id", EDocumentPurchaseLine."Unit of Measure");
                EDocumentLineMapping."Unit of Measure" := UnitOfMeasure.Code;
                IPurchaseLineAccountProvider.GetPurchaseLineAccount(EDocumentPurchaseLine, EDocumentLineMapping, EDocumentLineMapping."Purchase Line Type", EDocumentLineMapping."Purchase Type No.");
                EDocumentLineMapping.Modify();
            until EDocumentPurchaseLine.Next() = 0;
        exit("E-Document Type"::"Purchase Invoice");
    end;

    procedure OpenDraftPage(var EDocument: Record "E-Document")
    var
        EDocumentPurchaseDraft: Page "E-Document Purchase Draft";
    begin
        EDocumentPurchaseDraft.SetRecord(EDocument);
        EDocumentPurchaseDraft.Run();
    end;

}

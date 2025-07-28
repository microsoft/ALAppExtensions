// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using Microsoft.Foundation.UOM;
using Microsoft.Purchases.Vendor;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Bank.Reconciliation;
using Microsoft.eServices.EDocument.Service.Participant;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;


codeunit 6124 "E-Doc. Providers" implements IPurchaseLineProvider, IUnitOfMeasureProvider, IVendorProvider, IPurchaseOrderProvider
{
    Access = Internal;

    var
        NoVendorInformationErr: Label 'There is no vendor information in the source document. Verify that the source document is an invoice, and if it''s not, consider deleting this E-Document.';


    procedure GetVendor(EDocument: Record "E-Document") Vendor: Record Vendor
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        ServiceParticipant: Record "Service Participant";
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        EDocumentHasNoVendorInformation: Boolean;
    begin
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        EDocumentHasNoVendorInformation := (EDocumentPurchaseHeader."Vendor GLN" = '') and (EDocumentPurchaseHeader."Vendor VAT Id" = '') and (EDocumentPurchaseHeader."Vendor External Id" = '') and (EDocumentPurchaseHeader."Vendor Company Name" = '') and (EDocumentPurchaseHeader."Vendor Address" = '');
        if EDocumentHasNoVendorInformation then
            // We warn if there's no vendor information extracted from the E-Document, unless we are aware that it is a blank draft
            if EDocument."Read into Draft Impl." <> "E-Doc. Read into Draft"::"Blank Draft" then
                EDocErrorHelper.LogWarningMessage(EDocument, EDocumentPurchaseHeader, EDocumentPurchaseHeader.FieldNo("[BC] Vendor No."), NoVendorInformationErr);

        // If the E-Document has no vendor information, we can't find the vendor, so we exit early
        if EDocumentHasNoVendorInformation then
            exit;

        if Vendor.Get(EDocumentImportHelper.FindVendor('', EDocumentPurchaseHeader."Vendor GLN", EDocumentPurchaseHeader."Vendor VAT Id")) then
            exit;

        ServiceParticipant.SetRange("Participant Type", ServiceParticipant."Participant Type"::Vendor);
        ServiceParticipant.SetRange("Participant Identifier", EDocumentPurchaseHeader."Vendor External Id");
        ServiceParticipant.SetRange(Service, EDocument.GetEDocumentService().Code);
        if not ServiceParticipant.FindFirst() then begin
            ServiceParticipant.SetRange(Service);
            if ServiceParticipant.FindFirst() then;
        end;
        if Vendor.Get(ServiceParticipant.Participant) then
            exit;

        if Vendor.Get(EDocumentImportHelper.FindVendorByNameAndAddress(EDocumentPurchaseHeader."Vendor Company Name", EDocumentPurchaseHeader."Vendor Address")) then;
    end;

    procedure GetUnitOfMeasure(EDocumentHeader: Record "E-Document"; EDocumentLineId: Integer; ExternalUnitOfMeasure: Text) UnitOfMeasure: Record "Unit of Measure"
    begin
        if ExternalUnitOfMeasure = '' then
            exit;
        UnitOfMeasure.SetRange(Code, ExternalUnitOfMeasure);
        if UnitOfMeasure.FindFirst() then
            exit;
        Clear(UnitOfMeasure);
        UnitOfMeasure.SetRange("International Standard Code", ExternalUnitOfMeasure);
        if UnitOfMeasure.FindFirst() then
            exit;
        Clear(UnitOfMeasure);
        UnitOfMeasure.SetRange(Description, ExternalUnitOfMeasure);
        if UnitOfMeasure.FindFirst() then;
    end;

    procedure GetPurchaseLine(var EDocumentPurchaseLine: Record "E-Document Purchase Line")
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        ItemReference: Record "Item Reference";
        EDocument: Record "E-Document";
        TextToAccountMapping: Record "Text-to-Account Mapping";
        EDocImpSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";
        VendorNo: Code[20];
        FilterInvalidCharTxt: Label '(&)', Locked = true;
    begin
        EDocument.Get(EDocumentPurchaseLine."E-Document Entry No.");
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        VendorNo := EDocumentPurchaseHeader."[BC] Vendor No.";

        if GetPurchaseLineItemRef(EDocumentPurchaseLine, ItemReference) then begin
            EDocumentPurchaseLine."[BC] Purchase Line Type" := "Purchase Line Type"::Item;
            EDocumentPurchaseLine.Validate("[BC] Purchase Type No.", ItemReference."Item No.");
            EDocumentPurchaseLine.Validate("[BC] Unit of Measure", ItemReference."Unit of Measure");
            EDocumentPurchaseLine.Validate("[BC] Variant Code", ItemReference."Variant Code");
            EDocumentPurchaseLine.Validate("[BC] Item Reference No.", ItemReference."Reference No.");
            EDocImpSessionTelemetry.SetLineBool(EDocumentPurchaseLine.SystemId, 'Item Reference ', true);
            exit;
        end;

        TextToAccountMapping.SetRange("Vendor No.", VendorNo);
        TextToAccountMapping.SetFilter("Mapping Text", '%1', '@' + DelChr(EDocumentPurchaseLine.Description, '=', FilterInvalidCharTxt));
        if TextToAccountMapping.FindFirst() then begin
            EDocumentPurchaseLine."[BC] Purchase Line Type" := "Purchase Line Type"::"G/L Account";
            EDocumentPurchaseLine.Validate("[BC] Purchase Type No.", TextToAccountMapping."Debit Acc. No.");
            EDocImpSessionTelemetry.SetLineBool(EDocumentPurchaseLine.SystemId, 'Text To Account Mapping', true);
            exit;
        end;
    end;

    procedure GetPurchaseOrder(EDocumentPurchaseHeader: Record "E-Document Purchase Header") PurchaseHeader: Record "Purchase Header"
    begin
        if PurchaseHeader.Get("Purchase Document Type"::Order, EDocumentPurchaseHeader."Purchase Order No.") then;
    end;

    local procedure GetPurchaseLineItemRef(EDocumentPurchaseLine: Record "E-Document Purchase Line"; var ItemReference: Record "Item Reference"): Boolean
    var
        EDocument: Record "E-Document";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        Item: Record Item;
        VendorNo: Code[20];
    begin
        EDocument.Get(EDocumentPurchaseLine."E-Document Entry No.");
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        VendorNo := EDocumentPurchaseHeader."[BC] Vendor No.";
        ItemReference.SetRange("Reference Type", Enum::"Item Reference Type"::Vendor);
        ItemReference.SetRange("Reference Type No.", VendorNo);
        ItemReference.SetRange("Reference No.", EDocumentPurchaseLine."Product Code");
        ItemReference.SetRange("Unit of Measure", EDocumentPurchaseLine."[BC] Unit of Measure");
        ItemReference.SetFilter("Starting Date", '<= %1', WorkDate());
        ItemReference.SetFilter("Ending Date", '>= %1 | %2', WorkDate(), 0D);
        if ItemReference.FindSet() then
            repeat
                if ItemReference.HasValidUnitOfMeasure() then
                    exit(true);
            until ItemReference.Next() = 0;

        ItemReference.SetRange("Unit of Measure", '');
        if ItemReference.FindSet() then
            repeat
                if ItemReference.HasValidUnitOfMeasure() then
                    exit(true);
            until ItemReference.Next() = 0;

        ItemReference.SetRange("Unit of Measure");
        if ItemReference.FindFirst() then
            if Item.Get(ItemReference."Item No.") then
                exit(true);
    end;

}
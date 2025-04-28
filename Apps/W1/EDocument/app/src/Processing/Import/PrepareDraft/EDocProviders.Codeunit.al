#pragma warning disable AS0049
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


codeunit 6124 "E-Doc. Providers" implements IPurchaseLineAccountProvider, IUnitOfMeasureProvider, IVendorProvider, IPurchaseOrderProvider
{
    Access = Internal;

    procedure GetVendor(EDocument: Record "E-Document") Vendor: Record Vendor
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        ServiceParticipant: Record "Service Participant";
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
    begin
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        if (EDocumentPurchaseHeader."Vendor GLN" = '') and (EDocumentPurchaseHeader."Vendor VAT Id" = '') and (EDocumentPurchaseHeader."Vendor External Id" = '') and (EDocumentPurchaseHeader."Vendor Company Name" = '') and (EDocumentPurchaseHeader."Vendor Address" = '') then
            Error(NoVendorInformationErr);

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

    procedure GetPurchaseLineAccount(EDocumentPurchaseLine: Record "E-Document Purchase Line"; EDocumentLineMapping: Record "E-Document Line Mapping"; var AccountType: Enum "Purchase Line Type"; var AccountNo: Code[20])
    var
        EDocument: Record "E-Document";
        ItemReference: Record "Item Reference";
        Item: Record Item;
        TextToAccountMapping: Record "Text-to-Account Mapping";
        VendorNo: Code[20];
        FilterInvalidCharTxt: Label '(&)', Locked = true;
    begin
        AccountType := "Purchase Line Type"::" ";
        EDocument.Get(EDocumentPurchaseLine."E-Document Entry No.");
        VendorNo := EDocument.GetEDocumentHeaderMapping()."Vendor No.";
        ItemReference.SetRange("Reference Type", Enum::"Item Reference Type"::Vendor);
        ItemReference.SetRange("Reference Type No.", VendorNo);
        ItemReference.SetRange("Reference No.", EDocumentPurchaseLine."Product Code");
        ItemReference.SetRange("Unit of Measure", EDocumentLineMapping."Unit of Measure");
        if ItemReference.FindSet() then
            repeat
                if ItemReference.HasValidUnitOfMeasure() then
                    if Item.Get(ItemReference."Item No.") then begin
                        AccountNo := Item."No.";
                        AccountType := "Purchase Line Type"::Item;
                        exit;
                    end
            until ItemReference.Next() = 0;

        ItemReference.SetRange("Unit of Measure", '');
        if ItemReference.FindSet() then
            repeat
                if ItemReference.HasValidUnitOfMeasure() then
                    if Item.Get(ItemReference."Item No.") then begin
                        AccountNo := Item."No.";
                        AccountType := "Purchase Line Type"::Item;
                        exit;
                    end;
            until ItemReference.Next() = 0;

        ItemReference.SetRange("Unit of Measure");
        if ItemReference.FindFirst() then
            if Item.Get(ItemReference."Item No.") then begin
                AccountNo := Item."No.";
                AccountType := "Purchase Line Type"::Item;
                exit;
            end;
        TextToAccountMapping.SetRange("Vendor No.", VendorNo);
        TextToAccountMapping.SetFilter("Mapping Text", '%1', '@' + DelChr(EDocumentPurchaseLine.Description, '=', FilterInvalidCharTxt));
        if TextToAccountMapping.FindFirst() then begin
            AccountNo := TextToAccountMapping."Debit Acc. No.";
            AccountType := "Purchase Line Type"::"G/L Account";
            exit;
        end;
    end;

    procedure GetPurchaseOrder(EDocumentPurchaseHeader: Record "E-Document Purchase Header") PurchaseHeader: Record "Purchase Header"
    begin
        if PurchaseHeader.Get("Purchase Document Type"::Order, EDocumentPurchaseHeader."Purchase Order No.") then;
    end;

    var
        NoVendorInformationErr: Label 'There is no vendor information in the source document. Verify that the source document is an invoice, and if it''s not, consider deleting this E-Document.';
}
#pragma warning restore AS0049
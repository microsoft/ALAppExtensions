// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;

codeunit 30262 "Shpfy Document Link Mgt."
{
    Permissions = TableData "Shpfy Doc. Link To Doc." = imd;

    var
        DocLinkToBCDoc: Record "Shpfy Doc. Link To Doc.";
        ShpfyBCDocumentTypeConvert: Codeunit "Shpfy BC Document Type Convert";

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnDeleteSalesHeader(var Rec: Record "Sales Header")
    begin
        if Rec.IsTemporary() then
            exit;

        DocLinkToBCDoc.SetRange("Document Type", ShpfyBCDocumentTypeConvert.Convert(Rec."Document Type"));
        DocLinkToBCDoc.SetRange("Document No.", Rec."No.");
        DocLinkToBCDoc.SetCurrentKey("Document Type", "Document No.");
        if not DocLinkToBCDoc.IsEmpty then
            DocLinkToBCDoc.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PostSales-Delete", 'OnAfterDeleteHeader', '', true, false)]
    local procedure OnAfterDelete(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        if SalesHeader.IsTemporary() then
            exit;

        DocLinkToBCDoc.SetRange("Document Type", ShpfyBCDocumentTypeConvert.Convert(SalesHeader."Document Type"));
        DocLinkToBCDoc.SetRange("Document No.", SalesHeader."No.");
        DocLinkToBCDoc.SetCurrentKey("Document Type", "Document No.");
        if DocLinkToBCDoc.FindFirst() then begin
            CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", ShpfyBCDocumentTypeConvert.Convert(SalesShipmentHeader), SalesShipmentHeader."No.");
            CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", ShpfyBCDocumentTypeConvert.Convert(SalesInvoiceHeader), SalesInvoiceHeader."No.");
            CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", ShpfyBCDocumentTypeConvert.Convert(ReturnReceiptHeader), ReturnReceiptHeader."No.");
            CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", ShpfyBCDocumentTypeConvert.Convert(SalesCrMemoHeader), SalesCrMemoHeader."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeDeleteAfterPosting', '', true, false)]
    local procedure OnBeforeDeleteAfterPosting(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        if SalesHeader.IsTemporary() then
            exit;

        DocLinkToBCDoc.SetRange("Document Type", ShpfyBCDocumentTypeConvert.Convert(SalesHeader."Document Type"));
        DocLinkToBCDoc.SetRange("Document No.", SalesHeader."No.");
        DocLinkToBCDoc.SetCurrentKey("Document Type", "Document No.");
        if DocLinkToBCDoc.FindFirst() then begin
            CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", ShpfyBCDocumentTypeConvert.Convert(SalesInvoiceHeader), SalesInvoiceHeader."No.");
            CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", ShpfyBCDocumentTypeConvert.Convert(SalesCrMemoHeader), SalesCrMemoHeader."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, false)]
    local procedure OnAfterSalesPosting(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; SalesShptHdrNo: Code[20]; SalesInvHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesShipments: List of [Code[20]];
    begin
        if SalesHeader.IsTemporary() then
            exit;

        if PreviewMode then
            exit;

        DocLinkToBCDoc.SetRange("Document Type", ShpfyBCDocumentTypeConvert.Convert(SalesHeader."Document Type"));
        DocLinkToBCDoc.SetRange("Document No.", SalesHeader."No.");
        DocLinkToBCDoc.SetCurrentKey("Document Type", "Document No.");
        if DocLinkToBCDoc.FindFirst() then begin
            CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", "Shpfy Document Type"::"Posted Sales Shipment", SalesShptHdrNo);
            CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", "Shpfy Document Type"::"Posted Sales Invoice", SalesInvHdrNo);
            CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", "Shpfy Document Type"::"Posted Return Receipt", RetRcpHdrNo);
            CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", "Shpfy Document Type"::"Posted Sales Credit Memo", SalesCrMemoHdrNo);
            exit;
        end;

        DocLinkToBCDoc.SetRange("Document Type", DocLinkToBCDoc."Document Type"::"Posted Sales Invoice");
        DocLinkToBCDoc.SetRange("Document No.", SalesInvHdrNo);
        if DocLinkToBCDoc.FindFirst() then begin
            CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", "Shpfy Document Type"::"Posted Sales Shipment", SalesShptHdrNo);
            CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", "Shpfy Document Type"::"Posted Return Receipt", RetRcpHdrNo);
            exit;
        end;

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then begin
            SalesInvoiceLine.SetRange("Document No.", SalesInvHdrNo);
            SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
            SalesInvoiceLine.SetFilter("Shipment No.", '<>%1', '');
            if SalesInvoiceLine.FindSet() then
                repeat
                    if not SalesShipments.Contains(SalesInvoiceLine."Shipment No.") then
                        if SalesShipmentHeader.Get(SalesInvoiceLine."Shipment No.") then begin
                            SalesShipments.Add(SalesInvoiceLine."Shipment No.");
                            DocLinkToBCDoc.SetRange("Document Type", DocLinkToBCDoc."Document Type"::"Posted Sales Shipment");
                            DocLinkToBCDoc.SetRange("Document No.", SalesShipmentHeader."No.");
                            if DocLinkToBCDoc.FindFirst() then
                                CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", "Shpfy Document Type"::"Posted Sales Invoice", SalesInvHdrNo);
                        end;
                until SalesInvoiceLine.Next() = 0;
        end;
    end;

    local procedure CreateNewDocumentLink(DocumentType: Enum "Shpfy Shop Document Type"; DocumentId: BigInteger; BCDocumentType: Enum "Shpfy Document Type"; DocumentNo: code[20])
    var
        NewDocLinkToBCDoc: Record "Shpfy Doc. Link To Doc.";
    begin
        if (DocumentType <> "Shpfy Shop Document Type"::" ") and (DocumentId > 0) and (BCDocumentType <> "Shpfy Document Type"::" ") and (DocumentNo <> '') then begin
            NewDocLinkToBCDoc.Init();
            NewDocLinkToBCDoc."Shopify Document Type" := DocumentType;
            NewDocLinkToBCDoc."Shopify Document Id" := DocumentId;
            NewDocLinkToBCDoc."Document Type" := BCDocumentType;
            NewDocLinkToBCDoc."Document No." := DocumentNo;
            NewDocLinkToBCDoc.Insert();
        end;
    end;
}
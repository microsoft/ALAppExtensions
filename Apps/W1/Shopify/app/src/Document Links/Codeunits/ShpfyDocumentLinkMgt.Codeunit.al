codeunit 30262 "Shpfy Document Link Mgt."
{
    var
        DocLinkToBCDoc: Record "Shpfy Doc. Link To BC Doc.";
        ShpfyBCDocumentTypeConvert: Codeunit "Shpfy BC Document Type Convert";

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnDeleteSalesHeader(var Rec: Record "Sales Header")
    begin
        DocLinkToBCDoc.SetRange("BC Document Type", ShpfyBCDocumentTypeConvert.Convert(Rec."Document Type"));
        DocLinkToBCDoc.SetRange("BC Document No.", Rec."No.");
        DocLinkToBCDoc.SetCurrentKey("BC Document Type", "BC Document No.");
        if not DocLinkToBCDoc.IsEmpty then
            DocLinkToBCDoc.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PostSales-Delete", 'OnAfterDeleteHeader', '', true, false)]
    local procedure OnAfterDelete(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        DocLinkToBCDoc.SetRange("BC Document Type", ShpfyBCDocumentTypeConvert.Convert(SalesHeader."Document Type"));
        DocLinkToBCDoc.SetRange("BC Document No.", SalesHeader."No.");
        DocLinkToBCDoc.SetCurrentKey("BC Document Type", "BC Document No.");
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
        DocLinkToBCDoc.SetRange("BC Document Type", ShpfyBCDocumentTypeConvert.Convert(SalesHeader."Document Type"));
        DocLinkToBCDoc.SetRange("BC Document No.", SalesHeader."No.");
        DocLinkToBCDoc.SetCurrentKey("BC Document Type", "BC Document No.");
        if DocLinkToBCDoc.FindFirst() then begin
            CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", ShpfyBCDocumentTypeConvert.Convert(SalesInvoiceHeader), SalesInvoiceHeader."No.");
            CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", ShpfyBCDocumentTypeConvert.Convert(SalesCrMemoHeader), SalesCrMemoHeader."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, false)]
    local procedure OnAfterSalesPosting(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; SalesShptHdrNo: Code[20]; SalesInvHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    begin
        if not PreviewMode then begin
            DocLinkToBCDoc.SetRange("BC Document Type", ShpfyBCDocumentTypeConvert.Convert(SalesHeader."Document Type"));
            DocLinkToBCDoc.SetRange("BC Document No.", SalesHeader."No.");
            DocLinkToBCDoc.SetCurrentKey("BC Document Type", "BC Document No.");
            if DocLinkToBCDoc.FindFirst() then begin
                CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", "Shpfy BC Document Type"::"Posted Sales Shipment", SalesShptHdrNo);
                CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", "Shpfy BC Document Type"::"Posted Sales Invoice", SalesInvHdrNo);
                CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", "Shpfy BC Document Type"::"Posted Return Receipt", RetRcpHdrNo);
                CreateNewDocumentLink(DocLinkToBCDoc."Shopify Document Type", DocLinkToBCDoc."Shopify Document Id", "Shpfy BC Document Type"::"Posted Sales Credit Note", SalesCrMemoHdrNo);
            end;

        end;
    end;

    local procedure CreateNewDocumentLink(DocumentType: Enum "Shpfy Document Type"; DocumentId: BigInteger; BCDocumentType: Enum "Shpfy BC Document Type"; DocumentNo: code[20])
    var
        NewDocLinkToBCDoc: Record "Shpfy Doc. Link To BC Doc.";
    begin
        if (DocumentType <> "Shpfy document Type"::" ") and (DocumentId > 0) and (BCDocumentType <> "Shpfy BC Document Type"::" ") and (DocumentNo <> '') then begin
            NewDocLinkToBCDoc.Init();
            NewDocLinkToBCDoc."Shopify Document Type" := DocumentType;
            NewDocLinkToBCDoc."Shopify Document Id" := DocumentId;
            NewDocLinkToBCDoc."BC Document Type" := BCDocumentType;
            NewDocLinkToBCDoc."BC Document No." := DocumentNo;
            NewDocLinkToBCDoc.Insert();
        end;
    end;
}

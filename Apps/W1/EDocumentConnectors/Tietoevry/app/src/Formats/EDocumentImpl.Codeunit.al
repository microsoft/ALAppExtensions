// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using Microsoft.eServices.EDocument;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Service.History;
using Microsoft.Sales.Peppol;
using System.IO;
using Microsoft.eServices.EDocument.Service.Participant;
using Microsoft.Purchases.Document;

codeunit 6391 "Tietoevry E-Document" implements "E-Document"
{
    procedure Check(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service"; EDocumentProcessingPhase: enum Microsoft.eServices.EDocument."E-Document Processing Phase")
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        PEPPOLValidation: Codeunit "PEPPOL Validation";
        PEPPOLServiceValidation: Codeunit "PEPPOL Service Validation";
    begin
        case SourceDocumentHeader.Number of
            Database::"Sales Header":
                begin
                    SourceDocumentHeader.SetTable(SalesHeader);
                    PEPPOLValidation.Run(SalesHeader);
                end;
            Database::"Sales Invoice Header":
                begin
                    SourceDocumentHeader.SetTable(SalesInvoiceHeader);
                    PEPPOLValidation.CheckSalesInvoice(SalesInvoiceHeader);
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SourceDocumentHeader.SetTable(SalesCrMemoHeader);
                    PEPPOLValidation.CheckSalesCreditMemo(SalesCrMemoHeader);
                end;
            Database::"Service Invoice Header":
                begin
                    SourceDocumentHeader.SetTable(ServiceInvoiceHeader);
                    PEPPOLServiceValidation.CheckServiceInvoice(ServiceInvoiceHeader);
                end;
            Database::"Service Cr.Memo Header":
                begin
                    SourceDocumentHeader.SetTable(ServiceCrMemoHeader);
                    PEPPOLServiceValidation.CheckServiceCreditMemo(ServiceCrMemoHeader);
                end;
        end;
    end;

    procedure Create(EDocumentService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: codeunit System.Utilities."Temp Blob")
    var
        ServiceParticipant: Record "Service Participant";
        TempXMLBuffer: Record "XML Buffer" temporary;
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        DocOutStream: OutStream;
        DocInStream: InStream;
        MessageDocumentId: Text;
    begin
        TempBlob.CreateOutStream(DocOutStream);
        case EDocument."Document Type" of
            EDocument."Document Type"::"Sales Invoice", EDocument."Document Type"::"Service Invoice":
                this.GenerateInvoiceXMLFile(SourceDocumentHeader, DocOutStream);
            EDocument."Document Type"::"Sales Credit Memo", EDocument."Document Type"::"Service Credit Memo":
                this.GenerateCrMemoXMLFile(SourceDocumentHeader, DocOutStream);
            else
                EDocErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(this.DocumentTypeNotSupportedErr, EDocument.FieldCaption("Document Type"), EDocument."Document Type"));
        end;

        EDocument.Find();
        ServiceParticipant.Get(EDocumentService.Code, ServiceParticipant."Participant Type"::Customer, EDocument."Bill-to/Pay-to No.");
        EDocument."Bill-to/Pay-to Id" := ServiceParticipant."Participant Identifier";

        TempBlob.CreateInStream(DocInStream);
        TempXMLBuffer.LoadFromStream(DocInStream);
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Name, 'ProfileID');
        if TempXMLBuffer.FindFirst() then
            EDocument."Message Profile Id" := TempXMLBuffer.Value;

        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Attribute);
        TempXMLBuffer.SetRange(Name, 'xmlns');
        if TempXMLBuffer.FindFirst() then
            MessageDocumentId := TempXMLBuffer.Value;

        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Name);
        if TempXMLBuffer.FindFirst() then
            MessageDocumentId += '::' + TempXMLBuffer.Name;

        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Name, 'CustomizationID');
        if TempXMLBuffer.FindFirst() then
            MessageDocumentId += '##' + TempXMLBuffer.Value + '::2.1';

        EDocument."Message Document Id" := MessageDocumentId;
        EDocument.Modify();
    end;

    procedure CreateBatch(EDocumentService: Record "E-Document Service"; var EDocuments: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: codeunit System.Utilities."Temp Blob")
    begin

    end;

    procedure GetBasicInfoFromReceivedDocument(var EDocument: Record "E-Document"; var TempBlob: codeunit System.Utilities."Temp Blob")
    begin
        this.ImportTEPeppol.ParseBasicInfo(EDocument, TempBlob);
    end;

    procedure GetCompleteInfoFromReceivedDocument(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: codeunit System.Utilities."Temp Blob")
    var
        TempPurchaseHeader: Record "Purchase Header" temporary;
        TempPurchaseLine: Record "Purchase Line" temporary;
    begin
        this.ImportTEPeppol.ParseCompleteInfo(EDocument, TempPurchaseHeader, TempPurchaseLine, TempBlob);

        CreatedDocumentHeader.GetTable(TempPurchaseHeader);
        CreatedDocumentLines.GetTable(TempPurchaseLine);
    end;

    local procedure GenerateInvoiceXMLFile(VariantRec: Variant; var OutStr: OutStream)
    var
        SalesInvoicePEPPOLBIS30: XMLport "Sales Invoice - PEPPOL BIS 3.0";
    begin
        SalesInvoicePEPPOLBIS30.Initialize(VariantRec);
        SalesInvoicePEPPOLBIS30.SetDestination(OutStr);
        SalesInvoicePEPPOLBIS30.Export();
    end;

    local procedure GenerateCrMemoXMLFile(VariantRec: Variant; var OutStr: OutStream)
    var
        SalesCrMemoPEPPOLBIS30: XMLport "Sales Cr.Memo - PEPPOL BIS 3.0";
    begin
        SalesCrMemoPEPPOLBIS30.Initialize(VariantRec);
        SalesCrMemoPEPPOLBIS30.SetDestination(OutStr);
        SalesCrMemoPEPPOLBIS30.Export();
    end;

    var
        ImportTEPeppol: Codeunit "Tietoevry E-Document Import";
        DocumentTypeNotSupportedErr: Label '%1 %2 is not supported by PEPPOL BIS30 Format', Comment = '%1 - Document Type caption, %2 - Document Type';
}

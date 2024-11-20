namespace Microsoft.eServices.EDocument.IO.Peppol;

using Microsoft.eServices.EDocument;
using System.Utilities;
using Microsoft.Sales.Peppol;
using Microsoft.Purchases.Document;
using Microsoft.Service.History;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using System.IO;
using Microsoft.eServices.EDocument.Service.Participant;

codeunit 6385 "EDoc TE PEPPOL BIS 3.0" implements "E-Document"
{
    procedure Check(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service"; EDocumentProcessingPhase: Enum "E-Document Processing Phase")
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

    procedure Create(EDocumentService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
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
                GenerateInvoiceXMLFile(SourceDocumentHeader, DocOutStream);
            EDocument."Document Type"::"Sales Credit Memo", EDocument."Document Type"::"Service Credit Memo":
                GenerateCrMemoXMLFile(SourceDocumentHeader, DocOutStream);
            else
                EDocErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(DocumentTypeNotSupportedErr, EDocument.FieldCaption("Document Type"), EDocument."Document Type"));
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

    procedure CreateBatch(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: codeunit "Temp Blob");
    begin

    end;

    procedure GetBasicInfoFromReceivedDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    begin
        ImportTEPeppol.ParseBasicInfo(EDocument, TempBlob);
    end;

    procedure GetCompleteInfoFromReceivedDocument(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        TempPurchaseHeader: Record "Purchase Header" temporary;
        TempPurchaseLine: Record "Purchase Line" temporary;
    begin
        ImportTEPeppol.ParseCompleteInfo(EDocument, TempPurchaseHeader, TempPurchaseLine, TempBlob);

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
        ImportTEPeppol: Codeunit "EDoc Import Tietoevry";
        DocumentTypeNotSupportedErr: Label '%1 %2 is not supported by PEPPOL BIS30 Format', Comment = '%1 - Document Type caption, %2 - Document Type';
}
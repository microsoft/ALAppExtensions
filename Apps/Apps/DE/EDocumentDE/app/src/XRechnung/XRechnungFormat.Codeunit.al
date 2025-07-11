// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using System.Utilities;
using Microsoft.Sales.History;
using Microsoft.Purchases.Document;
using System.IO;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.Company;
using Microsoft.eServices.EDocument;

codeunit 13914 "XRechnung Format" implements "E-Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EDocImportXRechnung: Codeunit "Import XRechnung Document";

    procedure Check(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service"; EDocumentProcessingPhase: Enum "E-Document Processing Phase")
    begin
        CheckCompanyInfoMandatory();
        CheckBuyerReferenceMandatory(EDocumentService, SourceDocumentHeader);
    end;

    procedure Create(EDocumentService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    begin
        CreateSourceDocumentBlob(SourceDocumentHeader, TempBlob, EDocumentService);
    end;

    procedure CreateBatch(EDocumentService: Record "E-Document Service"; var EDocuments: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    begin
    end;

    procedure GetBasicInfoFromReceivedDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    begin
        EDocImportXRechnung.ParseBasicInfo(EDocument, TempBlob);
    end;

    procedure GetCompleteInfoFromReceivedDocument(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        TempPurchaseHeader: Record "Purchase Header" temporary;
        TempPurchaseLine: Record "Purchase Line" temporary;
    begin
        EDocImportXRechnung.ParseCompleteInfo(EDocument, TempPurchaseHeader, TempPurchaseLine, TempBlob);

        CreatedDocumentHeader.GetTable(TempPurchaseHeader);
        CreatedDocumentLines.GetTable(TempPurchaseLine);
    end;

    local procedure CreateSourceDocumentBlob(DocumentRecordRef: RecordRef; var TempBlob: Codeunit "Temp Blob"; EDocumentService: Record "E-Document Service")
    var
        TempRecordExportBuffer: Record "Record Export Buffer" temporary;
        ExportXRechnungDocument: Codeunit "Export XRechnung Document";
    begin
        TempRecordExportBuffer.RecordID := DocumentRecordRef.RecordId;
        TempRecordExportBuffer."Electronic Document Format" := Format(EDocumentService."Document Format");
        TempRecordExportBuffer.Insert();

        ExportXRechnungDocument.Run(TempRecordExportBuffer);
        if not TempRecordExportBuffer."File Content".HasValue() then
            exit;
        TempBlob.FromRecord(TempRecordExportBuffer, TempRecordExportBuffer.FieldNo("File Content"));
    end;

    local procedure CheckCompanyInfoMandatory()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.TestField("E-Mail");
    end;

    local procedure CheckBuyerReferenceMandatory(EDocumentService: Record "E-Document Service"; SourceDocumentHeader: RecordRef)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        CustomerNoFieldRef: FieldRef;
        YourReferenceFieldRef: FieldRef;
    begin
        if EDocumentService."Document Format" <> EDocumentService."Document Format"::XRechnung then
            exit;

        if not EDocumentService."Buyer Reference Mandatory" then
            exit;

        case EDocumentService."Buyer Reference" of
            EDocumentService."Buyer Reference"::"Customer Reference":
                begin
                    CustomerNoFieldRef := SourceDocumentHeader.Field(SalesInvoiceHeader.FieldNo("Sell-to Customer No."));
                    Customer.Get(Format(CustomerNoFieldRef.Value));
                    Customer.TestField("E-Invoice Routing No.");
                end;
            EDocumentService."Buyer Reference"::"Your Reference":
                begin
                    YourReferenceFieldRef := SourceDocumentHeader.Field(SalesInvoiceHeader.FieldNo("Your Reference"));
                    YourReferenceFieldRef.TestField();
                end;
            else
                OnBuyerReferenceOnElseCase(SourceDocumentHeader, EDocumentService);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"E-Document Service", 'OnAfterValidateEvent', 'Document Format', false, false)]
    local procedure OnAfterValidateDocumentFormat(var Rec: Record "E-Document Service"; var xRec: Record "E-Document Service"; CurrFieldNo: Integer)
    var
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
    begin
        if Rec."Document Format" <> Rec."Document Format"::XRechnung then
            exit;

        EDocServiceSupportedType.SetRange("E-Document Service Code", Rec.Code);
        if not EDocServiceSupportedType.IsEmpty() then
            exit;

        EDocServiceSupportedType.Init();
        EDocServiceSupportedType."E-Document Service Code" := Rec.Code;
        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Invoice";
        EDocServiceSupportedType.Insert();

        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Credit Memo";
        EDocServiceSupportedType.Insert();

        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Purchase Invoice";
        EDocServiceSupportedType.Insert();

        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Purchase Credit Memo";
        EDocServiceSupportedType.Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBuyerReferenceOnElseCase(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service")
    begin
    end;
}
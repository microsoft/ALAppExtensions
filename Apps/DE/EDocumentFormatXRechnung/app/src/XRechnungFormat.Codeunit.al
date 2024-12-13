// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using System.Utilities;
using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument;

codeunit 13914 "XRechnung Format" implements "E-Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EDocImportXRechnung: Codeunit "Import XRechnung Document";

    procedure Check(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service"; EDocumentProcessingPhase: Enum "E-Document Processing Phase")
    begin
    end;

    procedure Create(EDocumentService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    begin
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
}
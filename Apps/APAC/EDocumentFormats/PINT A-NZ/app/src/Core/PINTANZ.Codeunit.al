// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Format;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.IO.Peppol;
using System.Utilities;

codeunit 28005 "PINT A-NZ" implements "E-Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        PINTANZExport: Codeunit "PINT A-NZ Export";
        EDocPeppolBIS30: Codeunit "EDoc PEPPOL BIS 3.0";

    procedure Check(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service"; EDocumentProcessingPhase: Enum "E-Document Processing Phase")
    begin
        EDocPeppolBIS30.Check(SourceDocumentHeader, EDocumentService, EDocumentProcessingPhase);
        PINTANZExport.PINTANZValidation(SourceDocumentHeader, EDocumentService, EDocumentProcessingPhase);
    end;

    procedure Create(EDocumentService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        TempBlobBase: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        EDocPeppolBIS30.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlobBase);
        PINTANZExport.AddPINTANZSpecific(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlobBase);

        TempBlob.CreateOutStream(OutStream);
        TempBlobBase.CreateInStream(InStream);
        CopyStream(OutStream, InStream);
    end;

    procedure CreateBatch(EDocumentService: Record "E-Document Service"; var EDocuments: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    begin
        EDocPeppolBIS30.CreateBatch(EDocumentService, EDocuments, SourceDocumentHeaders, SourceDocumentsLines, TempBlob);
    end;

    procedure GetBasicInfoFromReceivedDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    var
        PINTANZImport: Codeunit "PINT A-NZ Import";
    begin
        PINTANZImport.ParseBasicInfo(EDocument, TempBlob);
    end;

    procedure GetCompleteInfoFromReceivedDocument(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    begin
        EDocPeppolBIS30.GetCompleteInfoFromReceivedDocument(EDocument, CreatedDocumentHeader, CreatedDocumentLines, TempBlob);
    end;

    [EventSubscriber(ObjectType::Table, Database::"E-Document Service", 'OnAfterValidateEvent', 'Document Format', false, false)]
    local procedure OnAfterValidateDocumentFormat(var Rec: Record "E-Document Service"; var xRec: Record "E-Document Service"; CurrFieldNo: Integer)
    var
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
    begin
        if Rec."Document Format" = Rec."Document Format"::"PINT A-NZ" then begin
            EDocServiceSupportedType.SetRange("E-Document Service Code", Rec.Code);
            if EDocServiceSupportedType.IsEmpty() then begin
                EDocServiceSupportedType.Init();
                EDocServiceSupportedType."E-Document Service Code" := Rec.Code;
                EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Invoice";
                EDocServiceSupportedType.Insert();

                EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Credit Memo";
                EDocServiceSupportedType.Insert();

                EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Service Invoice";
                EDocServiceSupportedType.Insert();

                EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Service Credit Memo";
                EDocServiceSupportedType.Insert();
            end;
        end;
    end;
}
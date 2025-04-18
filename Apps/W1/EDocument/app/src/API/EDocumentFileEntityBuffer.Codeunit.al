// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using System.Utilities;
using Microsoft.eServices.EDocument;

codeunit 6123 "E-Document File Entity Buffer"
{
    procedure CreateEDocumentFromReceivedFile(var EDocumentsFileBuffer: Record "E-Document File Entity Buffer")
    var
        EDocument: Record "E-Document";
    begin
        if not IsNullGuid(EDocumentsFileBuffer."Related E-Document Id") then
            if EDocument.GetBySystemId(EDocumentsFileBuffer."Related E-Document Id") then;

        this.UploadDocument(EDocument, EDocumentsFileBuffer);
    end;

    internal procedure UploadDocument(var EDocument: Record "E-Document"; var EDocumentsFileBuffer: Record "E-Document File Entity Buffer")
    var
        EDocumentService: Record "E-Document Service";
        EDocLog: Record "E-Document Log";
        TempBlob: Codeunit "Temp Blob";
        EDocImport: Codeunit "E-Doc. Import";
        OutStr: OutStream;
        InStr: InStream;
        FileName: Text;
        EDocumentServiceStatus: Enum "E-Document Service Status";
        BlobType: Enum "E-Doc. Data Storage Blob Type";
    begin
        if not this.GetEDocumentService(EDocumentService, EDocumentsFileBuffer) then
            exit;

        if not this.GetFileContent(EDocumentsFileBuffer, TempBlob, FileName) then
            exit;

        BlobType := EDocImport.GetFileType(FileName);
        if BlobType = Enum::"E-Doc. Data Storage Blob Type"::Unspecified then
            Error(this.FileTypeNotSupportedErr);

        EDocument.Direction := EDocument.Direction::Incoming;
        EDocument."Document Type" := Enum::"E-Document Type"::None;
        EDocument.Service := EDocumentService.Code;
        EDocumentServiceStatus := "E-Document Service Status"::Imported;

        OutStr := TempBlob.CreateOutStream();
        CopyStream(OutStr, InStr);

        EDocument."File Name" := CopyStr(FileName, 1, 256);
        EDocument."File Type" := BlobType;

        if EDocument."Entry No" = 0 then begin
            EDocument.Insert(true);
            this.EDocumentProcessing.InsertServiceStatus(EDocument, EDocumentService, EDocumentServiceStatus);
        end else begin
            EDocument.Modify(true);
            this.EDocumentProcessing.ModifyServiceStatus(EDocument, EDocumentService, EDocumentServiceStatus);
        end;

        EDocLog := this.EDocumentLog.InsertLog(EDocument, EDocumentService, TempBlob, EDocumentServiceStatus);
        EDocument."Unstructured Data Entry No." := EDocLog."E-Doc. Data Storage Entry No.";
        EDocument.Modify();
    end;

    local procedure GetEDocumentService(var EDocumentService: Record "E-Document Service"; var EDocumentsFileBuffer: Record "E-Document File Entity Buffer"): Boolean
    begin
        if not IsNullGuid(EDocumentsFileBuffer."Service Id") then
            if EDocumentService.GetBySystemId(EDocumentsFileBuffer."Service Id") then
                exit(true);
    end;

    local procedure GetFileContent(var EDocumentsFileBuffer: Record "E-Document File Entity Buffer"; var TempBlob: Codeunit "Temp Blob"; var FileName: Text): Boolean
    var
        InStr: InStream;
        OutStr: OutStream;
    begin
        if EDocumentsFileBuffer.Content.HasValue() then begin
            EDocumentsFileBuffer.CalcFields(Content);
            EDocumentsFileBuffer.Content.CreateInStream(InStr);
            TempBlob.CreateOutStream(OutStr);
            CopyStream(OutStr, InStr);
            FileName := EDocumentsFileBuffer."File Name";
            exit(true);
        end;
    end;

    var
        EDocumentLog: Codeunit "E-Document Log";
        EDocumentProcessing: Codeunit "E-Document Processing";
        FileTypeNotSupportedErr: Label 'File type not supported';

}

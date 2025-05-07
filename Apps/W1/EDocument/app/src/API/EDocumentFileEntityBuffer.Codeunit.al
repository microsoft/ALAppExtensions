// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using System.Utilities;
using Microsoft.eServices.EDocument;

codeunit 6123 "E-Document File Entity Buffer"
{
    var
        EDocumentLog: Codeunit "E-Document Log";
        EDocumentProcessing: Codeunit "E-Document Processing";
        FileTypeNotSupportedErr: Label 'File type not supported';

    /// <summary>
    /// Create an E-Document from a file received via API.
    /// </summary>
    /// <param name="EDocumentsFileBuffer"></param>
    procedure CreateEDocumentFromReceivedFile(var EDocumentsFileBuffer: Record "E-Document File Entity Buffer")
    var
        EDocument: Record "E-Document";
    begin
        if not IsNullGuid(EDocumentsFileBuffer."Related E-Document Id") then
            if EDocument.GetBySystemId(EDocumentsFileBuffer."Related E-Document Id") then;

        this.UploadDocument(EDocument, EDocumentsFileBuffer);
    end;

    local procedure UploadDocument(var EDocument: Record "E-Document"; var EDocumentsFileBuffer: Record "E-Document File Entity Buffer")
    var
        EDocumentService: Record "E-Document Service";
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

        this.LogUploadedEDocument(EDocument, EDocumentService, TempBlob, EDocumentServiceStatus);
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
    begin
        if not EDocumentsFileBuffer.Content.HasValue() then
            exit(false);

        EDocumentsFileBuffer.CalcFields(Content);
        EDocumentsFileBuffer.Content.CreateInStream(InStr);
        CopyStream(TempBlob.CreateOutStream(), InStr);
        FileName := EDocumentsFileBuffer."File Name";
        exit(true);
    end;

    local procedure LogUploadedEDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; var EDocumentServiceStatus: Enum "E-Document Service Status")
    var
        EDocLog: Record "E-Document Log";
    begin
        EDocLog := this.EDocumentLog.InsertLog(EDocument, EDocumentService, TempBlob, EDocumentServiceStatus);
        EDocument."Unstructured Data Entry No." := EDocLog."E-Doc. Data Storage Entry No.";
        EDocument.Modify(false);
    end;
}

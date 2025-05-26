// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;
using System.Utilities;
using System.Text;

codeunit 6129 "E-Documents API Helper"
{

    var
        EDocumentLog: Codeunit "E-Document Log";
        EDocumentProcessing: Codeunit "E-Document Processing";
        FileTypeNotSupportedErr: Label 'File type not supported';

    internal procedure LoadEDocumentFile(EntryNo: Integer; var Base64EDocument: Text; var ByteSize: Integer)
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        EDocumentServiceStatus: Enum "E-Document Service Status";
    begin
        Base64EDocument := '';
        ByteSize := 0;
        if EntryNo <> 0 then begin
            if not EDocument.Get(EntryNo) then
                exit;

            EDocumentService := EDocumentLog.GetLastServiceFromLog(EDocument);

            case EDocument.Direction of
                Enum::"E-Document Direction"::Incoming:
                    EDocumentServiceStatus := EDocumentServiceStatus::Imported;
                Enum::"E-Document Direction"::Outgoing:
                    EDocumentServiceStatus := EDocumentServiceStatus::Exported;

            end;
            EDocumentLog.GetDocumentBlobFromLog(EDocument, EDocumentService, TempBlob, EDocumentServiceStatus);

            if TempBlob.HasValue() then begin
                Base64EDocument := Base64Convert.ToBase64(TempBlob.CreateInStream());
                ByteSize := TempBlob.Length();
            end;
        end;
    end;

    internal procedure CreateEDocumentFromReceivedFile(FileBase64Text: Text; EDocumentServiceCode: Code[20]; FileName: Text)
    var
        EDocumentService: Record "E-Document Service";
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentServiceStatus: Enum "E-Document Service Status";
        BlobType: Enum "E-Doc. Data Storage Blob Type";
        Success: Boolean;
    begin
        if not EDocumentService.Get(EDocumentServiceCode) then
            exit;

        if not GetFileContent(FileBase64Text, TempBlob) then
            exit;

        BlobType := EDocImport.GetFileType(FileName);
        if BlobType = Enum::"E-Doc. Data Storage Blob Type"::Unspecified then
            Error(this.FileTypeNotSupportedErr);

        EDocument.Direction := EDocument.Direction::Incoming;
        EDocument."Document Type" := Enum::"E-Document Type"::None;
        EDocument.Service := EDocumentService.Code;
        EDocumentServiceStatus := "E-Document Service Status"::Imported;


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

        Success := EDocImport.ProcessAutomaticallyIncomingEDocument(EDocument);

        if not Success then
            Error('Error processing the incoming E-Document. Please check the log for more details.');
    end;

    local procedure GetFileContent(FileBase64Text: Text; var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        if FileBase64Text = '' then
            exit(false);

        Base64Convert.FromBase64(FileBase64Text, TempBlob.CreateOutStream());
        if TempBlob.HasValue() then
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

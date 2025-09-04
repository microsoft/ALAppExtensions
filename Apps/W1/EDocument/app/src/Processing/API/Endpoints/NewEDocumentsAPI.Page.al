// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;
using System.Utilities;
using System.Text;

/// <summary>
/// Creates a new E-Document.
/// This API allows you to create a new E-Document by providing the necessary details such as service code, file content, file name, and file type.
/// </summary>
page 6115 "New E-Documents API"
{
    PageType = API;

    APIGroup = 'edocument';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';

    InherentEntitlements = X;
    InherentPermissions = X;

    EntityCaption = 'E-Document';
    EntitySetCaption = 'E-Documents';
    EntityName = 'createEDocument';
    EntitySetName = 'createEDocuments';

    ODataKeyFields = SystemId;
    SourceTable = "E-Document";
    SourceTableTemporary = true;

    Extensible = false;
    Editable = true;
    DeleteAllowed = false;
    DelayedInsert = true;
    InsertAllowed = true;

    Permissions =
        tabledata "E-Document Service" = r;

    layout
    {
        area(content)
        {
            group(Group)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'System ID';
                    Editable = false;
                }
                field(edocumentEntryNumber; Rec."Entry No")
                {
                }
                field(edocumentService; EDocumentServiceText)
                {
                    Caption = 'E-Document Service Code';
                    ToolTip = 'Code of the E-Document Service.';
                }
                field(base64FileContent; FileContent)
                {
                    Caption = 'File Content';
                    ToolTip = 'Base64 encoded file content of the E-Document.';
                }
                field(fileName; Rec."File Name")
                {
                }
                field(fileType; Format(FileType))
                {
                    Caption = 'File Type';
                    ToolTip = 'Type of the file being uploaded for the E-Document.';
                }
                field(processDocument; ProcessDocument)
                {
                    Caption = 'Process Document';
                    ToolTip = 'Indicates whether the E-Document should be processed automatically as part of request.';
                }
            }
        }
    }

    var

        FileType: Enum "E-Doc. File Format";
        FileContent: Text;
        ProcessDocument: Boolean;
        EDocumentServiceText: Text[20];
        ReceivingNotSupportedErr: Label 'This API does not support the receiving data.';
        ContentOrFileEmptyErr: Label 'File content, E-Document Service or File Type cannot be empty.';
        EDocumentServiceNotFoundErr: Label 'E-Document Service %1 not found in environment.', Comment = '%1 - E-Document Service Code';


    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentImport: Codeunit "E-Doc. Import";
        TempBlob: Codeunit "Temp Blob";
        Instream: InStream;
    begin
        if not IsFieldsValid() then
            Error(ContentOrFileEmptyErr);

        if not EDocumentService.Get(EDocumentServiceText) then
            Error(EDocumentServiceNotFoundErr, EDocumentService);

        GetFileContent(FileContent, TempBlob);
        TempBlob.CreateInStream(Instream, TextEncoding::UTF8);
        EDocumentImport.CreateFromType(EDocument, EDocumentService, FileType, Rec."File Name", Instream);
        if ProcessDocument then begin
            if EDocumentImport.ProcessAutomaticallyIncomingEDocument(EDocument) then;
            Rec := EDocument;
        end;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        Error(ReceivingNotSupportedErr);
    end;

    local procedure IsFieldsValid(): Boolean
    begin
        if (FileContent = '') or
            (EDocumentServiceText = '') or
            (FileType = Enum::"E-Doc. File Format"::Unspecified) then
            exit(false);
        exit(true);
    end;

    local procedure GetFileContent(FileBase64Text: Text; var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        if FileBase64Text = '' then
            exit(false);

        Base64Convert.FromBase64(FileBase64Text, TempBlob.CreateOutStream(TextEncoding::UTF8));
        if TempBlob.HasValue() then
            exit(true);
    end;

}
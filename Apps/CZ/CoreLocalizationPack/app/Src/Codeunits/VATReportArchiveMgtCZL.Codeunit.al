// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;
using Microsoft.Foundation.Attachment;

codeunit 31173 "VAT Report Archive Mgt CZL"
{
    Permissions = TableData "VAT Report Archive" = d;

    var
        XmlFileExtensionTok: Label 'xml', Locked = true;

    procedure ArchiveSubmissionMessage(var TempBlobSubmission: Codeunit "Temp Blob"; VATReportHeader: Record "VAT Report Header")
    var
        VATReportArchive: Record "VAT Report Archive";
    begin
        if VATReportArchive.Get(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.") then
            VATReportArchive.Delete(true);
        VATReportArchive.ArchiveSubmissionMessage(
            VATReportHeader."VAT Report Config. Code".AsInteger(), VATReportHeader."No.", TempBlobSubmission);
    end;

    procedure ArchiveResponseMessage(var TempBlobResponse: Codeunit "Temp Blob"; VATReportHeader: Record "VAT Report Header")
    var
        VATReportArchive: Record "VAT Report Archive";
    begin
        VATReportArchive.ArchiveResponseMessage(
            VATReportHeader."VAT Report Config. Code".AsInteger(), VATReportHeader."No.", TempBlobResponse);
    end;

    procedure RemoveVATReportSubmissionFromDocAttachment(VATReportHeader: Record "VAT Report Header")
    begin
        RemoveVATReportDocumentFromDocAttachment(VATReportHeader, "Attachment Document Type"::"VAT Return Submission");
    end;

    procedure RemoveVATReportResponseFromDocAttachment(VATReportHeader: Record "VAT Report Header")
    begin
        RemoveVATReportDocumentFromDocAttachment(VATReportHeader, "Attachment Document Type"::"VAT Return Response");
    end;

    local procedure RemoveVATReportDocumentFromDocAttachment(VATReportHeader: Record "VAT Report Header"; AttachmentDocumentType: Enum "Attachment Document Type")
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        DocumentAttachment.SetRange("Table ID", Database::"VAT Report Header");
        DocumentAttachment.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        DocumentAttachment.SetRange("No.", VATReportHeader."No.");
        DocumentAttachment.SetRange("Document Type", AttachmentDocumentType);
        DocumentAttachment.DeleteAll(true);
    end;

    procedure InsertVATReportSubmissionToDocAttachment(VATReportHeader: Record "VAT Report Header"; var TempBlob: Codeunit "Temp Blob")
    begin
        InsertVATReportDocumentToDocAttachment(
            VATReportHeader, TempBlob, GenerateFileName(VATReportHeader, true),
            "Attachment Document Type"::"VAT Return Submission");
    end;

    procedure InsertVATReportResponseToDocAttachment(VATReportHeader: Record "VAT Report Header"; var TempBlob: Codeunit "Temp Blob")
    begin
        InsertVATReportDocumentToDocAttachment(
            VATReportHeader, TempBlob, GenerateFileName(VATReportHeader, false),
            "Attachment Document Type"::"VAT Return Response");
    end;

    local procedure InsertVATReportDocumentToDocAttachment(VATReportHeader: Record "VAT Report Header"; var TempBlob: Codeunit "Temp Blob"; FileName: Text; AttachmentDocumentType: Enum "Attachment Document Type")
    var
        DocumentAttachment: Record "Document Attachment";
        ID: Integer;
        FileInStream: InStream;
    begin
        DocumentAttachment.SetRange("Table ID", Database::"VAT Report Header");
        DocumentAttachment.SetRange("No.", VATReportHeader."No.");
        DocumentAttachment.SetRange("Document Type", AttachmentDocumentType);
        if DocumentAttachment.FindLast() then
            ID := DocumentAttachment.ID;
        ID += 10000;
        DocumentAttachment.Validate("Table ID", Database::"VAT Report Header");
        DocumentAttachment.Validate("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        DocumentAttachment.Validate("No.", VATReportHeader."No.");
        DocumentAttachment.Validate(ID, ID);
        DocumentAttachment.Validate("File Name", CopyStr(FileName, 1, MaxStrLen(DocumentAttachment."File Name")));
        DocumentAttachment.Validate("File Extension", XmlFileExtensionTok);
        DocumentAttachment.Validate("File Type", "Document Attachment File Type"::XML);
        DocumentAttachment.Validate("Document Type", AttachmentDocumentType);
        TempBlob.CreateInStream(FileInStream, TextEncoding::UTF8);
        DocumentAttachment."Document Reference ID".ImportStream(FileInStream, '');
        DocumentAttachment.Insert(true);
    end;

    local procedure GenerateFileName(VATReportHeader: Record "VAT Report Header"; Submission: Boolean): Text
    begin
        if Submission then
            exit('VAT Report-' + VATReportHeader."No.")
        else
            exit('VAT Report-' + VATReportHeader."No." + '-Response');
    end;
}
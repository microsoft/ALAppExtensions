namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Attachment;
using System.Utilities;

codeunit 13604 "Elec. VAT Decl. Archiving"
{
    Access = Internal;
    Permissions = TableData "VAT Report Archive" = d;

    procedure ArchiveSubmissionMessageBlob(var SubmissionTempBlob: Codeunit "Temp Blob"; VATReportHeader: Record "VAT Report Header")
    var
        VATReportArchive: Record "VAT Report Archive";
    begin
        if VATReportArchive.Get(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.") then
            VATReportArchive.Delete(true);
        VATReportArchive.ArchiveSubmissionMessage(VATReportHeader."VAT Report Config. Code".AsInteger(), VATReportHeader."No.", SubmissionTempBlob);
        RemoveSubmissionDocAttachments(VATReportHeader);
        AttachXmlSubmissionToVATRepHeader(SubmissionTempBlob, VATReportHeader, GenerateFileName(VATReportHeader, true));
    end;

    procedure ArchiveResponseMessageText(ResponseText: Text; VATReportHeader: Record "VAT Report Header")
    var
        VATReportArchive: Record "VAT Report Archive";
        ResponseTempBlob: Codeunit "Temp Blob";
        ResponseOutStream: OutStream;
    begin
        ResponseTempBlob.CreateOutStream(ResponseOutStream);
        ResponseOutStream.WriteText(ResponseText);
        VATReportArchive.ArchiveResponseMessage(VATReportHeader."VAT Report Config. Code".AsInteger(), VATReportHeader."No.", ResponseTempBlob);
        RemoveResponseDocAttachments(VATReportHeader);
        AttachXmlResponseToVATRepHeader(ResponseTempBlob, VATReportHeader, GenerateFileName(VATReportHeader, false));
    end;

    local procedure GenerateFileName(VATReportHeader: Record "VAT Report Header"; Submission: Boolean): Text
    begin
        if Submission then
            exit('Elec. VAT Decl.-' + VATReportHeader."No.")
        else
            exit('Elec. VAT Decl.-' + VATReportHeader."No." + '-Response');
    end;

    procedure RemoveSubmissionDocAttachments(VATReportHeader: Record "VAT Report Header")
    var
        DocType: Enum "Attachment Document Type";
    begin
        RemoveVATReportDocAttachments(VATReportHeader, DocType::"VAT Return Submission");
    end;

    procedure RemoveResponseDocAttachments(VATReportHeader: Record "VAT Report Header")
    var
        DocType: Enum "Attachment Document Type";
    begin
        RemoveVATReportDocAttachments(VATReportHeader, DocType::"VAT Return Response");
    end;

    procedure AttachXmlSubmissionToVATRepHeader(var TempBlob: Codeunit "Temp Blob"; VATReportHeader: Record "VAT Report Header"; FileName: Text)
    var
        FileType: Enum "Document Attachment File Type";
        DocType: Enum "Attachment Document Type";
    begin
        InsertDocAttachment(TempBlob, VATReportHeader, DocType::"VAT Return Submission", FileName, 'xml', FileType::XML, '');
    end;

    procedure AttachXmlResponseToVATRepHeader(var TempBlob: Codeunit "Temp Blob"; VATReportHeader: Record "VAT Report Header"; FileName: Text)
    var
        FileType: Enum "Document Attachment File Type";
        DocType: Enum "Attachment Document Type";
    begin
        InsertDocAttachment(TempBlob, VATReportHeader, DocType::"VAT Return Response", FileName, 'xml', FileType::XML, '');
    end;

    local procedure InsertDocAttachment(var TempBlob: Codeunit "Temp Blob"; VATReportHeader: Record "VAT Report Header"; DocType: Enum "Attachment Document Type"; FileName: Text; FileExtension: Text; FileType: Enum "Document Attachment File Type"; MimeType: Text)
    var
        DocumentAttachment: Record "Document Attachment";
        ID: Integer;
        FileInStream: InStream;
    begin
        DocumentAttachment.SetRange("Table ID", Database::"VAT Report Header");
        DocumentAttachment.SetRange("No.", VATReportHeader."No.");
        DocumentAttachment.SetRange("Document Type", DocType);
        if DocumentAttachment.FindLast() then
            ID := DocumentAttachment.ID;
        ID += 10000;
        DocumentAttachment.Validate("Table ID", Database::"VAT Report Header");
        DocumentAttachment.Validate("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        DocumentAttachment.Validate("No.", VATReportHeader."No.");
        DocumentAttachment.Validate(ID, ID);
        DocumentAttachment.Validate("File Name", CopyStr(FileName, 1, MaxStrLen(DocumentAttachment."File Name")));
        DocumentAttachment.Validate("File Extension", FileExtension);
        DocumentAttachment.Validate("File Type", FileType);
        DocumentAttachment.Validate("Document Type", DocType);
        TempBlob.CreateInStream(FileInStream, TextEncoding::UTF8);
        DocumentAttachment."Document Reference ID".ImportStream(FileInStream, '', MimeType);
        DocumentAttachment.Insert(true);
    end;

    local procedure RemoveVATReportDocAttachments(VATReportHeader: Record "VAT Report Header"; DocType: Enum "Attachment Document Type")
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        DocumentAttachment.SetRange("Table ID", Database::"VAT Report Header");
        DocumentAttachment.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        DocumentAttachment.SetRange("No.", VATReportHeader."No.");
        DocumentAttachment.SetRange("Document Type", DocType);
        DocumentAttachment.DeleteAll(true);
    end;
}
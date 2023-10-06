// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Attachment;
using System.Utilities;

codeunit 10688 "Elec. VAT Logging Mgt."
{
    var
        InvokeReqMsg: Label 'invoke request: %1', Locked = true;
        ValidateVATReturnTxt: Label 'validate VAT return';
        NOVATReturnSubmissionTok: Label 'NOVATReturnSubmissionTelemetryCategoryTok', Locked = true;
        InvokeReqSuccessMsg: Label 'https request successfully executed', Locked = true;
        RefreshAccessTokenMsg: Label 'refreshing access token', Locked = true;

    procedure LogValidationRun()
    begin
        Session.LogMessage(
            '0000G8O', StrSubstNo(InvokeReqMsg, ValidateVATReturnTxt), Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, 'Category', NOVATReturnSubmissionTok);
    end;

    procedure LogInvokRequestSuccess()
    begin
        Session.LogMessage(
            '0000G8P', InvokeReqSuccessMsg, Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, 'Category', NOVATReturnSubmissionTok);
    end;

    procedure LogRefreshAccessToken()
    begin
        Session.LogMessage('0000G8Q', RefreshAccessTokenMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', NOVATReturnSubmissionTok);
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

    procedure AttachXmlSubmissionTextToVATRepHeader(Request: Text; VATReportHeader: Record "VAT Report Header"; FileName: Text)
    var
        DocType: Enum "Attachment Document Type";
    begin
        AttachXmlTextToVATRepHeader(Request, VATReportHeader, DocType::"VAT Return Submission", FileName);
    end;

    procedure AttachXmlResponseTextToVATRepHeader(Request: Text; VATReportHeader: Record "VAT Report Header"; FileName: Text)
    var
        DocType: Enum "Attachment Document Type";
    begin
        AttachXmlTextToVATRepHeader(Request, VATReportHeader, DocType::"VAT Return Response", FileName);
    end;

    local procedure AttachXmlTextToVATRepHeader(Request: Text; VATReportHeader: Record "VAT Report Header"; DocType: Enum "Attachment Document Type"; FileName: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        MessageOutStream: OutStream;
        FileType: Enum "Document Attachment File Type";
    begin
        TempBlob.CreateOutStream(MessageOutStream, TEXTENCODING::UTF8);
        MessageOutStream.WriteText(Request);
        InsertDocAttachment(TempBlob, VATReportHeader, DocType, FileName, 'xml', FileType::XML, '');
    end;

    procedure AttachPDFResponseToVATRepHeader(var TempBlob: Codeunit "Temp Blob"; VATReportHeader: Record "VAT Report Header"; FileName: Text)
    var
        FileType: Enum "Document Attachment File Type";
        DocType: Enum "Attachment Document Type";
    begin
        InsertDocAttachment(TempBlob, VATReportHeader, DocType::"VAT Return Response", FileName, 'pdf', FileType::PDF, 'application/pdf');
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

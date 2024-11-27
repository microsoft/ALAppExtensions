// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;
using Microsoft.Foundation.Attachment;

codeunit 31170 "VAT Report Submit CZL"
{
    TableNo = "VAT Report Header";

    trigger OnRun()
    var
        EPOAPISubmission: Codeunit "EPO API Submission CZL";
        TempBlobSubmission: Codeunit "Temp Blob";
        TempBlobResponse: Codeunit "Temp Blob";
        VATReportArchiveMgtCZL: Codeunit "VAT Report Archive Mgt CZL";
        XmlDocumentSubmission: XmlDocument;
        OutStreamSubmission: OutStream;
    begin
        XmlDocumentSubmission := GetVATReportSubmission(Rec);
        if not EPOAPISubmission.TrySend(XmlDocumentSubmission) then
            Error(GetLastErrorText());

        // archive submission
        TempBlobSubmission.CreateOutStream(OutStreamSubmission, TextEncoding::UTF8);
        XmlDocumentSubmission.WriteTo(OutStreamSubmission);
        VATReportArchiveMgtCZL.RemoveVATReportSubmissionFromDocAttachment(Rec);
        VATReportArchiveMgtCZL.InsertVATReportSubmissionToDocAttachment(Rec, TempBlobSubmission);
        VATReportArchiveMgtCZL.ArchiveSubmissionMessage(TempBlobSubmission, Rec);

        // archive response
        TempBlobResponse := EPOAPISubmission.GetHttpResonse().GetContent().AsBlob();
        VATReportArchiveMgtCZL.RemoveVATReportResponseFromDocAttachment(Rec);
        VATReportArchiveMgtCZL.InsertVATReportResponseToDocAttachment(Rec, TempBlobResponse);
        VATReportArchiveMgtCZL.ArchiveResponseMessage(TempBlobResponse, Rec);

        Hyperlink(EPOAPISubmission.GetFormUrl());
    end;

    local procedure GetVATReportSubmission(VATReportHeader: Record "VAT Report Header"): XmlDocument
    var
        VATReportExportCZL: Codeunit "VAT Report Export CZL";
        XmlDocumentSubmission: XmlDocument;
    begin
        if not IsVATReportSubmissionExist(VATReportHeader) then
            VATReportExportCZL.Run(VATReportHeader);

        if GetVATReportSubmissionFromDocAttachment(VATReportHeader, XmlDocumentSubmission) then
            exit(XmlDocumentSubmission);
    end;

    local procedure IsVATReportSubmissionExist(VATReportHeader: Record "VAT Report Header"): Boolean
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        exit(DocumentAttachment.VATReturnSubmissionAttachmentsExist(VATReportHeader));
    end;

    local procedure GetVATReportSubmissionFromDocAttachment(VATReportHeader: Record "VAT Report Header"; var XmlDocumentSubmission: XmlDocument): Boolean
    var
        DocumentAttachment: Record "Document Attachment";
        TempBlobSubmission: Codeunit "Temp Blob";
        InStreamSubmission: InStream;
    begin
        DocumentAttachment.SetRange("Table ID", Database::"VAT Report Header");
        DocumentAttachment.SetRange("No.", VATReportHeader."No.");
        DocumentAttachment.SetRange("Document Type", "Attachment Document Type"::"VAT Return Submission");
        if not DocumentAttachment.FindFirst() then
            exit(false);

        DocumentAttachment.GetAsTempBlob(TempBlobSubmission);
        TempBlobSubmission.CreateInStream(InStreamSubmission);
        exit(XmlDocument.ReadFrom(InStreamSubmission, XmlDocumentSubmission));
    end;
}
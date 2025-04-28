// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Reporting;
using System.EMail;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using System.Utilities;
using System.IO;
using System.Reflection;

codeunit 6122 "E-Document Email"
{
    Access = Internal;

    /// <summary>
    /// Sends an e-mail with attached e-document if it exists for the specified posted sales document. 
    /// </summary>
    /// <param name="DocumentSendingProfile">Document sending profile</param>
    /// <param name="ReportUsage">Report selection usage to specify e-mail body and PDF attachment</param>
    /// <param name="RecordVariant">Document record as variant</param>
    /// <param name="DocNo">Document no.</param>
    /// <param name="DocName">Document name.</param>
    /// <param name="ToCust">Customer code.</param>
    /// <param name="ShowDialog">Indicates if dialog will be shown on e-mail sending</param>
    internal procedure SendEDocumentEmail(
        DocumentSendingProfile: Record "Document Sending Profile";
        ReportUsage: Enum "Report Selection Usage";
        RecordVariant: Variant;
        DocNo: Code[20];
        DocName: Text[150];
        ToCust: Code[20];
        ShowDialog: Boolean)
    var
        ReportSelections: Record "Report Selections";
        EDocument: Record "E-Document";
        DocumentMailing: Codeunit "Document-Mailing";
        TypeHelper: Codeunit "Type Helper";
        AttachmentsTempBlob: Codeunit "Temp Blob";
        EmailBodyTempBlob: Codeunit "Temp Blob";
        SourceReference: RecordRef;
        SourceTableIDs: List of [Integer];
        SourceIDs: List of [Guid];
        SourceRelationTypes: List of [Integer];
        SendToEmailAddress: Text[250];
        AttachmentFileName: Text[250];
        AttachmentFileExtension: Text[4];
    begin
        TypeHelper.CopyRecVariantToRecRef(RecordVariant, SourceReference);

        if not FindEDocument(DocNo, SourceReference, EDocument) then
            exit;

        CreateSourceLists(ToCust, SourceReference, SourceTableIDs, SourceIDs, SourceRelationTypes);
        ReportSelections.GetEmailBodyForCust(EmailBodyTempBlob, ReportUsage, RecordVariant, ToCust, SendToEmailAddress);

        AttachmentsTempBlob := GetAttachmentsBlob(
            DocumentSendingProfile,
            ReportUsage,
            RecordVariant,
            DocNo,
            DocName,
            ToCust,
            EDocument,
            AttachmentFileName,
            AttachmentFileExtension);

        DocumentMailing.EmailFile(
            AttachmentsTempBlob.CreateInStream(),
            AttachmentFileName + AttachmentFileExtension,
            EmailBodyTempBlob,
            DocNo,
            SendToEmailAddress,
            DocName,
            not ShowDialog,
            ReportUsage.AsInteger(),
            SourceTableIDs,
            SourceIDs,
            SourceRelationTypes
        );
    end;

    local procedure FindEDocument(DocNo: Code[20]; SourceReference: RecordRef; var EDocument: Record "E-Document"): Boolean
    begin
        case SourceReference.Number() of
            Database::"Sales Invoice Header":
                exit(GetEDocumentForSalesInvoice(DocNo, EDocument));
            Database::"Sales Cr.Memo Header":
                exit(GetEDocumentForSalesCrMemo(DocNo, EDocument));
            else
                exit(false);
        end;
    end;

    local procedure CreateSourceLists(
        ToCust: Code[20];
        var SourceReference: RecordRef;
        var SourceTableIDs: List of [Integer];
        var SourceIDs: List of [Guid];
        var SourceRelationTypes: List of [Integer])
    var
        Customer: Record Customer;
    begin
        SourceTableIDs.Add(SourceReference.Number());
        SourceIDs.Add(SourceReference.Field(SourceReference.SystemIdNo).Value());
        SourceRelationTypes.Add(Enum::"Email Relation Type"::"Primary Source".AsInteger());

        if Customer.Get(ToCust) then begin
            SourceTableIDs.Add(Database::Customer);
            SourceIDs.Add(Customer.SystemId);
            SourceRelationTypes.Add(Enum::"Email Relation Type"::"Related Entity".AsInteger());
        end;
    end;

    local procedure GetEDocumentForSalesInvoice(PostedDocNo: Code[20]; var EDocument: Record "E-Document"): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.Get(PostedDocNo);
        EDocument.SetRange("Document Record ID", SalesInvoiceHeader.RecordId());
        exit(EDocument.FindFirst());
    end;

    local procedure GetEDocumentForSalesCrMemo(PostedDocNo: Code[20]; var EDocument: Record "E-Document"): Boolean
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader.Get(PostedDocNo);
        EDocument.SetRange("Document Record ID", SalesCrMemoHeader.RecordId());
        exit(EDocument.FindFirst());
    end;

    local procedure CreateZipArchiveWithEDocAttachments(
        var DataCompression: Codeunit "Data Compression";
        var TempBlobList: Codeunit "Temp Blob List";
        AttachmentFileName: Text[250])
    var
        TempBlob: Codeunit "Temp Blob";
        FileNo: Text[3];
        i: Integer;
    begin
        DataCompression.CreateZipArchive();
        if TempBlobList.Count() = 1 then begin
            TempBlobList.Get(1, TempBlob);
            DataCompression.AddEntry(TempBlob.CreateInStream(), AttachmentFileName + XMLFileTypeTok);
        end else
            for i := 1 to TempBlobList.Count() do begin
                TempBlobList.Get(i, TempBlob);
                FileNo := StrSubstNo(FileNoTok, i);
                DataCompression.AddEntry(TempBlob.CreateInStream(), AttachmentFileName + FileNo + XMLFileTypeTok);
            end;
    end;

    local procedure GetAttachment(
        EDocument: Record "E-Document";
        TempBlobList: Codeunit "Temp Blob List";
        DocumentSendingProfile: Record "Document Sending Profile")
    var
        EDocumentService: Record "E-Document Service";
        EDocumentLog: Codeunit "E-Document Log";
        TempBlob: Codeunit "Temp Blob";
        EDocumentWorkFlowProcessing: Codeunit "E-Document WorkFlow Processing";
    begin
        EDocumentWorkFlowProcessing.DoesFlowHasEDocService(EDocumentService, DocumentSendingProfile."Electronic Service Flow");
        if EDocumentService.FindSet() then
            repeat
                Clear(TempBlob);
                EDocumentLog.GetDocumentBlobFromLog(EDocument, EDocumentService, TempBlob, Enum::"E-Document Service Status"::Exported);
                TempBlobList.Add(TempBlob);
            until EDocumentService.Next() = 0;
    end;

    local procedure CreateAttachmentName(PostedDocNo: Code[20]; EmailDocName: Text[250]): Text[250]
    begin
        exit(StrSubstNo(EDocumentAttachmentNameTok, EmailDocName, PostedDocNo));
    end;

    local procedure AddPdfAttachmentToZipArchive(
        var DataCompression: Codeunit "Data Compression";
        ReportUsage: Enum "Report Selection Usage";
        RecordVariant: Variant;
        ToCust: Code[20];
        AttachmentFileName: Text[250])
    var
        ReportSelections: Record "Report Selections";
        TempBlob: Codeunit "Temp Blob";
    begin
        ReportSelections.GetPdfReportForCust(TempBlob, ReportUsage, RecordVariant, ToCust);
        DataCompression.AddEntry(TempBlob.CreateInStream(), AttachmentFileName + PDFFileTypeTok);
    end;

    local procedure GetAttachmentsBlob(
        DocumentSendingProfile: Record "Document Sending Profile";
        ReportUsage: Enum "Report Selection Usage";
        RecordVariant: Variant;
        DocNo: Code[20];
        DocName: Text[150];
        ToCust: Code[20];
        EDocument: Record "E-Document";
        var AttachmentFileName: Text[250];
        var AttachmentFileExtension: Text[4]): Codeunit "Temp Blob"
    var
        DataCompression: Codeunit "Data Compression";
        TempBlobList: Codeunit "Temp Blob List";
        TempBlob: Codeunit "Temp Blob";
    begin
        GetAttachment(EDocument, TempBlobList, DocumentSendingProfile);
        AttachmentFileName := CreateAttachmentName(DocNo, DocName);
        if (TempBlobList.Count() = 1) and
            (DocumentSendingProfile."E-Mail Attachment" = Enum::"Document Sending Profile Attachment Type"::"E-Document")
        then begin
            TempBlobList.Get(1, TempBlob);
            AttachmentFileExtension := XMLFileTypeTok;
        end else begin
            CreateZipArchiveWithEDocAttachments(DataCompression, TempBlobList, AttachmentFileName);

            if DocumentSendingProfile."E-Mail Attachment" = Enum::"Document Sending Profile Attachment Type"::"PDF & E-Document" then
                AddPdfAttachmentToZipArchive(
                    DataCompression,
                    ReportUsage,
                    RecordVariant,
                    ToCust,
                    AttachmentFileName);

            DataCompression.SaveZipArchive(TempBlob);
            DataCompression.CloseZipArchive();
            AttachmentFileExtension := ZipFileTypeTok;
        end;
        exit(TempBlob);
    end;

    var
        EDocumentAttachmentNameTok: Label '%1 %2', Locked = true, Comment = '%1 = Attachment name, %2 = File format';
        XMLFileTypeTok: Label '.xml', Locked = true;
        PDFFileTypeTok: Label '.pdf', Locked = true;
        ZipFileTypeTok: Label '.zip', Locked = true;
        FileNoTok: Label '_%1', Locked = true;
}

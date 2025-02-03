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

codeunit 6105 "E-Document Email"
{
    Access = Internal;

    internal procedure SendEDocumentEmail(
        var DocumentSendingProfile: Record "Document Sending Profile";
        var ReportUsage: Enum "Report Selection Usage";
        var RecordVariant: Variant;
        DocNo: Code[20];
        DocName: Text[150];
        ToCust: Code[20];
        ShowDialog: Boolean)
    var
        ReportSelections: Record "Report Selections";
        DocumentMailing: Codeunit "Document-Mailing";
        TypeHelper: Codeunit "Type Helper";
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        TempBlobList: Codeunit "Temp Blob List";
        SourceReference: RecordRef;
        SourceTableIDs: List of [Integer];
        SourceIDs: List of [Guid];
        SourceRelationTypes: List of [Integer];
        ServerEmailBodyFilePath: Text[250];
        SendToEmailAddress: Text[250];
        AttachmentFileName: Text[250];
        AttachmentFileExtension: Text[4];
    begin
        case DocumentSendingProfile."E-Mail Attachment" of
            Enum::"Document Sending Profile Attachment Type"::"E-Document":
                begin
                    TypeHelper.CopyRecVariantToRecRef(RecordVariant, SourceReference);

                    if not GetAttachment(DocNo, DocName, SourceReference, AttachmentFileName, TempBlobList) then
                        exit;

                    CreateSourceLists(ToCust, SourceReference, SourceTableIDs, SourceIDs, SourceRelationTypes);

                    ReportSelections.GetEmailBodyForCust(ServerEmailBodyFilePath, ReportUsage, RecordVariant, ToCust, SendToEmailAddress);

                    if TempBlobList.Count() = 1 then begin
                        TempBlobList.Get(1, TempBlob);
                        AttachmentFileExtension := XMLFileTypeTok;
                    end else begin
                        CreateZipArchiveWithEDocAttachments(DataCompression, TempBlobList, AttachmentFileName);
                        DataCompression.SaveZipArchive(TempBlob);
                        DataCompression.CloseZipArchive();
                        AttachmentFileExtension := ZipFileTypeTok;
                    end;

                    DocumentMailing.EmailFile(
                        TempBlob.CreateInStream(),
                        AttachmentFileName + AttachmentFileExtension,
                        ServerEmailBodyFilePath,
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
            Enum::"Document Sending Profile Attachment Type"::"PDF & E-Document":
                begin
                    TypeHelper.CopyRecVariantToRecRef(RecordVariant, SourceReference);

                    if not GetAttachment(DocNo, DocName, SourceReference, AttachmentFileName, TempBlobList) then
                        exit;

                    CreateSourceLists(ToCust, SourceReference, SourceTableIDs, SourceIDs, SourceRelationTypes);

                    if TempBlobList.Count() = 1 then begin
                        TempBlobList.Get(1, TempBlob);
                        AttachmentFileExtension := XMLFileTypeTok;
                        DataCompression.CreateZipArchive();
                        DataCompression.AddEntry(TempBlob.CreateInStream(), AttachmentFileName + XMLFileTypeTok);
                    end else
                        CreateZipArchiveWithEDocAttachments(DataCompression, TempBlobList, AttachmentFileName);

                    ReportSelections.GetPdfReportForCust(TempBlob, ReportUsage, RecordVariant, ToCust);
                    DataCompression.AddEntry(TempBlob.CreateInStream(), AttachmentFileName + PDFFileTypeTok);
                    DataCompression.SaveZipArchive(TempBlob);
                    DataCompression.CloseZipArchive();

                    ReportSelections.GetEmailBodyForCust(ServerEmailBodyFilePath, ReportUsage, RecordVariant, ToCust, SendToEmailAddress);

                    DocumentMailing.EmailFile(
                        TempBlob.CreateInStream(),
                        AttachmentFileName + ZipFileTypeTok,
                        ServerEmailBodyFilePath,
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
        end;
    end;

    local procedure GetAttachment(
        DocNo: Code[20];
        DocName: Text[150];
        var SourceReference: RecordRef;
        var AttachmentFileName: Text[250];
        var TempBlobList: Codeunit "Temp Blob List"): Boolean
    var
        EDocument: Record "E-Document";
    begin
        case SourceReference.Number() of
            Database::"Sales Invoice Header":
                if GetEDocumentForSalesInvoice(DocNo, EDocument) then
                    GetBlobAttachmentFromEDocument(EDocument, DocNo, DocName, TempBlobList, AttachmentFileName)
                else
                    exit(false);
            Database::"Sales Cr.Memo Header":
                if GetEDocumentForSalesCrMemo(DocNo, EDocument) then
                    GetBlobAttachmentFromEDocument(EDocument, DocNo, DocName, TempBlobList, AttachmentFileName)
                else
                    exit(false);
            else
                exit(false);
        end;
        exit(true);
    end;

    local procedure CreateSourceLists(
        ToCust: Code[20]; var SourceReference: RecordRef;
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
        if EDocument.FindFirst() then
            exit(true);
    end;

    local procedure GetEDocumentForSalesCrMemo(PostedDocNo: Code[20]; var EDocument: Record "E-Document"): Boolean
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader.Get(PostedDocNo);
        EDocument.SetRange("Document Record ID", SalesCrMemoHeader.RecordId());
        if EDocument.FindFirst() then
            exit(true);
    end;

    local procedure GetBlobAttachmentFromEDocument(
        EDocument: Record "E-Document";
        PostedDocNo: Code[20];
        EmailDocName: Text[250];
        var TempBlobList: Codeunit "Temp Blob List";
        var EDocumentAttchmentName: Text[250])
    var
        EDocumentService: Record "E-Document Service";
        DocumentSendingProfile: Record "Document Sending Profile";
        EDocumentLog: Codeunit "E-Document Log";
        TempBlob: Codeunit "Temp Blob";
        EDocumentWorkFlowProcessing: Codeunit "E-Document WorkFlow Processing";
    begin
        DocumentSendingProfile.Get(EDocument."Document Sending Profile");
        EDocumentWorkFlowProcessing.DoesFlowHasEDocService(EDocumentService, DocumentSendingProfile."Electronic Service Flow");
        if EDocumentService.FindSet() then
            repeat
                Clear(TempBlob);
                EDocumentLog.GetDocumentBlobFromLog(EDocument, EDocumentService, TempBlob, Enum::"E-Document Service Status"::Exported);
                TempBlobList.Add(TempBlob);
            until EDocumentService.Next() = 0;
        EDocumentAttchmentName := StrSubstNo(EDocumentAttchmentNameTok, EmailDocName, PostedDocNo);
    end;

    local procedure CreateZipArchiveWithEDocAttachments(var DataCompression: Codeunit "Data Compression"; var TempBlobList: Codeunit "Temp Blob List"; AttachmentFileName: Text[250])
    var
        TempBlob: Codeunit "Temp Blob";
        FileNo: Text[3];
        i: Integer;
    begin
        DataCompression.CreateZipArchive();
        for i := 1 to TempBlobList.Count() do begin
            TempBlobList.Get(i, TempBlob);
            FileNo := StrSubstNo(FileNoTok, i);
            DataCompression.AddEntry(TempBlob.CreateInStream(), AttachmentFileName + FileNo + XMLFileTypeTok);
        end;
    end;

    var
        EDocumentAttchmentNameTok: Label '%1 %2', Locked = true;
        XMLFileTypeTok: Label '.xml', Locked = true;
        PDFFileTypeTok: Label '.pdf', Locked = true;
        ZipFileTypeTok: Label '.zip', Locked = true;
        FileNoTok: Label '_%1', Locked = true;
}

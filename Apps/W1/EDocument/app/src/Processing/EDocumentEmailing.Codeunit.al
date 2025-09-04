// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Reporting;
using System.Telemetry;
using System.EMail;
using Microsoft.Sales.Customer;
using System.Utilities;
using System.IO;
using System.Reflection;

codeunit 6188 "E-Document Emailing"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        TempBlobList: Codeunit "Temp Blob List";
        EDocumentAttachmentNameTok: Label '%1 %2', Locked = true, Comment = '%1 = Attachment name, %2 = File format';
        XMLFileTypeTok: Label '.xml', Locked = true;
        PDFFileTypeTok: Label '.pdf', Locked = true;
        ZipFileTypeTok: Label '.zip', Locked = true;
        FileNoTok: Label '_%1', Locked = true;

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
    procedure SendEDocumentEmail(
       DocumentSendingProfile: Record "Document Sending Profile";
       ReportUsage: Enum "Report Selection Usage";
       RecordVariant: Variant;
       DocNo: Code[20];
       DocName: Text[150];
       ToCust: Code[20];
       ShowDialog: Boolean)
    var
        ReportSelections: Record "Report Selections";
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
        CreateSourceLists(ToCust, SourceReference, SourceTableIDs, SourceIDs, SourceRelationTypes);
        ReportSelections.GetEmailBodyForCust(EmailBodyTempBlob, ReportUsage, RecordVariant, ToCust, SendToEmailAddress);

        AttachmentsTempBlob := CreateAttachmentsBlob(
            DocumentSendingProfile,
            ReportUsage,
            RecordVariant,
            DocNo,
            DocName,
            ToCust,
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

    procedure SetAttachments(Attachments: Codeunit "Temp Blob List")
    begin
        TempBlobList := Attachments;
    end;

    local procedure CreateSourceLists(ToCust: Code[20]; var SourceReference: RecordRef; var SourceTableIDs: List of [Integer]; var SourceIDs: List of [Guid]; var SourceRelationTypes: List of [Integer])
    var
        Customer: Record Customer;
        Telemetry: Codeunit Telemetry;
        EDocumentEmailingNoCustomerErr: Label 'No customer found for email sending';
    begin
        SourceTableIDs.Add(SourceReference.Number());
        SourceIDs.Add(SourceReference.Field(SourceReference.SystemIdNo).Value());
        SourceRelationTypes.Add(Enum::"Email Relation Type"::"Primary Source".AsInteger());

        Customer.SetLoadFields("No.", SystemId);
        if Customer.Get(ToCust) then begin
            SourceTableIDs.Add(Database::Customer);
            SourceIDs.Add(Customer.SystemId);
            SourceRelationTypes.Add(Enum::"Email Relation Type"::"Related Entity".AsInteger());
        end else
            Telemetry.LogMessage('0000Q1P', EDocumentEmailingNoCustomerErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All);
    end;

    local procedure CreateZipArchiveWithEDocAttachments(var DataCompression: Codeunit "Data Compression"; var TempBlobList: Codeunit "Temp Blob List"; AttachmentFileName: Text[250])
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

    local procedure AddPdfAttachmentToZipArchive(var DataCompression: Codeunit "Data Compression"; ReportUsage: Enum "Report Selection Usage"; RecordVariant: Variant; ToCust: Code[20]; AttachmentFileName: Text[250])
    var
        ReportSelections: Record "Report Selections";
        TempBlob: Codeunit "Temp Blob";
    begin
        ReportSelections.GetPdfReportForCust(TempBlob, ReportUsage, RecordVariant, ToCust);
        if TempBlob.HasValue() then
            DataCompression.AddEntry(TempBlob.CreateInStream(), AttachmentFileName + PDFFileTypeTok);
    end;

    local procedure CreateAttachmentsBlob(
        DocumentSendingProfile: Record "Document Sending Profile";
        ReportUsage: Enum "Report Selection Usage";
        RecordVariant: Variant;
        DocNo: Code[20];
        DocName: Text[150];
        ToCust: Code[20];
        var AttachmentFileName: Text[250];
        var AttachmentFileExtension: Text[4]): Codeunit "Temp Blob"
    var
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
    begin
        if TempBlobList.IsEmpty() then
            exit(TempBlob);

        AttachmentFileName := CreateAttachmentName(DocNo, DocName);
        if (TempBlobList.Count() = 1) and (DocumentSendingProfile."E-Mail Attachment" = Enum::"Document Sending Profile Attachment Type"::"E-Document")
        then begin
            TempBlobList.Get(1, TempBlob);
            AttachmentFileExtension := XMLFileTypeTok;
        end else begin
            CreateZipArchiveWithEDocAttachments(DataCompression, TempBlobList, AttachmentFileName);

            if DocumentSendingProfile."E-Mail Attachment" = Enum::"Document Sending Profile Attachment Type"::"PDF & E-Document" then
                AddPdfAttachmentToZipArchive(DataCompression, ReportUsage, RecordVariant, ToCust, AttachmentFileName);

            DataCompression.SaveZipArchive(TempBlob);
            DataCompression.CloseZipArchive();
            AttachmentFileExtension := ZipFileTypeTok;
        end;
        exit(TempBlob);
    end;

    local procedure CreateAttachmentName(PostedDocNo: Code[20]; EmailDocName: Text[250]): Text[250]
    begin
        exit(StrSubstNo(EDocumentAttachmentNameTok, EmailDocName, PostedDocNo));
    end;


}
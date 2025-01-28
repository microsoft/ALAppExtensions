// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.EServices.EDocument;
using System.Utilities;
using Microsoft.eServices.EDocument.Integration.Receive;
using System.Telemetry;
using System.Email;

codeunit 6385 "Outlook Processing"
{
    Access = Internal;
    Permissions = tabledata "E-Document" = m,
                  tabledata "E-Document Service Status" = m,
                  tabledata "Email Inbox" = r,
                  tabledata "Outlook Setup" = r;
    InherentPermissions = X;
    InherentEntitlements = X;

    internal procedure MarkMessageAsRead(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
    var
        OutlookSetup: Record "Outlook Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Email: Codeunit Email;
    begin
        CheckSetupEnabled(OutlookSetup);

        FeatureTelemetry.LogUptake('0000OGR', FeatureName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000OGU', FeatureName(), Format(EDocumentService."Service Integration V2"));
        if EDocument."Mail Message Id" = '' then
            Error(MailMessageIdEmptyErr, EDocument."Entry No");

        Email.MarkAsRead(OutlookSetup."Email Account ID", OutlookSetup."Email Connector", EDocument."Mail Message Id");
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; Documents: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        OutlookSetup: Record "Outlook Setup";
        EmailInbox: Record "Email Inbox";
        TempFilters: Record "Email Retrieval Filters" temporary;
        Email: Codeunit Email;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        DocumentsArray: JsonArray;
    begin
        CheckSetupEnabled(OutlookSetup);

        FeatureTelemetry.LogUptake('0000OGS', FeatureName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000OGV', FeatureName(), Format(EDocumentService."Service Integration V2"));
        TempFilters."Unread Emails" := true;
        TempFilters."Load Attachments" := true;
        TempFilters."Max No. of Emails" := GetMaxNoOfEmails();
        TempFilters."Earliest Email" := OutlookSetup."Last Sync At";
        TempFilters."Last Message Only" := true;
        TempFilters.Insert();
        Email.RetrieveEmails(OutlookSetup."Email Account ID", OutlookSetup."Email Connector", EmailInbox, TempFilters);
        BuildDocumentsArray(EmailInbox, DocumentsArray);
        BuildDocumentsList(Documents, DocumentsArray);

        OutlookSetup."Last Sync At" := CurrentDateTime();
        OutlookSetup.Modify();
    end;

    local procedure GetMaxNoOfEmails(): Integer
    begin
        exit(100);
    end;

    local procedure CheckSetupEnabled(var OutlookSetup: Record "Outlook Setup")
    begin
        if not OutlookSetup.Get() then
            Error(IntegrationNotEnabledErr, OutlookSetup.TableCaption());
        if not OutlookSetup.Enabled then
            Error(IntegrationNotEnabledErr, OutlookSetup.TableCaption());
    end;

    internal procedure FeatureName(): Text
    begin
        exit('Microsoft 365 E-Document Connector')
    end;

    local procedure BuildDocumentsArray(var EmailInbox: Record "Email Inbox"; var DocumentsArray: JsonArray)
    var
        EmailMessage: Codeunit "Email Message";
        TempBlob: Codeunit "Temp Blob";
        Attachment: JSonObject;
    begin
        if EmailInbox.FindSet() then
            repeat
                if EmailMessage.Get(EmailInbox."Message Id") then
                    if EmailMessage.Attachments_First() then
                        repeat
                            if not IgnoreMailAttachment(EmailMessage) then begin
                                Clear(Attachment);
                                Clear(TempBlob);
                                Attachment.Add('messageid', EmailInbox."Message Id");
                                Attachment.Add('externalmessageid', EmailInbox."External Message Id");
                                Attachment.Add('attachmentid', EmailMessage.Attachments_GetId());
                                Attachment.Add('contentid', EmailMessage.Attachments_GetContentId());
                                Attachment.Add('size', EmailMessage.Attachments_GetLength());
                                Attachment.Add('contentType', EmailMessage.Attachments_GetContentType());
                                Attachment.Add('name', EmailMessage.Attachments_GetName());
                                DocumentsArray.Add(Attachment);
                            end;
                        until EmailMessage.Attachments_Next() = 0;
            until EmailInbox.Next() = 0;
    end;

    internal procedure BuildDocumentsList(Documents: Codeunit "Temp Blob List"; var AttachmentsJson: JSonArray)
    var
        TempBlob: Codeunit "Temp Blob";
        AttachmentJson: JsonToken;
        OutStream: OutStream;
        AttachmentTxt: Text;
    begin
        foreach AttachmentJson in AttachmentsJson do begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
            if not IgnoreAttachmentJson(AttachmentJson.AsObject()) then begin
                AttachmentJson.WriteTo(AttachmentTxt);
                OutStream.WriteText(AttachmentTxt);
                Documents.Add(TempBlob);
            end;
        end;
    end;

    local procedure IgnoreAttachmentJson(Item: JSonObject): Boolean
    var
        SizeToken: JSonToken;
        Size: BigInteger;
        ContentTypeToken: JsonToken;
        ContentTypeValue: Text;
    begin
        if Item.Get('size', SizeToken) then
            if SizeToken.IsValue() then begin
                Size := SizeToken.AsValue().AsBigInteger();
                if Size > SizeThreshold() then
                    exit(true);
            end;

        if Item.Get('contentType', ContentTypeToken) then
            if ContentTypeToken.IsValue() then begin
                ContentTypeValue := ContentTypeToken.AsValue().AsText();
                if not LowerCase(DelChr(ContentTypeValue, '=', ' ')).Contains('application/pdf') then
                    exit(true);
            end;
    end;

    local procedure IgnoreMailAttachment(EmailMessage: Codeunit "Email Message"): Boolean
    var
        Ignore: Boolean;
    begin
        if EmailMessage.Attachments_GetLength() > SizeThreshold() then
            Ignore := true;

        if LowerCase(EmailMessage.Attachments_GetContentType()) <> 'application/pdf' then
            Ignore := true;

        exit(Ignore)
    end;

    local procedure SizeThreshold(): Integer
    var
        DriveProcessing: Codeunit "Drive Processing";
    begin
        exit(DriveProcessing.SizeThreshold())
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadataBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        OutlookSetup: Record "Outlook Setup";
        EmailMessage: Codeunit "Email Message";
        TempBlob: Codeunit "Temp Blob";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        DocumentOutStream: OutStream;
        InStream: InStream;
        FileId, AttachmentId, ExternalMessageId, MessageId : Text;
        AttachmentFound: Boolean;
    begin
        CheckSetupEnabled(OutlookSetup);

        FeatureTelemetry.LogUptake('0000OGT', FeatureName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000OGW', FeatureName(), Format(EDocumentService."Service Integration V2"));

        ExtractMessageAndAttachmentIds(DocumentMetadataBlob, MessageId, ExternalMessageId, FileId, AttachmentId);

        if EmailMessage.Get(MessageId) then
            if EmailMessage.Attachments_First() then
                repeat
                    if EmailMessage.Attachments_GetContentId() = AttachmentId then begin
                        AttachmentFound := true;
                        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
                        EmailMessage.Attachments_GetContent(InStream);
                        ReceiveContext.GetTempBlob().CreateOutStream(DocumentOutStream, TextEncoding::UTF8);
                        CopyStream(DocumentOutStream, InStream);
                        if not ReceiveContext.GetTempBlob().HasValue() then
                            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(NoContentErr, FileId));
                        UpdateEDocumentAfterMailAttachmentDownload(Edocument, ExternalMessageId, FileId, AttachmentId);
                        UpdateReceiveContextAfterDocumentDownload(ReceiveContext);
                    end;
                until (EmailMessage.Attachments_Next() = 0) or AttachmentFound;
    end;

    internal procedure UpdateReceiveContextAfterDocumentDownload(ReceiveContext: Codeunit ReceiveContext)
    begin
        ReceiveContext.Status().SetStatus(Enum::"E-Document Service Status"::"Ready For Processing");
    end;

    internal procedure UpdateEDocumentAfterMailAttachmentDownload(var EDocument: Record "E-Document"; ExternalMailMessageId: Text; FileId: Text; MailAttachmentId: Text)
    begin
        EDocument."Mail Message Id" := CopyStr(ExternalMailMessageId, 1, MaxStrLen(EDocument."Mail Message Id"));
        EDocument."File Id" := CopyStr(FileId, 1, MaxStrLen(EDocument."File Id"));
        EDocument."Mail Message Attachment Id" := CopyStr(MailAttachmentId, 1, MaxStrLen(EDocument."Mail Message Attachment Id"));
        EDocument.Modify();
    end;

    internal procedure ExtractMessageAndAttachmentIds(DocumentMetadataBlob: Codeunit "Temp Blob"; var MessageId: Text; var ExternalMessageId: Text; var FileId: Text; var MailAttachmentId: Text)
    var
        Instream: InStream;
        ItemObject: JsonObject;
        ContentData: Text;
    begin
        DocumentMetadataBlob.CreateInStream(Instream);
        Instream.ReadText(ContentData);
        ItemObject.ReadFrom(ContentData);
        MessageId := ItemObject.GetText('messageid');
        ExternalMessageId := ItemObject.GetText('externalmessageid');
        MailAttachmentId := ItemObject.GetText('contentid');
        FileId := ItemObject.GetText('name');
    end;

    var
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        NoContentErr: Label 'Empty content retrieved from the service for file: %1.', Comment = '%1 - file name';
        IntegrationNotEnabledErr: Label '%1 must be enabled.', Comment = '%1 - a table caption, Sharepoint Document Import Setup';
        MailMessageIdEmptyErr: Label 'Mail Message Id is empty on e-document %1.', Comment = '%1 - an integer';
}
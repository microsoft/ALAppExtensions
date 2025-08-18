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
using System.IO;
using Microsoft.eServices.EDocument.Processing.Import;

codeunit 6385 "Outlook Processing"
{
    Access = Internal;
    Permissions = tabledata "E-Document" = m,
                  tabledata "E-Document Service Status" = m,
                  tabledata "Email Inbox" = r,
                  tabledata "Outlook Setup" = rim;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnRun()
    var
        OutlookSetup: Record "Outlook Setup";
        Email: Codeunit Email;
    begin
        // OnRun defined to execute Email.RetrieveEmails() to allow for "catching" with the `if Codeunit.Run` pattern
        // we are dependent on Email.RetrieveEmails to be robust, and if it fails we want to be able to recover and keep reading emails
        CheckSetupEnabled(OutlookSetup);
        Clear(RetrievedEmailInbox);
        Email.RetrieveEmails(OutlookSetup."Email Account ID", OutlookSetup."Email Connector", RetrievedEmailInbox, TempEmailRetrievalFilters);
    end;

    internal procedure MarkMessageAsRead(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
    var
        OutlookSetup: Record "Outlook Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Email: Codeunit Email;
    begin
        CheckSetupEnabled(OutlookSetup);

        FeatureTelemetry.LogUptake('0000OGR', FeatureName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000OGU', FeatureName(), Format(EDocumentService."Service Integration V2"));
        if EDocument."Outlook Mail Message Id" = '' then
            Error(MailMessageIdEmptyErr, EDocument."Entry No");

        Email.MarkAsRead(OutlookSetup."Email Account ID", OutlookSetup."Email Connector", EDocument."Outlook Mail Message Id");
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; Documents: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        OutlookSetup: Record "Outlook Setup";
        TempFilters: Record "Email Retrieval Filters" temporary;
        OutlookProcessing: Codeunit "Outlook Processing";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        DocumentsArray: JsonArray;
    begin
        CheckSetupEnabled(OutlookSetup);
        if DailyLimitReached(EDocumentService) then begin
            Session.LogMessage('0000PKF', 'Daily limit for e-mails received has been reached.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
            exit;
        end;

        FeatureTelemetry.LogUptake('0000OGS', FeatureName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000OGV', FeatureName(), Format(EDocumentService."Service Integration V2"));
        TempFilters."Unread Emails" := true;
        TempFilters."Load Attachments" := true;
        TempFilters."Max No. of Emails" := GetMaxNoOfEmails();
        TempFilters."Earliest Email" := OutlookSetup."Last Sync At";
        OutlookProcessing.ConfigureForEmailRetrieval(TempFilters);
        if not OutlookProcessing.Run() then begin // Email.RetrieveEmails() called this way to "catch" and recover
            // If email retrieval fails, the problem may be triggered by a specific email, so we attempt to recover by pushing the date of the emails retrieved so that we skip the problematic email

            // This has as a possible side-effect that we may skip some valid emails.
            // In principle this should not happen, but if it happens then we are not completely stuck.
            if EDocumentService."Batch Minutes between runs" = 0 then
                OutlookSetup."Last Sync At" := CurrentDateTime()
            else
                OutlookSetup."Last Sync At" := OutlookSetup."Last Sync At" + (EDocumentService."Batch Minutes between runs" * 60 * 1000);

            if OutlookSetup."Last Sync At" > CurrentDateTime() then
                OutlookSetup."Last Sync At" := CurrentDateTime();
            OutlookSetup.Modify();
            Commit();
            Error(RetrieveEmailsErr);
        end;
        OutlookProcessing.GetRetrievedEmailsInbox(RetrievedEmailInbox);
        Session.LogMessage('0000PKG', 'Retrieved emails from the email connector', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName(), 'EmailsReceived', Format(RetrievedEmailInbox.Count()));
        BuildDocumentsArray(RetrievedEmailInbox, DocumentsArray);
        BuildDocumentsList(Documents, DocumentsArray);
    end;

    local procedure DailyLimitReached(var EDocumentService: Record "E-Document Service"): Boolean
    var
        EDocument: Record "E-Document";
        EmailsPer24HLimit: Integer;
        ExternalMailMessageIds: List of [Text[2048]];
    begin
        EmailsPer24HLimit := GetEmailsPer24HLimit();
        EDocument.ReadIsolation := IsolationLevel::ReadCommitted;
        EDocument.SetRange(Service, EDocumentService.Code);
        EDocument.SetRange(SystemCreatedAt, CurrentDateTime() - (24 * 3600 * 1000), CurrentDateTime());
        if EDocument.FindSet() then
            repeat
                if not ExternalMailMessageIds.Contains(EDocument."Outlook Mail Message Id") then
                    ExternalMailMessageIds.Add(EDocument."Outlook Mail Message Id");
            until EDocument.Next() = 0;
        exit(ExternalMailMessageIds.Count() >= EmailsPer24HLimit)
    end;

    local procedure GetEmailsPer24HLimit(): Integer
    begin
        exit(100);
    end;

    local procedure GetMaxNoOfEmails(): Integer
    begin
        exit(50);
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
        Attachment: JsonObject;
        TelemetryCustomDimensions: Dictionary of [Text, Text];
        AttachmentsAdded, IgnoredBecauseExisting, AttachmentsLoaded : Integer;
    begin
        if not EmailInbox.FindSet() then
            exit;
        repeat
            if not EmailMessage.Get(EmailInbox."Message Id") then begin
                Session.LogMessage('0000PKH', 'E-mail retrieved but not found afterwards', Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
                continue;
            end;
            AttachmentsLoaded := 0;
            AttachmentsAdded := 0;
            IgnoredBecauseExisting := 0;
            if EmailMessage.Attachments_First() then
                repeat
                    if not IgnoreMailAttachment(EmailMessage, IgnoredBecauseExisting) then begin
                        Clear(Attachment);
                        Clear(TempBlob);
                        Attachment.Add('emailInboxId', EmailInbox.Id);
                        Attachment.Add('messageid', EmailInbox."Message Id");
                        Attachment.Add('externalmessageid', EmailInbox."External Message Id");
                        Attachment.Add('receiveddatetime', EmailInbox."Received DateTime");
                        Attachment.Add('id', EmailMessage.Attachments_GetId());
                        Attachment.Add('size', EmailMessage.Attachments_GetLength());
                        Attachment.Add('contentType', EmailMessage.Attachments_GetContentType());
                        Attachment.Add('contentId', EmailMessage.Attachments_GetContentId());
                        Attachment.Add('name', EmailMessage.Attachments_GetName());
                        DocumentsArray.Add(Attachment);
                        AttachmentsAdded += 1;
                    end;
                    AttachmentsLoaded += 1;
                until EmailMessage.Attachments_Next() = 0;
            // if an e-mail message has no attachments of supported type, add it as well
            // it must be represented as an e-document with no attachment
            if (AttachmentsAdded = 0) and (IgnoredBecauseExisting = 0) then begin
                Clear(Attachment);
                Clear(TempBlob);
                Attachment.Add('emailInboxId', EmailInbox.Id);
                Attachment.Add('messageid', EmailInbox."Message Id");
                Attachment.Add('externalmessageid', EmailInbox."External Message Id");
                Attachment.Add('receiveddatetime', EmailInbox."Received DateTime");
                Attachment.Add('id', 0);
                Attachment.Add('size', 0);
                Attachment.Add('contentType', 'none');
                Attachment.Add('contentId', 'none');
                Attachment.Add('name', NoSupportedAttachmentTxt);
                DocumentsArray.Add(Attachment);
            end;
            Clear(TelemetryCustomDimensions);
            TelemetryCustomDimensions.Add('Category', FeatureName());
            TelemetryCustomDimensions.Add('ReceivedDateTime', Format(EmailInbox."Received DateTime"));
            TelemetryCustomDimensions.Add('AttachmentsLoaded', Format(AttachmentsLoaded));
            TelemetryCustomDimensions.Add('AttachmentsImported', Format(AttachmentsAdded));
            TelemetryCustomDimensions.Add('AttachmentsIgnoredBecauseExisting', Format(IgnoredBecauseExisting));
            Session.LogMessage('0000PFP', ProcessingEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryCustomDimensions);
        until EmailInbox.Next() = 0;
    end;

    internal procedure BuildDocumentsList(Documents: Codeunit "Temp Blob List"; var AttachmentsJson: JsonArray)
    var
        TempBlob: Codeunit "Temp Blob";
        AttachmentJson: JsonToken;
        OutStream: OutStream;
        AttachmentTxt: Text;
    begin
        foreach AttachmentJson in AttachmentsJson do begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
            AttachmentJson.WriteTo(AttachmentTxt);
            OutStream.WriteText(AttachmentTxt);
            Documents.Add(TempBlob);
        end;
    end;

    internal procedure IgnoreMailAttachment(AttachmentLength: Integer; AttachmentContentType: Text): Boolean // this procedure is internal to be called by tests
    begin
        if AttachmentLength > SizeThreshold() then begin
            Session.LogMessage('0000PKI', 'Ignoring attachment because it exceeds size threshold.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
            exit(true);
        end;

        if LowerCase(AttachmentContentType) <> 'application/pdf' then begin
            Session.LogMessage('0000PKJ', 'Ignoring attachment because it the attachment is not of a supported type.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
            exit(true);
        end;
        exit(false);
    end;

    local procedure IgnoreMailAttachment(EmailMessage: Codeunit "Email Message"; var IgnoredBecauseExisting: Integer): Boolean
    var
        EDocument: Record "E-Document";
    begin
        if IgnoreMailAttachment(EmailMessage.Attachments_GetLength(), EmailMessage.Attachments_GetContentType()) then
            exit(true);

        EDocument.ReadIsolation := IsolationLevel::ReadCommitted;
        EDocument.SetRange("Outlook Mail Message Id", EmailMessage.GetExternalId());
        EDocument.SetRange("Outlook Message Attachment Id", Format(EmailMessage.Attachments_GetContentId()));
        if not EDocument.IsEmpty() then begin
            IgnoredBecauseExisting += 1;
            Session.LogMessage('0000PKK', 'Ignoring attachment because it is already imported.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
            exit(true);
        end;

        exit(false)
    end;

    local procedure PageCountThreshold(): Integer
    begin
        exit(10)
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
        EmailInbox: Record "Email Inbox";
        EmailMessage: Codeunit "Email Message";
        TempBlob: Codeunit "Temp Blob";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        DocumentOutStream: OutStream;
        InStream: InStream;
        FileId, ExternalMessageId, MessageId, ContentType : Text;
        AttachmentFound: Boolean;
        EmailInboxId, AttachmentId : BigInteger;
        ReceivedDateTime: DateTime;
        MessageIdGuid, ExternalMessageIdGuid : Guid;
        ContentId: Text[2048];
        ExceedsPageCountThreshold: Boolean;
    begin
        CheckSetupEnabled(OutlookSetup);

        FeatureTelemetry.LogUptake('0000OGT', FeatureName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000OGW', FeatureName(), Format(EDocumentService."Service Integration V2"));

        ExtractMessageAndAttachmentIds(DocumentMetadataBlob, EmailInboxId, MessageId, ExternalMessageId, FileId, AttachmentId, ReceivedDateTime, ContentType, ContentId);
        ReceiveContext.SetName(CopyStr(FileId, 1, 250));

        if ReceivedDateTime > OutlookSetup."Last Sync At" then begin
            OutlookSetup."Last Sync At" := ReceivedDateTime;
            OutlookSetup.Modify();
        end;

        if not EmailInbox.Get(EmailInboxId) then
            Error(InvalidAttachmentIdErr);

        if not EmailMessage.Get(MessageId) then
            Error(InvalidAttachmentIdErr);

        EDocument."Source Details" := EmailInbox."Sender Address";
        EDocument."Additional Source Details" := EmailMessage.GetSubject();
        EDocument."Outlook Mail Message Id" := CopyStr(ExternalMessageId, 1, MaxStrLen(EDocument."Outlook Mail Message Id"));
        EDocument."Outlook Message Attachment Id" := ContentId;
        if Evaluate(ExternalMessageIdGuid, ExternalMessageId) then
            EDocument."Outlook Mail Message Id" := ExternalMessageIdGuid;
        if Evaluate(MessageIdGuid, MessageId) then
            EDocument."Mail Message Id" := MessageIdGuid;

        // this is the representation of email without supported attachment. register it in E-Document table.
        if (AttachmentId = 0) and (ContentType = 'none') then
            if EmailMessage.Get(MessageId) then begin
                EDocument."Structure Data Impl." := "Structure Received E-Doc."::"Already Structured";
                EDocument."Read into Draft Impl." := "E-Doc. Read Into Draft"::"Blank Draft";
                ReceiveContext.GetTempBlob().CreateOutStream(DocumentOutStream, TextEncoding::UTF8);
                if EmailMessage.Get(MessageId) then;
                DocumentOutStream.WriteText(EmailMessage.GetBody());
                EDocument.Modify();
                exit;
            end;

        if EmailMessage.Get(MessageId) then
            if EmailMessage.Attachments_First() then
                repeat
                    if EmailMessage.Attachments_GetId() = AttachmentId then begin
                        AttachmentFound := true;
                        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
                        EmailMessage.Attachments_GetContent(InStream);
                        if not DocumentExceedsPageCountThreshold(InStream, ExceedsPageCountThreshold) then
                            Session.LogMessage('0000PMR', PageCountCallFailedTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
                        if ExceedsPageCountThreshold then begin
                            Session.LogMessage('0000PKT', StrSubstNo(PageCountExceededTelemetryTxt, Format(PageCountThreshold())), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
                            EDocument."Structure Data Impl." := "Structure Received E-Doc."::"Already Structured";
                            EDocument."Read into Draft Impl." := "E-Doc. Read Into Draft"::"Blank Draft";
                            EDocumentErrorHelper.LogWarningMessage(EDocument, EDocument, EDocument.FieldNo("Structured Data Entry No."), StrSubstNo(PageCountExceededTxt, FileId, Format(PageCountThreshold())));
                        end else begin
                            ReceiveContext.SetFileFormat("E-Doc. File Format"::PDF);
                            ReceiveContext.GetTempBlob().CreateOutStream(DocumentOutStream, TextEncoding::UTF8);
                            CopyStream(DocumentOutStream, InStream);
                            if not ReceiveContext.GetTempBlob().HasValue() then
                                EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(NoContentErr, FileId));
                        end;
                        EDocument.Modify();
                    end;
                until (EmailMessage.Attachments_Next() = 0) or AttachmentFound;
    end;

    [TryFunction]
    local procedure DocumentExceedsPageCountThreshold(DocInStream: Instream; var Exceeds: Boolean)
    var
        PdfDocument: Codeunit "PDF Document";
    begin
        Exceeds := PdfDocument.GetPdfPageCount(DocInStream) > PageCountThreshold();
    end;

    internal procedure ExtractMessageAndAttachmentIds(DocumentMetadataBlob: Codeunit "Temp Blob"; var EmailInboxId: BigInteger; var MessageId: Text; var ExternalMessageId: Text; var FileId: Text; var MailAttachmentId: BigInteger; var ReceivedDateTime: DateTime; var ContentType: Text; var ContentId: Text[2048])
    var
        Instream: InStream;
        ItemObject: JsonObject;
        EmailInboxIdTxt, ContentData : Text;
    begin
        DocumentMetadataBlob.CreateInStream(Instream);
        Instream.ReadText(ContentData);
        ItemObject.ReadFrom(ContentData);
        EmailInboxIdTxt := ItemObject.GetText('emailInboxId', true);
        if not Evaluate(EmailInboxId, EmailInboxIdTxt) then;
        MessageId := ItemObject.GetText('messageid', true);
        ExternalMessageId := ItemObject.GetText('externalmessageid');
        FileId := ItemObject.GetText('name');
        if not Evaluate(MailAttachmentId, ItemObject.GetText('id')) then
            if ItemObject.GetText('id') <> '' then
                Error(InvalidAttachmentIdErr, FileId);
        if ItemObject.GetText('receiveddatetime') <> '' then
            if not Evaluate(ReceivedDateTime, ItemObject.GetText('receiveddatetime'), 9) then
                Error(InvalidAttachmentReceivedDateTimeErr, FileId);
        ContentType := ItemObject.GetText('contentType');
        ContentId := CopyStr(ItemObject.GetText('contentId'), 1, MaxStrLen(ContentId));
    end;

    internal procedure ConfigureForEmailRetrieval(var TempFilters: Record "Email Retrieval Filters" temporary)
    begin
        this.TempEmailRetrievalFilters.DeleteAll();
        this.TempEmailRetrievalFilters.Copy(TempFilters);
        this.TempEmailRetrievalFilters.Insert();
    end;

    internal procedure GetRetrievedEmailsInbox(var EmailInbox: Record "Email Inbox")
    begin
        EmailInbox.Copy(this.RetrievedEmailInbox);
    end;

#if not CLEAN27
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Page, Page::"Inbound E-Documents", OnAfterActionEvent, ViewMailMessage, false, false)]
    local procedure OnAfterViewEmailMessageAction(var Rec: Record "E-Document")
    var
        OutlookIntegrationImpl: Codeunit "Outlook Integration Impl.";
    begin
        if (Rec."Outlook Mail Message Id" <> '') then
            HyperLink(StrSubstNo(OutlookIntegrationImpl.WebLinkText(), Rec."Outlook Mail Message Id"))
    end;
#pragma warning restore AL0432
#endif

    var
        TempEmailRetrievalFilters: Record "Email Retrieval Filters" temporary;
        RetrievedEmailInbox: Record "Email Inbox";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        NoContentErr: Label 'Empty content retrieved from the service for file: %1.', Comment = '%1 - file name';
        IntegrationNotEnabledErr: Label '%1 must be enabled.', Comment = '%1 - a table caption, Sharepoint Document Import Setup';
        MailMessageIdEmptyErr: Label 'Mail Message Id is empty on e-document %1.', Comment = '%1 - an integer';
        InvalidAttachmentIdErr: Label 'Failed to determine id for attachment %1.', Comment = '%1 - a file name';
        InvalidAttachmentReceivedDateTimeErr: Label 'Failed to determine received date time for attachment %1.', Comment = '%1 - a file name';
        NoSupportedAttachmentTxt: Label 'E-mail with no attachment of supported type.';
        RetrieveEmailsErr: Label 'Failed to retrieve emails from the email connector.';
        ProcessingEmailTxt: label 'Processing email.', Locked = true;
        PageCountExceededTxt: Label 'Attachment %1 was ignored because it exceeds the feature limit of %2 pages.', Comment = '%1 - file name, %2 - an integer';
        PageCountExceededTelemetryTxt: label 'PDF Attachment ignored because it exceeds page count of %1.', Locked = true;
        PageCountCallFailedTelemetryTxt: label 'Unable to calculate page count for PDF Attachment.', Locked = true;
}
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8905 "Email Message Impl."
{
    Access = Internal;
    Permissions = tabledata "Sent Email" = r,
                  tabledata "Email Outbox" = rim,
                  tabledata "Email Message" = rimd,
                  tabledata "Email Error" = rd,
                  tabledata "Email Recipient" = rid,
                  tabledata "Email Message Attachment" = rid,
                  tabledata "Email Related Record" = rd,
                  tabledata "Tenant Media" = rm;

    procedure Create(EmailMessageImpl: Codeunit "Email Message Impl.")
    var
        EmailRelatedRecord: Record "Email Related Record";
        EmailImpl: Codeunit "Email Impl";
        AttachmentInStream: InStream;
    begin
        Create(EmailMessageImpl.GetRecipientsAsText(Enum::"Email Recipient Type"::"To"),
                EmailMessageImpl.GetSubject(), EmailMessageImpl.GetBody(), EmailMessageImpl.IsBodyHTMLFormatted());

        SetRecipients(Enum::"Email Recipient Type"::CC, EmailMessageImpl.GetRecipientsAsText(Enum::"Email Recipient Type"::CC));
        SetRecipients(Enum::"Email Recipient Type"::Bcc, EmailMessageImpl.GetRecipientsAsText(Enum::"Email Recipient Type"::Bcc));

        if EmailMessageImpl.Attachments_First() then
            repeat
                EmailMessageImpl.Attachments_GetContent(AttachmentInStream);
                AddAttachment(EmailMessageImpl.Attachments_GetName(), EmailMessageImpl.Attachments_GetContentType(), AttachmentInStream);
            until EmailMessageImpl.Attachments_Next() = 0;

        EmailRelatedRecord.SetRange("Email Message Id", EmailMessageImpl.GetId());
        if EmailRelatedRecord.FindSet() then
            repeat
                EmailImpl.AddRelation(GetId(), EmailRelatedRecord."Table Id", EmailRelatedRecord."System Id", EmailRelatedRecord."Relation Type", EmailRelatedRecord."Relation Origin");
            until EmailRelatedRecord.Next() = 0;
    end;

    procedure Create(ToRecipients: Text; Subject: Text; Body: Text; HtmlFormatted: Boolean)
    var
        EmptyList: List of [Text];
    begin
#pragma warning disable AA0205
        Create(EmptyList, Subject, Body, HtmlFormatted);
#pragma warning restore AA0205

        SetRecipients(Enum::"Email Recipient Type"::"To", ToRecipients);
    end;

    procedure Create(Recipients: List of [Text]; Subject: Text; Body: Text; HtmlFormatted: Boolean)
    var
        EmptyList: List of [Text];
    begin
#pragma warning disable AA0205
        Create(Recipients, Subject, Body, HtmlFormatted, EmptyList, EmptyList);
#pragma warning restore AA0205
    end;

    procedure Create(Recipients: List of [Text]; Subject: Text; Body: Text; HtmlFormatted: Boolean; CCRecipients: List of [Text]; BCCRecipients: List of [Text])
    begin
        Clear(EmailMessageAttachmentRec);
        Clear(EmailMessageRec);

        EmailMessageRec.Id := CreateGuid();
        EmailMessageRec.Insert();

        UpdateMessage(Recipients, Subject, Body, HtmlFormatted, CCRecipients, BCCRecipients);
    end;

    procedure UpdateMessage(ToRecipients: List of [Text]; Subject: Text; Body: Text; HtmlFormatted: Boolean; CCRecipients: List of [Text]; BCCRecipients: List of [Text])
    begin
        SetBody(Body);
        SetSubject(Subject);
        SetBodyHTMLFormatted(HtmlFormatted);
        Modify();

        SetRecipients(Enum::"Email Recipient Type"::"To", ToRecipients);
        SetRecipients(Enum::"Email Recipient Type"::Cc, CCRecipients);
        SetRecipients(Enum::"Email Recipient Type"::Bcc, BCCRecipients);
    end;

    procedure Modify()
    begin
        EmailMessageRec.Modify();
    end;

    procedure GetBody() BodyText: Text
    var
        BodyInStream: InStream;
    begin
        EmailMessageRec.CalcFields(Body);
        EmailMessageRec.Body.CreateInStream(BodyInStream, TextEncoding::UTF8);
        BodyInStream.Read(BodyText);
    end;

    procedure SetBody(BodyText: Text)
    var
        BodyOutStream: OutStream;
    begin
        Clear(EmailMessageRec.Body);

        if BodyText = '' then
            exit;

        ReplaceRgbaColorsWithRgb(BodyText);
        EmailMessageRec.Body.CreateOutStream(BodyOutStream, TextEncoding::UTF8);
        BodyOutStream.Write(BodyText);
    end;

    procedure GetSubject(): Text[2048]
    begin
        exit(EmailMessageRec.Subject);
    end;

    procedure SetSubject(Subject: Text)
    begin
        EmailMessageRec.Subject := CopyStr(Subject, 1, MaxStrLen(EmailMessageRec.Subject));
    end;

    procedure IsBodyHTMLFormatted(): Boolean
    begin
        exit(EmailMessageRec."HTML Formatted Body");
    end;

    procedure SetBodyHTMLFormatted(Value: Boolean)
    begin
        EmailMessageRec."HTML Formatted Body" := Value;
    end;

    procedure IsRead(): Boolean
    begin
        exit(not EmailMessageRec.Editable);
    end;

    procedure GetContentTypeFromFilename(FileName: Text): Text[250]
    begin
        if FileName.EndsWith('.graphql') or FileName.EndsWith('.gql') then
            exit('application/graphql');
        if FileName.EndsWith('.js') then
            exit('application/javascript');
        if FileName.EndsWith('.json') then
            exit('application/json');
        if FileName.EndsWith('.doc') then
            exit('application/msword(.doc)');
        if FileName.EndsWith('.pdf') then
            exit('application/pdf');
        if FileName.EndsWith('.sql') then
            exit('application/sql');
        if FileName.EndsWith('.xls') then
            exit('application/vnd.ms-excel(.xls)');
        if FileName.EndsWith('.ppt') then
            exit('application/vnd.ms-powerpoint(.ppt)');
        if FileName.EndsWith('.odt') then
            exit('application/vnd.oasis.opendocument.text(.odt)');
        if FileName.EndsWith('.pptx') then
            exit('application/vnd.openxmlformats-officedocument.presentationml.presentation(.pptx)');
        if FileName.EndsWith('.xlsx') then
            exit('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet(.xlsx)');
        if FileName.EndsWith('.docx') then
            exit('application/vnd.openxmlformats-officedocument.wordprocessingml.document(.docx)');
        if FileName.EndsWith('.xml') then
            exit('application/xml');
        if FileName.EndsWith('.zip') then
            exit('application/zip');
        if FileName.EndsWith('.zst') then
            exit('application/zstd(.zst)');
        if FileName.EndsWith('.mpeg') then
            exit('audio/mpeg');
        if FileName.EndsWith('.ogg') then
            exit('audio/ogg');
        if FileName.EndsWith('.gif') then
            exit('application/gif');
        if FileName.EndsWith('.jpeg') then
            exit('application/jpeg');
        if FileName.EndsWith('.jpg') then
            exit('application/jpg');
        if FileName.EndsWith('.png') then
            exit('application/png');
        if FileName.EndsWith('.css') then
            exit('text/css');
        if FileName.EndsWith('.csv') then
            exit('text/csv');
        if FileName.EndsWith('.html') then
            exit('text/html');
        if FileName.EndsWith('.php') then
            exit('text/php');
        if FileName.EndsWith('.txt') then
            exit('text/plain');
        exit('');
    end;

    procedure AddAttachment(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentBase64: Text)
    var
        EmailMessageAttachment: Record "Email Message Attachment";
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        AttachmentOutstream: OutStream;
        AttachmentInStream: InStream;
        NullGuid: Guid;
    begin
        AddAttachment(AttachmentName, ContentType, false, NullGuid, EmailMessageAttachment);
        TempBlob.CreateOutStream(AttachmentOutstream);
        Base64Convert.FromBase64(AttachmentBase64, AttachmentOutstream);
        TempBlob.CreateInStream(AttachmentInStream);
        EmailMessageAttachment.Data.ImportStream(AttachmentInStream, AttachmentName, EmailMessageAttachment."Content Type");
        EmailMessageAttachment.Insert();
    end;

    procedure AddAttachment(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentInStream: InStream)
    begin
        AddAttachmentInternal(AttachmentName, ContentType, AttachmentInStream);
    end;

    procedure AddAttachmentInternal(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentInStream: InStream) Size: Integer
    var
        EmailMessageAttachment: Record "Email Message Attachment";
        NullGuid, MediaID : Guid;
    begin
        AddAttachment(AttachmentName, ContentType, false, NullGuid, EmailMessageAttachment);

        MediaID := EmailMessageAttachment.Data.ImportStream(AttachmentInStream, '', EmailMessageAttachment."Content Type");
        TenantMedia.Get(MediaID);
        TenantMedia.CalcFields(Content);
        EmailMessageAttachment.Length := TenantMedia.Content.Length;

        EmailMessageAttachment.Insert();
        exit(EmailMessageAttachment.Length);
    end;

    local procedure ReplaceRgbaColorsWithRgb(var Body: Text)
    var
        RgbaRegexPattern: DotNet Regex;
    begin
        Body := RgbaRegexPattern.Replace(Body, RbgaPatternTok, RgbReplacementTok);
    end;

    local procedure AddAttachment(AttachmentName: Text[250]; ContentType: Text[250]; InLine: Boolean; ContentId: Text[40]; var EmailMessageAttachment: Record "Email Message Attachment")
    begin
        EmailMessageAttachment."Email Message Id" := EmailMessageRec.Id;
        EmailMessageAttachment."Attachment Name" := AttachmentName;
        EmailMessageAttachment."Content Type" := ContentType;
        EmailMessageAttachment.InLine := InLine;
        EmailMessageAttachment."Content Id" := ContentId;
    end;

    procedure GetRecipients(): List of [Text]
    var
        EmailRecipients: Record "Email Recipient";
    begin
        EmailRecipients.SetRange("Email Message Id", EmailMessageRec.Id);
        exit(GetEmailAddressesOfRecipients(EmailRecipients));
    end;

    procedure GetRecipients(RecipientType: Enum "Email Recipient Type"): List of [Text]
    var
        EmailRecipients: Record "Email Recipient";
    begin
        EmailRecipients.SetRange("Email Message Id", EmailMessageRec.Id);
        EmailRecipients.SetRange("Email Recipient Type", RecipientType);
        exit(GetEmailAddressesOfRecipients(EmailRecipients));
    end;

    local procedure GetEmailAddressesOfRecipients(var EmailRecipients: Record "Email Recipient"): List of [Text]
    var
        Recipients: List of [Text];
    begin
        if EmailRecipients.FindSet() then
            repeat
                Recipients.Add(EmailRecipients."Email Address");
            until EmailRecipients.Next() = 0;
        exit(Recipients);
    end;

    procedure GetRecipientsAsText(RecipientType: Enum "Email Recipient Type"): Text
    var
        RecipientList: List of [Text];
        Recipient, Result : Text;
    begin
        RecipientList := GetRecipients(RecipientType);

        foreach Recipient in RecipientList do
            Result += ';' + Recipient;

        Result := Result.TrimStart(';'); // trim extra semicolon
        exit(Result);
    end;

    procedure SetRecipients(RecipientType: Enum "Email Recipient Type"; RecipientsText: Text)
    var
        RecipientsList: List of [Text];
    begin
        RecipientsList := RecipientsText.Split(';');

        SetRecipients(RecipientType, RecipientsList);
    end;

    procedure SetRecipients(RecipientType: Enum "Email Recipient Type"; Recipients: List of [Text])
    var
        EmailRecipientRecord: Record "Email Recipient";
        UniqueRecipients: Dictionary of [Text, Text];
        Recipient: Text;
    begin
        EmailRecipientRecord.SetRange("Email Message Id", EmailMessageRec.Id);
        EmailRecipientRecord.SetRange("Email Recipient Type", RecipientType);

        if not EmailRecipientRecord.IsEmpty() then
            EmailRecipientRecord.DeleteAll();

        foreach Recipient in Recipients do begin
            Recipient := DelChr(Recipient, '<>'); // trim the whitespaces around
            if Recipient <> '' then
                if UniqueRecipients.Add(Recipient.ToLower(), Recipient) then begin // Set the recipient key to lowercase to prevent duplicates
                    EmailRecipientRecord.Init();
                    EmailRecipientRecord."Email Message Id" := EmailMessageRec.Id;
                    EmailRecipientRecord."Email Recipient Type" := RecipientType;
                    EmailRecipientRecord."Email Address" := CopyStr(Recipient, 1, MaxStrLen(EmailRecipientRecord."Email Address"));

                    EmailRecipientRecord.Insert();
                end;
        end;
    end;

    procedure Attachments_DeleteContent(): Boolean
    var
        MediaId: Guid;
    begin
        MediaId := EmailMessageAttachmentRec.Data.MediaId();
        TenantMedia.Get(MediaID);
        Clear(TenantMedia.Content);
        TenantMedia.Modify();
        exit(not TenantMedia.Content.HasValue());
    end;

    procedure Attachments_First(): Boolean
    begin
        EmailMessageAttachmentRec.SetRange("Email Message Id", EmailMessageRec.Id);
        exit(EmailMessageAttachmentRec.FindFirst());
    end;

    procedure Attachments_Next(): Integer
    begin
        EmailMessageAttachmentRec.SetRange("Email Message Id", EmailMessageRec.Id);
        exit(EmailMessageAttachmentRec.Next());
    end;

    procedure Attachments_GetName(): Text[250]
    begin
        exit(EmailMessageAttachmentRec."Attachment Name");
    end;

    procedure Attachments_GetContent(var InStream: InStream)
    var
        EmailMessage: Codeunit "Email Message";
        MediaID: Guid;
        Handled: Boolean;
    begin
        MediaID := EmailMessageAttachmentRec.Data.MediaId();
        TenantMedia.Get(MediaID);
        TenantMedia.CalcFields(Content);

        if TenantMedia.Content.HasValue() then
            TenantMedia.Content.CreateInStream(InStream)
        else begin
            EmailMessage.OnGetAttachmentContent(MediaID, InStream, Handled);
            if not Handled then
                Error(EmailMessageGetAttachmentContentErr);
        end;
    end;

    procedure Attachments_GetContentBase64(): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        InStream: InStream;
    begin
        Attachments_GetContent(InStream);
        exit(Base64Convert.ToBase64(InStream));
    end;

    procedure Attachments_GetContentType(): Text[250]
    begin
        exit(EmailMessageAttachmentRec."Content Type");
    end;

    procedure Attachments_GetContentId(): Text[40]
    begin
        exit(EmailMessageAttachmentRec."Content Id");
    end;

    procedure Attachments_IsInline(): Boolean
    begin
        exit(EmailMessageAttachmentRec.InLine);
    end;

    procedure Attachments_GetLength(): Integer
    begin
        exit(EmailMessageAttachmentRec.Length);
    end;

    procedure GetId(): Guid
    begin
        exit(EmailMessageRec.Id);
    end;

    procedure Get(MessageId: guid): Boolean
    begin
        Clear(EmailMessageAttachmentRec);

        exit(EmailMessageRec.Get(MessageId));
    end;

    procedure ValidateRecipients()
    var
        EmailAccount: Codeunit "Email Account";
        Recipients: List of [Text];
        Recipient: Text;
    begin
        Recipients := GetRecipients();

        if Recipients.Count() = 0 then
            Error(NoAccountErr);

        foreach Recipient in Recipients do
            EmailAccount.ValidateEmailAddress(Recipient, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sent Email", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteSentEmail(var Rec: Record "Sent Email"; RunTrigger: Boolean)
    var
        EmailMessage: Record "Email Message";
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
    begin
        if Rec.IsTemporary() then
            exit;

        EmailOutbox.SetRange("Message Id", Rec."Message Id");
        if not EmailOutbox.IsEmpty() then
            exit;

        SentEmail.SetRange("Message Id", Rec."Message Id");
        if not SentEmail.IsEmpty() then
            exit;

        if EmailMessage.Get(Rec."Message Id") then
            EmailMessage.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Email Outbox", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteEmailOutbox(var Rec: Record "Email Outbox"; RunTrigger: Boolean)
    var
        SentEmail: Record "Sent Email";
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Record "Email Message";
        EmailError: Record "Email Error";
    begin
        if Rec.IsTemporary() then
            exit;

        EmailError.SetRange("Outbox Id", Rec.Id);
        EmailError.DeleteAll(true);

        SentEmail.SetRange("Message Id", Rec."Message Id");
        if not SentEmail.IsEmpty() then
            exit;

        EmailOutbox.SetRange("Message Id", Rec."Message Id");
        if not EmailOutbox.IsEmpty() then
            exit;

        if EmailMessage.Get(Rec."Message Id") then
            EmailMessage.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Email Message", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteEmailMessage(var Rec: Record "Email Message"; RunTrigger: Boolean)
    var
        EmailMessageAttachment: Record "Email Message Attachment";
        EmailRecipient: Record "Email Recipient";
        EmailRelatedRecord: Record "Email Related Record";
    begin
        if Rec.IsTemporary() then
            exit;

        EmailMessageAttachment.SetRange("Email Message Id", Rec.Id);
        EmailMessageAttachment.DeleteAll();

        EmailRecipient.SetRange("Email Message Id", Rec.Id);
        EmailRecipient.DeleteAll();

        EmailRelatedRecord.SetRange("Email Message Id", Rec.Id);
        EmailRelatedRecord.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Email Message", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModifyEmailMessage(var Rec: Record "Email Message"; var xRec: Record "Email Message"; RunTrigger: Boolean)
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessageOld: Record "Email Message";
    begin
        if Rec.IsTemporary() then
            exit;

        EmailOutbox.SetRange("Message Id", Rec.Id);
        EmailOutbox.SetFilter(Status, '%1|%2', EmailOutbox.Status::Queued, EmailOutbox.Status::Processing);

        if not EmailOutbox.IsEmpty() then
            Error(EmailMessageQueuedCannotModifyErr);

        if EmailMessageOld.Get(Rec.Id) and (not EmailMessageOld.Editable) then
            Error(EmailMessageSentCannotModifyErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Email Message Attachment", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteAttachment(var Rec: Record "Email Message Attachment")
    var
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
    begin
        if Rec.IsTemporary() then
            exit;

        EmailOutbox.SetRange("Message Id", Rec."Email Message Id");
        EmailOutbox.SetFilter(Status, '%1|%2', EmailOutbox.Status::Queued, EmailOutbox.Status::Processing);
        if not EmailOutbox.IsEmpty() then
            Error(EmailMessageQueuedCannotDeleteAttachmentErr);

        SentEmail.SetRange("Message Id", Rec."Email Message Id");
        if not SentEmail.IsEmpty() then
            Error(EmailMessageSentCannotDeleteAttachmentErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Email Recipient", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteRecipient(var Rec: Record "Email Recipient")
    var
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
    begin
        if Rec.IsTemporary() then
            exit;

        EmailOutbox.SetRange("Message Id", Rec."Email Message Id");
        EmailOutbox.SetFilter(Status, '%1|%2', EmailOutbox.Status::Queued, EmailOutbox.Status::Processing);
        if not EmailOutbox.IsEmpty() then
            Error(EmailMessageQueuedCannotDeleteRecipientErr);

        SentEmail.SetRange("Message Id", Rec."Email Message Id");
        if not SentEmail.IsEmpty() then
            Error(EmailMessageSentCannotDeleteRecipientErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Email Message Attachment", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertAttachment(var Rec: Record "Email Message Attachment")
    var
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
    begin
        if Rec.IsTemporary then
            exit;

        EmailOutbox.SetRange("Message Id", Rec."Email Message Id");
        EmailOutbox.SetFilter(Status, '%1|%2', EmailOutbox.Status::Queued, EmailOutbox.Status::Processing);
        if not EmailOutbox.IsEmpty() then
            Error(EmailMessageQueuedCannotInsertAttachmentErr);

        SentEmail.SetRange("Message Id", Rec."Email Message Id");
        if not SentEmail.IsEmpty() then
            Error(EmailMessageSentCannotInsertAttachmentErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Email Recipient", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertRecipient(var Rec: Record "Email Recipient")
    var
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
    begin
        if Rec.IsTemporary() then
            exit;

        EmailOutbox.SetRange("Message Id", Rec."Email Message Id");
        EmailOutbox.SetFilter(Status, '%1|%2', EmailOutbox.Status::Queued, EmailOutbox.Status::Processing);
        if not EmailOutbox.IsEmpty() then
            Error(EmailMessageQueuedCannotInsertRecipientErr);

        SentEmail.SetRange("Message Id", Rec."Email Message Id");
        if not SentEmail.IsEmpty() then
            Error(EmailMessageSentCannotInsertRecipientErr);
    end;

    procedure MarkAsRead()
    begin
        if EmailMessageRec.Editable then begin
            EmailMessageRec.Editable := false;
            EmailMessageRec.Modify();
        end;
    end;

    procedure GetEmailMessage(var EmailMessage: Record "Email Message")
    begin
        EmailMessage := EmailMessageRec;
    end;

    var
        EmailMessageRec: Record "Email Message";
        EmailMessageAttachmentRec: Record "Email Message Attachment";
        TenantMedia: Record "Tenant Media";
        EmailMessageQueuedCannotModifyErr: Label 'Cannot edit the email because it has been queued to be sent.';
        EmailMessageSentCannotModifyErr: Label 'Cannot edit the message because it has already been sent.';
        EmailMessageQueuedCannotDeleteAttachmentErr: Label 'Cannot delete the attachment because the email has been queued to be sent.';
        EmailMessageSentCannotDeleteAttachmentErr: Label 'Cannot delete the attachment because the email has already been sent.';
        EmailMessageQueuedCannotInsertAttachmentErr: Label 'Cannot add the attachment because the email is queued to be sent.';
        EmailMessageSentCannotInsertAttachmentErr: Label 'Cannot add the attachment because the email has already been sent.';
        EmailMessageQueuedCannotDeleteRecipientErr: Label 'Cannot delete the recipient because the email is queued to be sent.';
        EmailMessageSentCannotDeleteRecipientErr: Label 'Cannot delete the recipient because the email has already been sent.';
        EmailMessageQueuedCannotInsertRecipientErr: Label 'Cannot add a recipient because the email is queued to be sent.';
        EmailMessageSentCannotInsertRecipientErr: Label 'Cannot add the recipient because the email has already been sent.';
        EmailMessageGetAttachmentContentErr: Label 'The attachment content was not found.';
        NoAccountErr: Label 'You must specify a valid email account to send the message to.';
        RgbReplacementTok: Label 'rgb($1, $2, $3)', Locked = true;
        RbgaPatternTok: Label 'rgba\((\d+), ?(\d+), ?(\d+), ?\d+\)', Locked = true;
}
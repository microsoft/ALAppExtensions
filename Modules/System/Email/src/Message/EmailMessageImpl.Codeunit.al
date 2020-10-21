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
                  tabledata "Email Message Attachment" = rid;

    procedure Create(EmailMessage: Codeunit "Email Message Impl.")
    begin
        Create(EmailMessage.GetRecipientsAsText(Enum::"Email Recipient Type"::"To"),
                EmailMessage.GetSubject(), EmailMessage.GetBody(), EmailMessage.IsBodyHTMLFormatted());

        SetRecipients(Enum::"Email Recipient Type"::CC, EmailMessage.GetRecipientsAsText(Enum::"Email Recipient Type"::CC));
        SetRecipients(Enum::"Email Recipient Type"::Bcc, EmailMessage.GetRecipientsAsText(Enum::"Email Recipient Type"::Bcc));

        if EmailMessage.Attachments_First() then
            repeat
                AddAttachment(EmailMessage.Attachments_GetName(), EmailMessage.Attachments_GetContentType(), EmailMessage.Attachments_GetContentBase64());
            until EmailMessage.Attachments_Next() = 0;
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
        Clear(Attachments);
        Clear(Message);

        Message.Id := CreateGuid();
        Message.Insert();

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
        Message.Modify();
    end;

    procedure GetBody() BodyText: Text
    var
        BodyInStream: InStream;
    begin
        Message.CalcFields(Body);
        Message.Body.CreateInStream(BodyInStream, TextEncoding::UTF8);
        BodyInStream.Read(BodyText);
    end;

    procedure SetBody(BodyText: Text)
    var
        BodyOutStream: OutStream;
    begin
        Clear(Message.Body);

        if BodyText = '' then
            exit;

        ReplaceRgbaColorsWithRgb(BodyText);
        Message.Body.CreateOutStream(BodyOutStream, TextEncoding::UTF8);
        BodyOutStream.Write(BodyText);
    end;

    procedure GetSubject(): Text[2048]
    begin
        exit(Message.Subject);
    end;

    procedure SetSubject(Subject: Text)
    begin
        Message.Subject := CopyStr(Subject, 1, MaxStrLen(Message.Subject));
    end;

    procedure IsBodyHTMLFormatted(): Boolean
    begin
        exit(Message."HTML Formatted Body");
    end;

    procedure SetBodyHTMLFormatted(Value: Boolean)
    begin
        Message."HTML Formatted Body" := Value;
    end;

    procedure IsReadOnly(): Boolean
    begin
        exit(not Message.Editable);
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
        EmailAttachment: Record "Email Message Attachment";
        Base64Convert: Codeunit "Base64 Convert";
        AttachmentOutstream: OutStream;
        NullGuid: Guid;
    begin
        AddAttachment(AttachmentName, ContentType, false, NullGuid, EmailAttachment);
        EmailAttachment.Attachment.CreateOutStream(AttachmentOutstream);
        Base64Convert.FromBase64(AttachmentBase64, AttachmentOutstream);
        EmailAttachment.Insert();
    end;

    procedure AddAttachment(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentInStream: InStream)
    begin
        AddAttachmentInternal(AttachmentName, ContentType, AttachmentInStream);
    end;

    procedure AddAttachmentInternal(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentInStream: InStream) Size: Integer
    var
        EmailAttachment: Record "Email Message Attachment";
        AttachmentOutstream: OutStream;
        NullGuid: Guid;
    begin
        AddAttachment(AttachmentName, ContentType, false, NullGuid, EmailAttachment);
        EmailAttachment.Attachment.CreateOutStream(AttachmentOutstream);
        CopyStream(AttachmentOutstream, AttachmentInStream);
        EmailAttachment.Insert();

        exit(EmailAttachment.Attachment.Length);
    end;

    local procedure ReplaceRgbaColorsWithRgb(var Body: Text)
    var
        RgbaRegexPattern: DotNet Regex;
    begin
        Body := RgbaRegexPattern.Replace(Body, RbgaPatternTok, RgbReplacementTok);
    end;

    local procedure AddAttachment(AttachmentName: Text[250]; ContentType: Text[250]; InLine: Boolean; ContentId: Text[40]; var EmailAttachment: Record "Email Message Attachment")
    begin
        EmailAttachment."Email Message Id" := Message.Id;
        EmailAttachment."Attachment Name" := AttachmentName;
        EmailAttachment."Content Type" := ContentType;
        EmailAttachment.InLine := InLine;
        EmailAttachment."Content Id" := ContentId;
    end;

    procedure GetRecipients(RecipientType: Enum "Email Recipient Type"; var Recipients: list of [Text])
    var
        EmailRecipients: Record "Email Recipient";
    begin
        Clear(Recipients);
        EmailRecipients.SetRange("Email Message Id", Message.Id);
        EmailRecipients.SetRange("Email Recipient Type", RecipientType);
        if not EmailRecipients.FindSet() then
            exit;
        repeat
            Recipients.Add(EmailRecipients."Email Address");
        until EmailRecipients.Next() = 0;
    end;

    procedure GetRecipientsAsText(RecipientType: Enum "Email Recipient Type"): Text
    var
        RecipientList: List of [Text];
        Recipient, Result : Text;
    begin
        GetRecipients(RecipientType, RecipientList);

        foreach Recipient in RecipientList do
            Result := Result + ';' + Recipient;

        Result := DelChr(Result, '<>', ';'); // trim extra semicolons
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
        EmailRecipientRecord.SetRange("Email Message Id", Message.Id);
        EmailRecipientRecord.SetRange("Email Recipient Type", RecipientType);

        if not EmailRecipientRecord.IsEmpty() then
            EmailRecipientRecord.DeleteAll();

        foreach Recipient in Recipients do begin
            Recipient := DelChr(Recipient, '<>'); // trim the whitespaces around
            if Recipient <> '' then
                if UniqueRecipients.Add(Recipient, Recipient) then begin
                    EmailRecipientRecord.Init();
                    EmailRecipientRecord."Email Message Id" := Message.Id;
                    EmailRecipientRecord."Email Recipient Type" := RecipientType;
                    EmailRecipientRecord."Email Address" := CopyStr(Recipient, 1, MaxStrLen(EmailRecipientRecord."Email Address"));

                    EmailRecipientRecord.Insert();
                end;
        end;
    end;

    procedure Attachments_First(): Boolean
    begin
        Attachments.SetRange("Email Message Id", Message.Id);
        exit(Attachments.FindFirst());
    end;

    procedure Attachments_Next(): Integer
    begin
        exit(Attachments.Next());
    end;

    procedure Attachments_GetName(): Text[250]
    begin
        exit(Attachments."Attachment Name");
    end;

    procedure Attachments_GetContent(var InStream: InStream)
    begin
        Attachments.CalcFields(Attachment);
        Attachments.Attachment.CreateInStream(InStream);
    end;

    procedure Attachments_GetContentBase64(): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        InStream: InStream;
    begin
        Attachments.CalcFields(Attachment);
        Attachments.Attachment.CreateInStream(InStream);
        exit(Base64Convert.ToBase64(InStream));
    end;

    procedure Attachments_GetContentType(): Text[250]
    begin
        exit(Attachments."Content Type");
    end;

    procedure Attachments_GetContentId(): Text[40]
    begin
        exit(Attachments."Content Id");
    end;

    procedure Attachments_IsInline(): Boolean
    begin
        exit(Attachments.InLine);
    end;

    procedure Attachments_GetLength(): Integer
    begin
        exit(Attachments.Attachment.Length);
    end;

    procedure GetId(): Guid
    begin
        exit(Message.Id);
    end;

    procedure Get(MessageId: guid): Boolean
    begin
        Clear(Attachments);

        exit(Message.Get(MessageId));
    end;

    procedure ValidateRecipients(RecipientType: Enum "Email Recipient Type")
    var
        Recipients: List of [Text];
    begin
        GetRecipients(RecipientType, Recipients);

        ValidateRecipients(Recipients, RecipientType);
    end;

    procedure ValidateRecipients(Recipients: List of [Text]; RecipientType: Enum "Email Recipient Type")
    var
        EmailAccount: Codeunit "Email Account";
        Recipient: Text;
    begin
        if (RecipientType = RecipientType::"To") and (Recipients.Count() = 0) then
            Error(NoToAccountErr);

        foreach Recipient in Recipients do
            EmailAccount.ValidateEmailAddress(Recipient, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sent Email", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteSentEmail(var Rec: Record "Sent Email"; RunTrigger: Boolean)
    var
        EmailMessage: Record "Email Message";
    begin
        if Rec.IsTemporary() then
            exit;

        if EmailMessage.Get(Rec."Message Id") then
            EmailMessage.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Email Outbox", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteEmailOutbox(var Rec: Record "Email Outbox"; RunTrigger: Boolean)
    var
        SentEmail: Record "Sent Email";
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

        if EmailMessage.Get(Rec."Message Id") then
            EmailMessage.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Email Message", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteEmailMessage(var Rec: Record "Email Message"; RunTrigger: Boolean)
    var
        EmaiMessageAttachemnt: Record "Email Message Attachment";
        EmailRecipient: Record "Email Recipient";
    begin
        if Rec.IsTemporary() then
            exit;

        EmaiMessageAttachemnt.SetRange("Email Message Id", Rec.Id);
        EmaiMessageAttachemnt.DeleteAll();

        EmailRecipient.SetRange("Email Message Id", Rec.Id);
        EmailRecipient.DeleteAll();
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

    local procedure UserHasPermissionToOpenMessage(): Boolean
    var
        SentEmail: Record "Sent Email";
        EmailOutbox: Record "Email Outbox";
    begin
        EmailOutbox.SetRange("Message Id", Message.Id);
        if EmailOutbox.FindFirst() then
            if not (EmailOutbox."User Security Id" = UserSecurityId()) then
                exit(false);

        SentEmail.SetRange("Message Id", Message.Id);
        if SentEmail.FindFirst() then
            if not (SentEmail."User Security Id" = UserSecurityId()) then
                exit(false);

        exit(true);
    end;

    procedure MarkAsReadOnly()
    begin
        if Message.Editable then begin
            Message.Editable := false;
            Message.Modify();
        end;
    end;

    procedure GetEmailMessage(var EmailMessage: Record "Email Message")
    begin
        EmailMessage := Message;
    end;

    var
        Message: Record "Email Message";
        Attachments: Record "Email Message Attachment";
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
        NoToAccountErr: Label 'You must specify a valid email account to send the message to.';
        RgbReplacementTok: Label 'rgb($1, $2, $3)', Locked = true;
        RbgaPatternTok: Label 'rgba\((\d+), ?(\d+), ?(\d+), ?\d+\)', Locked = true;
}
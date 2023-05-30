// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8905 "Email Message Impl."
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;
    Permissions = tabledata "Sent Email" = r,
                  tabledata "Email Outbox" = rim,
                  tabledata "Email Message" = rimd,
                  tabledata "Email Error" = rd,
                  tabledata "Email Recipient" = rid,
                  tabledata "Email Message Attachment" = rid,
                  tabledata "Email Related Record" = rd,
                  tabledata "Tenant Media" = rm,
                  tabledata "Email Attachments" = rimd;

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
                AddAttachment(EmailMessageImpl.Attachments_GetName(), EmailMessageImpl.Attachments_GetContentType(), AttachmentInStream, EmailMessageImpl.Attachments_IsInline(), EmailMessageImpl.Attachments_GetContentId());
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
        Clear(GlobalEmailMessageAttachment);
        Clear(GlobalEmailMessage);

        GlobalEmailMessage.Id := CreateGuid();
        GlobalEmailMessage.Insert();

        UpdateMessage(Recipients, Subject, Body, HtmlFormatted, CCRecipients, BCCRecipients);
    end;

    procedure UpdateMessage(ToRecipients: List of [Text]; Subject: Text; Body: Text; HtmlFormatted: Boolean; CCRecipients: List of [Text]; BCCRecipients: List of [Text])
    begin
        SetBodyValue(Body);
        SetSubjectValue(Subject);
        SetBodyHTMLFormattedValue(HtmlFormatted);
        Modify();

        SetRecipients(Enum::"Email Recipient Type"::"To", ToRecipients);
        SetRecipients(Enum::"Email Recipient Type"::Cc, CCRecipients);
        SetRecipients(Enum::"Email Recipient Type"::Bcc, BCCRecipients);
    end;

    procedure Modify()
    var
        EmailMessage: Record "Email Message";
    begin
        EmailMessage.SetRange(Id, GlobalEmailMessage.Id);
        if not EmailMessage.IsEmpty() then // Don't modify if email message hasn't been inserted
            GlobalEmailMessage.Modify();
    end;

    procedure GetBody() BodyText: Text
    var
        BodyInStream: InStream;
    begin
        GlobalEmailMessage.CalcFields(Body);
        GlobalEmailMessage.Body.CreateInStream(BodyInStream, TextEncoding::UTF8);
        BodyInStream.Read(BodyText);
    end;

    local procedure SetBodyValue(BodyText: Text)
    var
        BodyOutStream: OutStream;
    begin
        Clear(GlobalEmailMessage.Body);

        if BodyText = '' then
            exit;

        ReplaceRgbaColorsWithRgb(BodyText);
        GlobalEmailMessage.Body.CreateOutStream(BodyOutStream, TextEncoding::UTF8);
        BodyOutStream.Write(BodyText);
    end;

    procedure SetBody(BodyText: Text)
    begin
        SetBodyValue(BodyText);
        Modify();
    end;

    procedure AppendToBody(BodyText: Text)
    var
        ExistingBodyText: Text;
    begin
        if BodyText = '' then
            exit;

        ExistingBodyText := GetBody();
        SetBody(ExistingBodyText + BodyText);
    end;

    procedure GetSubject(): Text[2048]
    begin
        exit(GlobalEmailMessage.Subject);
    end;

    local procedure SetSubjectValue(Subject: Text)
    begin
        GlobalEmailMessage.Subject := CopyStr(Subject, 1, MaxStrLen(GlobalEmailMessage.Subject));
    end;

    procedure SetSubject(Subject: Text)
    begin
        SetSubjectValue(Subject);
        Modify();
    end;

    procedure IsBodyHTMLFormatted(): Boolean
    begin
        exit(GlobalEmailMessage."HTML Formatted Body");
    end;

    local procedure SetBodyHTMLFormattedValue(Value: Boolean)
    begin
        GlobalEmailMessage."HTML Formatted Body" := Value;
    end;

    procedure SetBodyHTMLFormatted(Value: Boolean)
    begin
        SetBodyHTMLFormattedValue(Value);
        Modify();
    end;

    procedure IsRead(): Boolean
    begin
        exit(not GlobalEmailMessage.Editable);
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
        InsertAttachment(EmailMessageAttachment, AttachmentInStream, AttachmentName);
    end;

    procedure AddAttachment(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentInStream: InStream)
    begin
        AddAttachmentInternal(AttachmentName, ContentType, AttachmentInStream);
    end;

    procedure AddAttachment(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentInStream: InStream; InLine: Boolean; ContentId: Text[40])
    begin
        AddAttachmentInternal(AttachmentName, ContentType, AttachmentInStream, InLine, ContentId);
    end;

    procedure AddAttachmentInternal(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentInStream: InStream) Size: Integer
    var
        NullGuid: Guid;
    begin
        exit(AddAttachmentInternal(AttachmentName, ContentType, AttachmentInStream, false, NullGuid));
    end;

    procedure AddAttachmentInternal(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentInStream: InStream; InLine: Boolean; ContentId: Text[40]) Size: Integer
    var
        EmailMessageAttachment: Record "Email Message Attachment";
    begin
        AddAttachment(AttachmentName, ContentType, InLine, ContentId, EmailMessageAttachment);
        InsertAttachment(EmailMessageAttachment, AttachmentInStream, '');
        exit(EmailMessageAttachment.Length);
    end;

    local procedure InsertAttachment(var EmailMessageAttachment: Record "Email Message Attachment"; AttachmentInStream: InStream; AttachmentName: Text)
    var
        MediaID: Guid;
    begin
        MediaID := EmailMessageAttachment.Data.ImportStream(AttachmentInStream, AttachmentName, EmailMessageAttachment."Content Type");
        TenantMedia.Get(MediaID);
        TenantMedia.CalcFields(Content);
        EmailMessageAttachment.Length := TenantMedia.Content.Length;
        EmailMessageAttachment.Insert();
        Modify();
    end;

    procedure AddAttachmentsFromScenario(var EmailAttachments: Record "Email Attachments")
    var
        EmailMessageAttachment: Record "Email Message Attachment";
        NullGuid: Guid;
        ContentType: Text[250];
    begin
        if not EmailAttachments.FindSet() then
            exit;
        repeat
            ContentType := GetContentTypeFromFilename(EmailAttachments."Attachment Name");
            AddAttachment(EmailAttachments."Attachment Name", ContentType, false, NullGuid, EmailMessageAttachment);
            InsertAttachmentsFromScenario(EmailMessageAttachment, EmailAttachments);
        until EmailAttachments.Next() = 0;
    end;

    local procedure InsertAttachmentsFromScenario(EmailMessageAttachment: Record "Email Message Attachment"; EmailAttachments: Record "Email Attachments")
    var
        TempBlob: Codeunit "Temp Blob";
        MediaOutStream: OutStream;
        MediaInStream: InStream;
        MediaID: Guid;
    begin
        TempBlob.CreateOutStream(MediaOutStream, TextEncoding::UTF8);
        EmailAttachments."Email Attachment".ExportStream(MediaOutStream);

        TempBlob.CreateInStream(MediaInStream, TextEncoding::UTF8);
        EmailMessageAttachment.Data.ImportStream(MediaInStream, EmailAttachments."Attachment Name");

        MediaID := EmailMessageAttachment.Data.MediaId();
        TenantMedia.Get(MediaID);
        TenantMedia.CalcFields(Content);
        EmailMessageAttachment.Length := TenantMedia.Content.Length;
        EmailMessageAttachment.Insert();
    end;

    local procedure ReplaceRgbaColorsWithRgb(var Body: Text)
    var
        RgbaRegexPattern: DotNet Regex;
    begin
        Body := RgbaRegexPattern.Replace(Body, RbgaPatternTok, RgbReplacementTok);
    end;

    local procedure AddAttachment(AttachmentName: Text[250]; ContentType: Text[250]; InLine: Boolean; ContentId: Text[40]; var EmailMessageAttachment: Record "Email Message Attachment")
    begin
        EmailMessageAttachment."Email Message Id" := GlobalEmailMessage.Id;
        EmailMessageAttachment."Attachment Name" := AttachmentName;
        EmailMessageAttachment."Content Type" := ContentType;
        EmailMessageAttachment.InLine := InLine;
        EmailMessageAttachment."Content Id" := ContentId;
    end;

    procedure GetRecipients(): List of [Text]
    var
        EmailRecipients: Record "Email Recipient";
    begin
        EmailRecipients.SetRange("Email Message Id", GlobalEmailMessage.Id);
        exit(GetEmailAddressesOfRecipients(EmailRecipients));
    end;

    procedure GetRecipients(RecipientType: Enum "Email Recipient Type"): List of [Text]
    var
        EmailRecipients: Record "Email Recipient";
    begin
        EmailRecipients.SetRange("Email Message Id", GlobalEmailMessage.Id);
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
        EmailRecipientRecord.SetRange("Email Message Id", GlobalEmailMessage.Id);
        EmailRecipientRecord.SetRange("Email Recipient Type", RecipientType);

        if not EmailRecipientRecord.IsEmpty() then
            EmailRecipientRecord.DeleteAll();

        foreach Recipient in Recipients do begin
            Recipient := DelChr(Recipient, '<>'); // trim the whitespaces around
            if Recipient <> '' then
                if UniqueRecipients.Add(Recipient.ToLower(), Recipient) then begin // Set the recipient key to lowercase to prevent duplicates
                    EmailRecipientRecord.Init();
                    EmailRecipientRecord."Email Message Id" := GlobalEmailMessage.Id;
                    EmailRecipientRecord."Email Recipient Type" := RecipientType;
                    EmailRecipientRecord."Email Address" := CopyStr(Recipient, 1, MaxStrLen(EmailRecipientRecord."Email Address"));

                    EmailRecipientRecord.Insert();
                end;
        end;
        Modify();
    end;

    procedure AddRecipient(RecipientType: Enum "Email Recipient Type"; Recipient: Text)
    var
        Recipients: List of [Text];
    begin
        Recipient := DelChr(Recipient, '<>'); // trim the whitespaces around

        if Recipient = '' then
            exit;

        Recipient := Recipient.ToLower();

        Recipients := GetRecipients(RecipientType);

        if Recipients.Contains(Recipient) then
            exit;

        Recipients.Add(Recipient);
        SetRecipients(RecipientType, Recipients);
    end;

    procedure Attachments_DeleteContent(): Boolean
    var
        MediaId: Guid;
    begin
        MediaId := GlobalEmailMessageAttachment.Data.MediaId();
        TenantMedia.Get(MediaID);
        Clear(TenantMedia.Content);
        TenantMedia.Modify();
        Modify();
        exit(not TenantMedia.Content.HasValue());
    end;

    procedure Attachments_First(): Boolean
    begin
        GlobalEmailMessageAttachment.SetRange("Email Message Id", GlobalEmailMessage.Id);
        exit(GlobalEmailMessageAttachment.FindFirst());
    end;

    procedure Attachments_Next(): Integer
    begin
        GlobalEmailMessageAttachment.SetRange("Email Message Id", GlobalEmailMessage.Id);
        exit(GlobalEmailMessageAttachment.Next());
    end;

    procedure Attachments_GetName(): Text[250]
    begin
        exit(GlobalEmailMessageAttachment."Attachment Name");
    end;

    procedure Attachments_GetContent(var InStream: InStream)
    var
        EmailMessage: Codeunit "Email Message";
        MediaID: Guid;
        Handled: Boolean;
    begin
        MediaID := GlobalEmailMessageAttachment.Data.MediaId();
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
        exit(GlobalEmailMessageAttachment."Content Type");
    end;

    procedure Attachments_GetContentId(): Text[40]
    begin
        exit(GlobalEmailMessageAttachment."Content Id");
    end;

    procedure Attachments_IsInline(): Boolean
    begin
        exit(GlobalEmailMessageAttachment.InLine);
    end;

    procedure Attachments_GetLength(): Integer
    begin
        exit(GlobalEmailMessageAttachment.Length);
    end;

    procedure GetRelatedAttachments(var EmailRelatedAttachments: Record "Email Related Attachment"): Boolean
    begin
        exit(GetRelatedAttachments(GlobalEmailMessage.Id, EmailRelatedAttachments));
    end;

    procedure GetRelatedAttachments(EmailMessageId: Guid; var EmailRelatedAttachmentOut: Record "Email Related Attachment"): Boolean
    var
        EmailRelatedAttachment: Record "Email Related Attachment";
        EmailRelatedRecord: Record "Email Related Record";
        Email: Codeunit "Email";
        EmailImpl: Codeunit "Email Impl";
    begin
        EmailRelatedRecord.SetRange("Email Message Id", EmailMessageId);
        EmailImpl.FilterRemovedSourceRecords(EmailRelatedRecord);

        if not EmailRelatedRecord.FindSet() then
            exit(false);

        repeat
            Email.OnFindRelatedAttachments(EmailRelatedRecord."Table Id", EmailRelatedRecord."System Id", EmailRelatedAttachment);
            if EmailRelatedAttachment.FindSet() then
                InsertRelatedAttachments(EmailRelatedRecord."Table Id", EmailRelatedRecord."System Id", EmailRelatedAttachment, EmailRelatedAttachmentOut);
            EmailRelatedAttachment.DeleteAll();
        until EmailRelatedRecord.Next() = 0;

        exit(true);
    end;

    procedure GetId(): Guid
    begin
        exit(GlobalEmailMessage.Id);
    end;

    procedure Get(MessageId: guid): Boolean
    begin
        Clear(GlobalEmailMessageAttachment);

        exit(GlobalEmailMessage.Get(MessageId));
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

    procedure GetNoOfModifies(): Integer
    begin
        exit(GlobalEmailMessage."No. of Modifies");
    end;

    local procedure InsertRelatedAttachments(TableID: Integer; SystemID: Guid; var EmailRelatedAttachment2: Record "Email Related Attachment"; var EmailRelatedAttachment: Record "Email Related Attachment")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.Open(TableID);
        if not RecordRef.GetBySystemId(SystemID) then begin
            Session.LogMessage('0000CTZ', StrSubstNo(RecordNotFoundMsg, TableID), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
            exit;
        end;

        repeat
            EmailRelatedAttachment.Copy(EmailRelatedAttachment2);
            EmailRelatedAttachment."Attachment Source" := CopyStr(Format(RecordRef.RecordId(), 0, 1), 1, MaxStrLen(EmailRelatedAttachment."Attachment Source"));
            EmailRelatedAttachment.Insert();
        until EmailRelatedAttachment2.Next() = 0;
    end;

    // Used for formatting a filesize in KB or MB (only)
    internal procedure FormatFileSize(SizeInBytes: Integer): Text
    var
        FileSizeConverted: Decimal;
        FileSizeUnit: Text;
    begin
        FileSizeConverted := SizeInBytes / 1024; // The smallest size we show is KB
        if FileSizeConverted < 1024 then
            FileSizeUnit := 'KB'
        else begin
            FileSizeConverted := FileSizeConverted / 1024; // The largest size we show is MB
            FileSizeUnit := 'MB'
        end;
        exit(StrSubstNo(FileSizeTxt, Round(FileSizeConverted, 1, '>'), FileSizeUnit));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sent Email", OnAfterDeleteEvent, '', false, false)]
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

    [EventSubscriber(ObjectType::Table, Database::"Email Outbox", OnAfterDeleteEvent, '', false, false)]
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

    [EventSubscriber(ObjectType::Table, Database::"Email Message", OnBeforeDeleteEvent, '', false, false)]
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

    [EventSubscriber(ObjectType::Table, Database::"Email Message", OnBeforeModifyEvent, '', false, false)]
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

        Rec."No. of Modifies" += 1;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Email Message Attachment", OnBeforeDeleteEvent, '', false, false)]
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

    [EventSubscriber(ObjectType::Table, Database::"Email Recipient", OnBeforeDeleteEvent, '', false, false)]
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

    [EventSubscriber(ObjectType::Table, Database::"Email Message Attachment", OnBeforeInsertEvent, '', false, false)]
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

    [EventSubscriber(ObjectType::Table, Database::"Email Recipient", OnBeforeInsertEvent, '', false, false)]
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
        if GlobalEmailMessage.Editable then begin
            GlobalEmailMessage.Editable := false;
            GlobalEmailMessage.Modify();
        end;
    end;

    procedure GetEmailMessage(var EmailMessage: Record "Email Message")
    begin
        EmailMessage := GlobalEmailMessage;
    end;

    var
        GlobalEmailMessage: Record "Email Message";
        GlobalEmailMessageAttachment: Record "Email Message Attachment";
        TenantMedia: Record "Tenant Media";
        EmailCategoryLbl: Label 'Email', Locked = true;
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
        RecordNotFoundMsg: Label 'Record not found in table: %1', Comment = '%1 - File size', Locked = true;
        RgbReplacementTok: Label 'rgb($1, $2, $3)', Locked = true;
        RbgaPatternTok: Label 'rgba\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3}),\s*1(\.0{0,2})?\)', Locked = true;
        FileSizeTxt: Label '%1 %2', Comment = '%1 = File Size, %2 = Unit of measurement', Locked = true;
}
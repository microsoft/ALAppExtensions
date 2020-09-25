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
                  tabledata "Email Error" = d,
                  tabledata "Email Recipient" = rid,
                  tabledata "Email Message Attachment" = rid;

    procedure CreateMessage(Recipients: List of [Text]; Subject: Text; Body: Text; HtmlFormatted: Boolean)
    var
        EmptyList: List of [Text];
    begin
#pragma warning disable AA0205
        CreateMessage(Recipients, Subject, Body, HtmlFormatted, EmptyList, EmptyList);
#pragma warning restore AA0205
    end;

    procedure CreateMessage(Recipients: List of [Text]; Subject: Text; Body: Text; HtmlFormatted: Boolean; CCRecipients: List of [Text]; BCCRecipients: List of [Text])
    begin
        CreateMessage(Recipients, Subject, Body, HtmlFormatted, CCRecipients, BCCRecipients, CreateGuid());
    end;

    procedure CreateMessage(Recipients: List of [Text]; Subject: Text; Body: Text; HtmlFormatted: Boolean; CCRecipients: List of [Text]; BCCRecipients: List of [Text]; Id: Guid)
    begin
        Clear(Attachments);
        Clear(Message);
        Message.Id := Id;
        Message.Editable := true;
        Message.Insert();

        UpdateMessage(Recipients, Subject, Body, HtmlFormatted, CCRecipients, BCCRecipients);
    end;

    procedure UpdateMessage(Recipients: List of [Text]; Subject: Text; Body: Text; HtmlFormatted: Boolean; CCRecipients: List of [Text]; BCCRecipients: List of [Text])
    var
        EmailRecipient: Record "Email Recipient";
        EmailRecipientType: Enum "Email Recipient Type";
        Recipient: Text;
        BodyOutStream: OutStream;
        FailedToReplaceInLineImagesErr: Label 'Failed to replace inline images message (XmlDocument.ReadFrom failed).', Locked = true;
    begin
        if HtmlFormatted then
            if not ReplaceInLineImagesWithAttachements(Body) then
                Session.LogMessage('0000CTW', FailedToReplaceInLineImagesErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);

        Message.Body.CreateOutStream(BodyOutStream, TextEncoding::UTF8);
        BodyOutStream.Write(Body);
        Message.Subject := CopyStr(Subject, 1, MaxStrLen(Message.Subject));
        Message."HTML Formatted Body" := HtmlFormatted;
        Message.Modify();

        EmailRecipient.SetRange("Email Message Id", Message.Id);
        if not EmailRecipient.IsEmpty() then
            EmailRecipient.DeleteAll();

        foreach Recipient in Recipients do begin
            EmailRecipient.Init();
            EmailRecipient."Email Message Id" := Message.Id;
            EmailRecipient."Email Recipient Type" := EmailRecipientType::"To";
            EmailRecipient."Email Address" := CopyStr(Recipient, 1, MaxStrLen(EmailRecipient."Email Address"));
            EmailRecipient.Insert();
        end;

        foreach Recipient in CCRecipients do begin
            EmailRecipient.Init();
            EmailRecipient."Email Message Id" := Message.Id;
            EmailRecipient."Email Recipient Type" := EmailRecipientType::Cc;
            EmailRecipient."Email Address" := CopyStr(Recipient, 1, MaxStrLen(EmailRecipient."Email Address"));
            EmailRecipient.Insert();
        end;

        foreach Recipient in BCCRecipients do begin
            EmailRecipient.Init();
            EmailRecipient."Email Message Id" := Message.Id;
            EmailRecipient."Email Recipient Type" := EmailRecipientType::Bcc;
            EmailRecipient."Email Address" := CopyStr(Recipient, 1, MaxStrLen(EmailRecipient."Email Address"));
            EmailRecipient.Insert();
        end;
    end;

    procedure GetBody() BodyText: Text
    var
        BodyInStream: InStream;
    begin
        Message.CalcFields(Body);
        Message.Body.CreateInStream(BodyInStream, TextEncoding::UTF8);
        BodyInStream.Read(BodyText);
    end;

    procedure GetSubject(): Text[2048]
    begin
        exit(Message.Subject);
    end;

    procedure IsBodyHTMLFormatted(): Boolean
    begin
        exit(Message."HTML Formatted Body");
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

    procedure ReplaceInLineImagesWithAttachements(var Body: Text): Boolean
    var
        Base64ImgRegexPattern: DotNet Regex;
        Document: XmlDocument;
        ReadOptions: XmlReadOptions;
        WriteOptions: XmlWriteOptions;
        ImageElements: XmlNodeList;
        ImageElement: XmlNode;
        ImageElementAttribute: XmlAttribute;
        Base64ImgMatch: DotNet Match;
        String: DotNet String;
        Filename: Text[250];
        DocumentSource: Text;
        ImageElementValue: Text;
        Base64Img: Text;
        MediaType: Text;
        MediaSubtype: Text;
        ContentId: Text[40];
        ImageElementAttributeLbl: Label 'cid:%1', Comment = '%1 - Content Id', Locked = true;
    begin
        if Body = '' then
            exit(true);

        ReadOptions.PreserveWhitespace(true);

        if not XmlDocument.ReadFrom(Body, ReadOptions, Document) then
            exit(false);

        // Get all <img> elements
        ImageElements := Document.GetDescendantElements('img');

        if ImageElements.Count() = 0 then
            exit(true); // No images to convert

        Base64ImgRegexPattern := Base64ImgRegexPattern.Regex('data:(.*);base64,(.*)');
        foreach ImageElement in ImageElements do
            if ImageElement.AsXmlElement().Attributes().Get('src', ImageElementAttribute) then begin
                ImageElementValue := ImageElementAttribute.Value();
                Base64ImgMatch := Base64ImgRegexPattern.Match(ImageElementValue);

                if not String.IsNullOrEmpty(Base64ImgMatch.Value) then begin
                    MediaType := Base64ImgMatch.Groups.Item(1).Value();
                    MediaSubtype := MediaType.Split('/').Get(2);
                    Base64Img := Base64ImgMatch.Groups.Item(2).Value();

                    ContentId := CopyStr(Format(CreateGuid(), 0, 3), 1, 40);
                    Filename := CopyStr(ContentId + '.' + MediaSubtype, 1, 250);

                    AddInLineAttachment(Filename, CopyStr(MediaType, 1, 250), ContentId, Base64Img);
                    ImageElementAttribute.Value(StrSubstNo(ImageElementAttributeLbl, ContentId));
                end;
            end;
        WriteOptions.PreserveWhitespace(true);
        Document.WriteTo(WriteOptions, DocumentSource);
        Body := DocumentSource;
        exit(true);
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
    var
        EmailAttachment: Record "Email Message Attachment";
        AttachmentOutstream: OutStream;
        NullGuid: Guid;
    begin
        AddAttachment(AttachmentName, ContentType, false, NullGuid, EmailAttachment);
        EmailAttachment.Attachment.CreateOutStream(AttachmentOutstream);
        CopyStream(AttachmentOutstream, AttachmentInStream);
        EmailAttachment.Insert();
    end;

    local procedure AddInLineAttachment(AttachmentName: Text[250]; ContentType: Text[250]; ContentId: Text[40]; AttachmentBase64: Text)
    var
        EmailAttachment: Record "Email Message Attachment";
        Base64Convert: Codeunit "Base64 Convert";
        AttachmentOutstream: OutStream;
    begin
        AddAttachment(AttachmentName, ContentType, true, ContentId, EmailAttachment);
        EmailAttachment.Attachment.CreateOutStream(AttachmentOutstream);
        Base64Convert.FromBase64(AttachmentBase64, AttachmentOutstream);
        EmailAttachment.Insert();
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

    procedure UpdateRecipients(Recipients: list of [Text]; CcRecipients: list of [Text]; BccRecipients: list of [Text])
    var
        EmailRecipients: Record "Email Recipient";
        Recipient: Text;
    begin
        EmailRecipients.SetRange("Email Message Id", Message.Id);
        if not EmailRecipients.IsEmpty() then
            EmailRecipients.DeleteAll();

        foreach Recipient in Recipients do begin
            EmailRecipients.Init();
            EmailRecipients."Email Message Id" := Message.Id;
            EmailRecipients."Email Recipient Type" := Enum::"Email Recipient Type"::"To";
            EmailRecipients."Email Address" := CopyStr(Recipient, 1, MaxStrLen(EmailRecipients."Email Address"));
            EmailRecipients.Insert();
        end;

        foreach Recipient in CcRecipients do begin
            EmailRecipients.Init();
            EmailRecipients."Email Message Id" := Message.Id;
            EmailRecipients."Email Recipient Type" := Enum::"Email Recipient Type"::Cc;
            EmailRecipients."Email Address" := CopyStr(Recipient, 1, MaxStrLen(EmailRecipients."Email Address"));
            EmailRecipients.Insert();
        end;

        foreach Recipient in BccRecipients do begin
            EmailRecipients.Init();
            EmailRecipients."Email Message Id" := Message.Id;
            EmailRecipients."Email Recipient Type" := Enum::"Email Recipient Type"::Bcc;
            EmailRecipients."Email Address" := CopyStr(Recipient, 1, MaxStrLen(EmailRecipients."Email Address"));
            EmailRecipients.Insert();
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

    procedure Find(MessageId: guid): Boolean
    begin
        Clear(Attachments);
        Message.SetRange(Id, MessageId);
        exit(Message.Get(MessageId));
    end;

    procedure OpenNewEditableCopyInEditor(AccountId: guid; Connector: Enum "Email Connector")
    var
        EmailRecipient: Record "Email Recipient";
        CopyEmailRecipient: Record "Email Recipient";
        EmailMessageAttachments: Record "Email Message Attachment";
        EmailMessage: Record "Email Message";
        TempEmailAccounts: Record "Email Account" temporary;
        EmailEditor: Page "Email Editor";
        EmailConnectorInterface: Interface "Email Connector";
        InStream: InStream;
    begin
        if not UserHasPermissionToOpenMessage() then
            Error(EmailMessageOpenPermissionErr);

        Message.CalcFields(Body);
        EmailMessage.Copy(Message);
        EmailMessage.Editable := true;
        EmailMessage.Id := CreateGuid();
        EmailMessage.Insert();

        // Copy recipients
        EmailRecipient.SetRange("Email Message Id", Message.Id);
        if EmailRecipient.FindSet() then
            repeat
                CopyEmailRecipient.Copy(EmailRecipient);
                CopyEmailRecipient."Email Message Id" := EmailMessage.Id;
                CopyEmailRecipient.Insert();
            until EmailRecipient.Next() = 0;

        // Copy attachments
        EmailMessageAttachments.SetRange("Email Message Id", Message.Id);
        if EmailMessageAttachments.FindSet() then begin
            Message := EmailMessage;
            repeat
                EmailMessageAttachments.CalcFields(Attachment);
                EmailMessageAttachments.Attachment.CreateInStream(InStream);
                AddAttachment(EmailMessageAttachments."Attachment Name", EmailMessageAttachments."Content Type", InStream);
            until EmailMessageAttachments.Next() = 0;
        end;

        EmailConnectorInterface := Connector;
        EmailConnectorInterface.GetAccounts(TempEmailAccounts);
        TempEmailAccounts.SetRange("Account Id", AccountId);
        if TempEmailAccounts.FindFirst() then;

        Message.CalcFields(Body);
        EmailEditor.SetRecord(EmailMessage);
        EmailEditor.SetEmailAccount(TempEmailAccounts);
        EmailEditor.Run()
    end;

    procedure OpenInEditor()
    var
        TempDummyEmailAccounts: Record "Email Account" temporary;
        WasEmailSent: Boolean;
    begin
        OpenInEditor(TempDummyEmailAccounts, false, WasEmailSent);
    end;

    procedure OpenInEditor(AccountId: guid)
    var
        TempEmailAccounts: Record "Email Account" temporary;
        EmailAccount: Codeunit "Email Account";
        WasEmailSent: Boolean;
    begin
        EmailAccount.GetAllAccounts(false, TempEmailAccounts);
        TempEmailAccounts.SetRange("Account Id", AccountId);
        if TempEmailAccounts.FindFirst() then;

        OpenInEditor(TempEmailAccounts, false, WasEmailSent);
    end;

    procedure OpenInEditor(AccountId: guid; Connector: Enum "Email Connector")
    begin
        OpenInEditor(AccountId, Connector, 0);
    end;

    procedure OpenInEditor(AccountId: Guid; Connector: Enum "Email Connector"; OutboxId: BigInteger)
    var
        TempEmailAccounts: Record "Email Account" temporary;
        IConnector: Interface "Email Connector";
        WasEmailSent: Boolean;
    begin
        IConnector := Connector;
        IConnector.GetAccounts(TempEmailAccounts);
        TempEmailAccounts.SetRange("Account Id", AccountId);
        if TempEmailAccounts.FindFirst() then
            TempEmailAccounts.Connector := Connector;

        OpenInEditor(TempEmailAccounts, false, OutboxId, WasEmailSent);
    end;

    procedure OpenInEditor(TempAccount: Record "Email Account" temporary; IsModal: Boolean; var WasEmailSent: Boolean)
    begin
        OpenInEditor(TempAccount, IsModal, 0, WasEmailSent);
    end;

    procedure OpenInEditor(TempAccount: Record "Email Account" temporary; IsModal: Boolean; OutboxId: BigInteger; var WasEmailSent: Boolean)
    var
        EmailOutbox: Record "Email Outbox";
        EmailEditor: Page "Email Editor";
    begin
        if not Message.Get(Message.Id) then begin
            Message(MessageNoLongerAvailableErr);
            exit;
        end;

        if not UserHasPermissionToOpenMessage() then
            Error(EmailMessageOpenPermissionErr);

        if EmailOutbox.Get(OutboxId) then
            EmailEditor.SetOutbox(EmailOutbox);

        Message.CalcFields(Body);
        EmailEditor.SetRecord(Message);
        EmailEditor.SaveRecord();

        if not IsNullGuid(TempAccount."Account Id") then
            EmailEditor.SetEmailAccount(TempAccount);

        if Message.Subject <> '' then
            EmailEditor.Caption(Message.Subject);

        if IsModal then
            EmailEditor.RunModal()
        else
            EmailEditor.Run();

        WasEmailSent := EmailEditor.WasEmailSent();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sent Email", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteSentEmail(var Rec: Record "Sent Email"; RunTrigger: Boolean)
    var
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
        EmailMessage: Record "Email Message";
    begin
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
    local procedure OnBeforeDeleteEmailOutbox(var Rec: Record "Email Outbox"; RunTrigger: Boolean)
    var
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
        EmailMessage: Record "Email Message";
        EmailError: Record "Email Error";
    begin
        EmailError.SetRange("Outbox Id", Rec.Id);
        EmailError.DeleteAll(true);

        SentEmail.SetRange("Message Id", Rec."Message Id");
        if not SentEmail.IsEmpty() then
            exit;

        EmailOutbox.SetRange("Message Id", Rec."Message Id");
        if not EmailOutbox.IsEmpty then
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
        if Rec.IsTemporary then
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
        if Rec.IsTemporary then
            exit;
        EmailOutbox.SetRange("Message Id", Rec.Id);
        EmailOutbox.SetFilter(Status, '%1|%2', EmailOutbox.Status::Queued, EmailOutbox.Status::Processing);
        if not EmailOutbox.IsEmpty() then
            Error(EmailMessageQueuedCannotModifyErr);

        if EmailMessageOld.Get(Rec.Id) and not EmailMessageOld.Editable then
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
        if Rec.IsTemporary then
            exit;

        EmailOutbox.SetRange("Message Id", Rec."Email Message Id");
        EmailOutbox.SetFilter(Status, '%1|%2', EmailOutbox.Status::Queued, EmailOutbox.Status::Processing);
        if not EmailOutbox.IsEmpty() then
            Error(EmailMessageQueuedCannotInsertRecipientErr);

        SentEmail.SetRange("Message Id", Rec."Email Message Id");
        if not SentEmail.IsEmpty() then
            Error(EmailMessageSentCannotInsertRecipientErr);
    end;

    procedure UploadAttachmentEditorAction(MessageId: guid)
    var
        EmailMessageAttachment: Record "Email Message Attachment";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        FileName: Text;
        Instream: Instream;
        OutStream: OutStream;
    begin
        EmailMessageAttachment.Init();
        EmailMessageAttachment."Email Message Id" := MessageId;
        if not UploadIntoStream('', '', '', FileName, Instream) then
            exit;

        EmailMessageAttachment."Attachment Name" := CopyStr(FileName, 1, 250);
        EmailMessageAttachment."Content Type" := EmailMessageImpl.GetContentTypeFromFilename(Filename);
        EmailMessageAttachment.Attachment.CreateOutStream(OutStream);
        CopyStream(OutStream, Instream);
        EmailMessageAttachment.Insert();

        Session.LogMessage('0000CTX', StrSubstNo(UploadingAttachmentMsg, EmailMessageAttachment.Attachment.Length, EmailMessageAttachment."Content Type"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
    end;

    procedure InsertOutboxFromEditor(Account: Record "Email Account")
    var
        EmailOutbox: Record "Email Outbox";
    begin
        EmailOutbox.Init();
        EmailOutbox."Message Id" := Message.Id;
        EmailOutbox.Description := Message.Subject;
        EmailOutbox.Connector := Account.Connector;
        EmailOutbox."Account Id" := Account."Account Id";
        EmailOutbox.Status := Enum::"Email Status"::Draft;
        EmailOutbox."User Security Id" := UserSecurityId();
        EmailOutbox."Send From" := Account."Email Address";
        EmailOutbox.Insert();
    end;

    procedure UpdateOutboxFromEditor(EmailOutBox: Record "Email Outbox"; Account: Record "Email Account")
    begin
        if not EmailOutbox.Find() then
            exit;
        EmailOutbox.Description := Message.Subject;
        EmailOutbox."Account Id" := Account."Account Id";
        EmailOutbox.Connector := Account.Connector;
        EmailOutbox."Send From" := Account."Email Address";
        EmailOutbox.Modify();
    end;

    procedure CreateOrUpdateMessageFromEditor(ToRecipient: Text; CcRecipient: Text; BccRecipient: Text; Subject: Text; Body: Text; HtmlFormatted: Boolean; MessageId: guid)
    var
        Recipients: List of [Text];
        CcRecipients: List of [Text];
        BccRecipients: List of [Text];
    begin
        ConvertRecipientsToLists(ToRecipient, CcRecipient, BccRecipient, Recipients, CcRecipients, BccRecipients);

        if Message.Id = MessageId then
            UpdateMessage(Recipients, Subject, Body, HtmlFormatted, CcRecipients, BccRecipients)
        else
            CreateMessage(Recipients, Subject, Body, HtmlFormatted, CcRecipients, BccRecipients, MessageId)
    end;

    local procedure ConvertRecipientsToLists(ToRecipient: Text; CcRecipient: Text; BccRecipient: Text; var Recipients: List of [Text]; var CcRecipients: List of [Text]; var BccRecipients: List of [Text])
    begin
        // Remove the separator from the start and the end
        ToRecipient := DelChr(ToRecipient, '<>', ';');
        if ToRecipient <> '' then
            Recipients.AddRange(ToRecipient.Split(';'));

        CcRecipient := DelChr(CcRecipient, '<>', ';');
        if CcRecipient <> '' then
            CcRecipients.AddRange(CcRecipient.Split(';'));

        BccRecipient := DelChr(BccRecipient, '<>', ';');
        if BccRecipient <> '' then
            BccRecipients.AddRange(BccRecipient.Split(';'));
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

    procedure LockEmailMessage()
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
        MessageNoLongerAvailableErr: Label 'The email message is no longer available.';
        EmailMessageOpenPermissionErr: Label 'You can only open your own email messages.';
        EmailCategoryLbl: Label 'Email', Locked = true;
        UploadingAttachmentMsg: Label 'Sending email with attachment file size: %1, Content type: %2', Comment = '%1 - File size, %2 - Content type', Locked = true;
}
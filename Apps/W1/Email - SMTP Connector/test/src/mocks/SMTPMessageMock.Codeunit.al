// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139758 "SMTP Message Mock"
{
    Access = Internal;
    SingleInstance = true;

    var
        SMTPAccount: Record "SMTP Account";
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        EmailMimeMessage: DotNet MimeMessage;
        Subject: Text;
        Body: Text;
        HTMLFormatted: Boolean;
        ToRecipients: List of [Text];
        CcRecipients: List of [Text];
        BccRecipients: List of [Text];
        AttachmentNames: List of [Text];

    procedure CreateEmailMessage(SMTPAccountId: Guid; var EmailMessage: Codeunit "Email Message")
    begin
        CreateEmailMessage(SMTPAccountId, 'Basic Subject', '<p>Basic Body</p>', true, EmailMessage);
    end;

    procedure CreateEmailMessage(SMTPAccountId: Guid; SubjectValue: Text; BodyValue: Text; HTML: Boolean; var EmailMessage: Codeunit "Email Message")
    begin
        SMTPAccount.Get(SMTPAccountId);

        Subject := SubjectValue;
        Body := BodyValue;
        HTMLFormatted := HTML;

#pragma warning disable AA0205
        EmailMessage.Create(ToRecipients, Subject, Body, HTMLFormatted, CcRecipients, BccRecipients);
#pragma warning restore AA0205
        AddAttachmentsBase64(EmailMessage, 1, AttachmentNames);
        AddAttachmentsStream(EmailMessage, 1, AttachmentNames);
    end;

    procedure AddAttachmentsStream(EmailMessage: Codeunit "Email Message"; NoOfAttachments: Integer; var AttachmentNames: List of [Text])
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
        AttachmentName: Text[250];
        Index: Integer;
    begin
        for Index := 1 to NoOfAttachments do begin
            AttachmentName := CopyStr(Any.AlphabeticText(246), 1, 246) + '.txt';
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(AttachmentName);
            TempBlob.CreateInStream(InStream);
            EmailMessage.AddAttachment(AttachmentName, 'Text', InStream);
            AttachmentNames.Add(AttachmentName);
        end;
    end;

    procedure AddAttachmentsBase64(EmailMessage: Codeunit "Email Message"; NoOfAttachments: Integer; var AttachmentNames: List of [Text])
    var
        Base64: Codeunit "Base64 Convert";
        AttachmentName: Text[250];
        Base64Name: Text;
        Index: Integer;
    begin
        for Index := 1 to NoOfAttachments do begin
            AttachmentName := CopyStr(Any.AlphabeticText(246), 1, 246) + '.txt';
            Base64Name := Base64.ToBase64(AttachmentName);
            EmailMessage.AddAttachment(AttachmentName, 'Text', Base64Name);
            AttachmentNames.Add(AttachmentName);
        end;
    end;

    procedure GetMessage(EmailMessage: Codeunit "Email Message"; AccountId: Guid; var Message: Codeunit "SMTP Message")
    begin
        SMTPAccount.Get(AccountId);

        Message.Initialize();
        Message.BuildMessage(EmailMessage, SMTPAccount);
        Message.GetMessage(EmailMimeMessage);
    end;

    procedure VerifyEmail()
    var
        Attachment: DotNet MimePart;
    begin
        ValidateFrom(SMTPAccount."Sender Name", SMTPAccount."Email Address", EmailMimeMessage.From);
        ValidateRecipients(ToRecipients, EmailMimeMessage."To");
        ValidateRecipients(CcRecipients, EmailMimeMessage."CC");
        ValidateRecipients(BccRecipients, EmailMimeMessage."Bcc");
        ValidateSubject(Subject, EmailMimeMessage.Subject());
        if HTMLFormatted then
            ValidateBody(Body, EmailMimeMessage.HtmlBody().ToString())
        else
            ValidateBody(Body, EmailMimeMessage.Body().ToString());

        foreach Attachment in EmailMimeMessage.Attachments do
            ValidateAttachment(Attachment, AttachmentNames);
    end;

    local procedure ValidateFrom(FromName: Text; FromAddress: Text; FromList: DotNet InternetAddressList)
    var
        Mailbox: DotNet MimeMailboxAddress;
    begin
        Assert.AreEqual(1, FromList.Count(), 'The number of from address(es) is not correct.');

        Mailbox := FromList.Item(0);
        Assert.AreEqual(FromName, Mailbox.Name, 'The name is incorrect.');
        Assert.AreEqual(FromAddress, Mailbox.Address, 'The email address is incorrect.');
    end;

    local procedure ValidateRecipients(Recipients: List of [Text]; AddressList: DotNet InternetAddressList)
    var
        Mailbox: DotNet MimeMailboxAddress;
    begin
        foreach Mailbox in AddressList do
            Assert.IsTrue(Recipients.Contains(Mailbox.Address), 'Recipient does not exist.');
    end;

    local procedure ValidateSubject(RecordSubject: Text; SentSubject: Text)
    begin
        Assert.AreEqual(RecordSubject, SentSubject, 'The subject is incorrect.');
    end;

    local procedure ValidateBody(RecordBody: Text; SentBody: Text)
    begin
        Assert.AreEqual(RecordBody, SentBody, 'The body is incorrect.');
    end;

    local procedure ValidateAttachment(Attachment: DotNet MimePart; AttachmentNames: List of [Text])
    var
        TempBlob: Codeunit "Temp Blob";
        Content: DotNet MimeContentObject;
        OutStream: OutStream;
        InStream: Instream;
        Value: Text;
    begin
        Content := Attachment.Content;
        TempBlob.CreateOutStream(OutStream);
        CopyStream(OutStream, Content.Stream);
        TempBlob.CreateInStream(InStream);
        Instream.ReadText(Value);

        Assert.AreNotEqual(0, AttachmentNames.IndexOf(Attachment.FileName), 'The attachment does not exist.');
        Assert.AreNotEqual(0, AttachmentNames.IndexOf(Value), 'The attachment content does not exist.');
    end;
}
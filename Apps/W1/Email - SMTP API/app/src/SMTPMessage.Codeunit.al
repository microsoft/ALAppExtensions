// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4613 "SMTP Message"
{
    Access = Public;

    var
        SMTPMessageImpl: Codeunit "SMTP Message Impl";

    /// <summary>
    /// Add the name and email address the message is being sent from.
    /// </summary>
    /// <param name="Name">The name of the sender</param>
    /// <param name="Address">The email address the message is sent from.</param>
    procedure AddFrom(Name: Text; Address: Text)
    begin
        SMTPMessageImpl.AddFrom(Name, Address);
    end;

    /// <summary>
    /// Adds the recipients that this email is being sent to.
    /// </summary>
    /// <param name="Recipients">The direct recipient(s)</param>
    procedure SetToRecipients(Recipients: List of [Text])
    begin
        SMTPMessageImpl.SetToRecipients(Recipients);
    end;

    /// <summary>
    /// Adds the cc recipients that this email is being sent to.
    /// </summary>
    /// <param name="Recipients">The cc recipient(s)</param>
    procedure SetCCRecipients(Recipients: List of [Text])
    begin
        SMTPMessageImpl.SetCCRecipients(Recipients);
    end;

    /// <summary>
    /// Adds the bcc recipients that this email is being sent to.
    /// </summary>
    /// <param name="Recipients">The bcc recipient(s)</param>
    procedure SetBCCRecipients(Recipients: List of [Text])
    begin
        SMTPMessageImpl.SetBCCRecipients(Recipients);
    end;

    /// <summary>
    /// Adds the subject of this email.
    /// </summary>
    /// <param name="Subject">The subject</param>
    procedure SetSubject(Subject: Text)
    begin
        SMTPMessageImpl.SetSubject(Subject);
    end;

    /// <summary>
    /// The body of the email. The body is expected to be HTML formatted.
    /// </summary>
    /// <param name="Body">The HTML body text</param>
    procedure SetBody(Body: Text)
    begin
        SMTPMessageImpl.SetBody(Body, true);
    end;

    /// <summary>
    /// Sets the body of the email.
    /// </summary>
    /// <param name="Body">The body text</param>
    /// <param name="HTMLFormatted">Boolean of whether the text is HTML formatted</param>
    procedure SetBody(Body: Text; HTMLFormatted: Boolean)
    begin
        SMTPMessageImpl.SetBody(Body, HTMLFormatted);
    end;

    /// <summary>
    /// Adds an attachment to the email.
    /// </summary>
    /// <param name="AttachmentInStream"></param>
    /// <param name="AttachmentName"></param>
    /// <returns></returns>
    procedure AddAttachment(AttachmentInStream: InStream; AttachmentName: Text): Boolean
    begin
        exit(SMTPMessageImpl.AddAttachment(AttachmentInStream, AttachmentName));
    end;

    internal procedure GetMessage(var EmailMimeMessage: DotNet MimeMessage)
    begin
        SMTPMessageImpl.GetMessage(EmailMimeMessage);
    end;

    /// <summary>
    /// Allows switching of From name and address when sending the email.
    /// The email used to connect to the server is still the same and the from address needs to have permission to Send As.
    /// </summary>
    /// <param name="FromName">New from name</param>
    /// <param name="FromAddress">new from address</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAddFrom(var FromName: Text; var FromAddress: Text)
    begin
    end;
}
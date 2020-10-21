// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Codeunit to create and manage email messages.
/// </summary>
codeunit 8904 "Email Message"
{
    Access = Public;

    /// <summary>
    /// Creates the email with recipients, subject, and body.
    /// </summary>
    /// <param name="ToRecipients">The recipient(s) of the email. A string containing the email addresses of the recipients separated by semicolon.</param>
    /// <param name="Subject">The subject of the email.</param>
    /// <param name="Body">Raw text that will be used as body of the email.</param>
    procedure Create(ToRecipients: Text; Subject: Text; Body: Text)
    begin
        EmailMessageImpl.Create(ToRecipients, Subject, Body, false);
    end;

    /// <summary>
    /// Creates the email with recipients, subject, and body.
    /// </summary>
    /// <param name="ToRecipients">The recipient(s) of the email. A string containing the email addresses of the recipients separated by semicolon.</param>
    /// <param name="Subject">The subject of the email.</param>
    /// <param name="Body">The body of the email.</param>
    /// <param name="HtmlFormatted">Whether the body is HTML formatted.</param>
    procedure Create(ToRecipients: Text; Subject: Text; Body: Text; HtmlFormatted: Boolean)
    begin
        EmailMessageImpl.Create(ToRecipients, Subject, Body, HtmlFormatted);
    end;

    /// <summary>
    /// Creates the email with recipients, subject, and body.
    /// </summary>
    /// <param name="ToRecipients">The recipient(s) of the email. A list of email addresses the email will be send directly to.</param>
    /// <param name="Subject">The subject of the email.</param>
    /// <param name="Body">The body of the email</param>
    /// <param name="HtmlFormatted">Whether the body is HTML formatted</param>
    procedure Create(ToRecipients: List of [Text]; Subject: Text; Body: Text; HtmlFormatted: Boolean)
    begin
        EmailMessageImpl.Create(ToRecipients, Subject, Body, HtmlFormatted);
    end;

    /// <summary>
    /// Creates the email with recipients, subject, and body.
    /// </summary>
    /// <param name="ToRecipients">The recipient(s) of the email. A list of email addresses the email will be send directly to.</param>
    /// <param name="Subject">The subject of the email.</param>
    /// <param name="Body">The body of the email.</param>
    /// <param name="HtmlFormatted">Whether the body is HTML formatted.</param>
    /// <param name="CCRecipients">The CC recipient(s) of the email. A list of email addresses that will be listed as CC.</param>
    /// <param name="BCCRecipients">TThe BCC recipient(s) of the email. A list of email addresses that will be listed as BCC.</param>
    procedure Create(ToRecipients: List of [Text]; Subject: Text; Body: Text; HtmlFormatted: Boolean; CCRecipients: List of [Text]; BCCRecipients: List of [Text])
    begin
        EmailMessageImpl.Create(ToRecipients, Subject, Body, HtmlFormatted, CCRecipients, BCCRecipients);
    end;

    /// <summary>
    /// Gets the email message with the given ID.
    /// </summary>
    /// <param name="MessageId">The ID of the email message to get.</param>
    /// <returns>True if the email was found; otherwise - false.</returns>
    procedure Get(MessageId: Guid): Boolean
    begin
        exit(EmailMessageImpl.Get(MessageId));
    end;

    /// <summary>
    /// Gets the body of the email message.
    /// </summary>
    /// <returns>The body of the email.</returns>
    procedure GetBody(): Text
    begin
        exit(EmailMessageImpl.GetBody());
    end;

    /// <summary>
    /// Gets the subject of the email message.
    /// </summary>
    /// <returns>The subject of the email.</returns>
    procedure GetSubject(): Text[2048]
    begin
        exit(EmailMessageImpl.GetSubject());
    end;

    /// <summary>
    /// Checks if the email body is formatted in HTML.
    /// </summary>
    /// <returns>True if the email body is formatted in HTML; otherwise - false.</returns>
    procedure IsBodyHTMLFormatted(): Boolean
    begin
        exit(EmailMessageImpl.IsBodyHTMLFormatted());
    end;

    /// <summary>
    /// Gets the ID of the email message.
    /// </summary>
    /// <returns>The ID of the email.</returns>
    procedure GetId(): Guid
    begin
        exit(EmailMessageImpl.GetId());
    end;

    /// <summary>
    /// Gets the recipents of a certain type of the email message.
    /// </summary>
    /// <param name="RecipientType">Sepcifies the type of the recipients.</param>
    /// <param name="Recipients">Out parameter filled with the recipients' email addresses.</param>
    procedure GetRecipients(RecipientType: Enum "Email Recipient Type"; var Recipients: list of [Text])
    begin
        EmailMessageImpl.GetRecipients(RecipientType, Recipients)
    end;

    /// <summary>
    /// Adds a file attachment to the email message.
    /// </summary>
    /// <param name="AttachmentName">The name of the file attachment.</param>
    /// <param name="ContentType">The Content Type of the file attachment.</param>
    /// <param name="AttachmentBase64">The Base64 text representation of the attachment.</param>
    /// <returns>True if the attachment was added; otherwise - false.</returns>
    procedure AddAttachment(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentBase64: Text)
    begin
        EmailMessageImpl.AddAttachment(AttachmentName, ContentType, AttachmentBase64);
    end;

    /// <summary>
    /// Adds a file attachment to the email message.
    /// </summary>
    /// <param name="AttachmentName">The name of the file attachment.</param>
    /// <param name="ContentType">The Content Type of the file attachment.</param>
    /// <param name="AttachmentStream">The instream of the attachment.</param>
    /// <returns>True if the attachment was added; otherwise - false.</returns>
    procedure AddAttachment(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentStream: InStream)
    begin
        EmailMessageImpl.AddAttachment(AttachmentName, ContentType, AttachmentStream);
    end;

    /// <summary>
    /// Finds the first attachment of the email message.
    /// </summary>
    /// <returns>True if there is any attachment; otherwise - false.</returns>
    procedure Attachments_First(): Boolean
    begin
        exit(EmailMessageImpl.Attachments_First());
    end;

    /// <summary>
    /// Finds the next attachment of the email message.
    /// </summary>
    /// <returns>The ID of the next attachment if it was found; otherwise - 0.</returns>
    procedure Attachments_Next(): Integer
    begin
        exit(EmailMessageImpl.Attachments_Next());
    end;

    /// <summary>
    /// Gets the name of the current attachment.
    /// </summary>
    /// <returns>The name of the current attachment.</returns>
    procedure Attachments_GetName(): Text[250]
    begin
        exit(EmailMessageImpl.Attachments_GetName());
    end;

    /// <summary>
    /// Gets the content of the current attachment.
    /// </summary>
    /// <param name="AttachmentStream">Out parameter with the content of the current attachment.</param>
    procedure Attachments_GetContent(var AttachmentStream: InStream)
    begin
        EmailMessageImpl.Attachments_GetContent(AttachmentStream);
    end;

    /// <summary>
    /// Gets the content of the current attachment in Base64 encoding.
    /// </summary>
    /// <returns>The content of the current attachment in Base64 encoding.</returns>
    procedure Attachments_GetContentBase64(): Text
    begin
        exit(EmailMessageImpl.Attachments_GetContentBase64());
    end;

    /// <summary>
    /// Gets the content type of the current attachment.
    /// </summary>
    /// <returns>The content type of the current attachment.</returns>
    procedure Attachments_GetContentType(): Text[250]
    begin
        exit(EmailMessageImpl.Attachments_GetContentType());
    end;

    /// <summary>
    /// Gets the content ID of the current attachment.
    /// </summary>
    /// <returns>The content ID of the current attachment.</returns>
    /// <remarks>This value is filled only if the attachment is inline the email body.</remarks>
    procedure Attachments_GetContentId(): Text[40]
    begin
        exit(EmailMessageImpl.Attachments_GetContentId());
    end;

    /// <summary>
    /// Checks if the attachment is inline the message body.
    /// </summary>
    /// <returns>True if the attachment is inline the message body; otherwise - false.</returns>
    procedure Attachments_IsInline(): Boolean
    begin
        exit(EmailMessageImpl.Attachments_IsInline());
    end;

    var
        EmailMessageImpl: Codeunit "Email Message Impl.";
}
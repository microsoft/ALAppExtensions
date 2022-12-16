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
    /// Sets the body of the email message.
    /// </summary>
    /// <param name="Body">The body to set to the email message.</param>
    procedure SetBody(Body: Text)
    begin
        EmailMessageImpl.SetBody(Body);
    end;

    /// <summary>
    /// Appends to the body of the email message.
    /// <param name="Value">The value to append to the body of the email message.</param>
    /// </summary>
    procedure AppendToBody(Value: Text)
    begin
        EmailMessageImpl.AppendToBody(Value);
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
    /// Sets the subject of the email message.
    /// </summary>
    /// <param name="Subject">The subject to set to the email message.</param>
    procedure SetSubject(Subject: Text)
    begin
        EmailMessageImpl.SetSubject(Subject);
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
    /// Sets whether the email body is formatted in HTML.
    /// <param name="Value">True if the email body is formatted in HTML; otherwise - false.</param>
    /// </summary>
    procedure SetBodyHTMLFormatted(Value: Boolean)
    begin
        EmailMessageImpl.SetBodyHTMLFormatted(Value);
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
    /// <param name="RecipientType">Specifies the type of the recipients.</param>
    /// <param name="Recipients">Out parameter filled with the recipients' email addresses.</param>
    procedure GetRecipients(RecipientType: Enum "Email Recipient Type"; var Recipients: list of [Text])
    begin
        Recipients := EmailMessageImpl.GetRecipients(RecipientType);
    end;

    /// <summary>
    /// Sets the recipents of a certain type of the email message.
    /// </summary>
    /// <param name="RecipientType">Specifies the type of the recipients.</param>
    /// <param name="Recipients">Specifies the list of the recipients' email addresses as a semicolon (;) separated list.</param>
    procedure SetRecipients(RecipientType: Enum "Email Recipient Type"; Recipients: Text)
    begin
        EmailMessageImpl.SetRecipients(RecipientType, Recipients);
    end;

    /// <summary>
    /// Sets the recipents of a certain type of the email message.
    /// </summary>
    /// <param name="RecipientType">Specifies the type of the recipients.</param>
    /// <param name="Recipients">Specifies the list of the recipients' email addresses.</param>
    procedure SetRecipients(RecipientType: Enum "Email Recipient Type"; Recipients: list of [Text])
    begin
        EmailMessageImpl.SetRecipients(RecipientType, Recipients);
    end;

    /// <summary>
    /// Adds a recipient of a certain type to the email message.
    /// </summary>
    /// <param name="RecipientType">Specifies the type of the recipient.</param>
    /// <param name="Recipient">Specifies the recipient's email address.</param>
    procedure AddRecipient(RecipientType: Enum "Email Recipient Type"; Recipient: Text)
    begin
        EmailMessageImpl.AddRecipient(RecipientType, Recipient);
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
    /// <param name="AttachmentInStream">The instream of the attachment.</param>
    /// <returns>True if the attachment was added; otherwise - false.</returns>
    procedure AddAttachment(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentInStream: InStream)
    begin
        EmailMessageImpl.AddAttachment(AttachmentName, ContentType, AttachmentInStream);
    end;

    /// <summary>
    /// Adds attachments from scenario to the email message.
    /// </summary>
    /// <param name="EmailAttachments">The reference to the email attachments </param>
    procedure AddAttachmentFromScenario(var EmailAttachments: Record "Email Attachments")
    begin
        EmailMessageImpl.AddAttachmentsFromScenario(EmailAttachments);
    end;

    /// <summary>
    /// Deletes the contents of the currently selected attachment.
    /// </summary>
    /// <returns>Returns true if contents was successfully deleted, otherwise false.</returns>
    procedure Attachments_DeleteContent(): Boolean
    begin
        exit(EmailMessageImpl.Attachments_DeleteContent());
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
    /// <param name="AttachmentInStream">Out parameter with the content of the current attachment.</param>
    procedure Attachments_GetContent(var AttachmentInStream: InStream)
    begin
        EmailMessageImpl.Attachments_GetContent(AttachmentInStream);
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
    /// Gets the content length of the current attachment.
    /// </summary>
    /// <returns>The content length of the current attachment.</returns>
    procedure Attachments_GetLength(): Integer
    begin
        exit(EmailMessageImpl.Attachments_GetLength());
    end;

    /// <summary>
    /// Checks if the attachment is inline the message body.
    /// </summary>
    /// <returns>True if the attachment is inline the message body; otherwise - false.</returns>
    procedure Attachments_IsInline(): Boolean
    begin
        exit(EmailMessageImpl.Attachments_IsInline());
    end;

    /// <summary>
    /// Gets the related attachments.
    /// </summary>
    /// <param name="EmailRelatedAttachments">Out parameter with the related attachments.</param>
    /// <returns>True if any related attachments were found; otherwise - false</returns>
    procedure GetRelatedAttachments(var EmailRelatedAttachments: Record "Email Related Attachment"): Boolean
    begin
        exit(EmailMessageImpl.GetRelatedAttachments(EmailRelatedAttachments));
    end;

    /// <summary>
    /// Gets number of modifies on the message.
    /// </summary>
    /// <returns>The number of modifies.</returns>
    internal procedure GetNoOfModifies(): Integer
    begin
        exit(EmailMessageImpl.GetNoOfModifies());
    end;

    /// <summary>
    /// Integration event to provide the stream of data for a given MediaID. If attachment content has been deleted, this event makes it possible to provide 
    /// the data from elsewhere.
    /// </summary>
    /// <param name="MediaID">Id of the underlying media field that contains the attachment data.</param>
    /// <param name="InStream">Stream to that should pointed to the attachment data.</param>
    /// <param name="Handled">Was the attachment content added to the stream.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnGetAttachmentContent(MediaID: Guid; var InStream: Instream; var Handled: Boolean)
    begin
    end;

    var
        EmailMessageImpl: Codeunit "Email Message Impl.";
}
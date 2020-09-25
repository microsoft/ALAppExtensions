// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8904 "Email Message"
{
    Access = Public;

    /// <summary>
    /// Creates the email with the name and address it is being sent from, the recipients, subject, and body.
    /// </summary>
    /// <param name="FromName">The name of the email sender</param>
    /// <param name="FromAddress">The address of the default sender or, when using the Send As or Send on Behalf functionality, the address of the substitute sender</param>
    /// <param name="ToRecipients">The recipient(s) of the email</param>
    /// <param name="Subject">The subject of the email</param>
    /// <param name="Body">The body of the email</param>
    /// <param name="HtmlFormatted">Whether the body is html formatted</param>
    procedure CreateMessage(ToRecipients: List of [Text]; Subject: Text; Body: Text; HtmlFormatted: Boolean)
    begin
        EmailMessageImpl.CreateMessage(ToRecipients, Subject, Body, HtmlFormatted);
    end;

    /// <summary>
    /// Creates the email with the name and address it is being sent from, the recipients, subject, and body.
    /// </summary>
    /// <param name="FromName">The name of the email sender</param>
    /// <param name="FromAddress">The address of the default sender or, when using the Send As or Send on Behalf functionality, the address of the substitute sender</param>
    /// <param name="ToRecipients">The recipient(s) of the mail</param>
    /// <param name="Subject">The subject of the mail</param>
    /// <param name="Body">The body of the mail</param>
    /// <param name="HtmlFormatted">Whether the body is html formatted</param>
    /// <param name="CCRecipients">The recipient(s) of the mail</param>
    /// <param name="BCCRecipients">The recipient(s) of the mail</param>
    procedure CreateMessage(ToRecipients: List of [Text]; Subject: Text; Body: Text; HtmlFormatted: Boolean; CCRecipients: List of [Text]; BCCRecipients: List of [Text])
    begin
        EmailMessageImpl.CreateMessage(ToRecipients, Subject, Body, HtmlFormatted, CCRecipients, BCCRecipients);
    end;

    /// <summary>
    /// Finds the email message with the given Id.
    /// </summary>
    /// <param name="MessageId">The Id of the email message to fing</param>
    /// <return>True if the email was found.</return>
    procedure Find(MessageId: guid): Boolean
    begin
        exit(EmailMessageImpl.Find(MessageId));
    end;

    /// <summary>
    /// Returns the body of the message.
    /// </summary>
    /// <return>The body of the email</return>
    procedure GetBody(): Text
    begin
        exit(EmailMessageImpl.GetBody());
    end;

    /// <summary>
    /// Returns the subject of the message.
    /// </summary>
    /// <return>The subject of the email</return>
    procedure GetSubject(): Text[2048]
    begin
        exit(EmailMessageImpl.GetSubject());
    end;

    /// <summary>
    /// Returns true if the email body is formatted in HTML.
    /// </summary>
    /// <return>True if the email body is formatted in HTML.</return>
    procedure IsBodyHTMLFormatted(): Boolean
    begin
        exit(EmailMessageImpl.IsBodyHTMLFormatted());
    end;

    /// <summary>
    /// Returns the id of the message.
    /// </summary>
    /// <return>The id of the email</return>
    procedure GetId(): Guid
    begin
        exit(EmailMessageImpl.GetId());
    end;

    /// <summary>
    /// Returns the Recipents of a certain Type of the email message.
    /// </summary>
    /// <param name="RecipientType">Sepcifies the type of the recipients.</param>
    /// <param name="Recipients">Out parameter filled with the Recipients of that type.</param>
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
    /// <return>True if the attachment was added.</return>
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
    /// <return>True if the attachment was added.</return>
    procedure AddAttachment(AttachmentName: Text[250]; ContentType: Text[250]; AttachmentStream: InStream)
    begin
        EmailMessageImpl.AddAttachment(AttachmentName, ContentType, AttachmentStream);
    end;

    /// <summary>
    /// Finds the first attachment of the email message.
    /// </summary>
    /// <returns>True if there is any attachment.</returns>
    procedure Attachments_First(): Boolean
    begin
        exit(EmailMessageImpl.Attachments_First());
    end;

    /// <summary>
    /// Finds the next attachment of the email message.
    /// </summary>
    /// <returns>True if there are any more attachments.</returns>
    procedure Attachments_Next(): Integer
    begin
        exit(EmailMessageImpl.Attachments_Next());
    end;

    /// <summary>
    /// Returns the name of the current attachment.
    /// </summary>
    /// <returns>The name of the current attachment.</returns>
    procedure Attachments_GetName(): Text[250]
    begin
        exit(EmailMessageImpl.Attachments_GetName());
    end;

    /// <summary>
    /// Returns the content of the current attachment.
    /// </summary>
    /// <param name="AttachmentStream">Out parameter with the content of the current attachment</param>
    procedure Attachments_GetContent(var AttachmentStream: InStream)
    begin
        EmailMessageImpl.Attachments_GetContent(AttachmentStream);
    end;

    /// <summary>
    /// Returns the content of the current attachment in Base64 encoding.
    /// </summary>
    /// <returns>The content of the current attachment in Base64 encoding.</returns>
    procedure Attachments_GetContentBase64(): Text
    begin
        exit(EmailMessageImpl.Attachments_GetContentBase64());
    end;

    /// <summary>
    /// Returns the content type of the current attachment.
    /// </summary>
    /// <returns>The content type of the current attachment.</returns>
    procedure Attachments_GetContentType(): Text[250]
    begin
        exit(EmailMessageImpl.Attachments_GetContentType());
    end;

    /// <summary>
    /// Returns the content id of the current attachment.
    /// </summary>
    /// <returns>The content id of the current attachment.</returns>
    /// <remarks>This value is filled only when the attachment is inline the mail body</remarks>
    procedure Attachments_GetContentId(): Text[40]
    begin
        exit(EmailMessageImpl.Attachments_GetContentId());
    end;

    /// <summary>
    /// True if the attachment is inline the message body.
    /// </summary>
    /// <returns>True if the attachment is inline the message body.</returns>
    procedure Attachments_IsInline(): Boolean
    begin
        exit(EmailMessageImpl.Attachments_IsInline());
    end;

    /// <summary>
    /// Opens the current message in the "Email Editor" page
    /// </summary>
    procedure OpenInEditor()
    begin
        EmailMessageImpl.OpenInEditor();
    end;

    /// <summary>
    /// Opens the current message in the "Email Editor" page
    /// </summary>
    /// <param name="AccountId">Specifies which account to show on the page.</param>
    procedure OpenInEditor(AccountId: guid)
    begin
        EmailMessageImpl.OpenInEditor(AccountId);
    end;

    /// <summary>
    /// Opens the current message in the "Email Editor" page
    /// </summary>
    /// <param name="AccountId">Specifies which account to show on the page.</param>
    /// <param name="Connector">Specifies the Connector that the account belongs to.</param>
    procedure OpenInEditor(AccountId: guid; Connector: Enum "Email Connector")
    begin
        EmailMessageImpl.OpenInEditor(AccountId, Connector)
    end;

    /// <summary>
    /// Opens the current message in the "Email Editor" page
    /// </summary>
    /// <param name="Account">Specifies which account to show on the page.</param>
    /// <param name="IsModal">Specifies if the editor will be open modally (no input, such as a keyboard or mouse click, can occur outside of the editor).</param>
    /// <param name="WasEmailSent">Specifies if the email was sent from the editor (will only be filled if the page was open modally).</param>
    /// <remarks>Both "Account Id" and Connector fields need to be set on the Account Record.</remarks>
    procedure OpenInEditor(Account: Record "Email Account" temporary; IsModal: Boolean; var WasEmailSent: Boolean)
    begin
        EmailMessageImpl.OpenInEditor(Account, IsModal, WasEmailSent);
    end;

    var
        EmailMessageImpl: Codeunit "Email Message Impl.";
}
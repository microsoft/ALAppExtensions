// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

/// <summary>
/// Interface for the Email - Outlook API Client which allows retrieval of emails, replying to emails and marking emails as read.
/// </summary>
interface "Email - Outlook API Client v5"
{
    /// <summary>
    /// Gets account information from the Outlook API.
    /// </summary>
    /// <param name="AccessToken">The access token used for connecting to exchange via graph.</param>
    /// <param name="Email">The email address of the mailbox.</param>
    /// <param name="Name">The name of the mailbox owner.</param>
    /// <returns>True if the account information was retrieved successfully, false otherwise.</returns>
    procedure GetAccountInformation(AccessToken: SecretText; var Email: Text[250]; var Name: Text[250]): Boolean;

    /// <summary>
    /// Sends an email via the Outlook API.
    /// </summary>
    /// <param name="AccessToken">The access token used for connecting to exchange via graph.</param>
    /// <param name="MessageJson">The JSON object containing the email message to be sent.</param>
    procedure SendEmail(AccessToken: SecretText; MessageJson: JsonObject);

    /// <summary>
    /// Retrieves the emails from the Outlook API.
    /// </summary>
    /// <param name="AccessToken">The access token used for connecting to exchange via graph.</param>
    /// <param name="OutlookAccount">The email account to retrieve emails from.</param>
    /// <param name="Filters">Filters for filtering the retrieval of emails.</param>
    /// <returns>The json containing the information of the emails.</returns>"
    procedure RetrieveEmails(AccessToken: SecretText; OutlookAccount: Record "Email - Outlook Account"; var Filters: Record "Email Retrieval Filters" temporary): JsonArray;

    /// <summary>
    /// Retrieves an email from the Outlook API.
    /// </summary>
    /// <param name="AccessToken">The access token used for connecting to exchange via graph.</param>
    /// <param name="EmailAddress">The email address of the mailbox.</param>
    /// <param name="ExternalMessageId">The external message id of the message to retrieve.</param>
    /// <param name="Filters">Filters for filtering the retrieval of emails.</param>
    /// <returns>The json containing the information of the email.</returns>
    procedure RetrieveEmail(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text; var Filters: Record "Email Retrieval Filters" temporary): JsonObject;

    /// <summary>
    /// Creates a draft reply to a specific email.
    /// </summary>
    /// <param name="AccessToken">The access token used for connecting to exchange via graph.</param>
    /// <param name="EmailAddress">The email address of the mailbox.</param>
    /// <param name="ExternalMessageId">The external message id of the message to create a reply for.</param>
    /// <returns>The external message id of the created draft.</returns>
    procedure CreateDraftReply(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text): Text;

    /// <summary>
    /// Replies to an email.
    /// </summary>
    /// <param name="AccessToken">The access token used for connecting to exchange via graph.</param>
    /// <param name="EmailAddress">The email address of the mailbox.</param>
    /// <param name="EmailMessage">The email message containg the response for replying to the email.</param>
    procedure ReplyEmail(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text; MessageJsonText: Text);

    /// <summary>
    /// Marks an email as read.
    /// </summary>
    /// <param name="AccessToken">The access token used for connecting to exchange via graph.</param>
    /// <param name="EmailAddress">The email address of the mailbox.</param>
    /// <param name="ExternalMessageId">The external message id to be marked as read.</param>
    procedure MarkEmailAsRead(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text);

    /// <summary>
    /// Gets mailbox folders from the Outlook API.
    /// </summary>
    /// <param name="AccessToken">The access token used for connecting to exchange via graph.</param>
    /// <param name="OutlookAccount">The email account to retrieve mailbox folders from.</param>
    /// <returns>The JSON array containing the information of the mailbox folders.</returns>
    procedure GetMailboxFolders(AccessToken: SecretText; OutlookAccount: Record "Email - Outlook Account"): JsonArray;

    /// <summary>
    /// Gets child mailbox folders from the Outlook API.
    /// </summary>
    /// <param name="AccessToken">The access token used for connecting to exchange via graph.</param>
    /// <param name="OutlookAccount">The email account to retrieve child mailbox folders from.</param>
    /// <param name="ParentFolderId">The ID of the parent folder to retrieve child folders for.</param>
    /// <returns>The JSON array containing the information of the child mailbox folders.</returns>
    procedure GetChildMailboxFolders(AccessToken: SecretText; OutlookAccount: Record "Email - Outlook Account"; ParentFolderId: Text): JsonArray;
}
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

/// <summary>
/// Interface for the Email - Outlook API Client which allows retrieval of emails, replying to emails and marking emails as read.
/// </summary>
interface "Email - Outlook API Client v4" extends "Email - Outlook API Client v2"
{
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
}
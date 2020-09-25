// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to create and send emails.
/// </summary>
codeunit 8901 "Email"
{
    Access = Public;

    /// <summary>
    /// Queues a draft email in the Outbox.
    /// </summary>
    /// <param name="EmailMessageId">The ID of the email to enqueue</param>
    procedure Enqueue(EmailMessageId: Guid)
    begin
        EmailImpl.Enqueue(EmailMessageId);
    end;

    /// <summary>
    /// Queues a draft email in the Outbox with the given message, account and connector.
    /// The email will be sent in the background.
    /// </summary>
    /// <param name="EmailMessageId">The id of the email message</param>
    /// <param name="AccountId">The id of the email account</param>
    /// <param name="EmailConnector">The email connector type</param>
    procedure Enqueue(EmailMessageId: Guid; AccountId: Guid; EmailConnector: Enum "Email Connector")
    begin
        EmailImpl.Enqueue(EmailMessageId, AccountId, EmailConnector);
    end;

    /// <summary>
    /// Sends the email through the given message, account and connector in the current session.
    /// </summary>
    /// <param name="EmailMessageId">The id of the email message</param>
    /// <param name="AccountId">The ID of the e-mail account</param>
    /// <param name="EmailConnector">The email connector type</param>
    /// <return>True if the email was successfully sent</return>
    procedure Send(EmailMessageId: Guid; AccountId: Guid; EmailConnector: Enum "Email Connector"): Boolean
    begin
        exit(EmailImpl.Send(EmailMessageId, AccountId, EmailConnector));
    end;

    /// <summary>
    /// Checks to see if there is any connectors installed.
    /// </summary>
    procedure IsAnyConnectorInstalled(): Boolean
    begin
        exit(EmailImpl.IsAnyConnectorInstalled());
    end;

    /// <summary>
    /// Integration event to override the default email body for test messages.
    /// </summary>
    /// <param name="Connector">The connector used to send the email message.</param>
    /// <param name="Body">Out param to set the email body to a new value.</param>
    [IntegrationEvent(false, false)]
    procedure OnGetTestEmailBody(Connector: Enum "Email Connector"; var Body: Text)
    begin
    end;

    var
        EmailImpl: Codeunit "Email Impl";
}
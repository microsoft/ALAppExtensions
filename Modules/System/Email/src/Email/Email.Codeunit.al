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

    #region SaveAsDraft

    /// <summary>
    /// Saves a draft email in the Outbox.
    /// </summary>
    /// <param name="EmailMessage">The email message to save.</param>
    procedure SaveAsDraft(EmailMessage: Codeunit "Email Message")
    begin
        EmailImpl.SaveAsDraft(EmailMessage);
    end;

    /// <summary>
    /// Saves a draft email in the Outbox.
    /// </summary>
    /// <param name="EmailMessage">The email message to save.</param>
    /// <param name="EmailOutbox">The created outbox entry.</param>
    procedure SaveAsDraft(EmailMessage: Codeunit "Email Message"; var EmailOutbox: Record "Email Outbox")
    begin
        EmailImpl.SaveAsDraft(EmailMessage, EmailOutbox);
    end;

    #endregion

    #region Enqueue

    /// <summary>
    /// Enqueues an email to be sent in the background.
    /// </summary>
    /// <remarks>The default account will be used for sending the email.</remarks>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    procedure Enqueue(EmailMessage: Codeunit "Email Message")
    begin
        EmailImpl.Enqueue(EmailMessage, Enum::"Email Scenario"::Default);
    end;

    /// <summary>
    /// Enqueues an email to be sent in the background.
    /// </summary>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    /// <param name="EmailScenario">The scenario to use in order to determine the email account to use for sending the email.</param>
    procedure Enqueue(EmailMessage: Codeunit "Email Message"; EmailScenario: Enum "Email Scenario")
    begin
        EmailImpl.Enqueue(EmailMessage, EmailScenario);
    end;

    /// <summary>
    /// Enqueues an email to be sent in the background.
    /// </summary>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    /// <param name="EmailAccount">The email account to use for sending the email.</param>
    /// <remarks>Both "Account Id" and Connector fields need to be set on the <paramref name="EmailAccount"/> parameter.</remarks>
    procedure Enqueue(EmailMessage: Codeunit "Email Message"; EmailAccount: Record "Email Account" temporary)
    begin
        EmailImpl.Enqueue(EmailMessage, EmailAccount."Account Id", EmailAccount.Connector);
    end;

    /// <summary>
    /// Enqueues an email to be sent in the background.
    /// </summary>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    /// <param name="EmailAccountId">The ID of the email account to use for sending the email.</param>
    /// <param name="EmailConnector">The email connector to use for sending the email.</param>
    procedure Enqueue(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector")
    begin
        EmailImpl.Enqueue(EmailMessage, EmailAccountId, EmailConnector);
    end;

    #endregion

    #region Send

    /// <summary>
    /// Sends the email in the current session.
    /// </summary>
    /// <remarks>The default account will be used for sending the email.</remarks>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    /// <returns>True if the email was successfully sent; otherwise - false.</returns>
    procedure Send(EmailMessage: Codeunit "Email Message"): Boolean
    begin
        exit(EmailImpl.Send(EmailMessage, Enum::"Email Scenario"::Default));
    end;


    /// <summary>
    /// Sends the email in the current session.
    /// </summary>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    /// <param name="EmailScenario">The scenario to use in order to determine the email account to use for sending the email.</param>
    /// <returns>True if the email was successfully sent; otherwise - false.</returns>
    procedure Send(EmailMessage: Codeunit "Email Message"; EmailScenario: Enum "Email Scenario"): Boolean
    begin
        exit(EmailImpl.Send(EmailMessage, EmailScenario));
    end;

    /// <summary>
    /// Sends the email in the current session.
    /// </summary>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    /// <param name="EmailAccount">The email account to use for sending the email.</param>
    /// <remarks>Both "Account Id" and Connector fields need to be set on the <paramref name="EmailAccount"/> parameter.</remarks>
    /// <returns>True if the email was successfully sent; otherwise - false</returns>
    procedure Send(EmailMessage: Codeunit "Email Message"; EmailAccount: Record "Email Account" temporary): Boolean
    begin
        exit(EmailImpl.Send(EmailMessage, EmailAccount."Account Id", EmailAccount.Connector));
    end;

    /// <summary>
    /// Sends the email in the current session.
    /// </summary>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    /// <param name="EmailAccountId">The ID of the email account to use for sending the email.</param>
    /// <param name="EmailConnector">The email connector to use for sending the email.</param>
    /// <returns>True if the email was successfully sent; otherwise - false</returns>
    procedure Send(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"): Boolean
    begin
        exit(EmailImpl.Send(EmailMessage, EmailAccountId, EmailConnector));
    end;

    #endregion

    #region OpenInEditor

    /// <summary>
    /// Opens an email message in "Email Editor" page.
    /// </summary>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    procedure OpenInEditor(EmailMessage: Codeunit "Email Message")
    begin
        EmailImpl.OpenInEditor(EmailMessage, Enum::"Email Scenario"::Default, false);
    end;

    /// <summary>
    /// Opens an email message in "Email Editor" page.
    /// </summary>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    /// <param name="EmailScenario">The scenario to use in order to determine the email account to use  on the page.</param>
    procedure OpenInEditor(EmailMessage: Codeunit "Email Message"; EmailScenario: Enum "Email Scenario")
    begin
        EmailImpl.OpenInEditor(EmailMessage, EmailScenario, false);
    end;

    /// <summary>
    /// Opens an email message in "Email Editor" page.
    /// </summary>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    /// <param name="EmailAccount">The email account to fill in.</param>
    /// <remarks>Both "Account Id" and Connector fields need to be set on the <paramref name="EmailAccount"/> parameter.</remarks>
    procedure OpenInEditor(EmailMessage: Codeunit "Email Message"; EmailAccount: Record "Email Account" temporary)
    begin
        EmailImpl.OpenInEditor(EmailMessage, EmailAccount."Account Id", EmailAccount.Connector, false);
    end;

    /// <summary>
    /// Opens an email message in "Email Editor" page.
    /// </summary>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    /// <param name="EmailAccountId">The ID of the email account to use on the page.</param>
    /// <param name="EmailConnector">The email connector to use on the page.</param>
    procedure OpenInEditor(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector")
    begin
        EmailImpl.OpenInEditor(EmailMessage, EmailAccountId, EmailConnector, false);
    end;

    /// <summary>
    /// Opens an email message in "Email Editor" page modally.
    /// </summary>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    /// <returns>The action that the user performed with the email message.</returns>
    procedure OpenInEditorModally(EmailMessage: Codeunit "Email Message"): Enum "Email Action"
    begin
        exit(EmailImpl.OpenInEditor(EmailMessage, Enum::"Email Scenario"::Default, true));
    end;

    /// <summary>
    /// Opens an email message in "Email Editor" page modally.
    /// </summary>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    /// <param name="EmailScenario">The scenario to use in order to determine the email account to use  on the page.</param>
    /// <returns>The action that the user performed with the email message.</returns>
    procedure OpenInEditorModally(EmailMessage: Codeunit "Email Message"; EmailScenario: Enum "Email Scenario"): Enum "Email Action"
    begin
        exit(EmailImpl.OpenInEditor(EmailMessage, EmailScenario, true));
    end;

    /// <summary>
    /// Opens an email message in "Email Editor" page modally.
    /// </summary>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    /// <param name="EmailAccount">The email account to fill in.</param>
    /// <remarks>Both "Account Id" and Connector fields need to be set on the <paramref name="EmailAccount"/> parameter.</remarks>
    /// <returns>The action that the user performed with the email message.</returns>
    procedure OpenInEditorModally(EmailMessage: Codeunit "Email Message"; EmailAccount: Record "Email Account" temporary): Enum "Email Action"
    begin
        exit(EmailImpl.OpenInEditor(EmailMessage, EmailAccount."Account Id", EmailAccount.Connector, true));
    end;

    /// <summary>
    /// Opens an email message in "Email Editor" page modally.
    /// </summary>
    /// <param name="EmailMessage">The email message to use as payload.</param>
    /// <param name="EmailAccountId">The ID of the email account to use on the page.</param>
    /// <param name="EmailConnector">The email connector to use on the page.</param>
    /// <returns>The action that the user performed with the email message.</returns>
    procedure OpenInEditorModally(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"): Enum "Email Action"
    begin
        exit(EmailImpl.OpenInEditor(EmailMessage, EmailAccountId, EmailConnector, true));
    end;

    #endregion

    #region Events

    /// <summary>
    /// Integration event to override the default email body for test messages.
    /// </summary>
    /// <param name="Connector">The connector used to send the email message.</param>
    /// <param name="Body">Out param to set the email body to a new value.</param>
    [IntegrationEvent(false, false)]
    procedure OnGetTestEmailBody(Connector: Enum "Email Connector"; var Body: Text)
    begin
    end;

    #endregion

    var
        EmailImpl: Codeunit "Email Impl";
}
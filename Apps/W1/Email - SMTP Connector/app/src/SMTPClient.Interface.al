#if not CLEAN20
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

interface "SMTP Client"
{
    ObsoleteReason = 'SMTP Client API moved to "SMTP API" app';
    ObsoleteState = Pending;
    ObsoleteTag = '20.0';

    /// <summary>
    /// Initialize the SMTP client with the account to use and the email message to send.
    /// </summary>
    /// <param name="Account">The account to send the email from.</param>
    /// <param name="Message">The email message to send.</param>
    procedure Initialize(Account: Record "SMTP Account"; Message: Codeunit "SMTP Message");

    /// <summary>
    /// Connects to the SMTP server specified in the Account variable during initialize.
    /// </summary>
    /// <returns>True if the connection was successful.</returns>
    procedure Connect(): Boolean;

    /// <summary>
    /// Authenticates the user to the SMTP server specified in the Account variable during initialize.
    /// </summary>
    /// <returns>True if the authentication was successful.</returns>
    procedure Authenticate(): Boolean;

    /// <summary>
    /// Sends the email message specified during initialize from the account specified during initialize.
    /// </summary>
    /// <returns>True if the message was sent.</returns>
    procedure SendMessage(): Boolean;

    /// <summary>
    /// Disconnects from the SMTP server.
    /// </summary>
    procedure Disconnect();
}
#endif
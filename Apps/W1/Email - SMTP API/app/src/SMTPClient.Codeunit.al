// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4611 "SMTP Client"
{
    Access = Public;

    var
        SMTPClientImpl: Codeunit "SMTP Client Impl";

    /// <summary>
    /// Connect to the specified SMTP server and port.
    /// </summary>
    /// <param name="Host">Server url or ip</param>
    /// <param name="Port">Server port number</param>
    /// <param name="SecureConnection">Boolean on whether to connect securely</param>
    /// <returns>True if connected successfully.</returns>
    procedure Connect(Host: Text; Port: Integer; SecureConnection: Boolean): Boolean
    begin
        exit(SMTPClientImpl.Connect(Host, Port, SecureConnection));
    end;

    /// <summary>
    /// Authenticate to connected server.
    /// </summary>
    /// <param name="AuthenticationType">Authentication type to authenticate with.</param>
    /// <param name="SMTPAuthentication">Authentication details for authentication.</param>
    /// <returns>True if authenticated successfully.</returns>
    procedure Authenticate(AuthenticationType: Enum "SMTP Authentication Types"; var SMTPAuthentication: Codeunit "SMTP Authentication"): Boolean
    begin
        exit(SMTPClientImpl.Authenticate(AuthenticationType, SMTPAuthentication));
    end;

    /// <summary>
    /// Sends the email.
    /// </summary>
    /// <param name="SMTPMessage">The message with details of the email to be sent.</param>
    /// <returns>True if sent successfully.</returns>
    procedure Send(SMTPMessage: Codeunit "SMTP Message"): Boolean
    begin
        exit(SMTPClientImpl.SendMessage(SMTPMessage));
    end;

    /// <summary>
    /// Disconnect from the host.
    /// </summary>
    procedure Disconnect()
    begin
        SMTPClientImpl.Disconnect();
    end;
}
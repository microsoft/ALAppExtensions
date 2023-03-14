// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4615 "MailKit Client" implements "iSMTP Client"
{
    Access = Internal;

    var
        SmtpClient: DotNet SmtpClient;
        CancellationToken: DotNet CancellationToken;
        ITransferProgress: Dotnet ITransferProgress;
        ServerNotConnectedErr: Label 'Please connect to a server first.';
        ConnectedToSMTPServerTxt: Label 'Connected to SMTP server.', Locked = true;
        AuthenticatedToServerTxt: Label 'Authenticated to SMTP server.', Locked = true;
        SentEmailTxt: Label 'Sent email.', Locked = true;
        SMTPAPICategoryTxt: Label 'SMTP API', Locked = true;

    procedure Initialize()
    begin
        SmtpClient := SmtpClient.SmtpClient();
    end;

    procedure Connect(Host: Text; Port: Integer; SecureConnection: Boolean) Connected: Boolean
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        if IsNull(SmtpClient) then
            Initialize();
        Connected := TryConnect(Host, Port, SecureConnection);

        Dimensions.Add('Category', SMTPAPICategoryTxt);
        Dimensions.Add('Connected', Format(Connected));

        Session.LogMessage('0000GKJ', ConnectedToSMTPServerTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, Dimensions);
    end;

    procedure Authenticate(Authentication: Enum "SMTP Authentication Types"; var SMTPAuthentication: Codeunit "SMTP Authentication") Authenticated: Boolean
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        if IsNull(SmtpClient) then
            Error(ServerNotConnectedErr);
        Authenticated := TryAuthenticate(Authentication, SMTPAuthentication);

        Dimensions.Add('Category', SMTPAPICategoryTxt);
        Dimensions.Add('Authenticated', Format(Authenticated));

        Session.LogMessage('0000GKK', AuthenticatedToServerTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, Dimensions);
    end;

    procedure Send(SMTPMessage: Codeunit "SMTP Message") Sent: Boolean
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        if IsNull(SmtpClient) then
            Error(ServerNotConnectedErr);
        Sent := TrySendMessage(SMTPMessage);

        Dimensions.Add('Category', SMTPAPICategoryTxt);
        Dimensions.Add('Sent', Format(Sent));

        Session.LogMessage('0000GKL', SentEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, Dimensions);
    end;

    procedure Disconnect()
    begin
        SmtpClient.Disconnect(true, CancellationToken);
    end;

    /// <summary>
    /// Tries to send the email.
    /// </summary>
    [TryFunction]
    local procedure TrySendMessage(SMTPMessage: Codeunit "SMTP Message")
    var
        EmailMimeMessage: DotNet MimeMessage;
    begin
        SMTPMessage.GetMessage(EmailMimeMessage);
        SmtpClient.Send(EmailMimeMessage, CancellationToken, ITransferProgress);
    end;

    /// <summary>
    /// Tries to connect to the SMTP server.
    /// </summary>
    /// <returns>True if there are no exceptions.</returns>
    [TryFunction]
    [NonDebuggable]
    local procedure TryConnect(Host: Text; Port: Integer; SecureConnection: Boolean)
    var
        SecureSocketOptions: DotNet SecureSocketOptions;
    begin
        if SecureConnection then
            SecureSocketOptions := SecureSocketOptions.Auto
        else
            SecureSocketOptions := SecureSocketOptions.None;

        SmtpClient.Connect(Host, Port, SecureSocketOptions, CancellationToken)
    end;

    /// <summary>
    /// Tries to authenticate to the SMTP server.
    /// </summary>
    /// <returns>True if there are no exceptions.</returns>
    [NonDebuggable]
    [TryFunction]
    local procedure TryAuthenticate(SMTPAuthenticationType: Enum "SMTP Authentication Types"; SMTPAuthentication: Codeunit "SMTP Authentication")
    var
        SMTPAuth: Interface "SMTP Auth";
    begin
        SMTPAuth := SMTPAuthenticationType;
        SMTPAuth.Authenticate(SmtpClient, SMTPAuthentication);
    end;
}
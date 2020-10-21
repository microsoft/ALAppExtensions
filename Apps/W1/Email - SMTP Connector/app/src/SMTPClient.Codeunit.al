// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4511 "SMTP Client" implements "SMTP Client"
{
    Access = Internal;

    var
        SMTPAccount: Record "SMTP Account";
        SMTPMessage: Codeunit "SMTP Message";
        SmtpClient: DotNet SmtpClient;
        CancellationToken: DotNet CancellationToken;
        ITransferProgress: Dotnet ITransferProgress;

    procedure Initialize(Account: Record "SMTP Account"; Message: Codeunit "SMTP Message")
    begin
        SMTPAccount := Account;
        SMTPMessage := Message;
        SmtpClient := SmtpClient.SmtpClient();
    end;

    procedure Connect(): Boolean
    begin
        exit(TryConnect());
    end;

    procedure Authenticate(): Boolean
    begin
        exit(TryAuthenticate());
    end;

    procedure SendMessage(): Boolean
    begin
        exit(TrySendMessage());
    end;

    procedure Disconnect()
    begin
        SmtpClient.Disconnect(true, CancellationToken);
    end;

    /// <summary>
    /// Tries to send the email.
    /// </summary>
    /// <returns>True if there are no exceptions.</returns>
    [TryFunction]
    local procedure TrySendMessage()
    var
        Email: DotNet MimeMessage;
    begin
        SMTPMessage.GetMessage(Email);
        SmtpClient.Send(Email, CancellationToken, ITransferProgress);
    end;

    /// <summary>
    /// Tries to connect to the SMTP server.
    /// </summary>
    /// <returns>True if there are no exceptions.</returns>
    [TryFunction]
    local procedure TryConnect()
    var
        SecureSocketOptions: DotNet SecureSocketOptions;
    begin
        if SMTPAccount."Secure Connection" then
            SecureSocketOptions := SecureSocketOptions.Auto
        else
            SecureSocketOptions := SecureSocketOptions.None;

        SmtpClient.Connect(SMTPAccount.Server, SMTPAccount."Server Port", SecureSocketOptions, CancellationToken)
    end;

    /// <summary>
    /// Tries to authenticate to the SMTP server.
    /// </summary>
    /// <returns>True if there are no exceptions.</returns>
    [NonDebuggable]
    [TryFunction]
    local procedure TryAuthenticate()
    var
        Password: Text;
    begin
        Password := SMTPAccount.GetPassword(SMTPAccount."Password Key");
        SmtpClient.Authenticate(SMTPAccount."User Name", Password, CancellationToken);
    end;
}
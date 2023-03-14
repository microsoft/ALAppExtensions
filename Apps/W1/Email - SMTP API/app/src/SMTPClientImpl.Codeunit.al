// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4612 "SMTP Client Impl"
{
    Access = Internal;

    var
        MailKitClient: Codeunit "MailKit Client";
        iSMTPClient: Interface "iSMTP Client";
        ClientInitialized: Boolean;

    procedure Connect(Host: Text; Port: Integer; SecureConnection: Boolean): Boolean
    begin
        Initialize();
        exit(iSMTPClient.Connect(Host, Port, SecureConnection));
    end;

    procedure Authenticate(Authentication: Enum "SMTP Authentication Types"; SMTPAuthentication: Codeunit "SMTP Authentication"): Boolean
    begin
        Initialize();
        exit(iSMTPClient.Authenticate(Authentication, SMTPAuthentication));
    end;

    procedure SendMessage(SMTPMessage: Codeunit "SMTP Message"): Boolean
    var
        Result: Boolean;
    begin
        Initialize();
        Result := iSMTPClient.Send(SMTPMessage);
        exit(Result);
    end;

    procedure Disconnect()
    begin
        iSMTPClient.Disconnect();
    end;

    procedure SetClient(Client: Interface "iSMTP Client")
    begin
        iSMTPClient := Client;
        ClientInitialized := true;
    end;

    local procedure Initialize()
    begin
        if not ClientInitialized then begin
            iSMTPClient := MailKitClient;
            ClientInitialized := true;
        end;
    end;
}
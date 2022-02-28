// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139353 "Library - SMTP API"
{
    Access = Public;

    procedure SetClient(iSMTPClient: Interface "iSMTP Client")
    begin
        SMTPClientImpl.SetClient(iSMTPClient);
    end;

    procedure Connect(Server: Text[250]; Port: Integer; SecureConnection: Boolean): Boolean
    begin
        exit(SMTPClientImpl.Connect(Server, Port, SecureConnection));
    end;

    procedure Authenticate(Authentication: enum "SMTP Authentication Types"; var SMTPAuthentication: codeunit "SMTP Authentication"): Boolean
    begin
        exit(SMTPClientImpl.Authenticate(Authentication, SMTPAuthentication));
    end;

    procedure Send(SMTPMessage: codeunit "SMTP Message"): Boolean
    begin
        exit(SMTPClientImpl.SendMessage(SMTPMessage));
    end;

    var
        SMTPClientImpl: Codeunit "SMTP Client Impl";
}
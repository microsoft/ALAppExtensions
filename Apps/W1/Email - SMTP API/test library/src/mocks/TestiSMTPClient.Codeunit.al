// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139772 "Test iSMTP Client" implements "iSMTP Client"
{
    Access = Public;

    var
        SMTPAPIClientMock: Codeunit "SMTP API Client Mock";

    procedure Connect(Host: Text; Port: Integer; SecureConnection: Boolean): Boolean
    begin
        if SMTPAPIClientMock.FailOnConnect() then
            exit(false);
        exit(true);
    end;

    procedure Authenticate(Authentication: enum "SMTP Authentication Types"; var SMTPAuthentication: codeunit "SMTP Authentication"): Boolean
    begin
        if SMTPAPIClientMock.FailOnAuthenticate() then
            exit(false);
        exit(true);
    end;

    procedure Send(SMTPMessage: codeunit "SMTP Message"): Boolean
    begin
        if SMTPAPIClientMock.FailOnSendMessage() then
            exit(false);
        exit(true);
    end;

    procedure Disconnect()
    begin
        // No need to do anything
    end;
}
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139759 "Test SMTP Client" implements "SMTP Client"
{

    var
        SMTPAccount: Record "SMTP Account";
        SMTPMessage: Codeunit "SMTP Message";
        SMTPClientMock: Codeunit "SMTP Client Mock";

    procedure Initialize(Account: Record "SMTP Account"; Message: codeunit "SMTP Message");
    begin
        SMTPAccount := Account;
        SMTPMessage := Message;
    end;

    procedure Connect(): Boolean;
    begin
        if SMTPClientMock.FailOnConnect() then
            exit(false);
        exit(true);
    end;

    procedure Authenticate(): Boolean;
    begin
        if SMTPClientMock.FailOnAuthenticate() then
            exit(false);
        exit(true);
    end;

    procedure SendMessage(): Boolean;
    begin
        if SMTPClientMock.FailOnSendMessage() then
            exit(false);
        exit(true);
    end;

    procedure Disconnect();
    begin
    end;
}
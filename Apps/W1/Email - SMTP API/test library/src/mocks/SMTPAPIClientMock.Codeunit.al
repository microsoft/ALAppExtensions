// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139773 "SMTP API Client Mock"
{
    SingleInstance = true;

    var
        FailOnConnectVar: Boolean;
        FailOnAuthenticateVar: Boolean;
        FailOnSendMessageVar: Boolean;

    procedure Initialize(var SMTPClient: Interface "iSMTP Client")
    var
        TestiSMTPClient: Codeunit "Test iSMTP Client";
    begin
        SMTPClient := TestiSMTPClient;
        FailOnConnectVar := false;
        FailOnAuthenticateVar := false;
        FailOnSendMessageVar := false;
    end;

    procedure FailOnConnect(): Boolean
    begin
        exit(FailOnConnectVar);
    end;

    procedure FailOnConnect(Fail: Boolean)
    begin
        FailOnConnectVar := Fail;
    end;

    procedure FailOnAuthenticate(): Boolean
    begin
        exit(FailOnAuthenticateVar);
    end;

    procedure FailOnAuthenticate(Fail: Boolean)
    begin
        FailOnAuthenticateVar := Fail;
    end;

    procedure FailOnSendMessage(): Boolean
    begin
        exit(FailOnSendMessageVar);
    end;

    procedure FailOnSendMessage(Fail: Boolean)
    begin
        FailOnSendMessageVar := Fail;
    end;

}
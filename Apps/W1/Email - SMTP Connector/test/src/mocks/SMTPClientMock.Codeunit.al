// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139757 "SMTP Client Mock"
{
    Access = Internal;
    SingleInstance = true;

    var
        Any: Codeunit Any;
        FailOnConnectVar: Boolean;
        FailOnAuthenticateVar: Boolean;
        FailOnSendMessageVar: Boolean;

    procedure Initialize()
    begin
        FailOnConnectVar := false;
        FailOnAuthenticateVar := false;
        FailOnSendMessageVar := false;
    end;

    procedure InitializeClient(Account: Record "SMTP Account"; Message: Codeunit "SMTP Message"; var SMTPClient: Interface "SMTP Client")
    var
        TestSMTPClient: Codeunit "Test SMTP Client";
    begin
        TestSMTPClient.Initialize(Account, Message);
        SMTPClient := TestSMTPClient;
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

    procedure AddAccount(var SMTPAccount: Record "SMTP Account")
    begin
        SMTPAccount.Id := Any.GuidValue();
        SMTPAccount.Name := CopyStr(Any.AlphanumericText(250), 1, 250);
        SMTPAccount."Sender Name" := CopyStr(Any.AlphanumericText(250), 1, 250);
        SMTPAccount."User Name" := CopyStr(Any.Email(), 1, 250);
        SMTPAccount."Email Address" := CopyStr(Any.Email(), 1, 250);
        SMTPAccount.Insert();
    end;

}
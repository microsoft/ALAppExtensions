// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Email;

using System.Email;
using System.TestLibraries.Utilities;

codeunit 134688 "Connector Mock"
{
    Permissions = tabledata "Email Rate Limit" = rimd;

    var
        Any: Codeunit Any;

    procedure Initialize()
    var
        TestEmailConnectorSetup: Record "Test Email Connector Setup";
        EmailRateLimit: Record "Email Rate Limit";
        TestEmailAccount: Record "Test Email Account";
    begin
        TestEmailConnectorSetup.DeleteAll();
        TestEmailConnectorSetup.Init();
        TestEmailConnectorSetup.Id := Any.GuidValue();
        TestEmailConnectorSetup."Fail On Send" := false;
        TestEmailConnectorSetup."Fail On Register Account" := false;
        TestEmailConnectorSetup."Unsuccessful Register" := false;
        TestEmailConnectorSetup.Insert();

        TestEmailAccount.DeleteAll();
        EmailRateLimit.DeleteAll();
    end;

    procedure GetAccounts(var EmailAccount: Record "Email Account")
    var
        TestEmailAccount: Record "Test Email Account";
    begin
        if TestEmailAccount.FindSet() then
            repeat
                EmailAccount.Init();
                EmailAccount."Account Id" := TestEmailAccount.Id;
                EmailAccount.Name := TestEmailAccount.Name;
                EmailAccount."Email Address" := TestEmailAccount.Email;
                EmailAccount.Insert();
            until TestEmailAccount.Next() = 0;
    end;

    procedure AddAccount(var EmailAccount: Record "Email Account")
    var
        EmailRateLimit: Record "Email Rate Limit";
        TestEmailAccount: Record "Test Email Account";
    begin
        TestEmailAccount.Id := Any.GuidValue();
        TestEmailAccount.Name := CopyStr(Any.AlphanumericText(250), 1, 250);
        TestEmailAccount.Email := CopyStr(Any.Email(), 1, 250);
        TestEmailAccount.Insert();

        EmailAccount."Account Id" := TestEmailAccount.Id;
        EmailAccount.Name := TestEmailAccount.Name;
        EmailAccount."Email Address" := TestEmailAccount.Email;
        EmailAccount.Connector := Enum::"Email Connector"::"Test Email Connector";

        EmailRateLimit."Account Id" := EmailAccount."Account Id";
        EmailRateLimit.Connector := EmailAccount.Connector;
        EmailRateLimit."Email Address" := EmailAccount."Email Address";
        EmailRateLimit."Rate Limit" := 0;
        EmailRateLimit.Insert();
    end;

    procedure AddAccount(var Id: Guid)
    var
        EmailRateLimit: Record "Email Rate Limit";
        TestEmailAccount: Record "Test Email Account";
    begin
        TestEmailAccount.Id := Any.GuidValue();
        TestEmailAccount.Name := CopyStr(Any.AlphanumericText(250), 1, 250);
        TestEmailAccount.Email := CopyStr(Any.Email(), 1, 250);
        TestEmailAccount.Insert();

        Id := TestEmailAccount.Id;

        EmailRateLimit."Account Id" := Id;
        EmailRateLimit.Connector := Enum::"Email Connector"::"Test Email Connector";
        EmailRateLimit."Email Address" := TestEmailAccount.Email;
        EmailRateLimit."Rate Limit" := 0;
        EmailRateLimit.Insert();
    end;

    procedure FailOnSend(): Boolean
    var
        TestEmailConnectorSetup: Record "Test Email Connector Setup";
    begin
        TestEmailConnectorSetup.FindFirst();
        exit(TestEmailConnectorSetup."Fail On Send");
    end;

    procedure FailOnSend(Fail: Boolean)
    var
        TestEmailConnectorSetup: Record "Test Email Connector Setup";
    begin
        TestEmailConnectorSetup.FindFirst();
        TestEmailConnectorSetup."Fail On Send" := Fail;
        TestEmailConnectorSetup.Modify();
    end;

    procedure FailOnRegisterAccount(): Boolean
    var
        TestEmailConnectorSetup: Record "Test Email Connector Setup";
    begin
        TestEmailConnectorSetup.FindFirst();
        exit(TestEmailConnectorSetup."Fail On Register Account");
    end;

    procedure FailOnRegisterAccount(Fail: Boolean)
    var
        TestEmailConnectorSetup: Record "Test Email Connector Setup";
    begin
        TestEmailConnectorSetup.FindFirst();
        TestEmailConnectorSetup."Fail On Register Account" := Fail;
        TestEmailConnectorSetup.Modify();
    end;

    procedure UnsuccessfulRegister(): Boolean
    var
        TestEmailConnectorSetup: Record "Test Email Connector Setup";
    begin
        TestEmailConnectorSetup.FindFirst();
        exit(TestEmailConnectorSetup."Unsuccessful Register");
    end;

    procedure UnsuccessfulRegister(Fail: Boolean)
    var
        TestEmailConnectorSetup: Record "Test Email Connector Setup";
    begin
        TestEmailConnectorSetup.FindFirst();
        TestEmailConnectorSetup."Unsuccessful Register" := Fail;
        TestEmailConnectorSetup.Modify();
    end;

    procedure SetEmailMessageID(EmailMessageID: Guid)
    var
        TestEmailConnectorSetup: Record "Test Email Connector Setup";
    begin
        TestEmailConnectorSetup.FindFirst();
        TestEmailConnectorSetup."Email Message ID" := EmailMessageID;
        TestEmailConnectorSetup.Modify();
    end;

    procedure GetEmailMessageID(): Guid
    var
        TestEmailConnectorSetup: Record "Test Email Connector Setup";
    begin
        TestEmailConnectorSetup.FindFirst();
        exit(TestEmailConnectorSetup."Email Message ID");
    end;
}
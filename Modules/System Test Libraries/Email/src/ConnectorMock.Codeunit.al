// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134688 "Connector Mock"
{
    procedure Initialize()
    begin
        TestEmailAccountSetup.DeleteAll();
        TestEmailAccountSetup.Init();
        TestEmailAccountSetup.Id := Any.GuidValue();
        TestEmailAccountSetup."Fail On Send" := false;
        TestEmailAccountSetup."Fail On Register Account" := false;
        TestEmailAccountSetup."Unsuccessful Register" := false;
        TestEmailAccountSetup.Insert();

        EmailAccounts.DeleteAll();
    end;

    procedure GetAccounts(var Accounts: Record "Email Account")
    begin
        if EmailAccounts.FindSet() then
            repeat
                Accounts."Account Id" := EmailAccounts.Id;
                Accounts.Name := EmailAccounts.Name;
                Accounts."Email Address" := EmailAccounts.Email;

                Accounts.Insert();
            until EmailAccounts.Next() = 0;
    end;

    procedure AddAccount(var EmailAccount: Record "Email Account")
    begin
        EmailAccounts.Id := Any.GuidValue();
        EmailAccounts.Name := CopyStr(Any.AlphanumericText(250), 1, 250);
        EmailAccounts.Email := CopyStr(Any.Email(), 1, 250);
        #pragma warning disable AA0205
        EmailAccounts.Insert();
        #pragma warning restore AA0205

        EmailAccount."Account Id" := EmailAccounts.Id;
        EmailAccount.Name := EmailAccounts.Name;
        EmailAccount."Email Address" := EmailAccounts.Email;
        EmailAccount.Connector := Enum::"Email Connector"::"Test Email Connector";
    end;

    procedure AddAccount(var Id: Guid)
    begin
        EmailAccounts.Id := Any.GuidValue();
        EmailAccounts.Name := CopyStr(Any.AlphanumericText(250), 1, 250);
        EmailAccounts.Email := CopyStr(Any.Email(), 1, 250);
        EmailAccounts.Insert();

        Id := EmailAccounts.Id;
    end;

    procedure FailOnSend(): Boolean
    begin
        TestEmailAccountSetup.FindFirst();
        exit(TestEmailAccountSetup."Fail On Send");
    end;

    procedure FailOnSend(Fail: Boolean)
    begin
        TestEmailAccountSetup.FindFirst();
        TestEmailAccountSetup."Fail On Send" := Fail;
        TestEmailAccountSetup.Modify();
    end;

    procedure FailOnRegisterAccount(): Boolean
    begin
        TestEmailAccountSetup.FindFirst();
        exit(TestEmailAccountSetup."Fail On Register Account");
    end;

    procedure FailOnRegisterAccount(Fail: Boolean)
    begin
        TestEmailAccountSetup.FindFirst();
        TestEmailAccountSetup."Fail On Register Account" := Fail;
        TestEmailAccountSetup.Modify();
    end;

    procedure UnsuccessfulRegister(): Boolean
    begin
        TestEmailAccountSetup.FindFirst();
        exit(TestEmailAccountSetup."Unsuccessful Register");
    end;

    procedure UnsuccessfulRegister(Fail: Boolean)
    begin
        TestEmailAccountSetup.FindFirst();
        TestEmailAccountSetup."Unsuccessful Register" := Fail;
        TestEmailAccountSetup.Modify();
    end;

    procedure SetEmailMessageID(EmailMessageID: Guid)
    begin
        TestEmailAccountSetup.FindFirst();
        TestEmailAccountSetup."Email Message ID" := EmailMessageID;
        TestEmailAccountSetup.Modify();
    end;

    procedure GetEmailMessageID(): Guid
    begin
        TestEmailAccountSetup.FindFirst();
        exit(TestEmailAccountSetup."Email Message ID");
    end;

    var
        EmailAccounts: Record "Test Email Account";
        TestEmailAccountSetup: Record "Test Email Connector Setup";
        Any: Codeunit Any;
}
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Email;

using System.Email;
using System.TestLibraries.Email;
using System.TestLibraries.Utilities;
using System.TestLibraries.Security.AccessControl;

codeunit 134705 "Email Rate Limit Page Test"
{
    Subtype = Test;
    Permissions = tabledata "Email Outbox" = rimd,
                  tabledata "Email Rate Limit" = rimd;

    var
        Assert: Codeunit "Library Assert";
        ConnectorMock: Codeunit "Connector Mock";
        PermissionsMock: Codeunit "Permissions Mock";

    [Test]
    [Scope('OnPrem')]
    procedure DefaultRateLimiteSendMultipleEmails()
    var
        EmailAccount: Record "Email Account";
        EmailOutbox: Record "Email Outbox";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
    begin
        // [Scenario] The "Email Rate Limit Setup" shows one entry when there is only one email account and no scenarios
        PermissionsMock.Set('Email Admin');

        // [Given] One email account is registered
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);

        // [Then] Send the first email, it should be sucessful
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The first email should exist');
        Assert.IsTrue(Email.Send(EmailMessage, EmailAccount), 'Sending one email should be successful');

        // [Then] Send two emails, should be sucessful
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The second email should exist');
        Assert.IsTrue(Email.Send(EmailMessage, EmailAccount), 'Sending two emails should be successful');

        // [Then] Send three emails, should be sucessful
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The third email should exist');
        Assert.IsTrue(Email.Send(EmailMessage, EmailAccount), 'Sending three emails should be successful');

        // [Then] Check the email outbox, should be empty
        EmailOutbox.SetRange("Account Id", EmailAccount."Account Id");
        Assert.AreEqual(0, EmailOutbox.Count(), 'Email Outbox should be empty.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure RateLimitEqualsOneSendTwoEmails()
    var
        EmailAccount: Record "Email Account";
        EmailRateLimit: Record "Email Rate Limit";
        EmailOutbox: Record "Email Outbox";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
    begin
        // [Scenario] The "Email Rate Limit Setup" shows one entry when there is only one email account and no scenarios
        PermissionsMock.Set('Email Edit');

        // [Given] One email account is registered
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);

        // [Then] Editing the rate limit, set the rate limit to 1
        EmailRateLimit.Get(EmailAccount."Account Id", EmailAccount.Connector);
        EmailRateLimit."Rate Limit" := 1;
        EmailRateLimit.Modify();

        // [Then] Send the first email, it should be successful. The Outbox should be empty
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');
        Assert.IsTrue(Email.Send(EmailMessage, EmailAccount), 'Sending an email should be successful');

        EmailOutbox.SetRange("Account Id", EmailAccount."Account Id");
        Assert.AreEqual(0, EmailOutbox.Count(), 'Email Outbox should be empty.');

        // [Then] Send the second email, it should succeed (and be rescheduled)
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');
        Assert.IsTrue(Email.Send(EmailMessage, EmailAccount), 'Sending an email should be successful');

        // [Then] Check the email outbox, there should be one rescheduled email.
        EmailOutbox.SetRange("Account Id", EmailAccount."Account Id");
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'The email outbox entry should exist');

        EmailOutbox.DeleteAll();
    end;

    local procedure CreateEmail(var EmailMessage: Codeunit "Email Message")
    var
        Any: Codeunit Any;
    begin
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
    end;

}
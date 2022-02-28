// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134701 "Email View Policy Tests"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;
    Permissions = tabledata "Email View Policy" = rimd,
                  tabledata "Email Related Record" = rmd,
                  tabledata "Sent Email" = rimd,
                  tabledata "Email Recipient" = rimd,
                  tabledata "Email Outbox" = rimd,
                  tabledata "Test Email Account" = rimd,
                  tabledata "Word Template" = rimd;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        EmailViewerErr: Label 'You do not have permission to open the email message.';

    [Test]
    procedure OwnEmailPolicySentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        SentEmail: Record "Sent Email";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        SentEmailsPage: TestPage "Sent Emails";
        EmailViewer: TestPage "Email Viewer";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::OwnEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, Account), 'Email should send');

        // [Then] Email is send
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] Email is shown in sent emails page
        Assert.IsTrue(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should be visible to user per policy');

        // [Then] Email can be opened by email viewer
        EmailViewer.Trap();
        SentEmailsPage.Desc.Drilldown();
    end;

    [Test]
    procedure OwnEmailPolicyFailToSeeOthersSentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        SentEmail: Record "Sent Email";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailViewer: Codeunit "Email Viewer";
        SentEmailsPage: TestPage "Sent Emails";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::OwnEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, Account), 'Email should send');

        // [Then] Email is send as other user
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        SentEmail."User Security Id" := CreateGuid();
        SentEmail.Modify();

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] Email is not shown in sent emails page per policy
        Assert.IsFalse(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should not be visible to user per policy');

        // [Then] Email can not be opened by email viewer
        asserterror EmailViewer.Open(SentEmail);
        Assert.ExpectedError(EmailViewerErr);
    end;

    [Test]
    procedure AllEmailPolicySentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        SentEmail: Record "Sent Email";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        SentEmailsPage: TestPage "Sent Emails";
        EmailViewer: TestPage "Email Viewer";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, Account), 'Email should send');

        // [Then] Email is send
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] Email is shown in sent emails page
        Assert.IsTrue(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should be visible to user per policy');

        // [Then] Email can be opened by email viewer
        EmailViewer.Trap();
        SentEmailsPage.Desc.Drilldown();
    end;

    [Test]
    procedure AllEmailPolicyOtherUserSentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        SentEmail: Record "Sent Email";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        SentEmailsPage: TestPage "Sent Emails";
        EmailViewer: TestPage "Email Viewer";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, Account), 'Email should send');

        // [Then] Email is send
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        SentEmail."User Security Id" := CreateGuid();
        SentEmail.Modify();

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] Email is shown in sent emails page
        Assert.IsTrue(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should be visible to user per policy');

        // [Then] Email can be opened by email viewer
        EmailViewer.Trap();
        SentEmailsPage.Desc.Drilldown();
    end;

    [Test]
    procedure AllRelatedRecordsEmailPolicySentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        SentEmail: Record "Sent Email";
        EmailRecipient: Record "Email Recipient";
        EmailOutbox: Record "Email Outbox";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        SentEmailsPage: TestPage "Sent Emails";
        EmailViewer: TestPage "Email Viewer";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllRelatedRecordsEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);

        EmailRecipient.Init();
        EmailRecipient."Email Address" := 'Test@test.com';
        EmailRecipient."Email Message Id" := EmailMessage.GetId();
        EmailRecipient."Email Recipient Type" := "Email Recipient Type"::"To";
        EmailRecipient.Insert();

        Assert.IsTrue(Email.Send(EmailMessage, Account), 'Email should send');
        Assert.IsTrue(EmailRecipient.ReadPermission(), 'Email Edit permissions must give read access to Sent Email');
        Assert.IsTrue(EmailOutbox.ReadPermission(), 'Email Edit permissions must give read access to Email OutBox');

        EmailOutbox.Init();
        EmailOutbox."Message Id" := CreateGuid();
        EmailOutbox."User Security Id" := CreateGuid();
        EmailOutbox."Send From" := 'TEST';
        EmailOutbox.Status := Enum::"Email Status"::Draft;
        EmailOutbox.Insert();

        // We have direct permission for both
        Email.AddRelation(EmailMessage, Database::"Email Recipient", EmailRecipient.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        Email.AddRelation(EmailMessage, Database::"Email Outbox", EmailOutbox.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        // [Then] Email is send
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        Assert.AreEqual(SentEmail.Count, 1, 'Only single email should be in sent');
        SentEmail."User Security Id" := CreateGuid();
        SentEmail.Modify();

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        SentEmailsPage.GoToRecord(SentEmail);
        // [Then] Email is shown in sent emails page
        Assert.IsTrue(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should be visible to user per policy');

        // [Then] Email can be opened by email viewer
        EmailViewer.Trap();
        SentEmailsPage.Desc.Drilldown();
    end;

    [Test]
    procedure AllRelatedRecordsEmailPolicyNotAccessToAllSentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        SentEmail: Record "Sent Email";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailViewer: Codeunit "Email Viewer";
        SentEmailsPage: TestPage "Sent Emails";
    begin
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Scenario] User is given own email policy and can therefore see emails that he send
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllRelatedRecordsEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, Account), 'Email should send');

        SentEmail.Init();
        SentEmail."Message Id" := CreateGuid();
        SentEmail."User Security Id" := CreateGuid();
        SentEmail."Sent From" := 'TEST';
        SentEmail.Insert();

        // We have direct permission for sent emails, but not for email message
        Email.AddRelation(EmailMessage, Database::"Sent Email", SentEmail.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        Email.AddRelation(EmailMessage, Database::"Email Message", CreateGuid(), Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        // [Then] Email is send
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        SentEmail."User Security Id" := CreateGuid();
        SentEmail.Modify();

        PermissionsMock.Set('Email View Perm');

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] Email is not shown in sent emails page
        Assert.IsFalse(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should not be visible to user per policy');

        // [Then] Email can not be opened by email viewer
        asserterror EmailViewer.Open(SentEmail);
        Assert.ExpectedError(EmailViewerErr);
    end;

    [Test]
    procedure AllRelatedRecordsEmailPolicyNoRelatedRecordsOnSentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailRelatedRecord: Record "Email Related Record";
        SentEmail: Record "Sent Email";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailViewer: Codeunit "Email Viewer";
        SentEmailsPage: TestPage "Sent Emails";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllRelatedRecordsEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, Account), 'Email should send');

        // [Then] Email is send from random user
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        SentEmail."User Security Id" := CreateGuid();
        SentEmail.Modify();

        // Remove all related records
        EmailRelatedRecord.SetRange("Email Message Id", EmailMessage.GetId());
        EmailRelatedRecord.DeleteAll();

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] Email is not shown in sent emails page because it had no related records
        Assert.IsFalse(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should not be visible to user per policy');

        // [Then] Email can not be opened by email viewer
        asserterror EmailViewer.Open(SentEmail);
        Assert.ExpectedError(EmailViewerErr);
    end;

    [Test]
    procedure AnyRelatedRecordsEmailPolicySentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        SentEmail: Record "Sent Email";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        SentEmailsPage: TestPage "Sent Emails";
        EmailViewer: TestPage "Email Viewer";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AnyRelatedRecordEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, Account), 'Email should send');
        Assert.IsTrue(SentEmail.ReadPermission(), 'Email Edit permissions must give read access to Sent Email');

        SentEmail.Init();
        SentEmail."Message Id" := CreateGuid();
        SentEmail."User Security Id" := CreateGuid();
        SentEmail."Sent From" := 'TEST';
        SentEmail.Insert();

        Email.AddRelation(EmailMessage, Database::"Sent Email", SentEmail.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");

        // [Then] Email is send
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        SentEmail."User Security Id" := CreateGuid();
        SentEmail.Modify();

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] Email is shown in sent emails page
        Assert.IsTrue(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should be visible to user per policy');

        // [Then] Email can be opened by email viewer
        EmailViewer.Trap();
        SentEmailsPage.Desc.Drilldown();
    end;

    [Test]
    procedure AnyRelatedRecordsEmailPolicyNotAccessToAllSentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        SentEmail: Record "Sent Email";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        SentEmailsPage: TestPage "Sent Emails";
        EmailViewer: TestPage "Email Viewer";
    begin
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Scenario] User is given any email policy and can therefore see emails that he send
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        // We use this as it gives access to word template table
        PermissionsMock.Set('Email View Perm');

        // [Given] The any email policy is set
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AnyRelatedRecordEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, Account), 'Email should send');

        SentEmail.Init();
        SentEmail."Message Id" := CreateGuid();
        SentEmail."User Security Id" := CreateGuid();
        SentEmail."Sent From" := 'TEST';
        SentEmail.Insert();

        // We have direct permission for sent emails, but not for email message
        Email.AddRelation(EmailMessage, Database::"Sent Email", SentEmail.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        Email.AddRelation(EmailMessage, Database::"Email Message", CreateGuid(), Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        // [Then] Email is send
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        Assert.AreEqual(SentEmail.Count, 1, 'Only single email should be in sent');
        SentEmail."User Security Id" := CreateGuid();
        SentEmail.Modify();

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] Email is shown in sent emails page
        Assert.IsTrue(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should be visible to user per policy');

        // [Then] Email can be opened by email viewer
        EmailViewer.Trap();
        SentEmailsPage.Desc.Drilldown();
    end;

    [Test]
    procedure AnyRelatedRecordsEmailPolicyNoRelatedRecordOnSentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailRelatedRecord: Record "Email Related Record";
        SentEmail: Record "Sent Email";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailViewer: Codeunit "Email Viewer";
        SentEmailsPage: TestPage "Sent Emails";
    begin
        // [Scenario] User has set any related email policy and can therefore see emails that has no relations on them
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] The any email policy is set
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AnyRelatedRecordEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, Account), 'Email should send');
        Assert.IsTrue(SentEmail.ReadPermission(), 'Email Edit permissions must give read access to Sent Email');

        // [Then] Email is send
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        SentEmail."User Security Id" := CreateGuid();
        SentEmail.Modify();

        // Remove all related records
        EmailRelatedRecord.SetRange("Email Message Id", EmailMessage.GetId());
        EmailRelatedRecord.DeleteAll();

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] Email is not shown in sent emails page
        Assert.IsFalse(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should not be visible to user per policy');

        // [Then] Email can not be opened by email viewer
        asserterror EmailViewer.Open(SentEmail);
        Assert.ExpectedError(EmailViewerErr);
    end;

    [Test]
    procedure OwnEmailPolicyOutboxEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailOutbox: Record "Email Outbox";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailOutboxPage: TestPage "Email Outbox";
        EmailEditor: TestPage "Email Editor";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that is in outbox
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');
        EmailOutbox.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::OwnEmails;
        EmailViewPolicy.Insert();

        // [When]  Create email and save email to outbox
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage);

        // [Then] Email is in outbox
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'Email should be in outbox');

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is shown in email outbox page
        Assert.IsTrue(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should be visible to user per policy');

        // [Then] Email can be opened by email viewer
        EmailEditor.Trap();
        EmailOutboxPage.Desc.Drilldown();
    end;

    [Test]
    procedure OwnEmailPolicyFailToSeeOthersOutboxEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailOutbox: Record "Email Outbox";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        EmailEditor: Codeunit "Email Editor";
        Email: Codeunit Email;
        EmailOutboxPage: TestPage "Email Outbox";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that is in outbox
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');
        EmailOutbox.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::OwnEmails;
        EmailViewPolicy.Insert();

        // [When]  Create email and save email to outbox
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage);

        // [Then] Email is in outbox
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'Email should be in outbox');
        EmailOutbox."User Security Id" := CreateGuid();
        EmailOutbox.Modify();

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is shown in email outbox page
        Assert.IsFalse(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should not be visible to user per policy');

        // [Then] Email can not be opened by email editor
        asserterror EmailEditor.Open(EmailOutbox, true);
        Assert.ExpectedError(EmailViewerErr);
    end;

    [Test]
    procedure AllEmailPolicyOutboxEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailOutbox: Record "Email Outbox";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailOutboxPage: TestPage "Email Outbox";
        EmailEditor: TestPage "Email Editor";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that is in outbox
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');
        EmailOutbox.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllEmails;
        EmailViewPolicy.Insert();

        // [When]  Create email and save email to outbox
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage);

        // [Then] Email is in outbox
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'Email should be in outbox');

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is shown in email outbox page
        Assert.IsTrue(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should be visible to user per policy');

        // [Then] Email can be opened by email viewer
        EmailEditor.Trap();
        EmailOutboxPage.Desc.Drilldown();
    end;

    [Test]
    procedure AllEmailPolicyOtherUsersOutboxEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailOutbox: Record "Email Outbox";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailOutboxPage: TestPage "Email Outbox";
        EmailEditor: TestPage "Email Editor";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that is in outbox
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');
        EmailOutbox.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllEmails;
        EmailViewPolicy.Insert();

        // [When]  Create email and save email to outbox
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage);

        // [Then] Email is in outbox
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'Email should be in outbox');
        EmailOutbox."User Security Id" := CreateGuid();
        EmailOutbox.Modify();

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is shown in email outbox page
        Assert.IsTrue(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should be visible to user per policy');

        // [Then] Email can be opened by email viewer
        EmailEditor.Trap();
        EmailOutboxPage.Desc.Drilldown();
    end;

    [Test]
    procedure AllRelatedRecordsEmailPolicyOutboxEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailOutbox: Record "Email Outbox";
        EmailRecipient: Record "Email Recipient";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailOutboxPage: TestPage "Email Outbox";
        EmailEditor: TestPage "Email Editor";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that is in outbox
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');

        EmailOutbox.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllRelatedRecordsEmails;
        EmailViewPolicy.Insert();

        // [When]  Create email and save email to outbox
        CreateEmail(EmailMessage);

        EmailRecipient.Init();
        EmailRecipient."Email Address" := 'Test@test.com';
        EmailRecipient."Email Message Id" := EmailMessage.GetId();
        EmailRecipient."Email Recipient Type" := "Email Recipient Type"::"To";
        EmailRecipient.Insert();

        Email.SaveAsDraft(EmailMessage);

        EmailOutbox.Init();
        EmailOutbox."Message Id" := CreateGuid();
        EmailOutbox."User Security Id" := CreateGuid();
        EmailOutbox."Send From" := 'TEST';
        EmailOutbox.Status := Enum::"Email Status"::Draft;
        EmailOutbox.Insert();

        // We have direct permission for both
        Email.AddRelation(EmailMessage, Database::"Email Recipient", EmailRecipient.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        Email.AddRelation(EmailMessage, Database::"Email Outbox", EmailOutbox.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        // [Then] Email is in outbox
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'Email should be in outbox');
        EmailOutbox."User Security Id" := CreateGuid();
        EmailOutbox.Modify();

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is shown in email outbox page
        Assert.IsTrue(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should be visible to user per policy');

        // [Then] Email can be opened by email viewer
        EmailEditor.Trap();
        EmailOutboxPage.Desc.Drilldown();
    end;

    [Test]
    procedure AllRelatedRecordsEmailPolicyNotAccessToAllOutboxEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailEditor: Codeunit "Email Editor";
        EmailOutboxPage: TestPage "Email Outbox";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that is in outbox
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');

        EmailOutbox.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllRelatedRecordsEmails;
        EmailViewPolicy.Insert();

        // [When]  Create email and save email to outbox
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage);

        SentEmail.Init();
        SentEmail."Message Id" := CreateGuid();
        SentEmail."User Security Id" := CreateGuid();
        SentEmail."Sent From" := 'TEST';
        SentEmail.Insert();

        // We have direct permission for sent emails, but not for email message
        Email.AddRelation(EmailMessage, Database::"Sent Email", SentEmail.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        Email.AddRelation(EmailMessage, Database::"Email Message", CreateGuid(), Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        // [Then] Email is in outbox
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'Email should be in outbox');
        EmailOutbox."User Security Id" := CreateGuid();
        EmailOutbox.Modify();

        PermissionsMock.Set('Email View Perm');

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is not shown in email outbox page
        Assert.IsFalse(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should not be visible to user per policy');

        // [Then] Email can not be opened by email viewer
        asserterror EmailEditor.Open(EmailOutbox, true);
        Assert.ExpectedError(EmailViewerErr);
    end;

    [Test]
    procedure AllRelatedRecordsEmailPolicyNoRelatedRecordsOnOutboxEmailsTest()
    var
        EmailRelatedRecord: Record "Email Related Record";
        EmailViewPolicy: Record "Email View Policy";
        EmailOutbox: Record "Email Outbox";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailEditor: Codeunit "Email Editor";
        EmailOutboxPage: TestPage "Email Outbox";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that is in outbox
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');

        EmailOutbox.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllRelatedRecordsEmails;
        EmailViewPolicy.Insert();

        // [When]  Create email and save email to outbox
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage);

        // [Then] Email is in outbox
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'Email should be in outbox');
        EmailOutbox."User Security Id" := CreateGuid();
        EmailOutbox.Modify();

        // Remove all related records
        EmailRelatedRecord.SetRange("Email Message Id", EmailMessage.GetId());
        EmailRelatedRecord.DeleteAll();

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is not shown in email outbox page
        Assert.IsFalse(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should not be visible to user per policy');

        // [Then] Email can not be opened by email viewer
        asserterror EmailEditor.Open(EmailOutbox, true);
        Assert.ExpectedError(EmailViewerErr);
    end;

    [Test]
    procedure AnyRelatedRecordsEmailPolicyOutboxEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailOutboxPage: TestPage "Email Outbox";
        EmailEditor: TestPage "Email Editor";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');

        EmailOutbox.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AnyRelatedRecordEmails;
        EmailViewPolicy.Insert();

        // [When]  Create email and save email to outbox
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage);

        SentEmail.Init();
        SentEmail."Message Id" := CreateGuid();
        SentEmail."User Security Id" := CreateGuid();
        SentEmail."Sent From" := 'TEST';
        SentEmail.Insert();

        Email.AddRelation(EmailMessage, Database::"Sent Email", SentEmail.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");

        // [Then] Email is in outbox
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'Email should be in outbox');
        EmailOutbox."User Security Id" := CreateGuid();
        EmailOutbox.Modify();

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is shown in email outbox page
        Assert.IsTrue(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should be visible to user per policy');

        // [Then] Email can be opened by email viewer
        EmailEditor.Trap();
        EmailOutboxPage.Desc.Drilldown();
    end;

    [Test]
    procedure AnyRelatedRecordsEmailPolicyNotAccessToAllOutboxEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailOutboxPage: TestPage "Email Outbox";
        EmailEditor: TestPage "Email Editor";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');

        EmailOutbox.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AnyRelatedRecordEmails;
        EmailViewPolicy.Insert();

        // [When]  Create email and save email to outbox
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage);

        SentEmail.Init();
        SentEmail."Message Id" := CreateGuid();
        SentEmail."User Security Id" := CreateGuid();
        SentEmail."Sent From" := 'TEST';
        SentEmail.Insert();

        // We have direct permission for sent emails, but not for email message
        Email.AddRelation(EmailMessage, Database::"Sent Email", SentEmail.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        Email.AddRelation(EmailMessage, Database::"Email Message", CreateGuid(), Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        // [Then] Email is in outbox
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'Email should be in outbox');
        EmailOutbox."User Security Id" := CreateGuid();
        EmailOutbox.Modify();

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is shown in email outbox page
        Assert.IsTrue(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should be visible to user per policy');

        // [Then] Email can be opened by email viewer
        EmailEditor.Trap();
        EmailOutboxPage.Desc.Drilldown();
    end;

    [Test]
    procedure AnyRelatedRecordsEmailPolicyNoRelatedRecordOnOutboxEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailRelatedRecord: Record "Email Related Record";
        EmailOutbox: Record "Email Outbox";
        Account: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailEditor: Codeunit "Email Editor";
        EmailOutboxPage: TestPage "Email Outbox";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        PermissionsMock.Set('Email View Perm');

        EmailOutbox.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AnyRelatedRecordEmails;
        EmailViewPolicy.Insert();

        // [When]  Create email and save email to outbox
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage);

        // [Then] Email is in outbox
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'Email should be in outbox');
        EmailOutbox."User Security Id" := CreateGuid();
        EmailOutbox.Modify();

        // Remove all related records
        EmailRelatedRecord.SetRange("Email Message Id", EmailMessage.GetId());
        EmailRelatedRecord.DeleteAll();

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is not shown in email outbox page
        Assert.IsFalse(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should not be visible to user per policy');

        // [Then] Email can not be opened by email viewer
        asserterror EmailEditor.Open(EmailOutbox, true);
        Assert.ExpectedError(EmailViewerErr);
    end;

    internal procedure CreateEmail(var EmailMessage: Codeunit "Email Message")
    var
        Any: Codeunit Any;
    begin
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
    end;

}
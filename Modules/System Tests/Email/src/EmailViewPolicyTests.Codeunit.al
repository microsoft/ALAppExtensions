// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Email;

using System.Email;
using System.TestLibraries.Email;
using System.Integration.Word;
using System.Security.AccessControl;
using System.TestLibraries.Utilities;
using System.TestLibraries.Security.AccessControl;

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
                  tabledata "Word Template" = rimd,
                  tabledata "Email Message" = rid;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        EmailViewerErr: Label 'You do not have permission to open the email message.';

    [Test]
    procedure OpenUserEmailViewPolicyPageDefaultPolicyTest()
    var
        EmailViewPolicyRecord: Record "Email View Policy";
        EmailViewPolicy: Codeunit "Email View Policy";
        EmailViewPolicyListPage: TestPage "Email View Policy List";
    begin
        // [Scenario] Opening User Email View Policies page does not change default policy
        // [Given] There exists a default Email View Policy
        EmailViewPolicyRecord.SetFilter("User Id", EmailViewPolicy.GetDefaultUserId());
        Assert.IsTrue(EmailViewPolicyRecord.FindFirst(), 'There should exist a default Email View Policy');
        Assert.AreEqual(Enum::"Email View Policy"::AllRelatedRecordsEmails, EmailViewPolicyRecord."Email View Policy", 'Default email view policy (for new tenant) should be All Related Records Emails');

        // [Given] User opens the User Email View Policies page
        EmailViewPolicyListPage.Trap();
        Page.Run(Page::"Email View Policy List");

        // [Then] The default Email View Policy remains unchanged
        Assert.AreEqual(Enum::"Email View Policy"::AllRelatedRecordsEmails, EmailViewPolicyRecord."Email View Policy", 'Default email view policy should still be All Related Records Emails');
    end;

    [Test]
    procedure OwnEmailPolicySentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        SentEmail: Record "Sent Email";
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        SentEmailsPage: TestPage "Sent Emails";
        EmailViewer: TestPage "Email Viewer";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::OwnEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, TempEmailAccount), 'Email should send');

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
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailViewer: Codeunit "Email Viewer";
        SentEmailsPage: TestPage "Sent Emails";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::OwnEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, TempEmailAccount), 'Email should send');

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
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        SentEmailsPage: TestPage "Sent Emails";
        EmailViewer: TestPage "Email Viewer";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, TempEmailAccount), 'Email should send');

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
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        SentEmailsPage: TestPage "Sent Emails";
        EmailViewer: TestPage "Email Viewer";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, TempEmailAccount), 'Email should send');

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
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        SentEmailsPage: TestPage "Sent Emails";
        EmailViewer: TestPage "Email Viewer";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

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

        Assert.IsTrue(Email.Send(EmailMessage, TempEmailAccount), 'Email should send');
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
        TempEmailAccount: Record "Email Account" temporary;
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
        ConnectorMock.AddAccount(TempEmailAccount);

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllRelatedRecordsEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);

        // We will have direct read permission for sent emails, but not for "Test Email Account"
        Email.AddRelation(EmailMessage, Database::"Sent Email", SentEmail.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        Email.AddRelation(EmailMessage, Database::"Test Email Account", CreateGuid(), Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        Assert.IsTrue(Email.Send(EmailMessage, TempEmailAccount), 'Email should be sent');

        // [Then] Email is sent
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        SentEmail."User Security Id" := CreateGuid();
        SentEmail.Modify();

        PermissionsMock.Start();
        PermissionsMock.Set('Email View Low Perm');

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
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailViewer: Codeunit "Email Viewer";
        SentEmailsPage: TestPage "Sent Emails";
    begin
        // [Scenario] User has set AllRelatedRecordsEmails email policy and cannot see other users' sent email that have no related records
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An AllRelatedRecordsEmails email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllRelatedRecordsEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, TempEmailAccount), 'Email should send');

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
    procedure AllRelatedRecordsEmailPolicyRelatedToUserOnSentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        SentEmail: Record "Sent Email";
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailViewer: Codeunit "Email Viewer";
        SentEmailsPage: TestPage "Sent Emails";
    begin
        // [Scenario] User has set AllRelatedRecordsEmails email policy and cannot see other users' sent emails even though they are related to the User table
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An AllRelatedRecordsEmails email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllRelatedRecordsEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, TempEmailAccount), 'Email should send');

        // [Then] Email is send from random user
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        SentEmail."User Security Id" := CreateGuid();
        SentEmail.Modify();

        // [When] There is a relation to a user
        Email.AddRelation(EmailMessage, Database::User, CreateGuid(), Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Email Address Lookup");

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] Email is still not shown in sent emails page because it had no related records
        Assert.IsFalse(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should not be visible to user per policy');

        // [Then] Email can still not be opened by email viewer
        asserterror EmailViewer.Open(SentEmail);
        Assert.ExpectedError(EmailViewerErr);
    end;

    [Test]
    procedure AnyRelatedRecordsEmailPolicySentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        RandomRelatedEntity, SentEmail : Record "Sent Email";
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        SentEmailsPage: TestPage "Sent Emails";
        EmailViewer: TestPage "Email Viewer";
    begin
        // [Scenario] User has set AnyRelatedRecordEmails policy and can therefore see emails from other user based on the related entities
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] The current user AnyRelatedRecordEmails email view policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AnyRelatedRecordEmails;
        EmailViewPolicy.Insert();

        // [When] The current user sends an email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, TempEmailAccount), 'Email should send');

        RandomRelatedEntity.Init();
        RandomRelatedEntity."Message Id" := CreateGuid();
        RandomRelatedEntity."User Security Id" := CreateGuid();
        RandomRelatedEntity."Sent From" := 'TEST';
        RandomRelatedEntity.Insert();

        // [When] A entity is related to the user and the user has read permissions for it
        Email.AddRelation(EmailMessage, Database::"Sent Email", RandomRelatedEntity.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        Assert.IsTrue(SentEmail.ReadPermission(), 'Email Edit permissions must give read access to Sent Email');

        // [When] There is an email from another user
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        SentEmail."User Security Id" := CreateGuid();  // Modify the sender to appear as the email was sent by another user
        SentEmail.Modify();

        // [When] The Sent Email page is opened by the current user
        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] The email from the other user is shown in sent emails page
        Assert.IsTrue(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should be visible to user per policy');

        // [Then] The sent email can be opened by the current user
        EmailViewer.Trap();
        SentEmailsPage.Desc.Drilldown();
        EmailViewer.Close();

        // [When] There are no email related records, except to the user
        Email.RemoveRelation(EmailMessage, Database::"Sent Email", RandomRelatedEntity.SystemId);

        // [When] The Sent Email page is opened by the current user
        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] The email (that is sent by another user) is not shown in sent emails page
        Assert.IsFalse(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should not be visible to user per policy');
    end;

    [Test]
    procedure AnyRelatedRecordsEmailPolicyNotAccessToAllSentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        RandomRelatedEntity, SentEmail : Record "Sent Email";
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        SentEmailsPage: TestPage "Sent Emails";
        EmailViewer: TestPage "Email Viewer";
        RandomGuid: Guid;
    begin
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Scenario] User is given AnyRelatedRecordEmails email policy and can therefore they cannot see other users' emails in they cannot access the related records. 
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email View Perm');

        // [Given] The any email policy is set
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AnyRelatedRecordEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, TempEmailAccount), 'Email should send');

        RandomRelatedEntity.Init();
        RandomRelatedEntity."Message Id" := CreateGuid();
        RandomRelatedEntity."User Security Id" := CreateGuid();
        RandomRelatedEntity."Sent From" := 'TEST';
        RandomRelatedEntity.Insert();

        // We have direct permission for sent emails, but not for email message
        RandomGuid := CreateGuid();
        Email.AddRelation(EmailMessage, Database::"Sent Email", RandomRelatedEntity.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        Email.AddRelation(EmailMessage, Database::"Email Message", RandomGuid, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        // [Then] Email is send
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        Assert.AreEqual(SentEmail.Count, 1, 'Only single email should be in sent');
        SentEmail."User Security Id" := CreateGuid();  // Modify the sender to appear as the email was sent by another user
        SentEmail.Modify();

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] Email is shown in sent emails page
        Assert.IsTrue(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should be visible to user per policy');

        // [Then] Email can be opened by email viewer
        EmailViewer.Trap();
        SentEmailsPage.Desc.Drilldown();
        EmailViewer.Close();

        SentEmailsPage.Close();

        // [When] The relation to Sent Email is removed
        Email.RemoveRelation(EmailMessage, Database::"Sent Email", RandomRelatedEntity.SystemId);

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] Email is not shown in sent emails page as the user cannot access the other related entity
        Assert.IsFalse(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should not be visible to user per policy');

        // [When] The relation to Email Message is removed
        Email.RemoveRelation(EmailMessage, Database::"Email Message", RandomGuid);

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] Email is not shown in sent emails page as there are not related entities
        Assert.IsFalse(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should be visible to user per policy');
    end;

    [Test]
    procedure AnyRelatedRecordsEmailPolicyNoRelatedRecordOnSentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailRelatedRecord: Record "Email Related Record";
        SentEmail: Record "Sent Email";
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailViewer: Codeunit "Email Viewer";
        SentEmailsPage: TestPage "Sent Emails";
    begin
        // [Scenario] User has set AnyRelatedRecordEmails related email policy and cannot therefore see other users' emails that have no related records
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] The AnyRelatedRecordEmails email policy is set
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AnyRelatedRecordEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, TempEmailAccount), 'Email should send');
        Assert.IsTrue(SentEmail.ReadPermission(), 'Email Edit permissions must give read access to Sent Email');

        // [Then] Email is send
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        SentEmail."User Security Id" := CreateGuid(); // Modify the sender to appear as the email was sent by another user
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
    procedure AnyRelatedRecordsEmailPolicyRelatedToUserOnSentEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        SentEmail: Record "Sent Email";
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailViewer: Codeunit "Email Viewer";
        SentEmailsPage: TestPage "Sent Emails";
        RandomGuid: Guid;
    begin
        // [Scenario] User has set AnyRelatedRecordEmails related email policy and cannot therefore see other users' emails that have relation to the User table
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email View Perm');
        SentEmail.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] The AnyRelatedRecordEmails email policy is set
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AnyRelatedRecordEmails;
        EmailViewPolicy.Insert();

        // [When] Create and send email
        CreateEmail(EmailMessage);
        Assert.IsTrue(Email.Send(EmailMessage, TempEmailAccount), 'Email should send');
        Assert.IsTrue(SentEmail.ReadPermission(), 'Email Edit permissions must give read access to Sent Email');

        // [Then] Email is send
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');

        RandomGuid := CreateGuid();
        SentEmail."User Security Id" := RandomGuid; // Modify the sender to appear as the email was sent by another user
        SentEmail.Modify();

        // [When] There is a relation to a user
        Email.AddRelation(EmailMessage, Database::User, RandomGuid, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Email Address Lookup");

        SentEmailsPage.Trap();
        Page.Run(Page::"Sent Emails");

        // [Then] Email is not still shown in sent emails page
        Assert.IsFalse(SentEmailsPage.GoToRecord(SentEmail), 'Sent email should not be visible to user per policy');

        // [Then] Email still can not be opened by email viewer
        asserterror EmailViewer.Open(SentEmail);
        Assert.ExpectedError(EmailViewerErr);
    end;

    [Test]
    procedure OwnEmailPolicyOutboxEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailOutbox: Record "Email Outbox";
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailOutboxPage: TestPage "Email Outbox";
        EmailEditor: TestPage "Email Editor";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that is in outbox
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

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
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        EmailEditor: Codeunit "Email Editor";
        Email: Codeunit Email;
        EmailOutboxPage: TestPage "Email Outbox";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that is in outbox
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

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
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailOutboxPage: TestPage "Email Outbox";
        EmailEditor: TestPage "Email Editor";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that is in outbox
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

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
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailOutboxPage: TestPage "Email Outbox";
        EmailEditor: TestPage "Email Editor";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that is in outbox
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

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
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailOutboxPage: TestPage "Email Outbox";
        EmailEditor: TestPage "Email Editor";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that is in outbox
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

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
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailEditor: Codeunit "Email Editor";
        EmailOutboxPage: TestPage "Email Outbox";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that is in outbox
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        EmailOutbox.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An own email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllRelatedRecordsEmails;
        EmailViewPolicy.Insert();

        // [When] Create email and save it to outbox
        CreateEmail(EmailMessage);

        // We will have direct read permission for sent emails, but not for "Test Email Account"
        Email.AddRelation(EmailMessage, Database::"Sent Email", CreateGuid(), Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        Email.AddRelation(EmailMessage, Database::"Test Email Account", CreateGuid(), Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        Email.SaveAsDraft(EmailMessage);

        // [Then] Email is in outbox
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'Email should be in outbox');
        EmailOutbox."User Security Id" := CreateGuid();
        EmailOutbox.Modify();

        PermissionsMock.Start();
        PermissionsMock.Set('Email View Low Perm');

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
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailEditor: Codeunit "Email Editor";
        EmailOutboxPage: TestPage "Email Outbox";
    begin
        // [Scenario] User has set AllRelatedRecordsEmails email policy and cannot therefore see other users' outbox emails that have no related records
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email View Perm');

        EmailOutbox.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An AllRelatedRecordsEmails email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllRelatedRecordsEmails;
        EmailViewPolicy.Insert();

        // [When]  Create email and save email to outbox
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage);

        // [Then] Email is in outbox
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'Email should be in outbox');
        EmailOutbox."User Security Id" := CreateGuid(); // Modify the sender to appear as the email was created by another user
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

        EmailOutboxPage.Close();

        // [When] There is a relation to a user
        Email.AddRelation(EmailMessage, Database::User, CreateGuid(), Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Email Address Lookup");

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is still not shown in email outbox page
        Assert.IsFalse(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should still not be visible to user per policy');

        // [Then] Email can still not be opened by email viewer
        asserterror EmailEditor.Open(EmailOutbox, true);
        Assert.ExpectedError(EmailViewerErr);
    end;

    [Test]
    procedure AnyRelatedRecordsEmailPolicyOutboxEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailOutboxPage: TestPage "Email Outbox";
        EmailEditor: TestPage "Email Editor";
    begin
        // [Scenario] User has set own email policy and can therefore see emails that he send
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

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
        EmailEditor.Close();
    end;

    [Test]
    procedure AnyRelatedRecordsEmailPolicyNotAccessToAllOutboxEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailOutbox: Record "Email Outbox";
        RandomRelatedEntity: Record "Sent Email";
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailOutboxPage: TestPage "Email Outbox";
        EmailEditor: TestPage "Email Editor";
        RandomGuid: Guid;
    begin
        // [Scenario] User has set AnyRelatedRecordEmails email policy and can therefore see emails from other users only if the current user can access any of the related entities
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email View Perm');

        EmailOutbox.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] The current user has AnyRelatedRecordEmails email view policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AnyRelatedRecordEmails;
        EmailViewPolicy.Insert();

        // [When] Create email and save email to outbox
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage);

        RandomRelatedEntity.Init();
        RandomRelatedEntity."Message Id" := CreateGuid();
        RandomRelatedEntity."User Security Id" := CreateGuid();
        RandomRelatedEntity."Sent From" := 'TEST';
        RandomRelatedEntity.Insert();

        // We have direct permission for sent emails, but not for email message
        RandomGuid := CreateGuid();
        Email.AddRelation(EmailMessage, Database::"Sent Email", RandomRelatedEntity.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        Email.AddRelation(EmailMessage, Database::"Email Message", RandomGuid, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        // [Then] Email is in outbox
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'Email should be in outbox');
        EmailOutbox."User Security Id" := CreateGuid(); // Modify the sender to appear as the email outbox was created by another user
        EmailOutbox.Modify();

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is shown in email outbox page
        Assert.IsTrue(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should be visible to user per policy');

        // [Then] Email can be opened by email viewer
        EmailEditor.Trap();
        EmailOutboxPage.Desc.Drilldown();
        EmailEditor.Close();

        EmailOutboxPage.Close();

        // [When] The relation to the Sent Email is removed
        Email.RemoveRelation(EmailMessage, Database::"Sent Email", RandomRelatedEntity.SystemId);

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is not shown in email outbox page as the current user cannot access the related entity
        Assert.IsFalse(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should be visible to user per policy');

        EmailOutboxPage.Close();

        // [When] The relation to the Sent Email is removed
        Email.RemoveRelation(EmailMessage, Database::"Email Message", RandomGuid);

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is not shown in email outbox page as there are no related entities
        Assert.IsFalse(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should be visible to user per policy');
    end;

    [Test]
    procedure AnyRelatedRecordsEmailPolicyNoRelatedRecordOnOutboxEmailsTest()
    var
        EmailViewPolicy: Record "Email View Policy";
        EmailRelatedRecord: Record "Email Related Record";
        EmailOutbox: Record "Email Outbox";
        TempEmailAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailEditor: Codeunit "Email Editor";
        EmailOutboxPage: TestPage "Email Outbox";
    begin
        // [Scenario] User has set AnyRelatedRecordEmails email policy and therefore cannot see other users' outbox emails that have no related records
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email View Perm');

        EmailOutbox.DeleteAll();
        EmailViewPolicy.DeleteAll();

        // [Given] An AnyRelatedRecordEmails email policy
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AnyRelatedRecordEmails;
        EmailViewPolicy.Insert();

        // [When]  Create email and save email to outbox
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage);

        // [Then] Email is in outbox
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.FindFirst(), 'Email should be in outbox');
        EmailOutbox."User Security Id" := CreateGuid();  // Modify the sender to appear as the email was sent by another user
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

        EmailOutboxPage.Close();

        // [When] There is a relation to a user
        Email.AddRelation(EmailMessage, Database::User, CreateGuid(), Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Email Address Lookup");

        EmailOutboxPage.Trap();
        Page.Run(Page::"Email Outbox");

        // [Then] Email is still not shown in email outbox page
        Assert.IsFalse(EmailOutboxPage.GoToRecord(EmailOutbox), 'Outbox email should still not be visible to user per policy');

        // [Then] Email can still not be opened by email viewer
        asserterror EmailEditor.Open(EmailOutbox, true);
        Assert.ExpectedError(EmailViewerErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure GetEmailMessageIdFiltersOneEntryTest()
    var
        EmailMessageRecord: Record "Email Message";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailRelatedRecordQuery: Query "Email Related Record";
        EmailMessageIDsFilters: List of [Text];
        Iterator: Integer;
    begin
        Initialize();

        // [GIVEN] Five email messages are created (with 2 email related records each)
        for Iterator := 1 to 5 do begin
            CreateEmail(EmailMessage);
            Email.AddRelation(EmailMessage, Database::"User", CreateGuid(), Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
            Email.AddRelation(EmailMessage, Database::"Email Related Record Test", CreateGuid(), Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");
        end;

        // [WHEN] The filters for email message ID field are retrieved
        EmailMessageIDsFilters := EmailRelatedRecordQuery.GetEmailMessageIdFilters(6);

        // [THEN] We have 1 filter text in the lis - with 5 elements
        Assert.AreEqual(1, EmailMessageIDsFilters.Count(), 'Expected to have 1 filter text in the list.');

        EmailMessageRecord.SetFilter(Id, EmailMessageIDsFilters.Get(1));
        Assert.AreEqual(5, EmailMessageRecord.Count(), 'Expected to have 5 email messages within the filter.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure GetEmailMessageIdFiltersMultipleEntriesTest()
    var
        EmailMessageRecord: Record "Email Message";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailRelatedRecordQuery: Query "Email Related Record";
        EmailMessageIDsFilters: List of [Text];
        Iterator: Integer;
    begin
        Initialize();

        // [GIVEN] 7 email messages are created (with 2 email related records each)
        for Iterator := 1 to 7 do begin
            CreateEmail(EmailMessage);
            Email.AddRelation(EmailMessage, Database::"User", CreateGuid(), Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
            Email.AddRelation(EmailMessage, Database::"Email Related Record Test", CreateGuid(), Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");
        end;

        // [WHEN] The filters for email message ID field are retrieved
        EmailMessageIDsFilters := EmailRelatedRecordQuery.GetEmailMessageIdFilters(3);

        // [THEN] We have 3 filter texts in the list: two with 3 elements, and one with 1 element
        Assert.AreEqual(3, EmailMessageIDsFilters.Count(), 'Expected to have 3 filter texts in the list.');

        EmailMessageRecord.SetFilter(Id, EmailMessageIDsFilters.Get(1));
        Assert.AreEqual(3, EmailMessageRecord.Count(), 'Expected to have 3 email messages within the filter.');

        EmailMessageRecord.SetFilter(Id, EmailMessageIDsFilters.Get(2));
        Assert.AreEqual(3, EmailMessageRecord.Count(), 'Expected to have 3 email messages within the filter.');

        EmailMessageRecord.SetFilter(Id, EmailMessageIDsFilters.Get(3));
        Assert.AreEqual(1, EmailMessageRecord.Count(), 'Expected to have 1 email messages within the filter.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure GetSentEmailsTest()
    var
        SentEmail: Record "Sent Email";
        TempSentEmailOutput: Record "Sent Email" temporary;
        EmailViewPolicy: Codeunit "Email View Policy";
        UserSecurityIDs: List of [Guid];
        TestUserSecurityID: Guid;
        Iterator: Integer;
    begin
        Initialize();

        // [GIVEN] There are 5 sent emails with senders: "Sender 1", ..., "Sender 5"
        for Iterator := 1 to 5 do begin
            SentEmail.Id := Iterator;
            TestUserSecurityID := CreateGuid();
            SentEmail."User Security Id" := TestUserSecurityID;
            UserSecurityIDs.Add(TestUserSecurityID);
            SentEmail.Insert();
        end;

        // [WHEN] Sent emails are retrived
        EmailViewPolicy.GetSentEmails(TempSentEmailOutput);
        // [THEN] All 5 sent emails are present in the ouput
        Assert.AreEqual(5, TempSentEmailOutput.Count(), 'Expected to retrieve 5 sent emails.');

        // [GIVEN] A filter is applied to the User Security ID field of the out parameter
        TempSentEmailOutput.SetRange("User Security Id", UserSecurityIDs.Get(1));
        // [WHEN] Sent emails are retrived
        EmailViewPolicy.GetSentEmails(TempSentEmailOutput);
        // [THEN] Only one sent email is present in the output
        Assert.AreEqual(1, TempSentEmailOutput.Count(), 'Expected to retrieve 1 sent email.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure GetOutboxEmailsTest()
    var
        EmailOutbox: Record "Email Outbox";
        TempEmailOutboxOutput: Record "Email Outbox" temporary;
        EmailViewPolicy: Codeunit "Email View Policy";
        UserSecurityIDs: List of [Guid];
        TestUserSecurityID: Guid;
        Iterator: Integer;
    begin
        Initialize();

        // [GIVEN] There are 5 outbox emails with senders: "Sender 1", ..., "Sender 5"
        for Iterator := 1 to 5 do begin
            EmailOutbox.Id := Iterator;
            TestUserSecurityID := CreateGuid();
            EmailOutbox."User Security Id" := TestUserSecurityID;
            UserSecurityIDs.Add(TestUserSecurityID);
            EmailOutbox.Insert();
        end;

        // [WHEN] Outbox emails are retrived
        EmailViewPolicy.GetOutboxEmails(TempEmailOutboxOutput);
        // [THEN] All 5 outbox emails are present in the ouput
        Assert.AreEqual(5, TempEmailOutboxOutput.Count(), 'Expected to retrieve 5 outbox emails.');

        // [GIVEN] A filter is applied to the User Security ID field of the out parameter
        TempEmailOutboxOutput.SetRange("User Security Id", UserSecurityIDs.Get(1));
        // [WHEN] Outbox emails are retrived
        EmailViewPolicy.GetOutboxEmails(TempEmailOutboxOutput);
        // [THEN] Only one outbox email is present in the output
        Assert.AreEqual(1, TempEmailOutboxOutput.Count(), 'Expected to retrieve 1 outbox email.');
    end;

    local procedure Initialize()
    var
        SentEmail: Record "Sent Email";
        EmailOutbox: Record "Email Outbox";
        EmailRelatedRecord: Record "Email Related Record";
        EmailMessageRecord: Record "Email Message";
    begin
        PermissionsMock.Start();
        PermissionsMock.Set('Email Admin');
        SentEmail.DeleteAll();
        EmailOutbox.DeleteAll();
        EmailMessageRecord.DeleteAll();
        EmailRelatedRecord.DeleteAll();
    end;

    internal procedure CreateEmail(var EmailMessage: Codeunit "Email Message")
    var
        Any: Codeunit Any;
    begin
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
    end;
}
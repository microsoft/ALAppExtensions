// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Email;

using System.Email;
using System.TestLibraries.Email;
using System.Utilities;
using System.TestLibraries.Utilities;
using System.TestLibraries.Security.AccessControl;

codeunit 134853 "Email Default Attachment Tests"
{
    Subtype = Test;
    Permissions = tabledata "Email Scenario" = r,
                tabledata "Email Scenario Attachments" = rimd,
                tabledata "Email Attachments" = rimd,
                tabledata "Email Message" = rm;

    var
        Assert: Codeunit "Library Assert";
        ConnectorMock: Codeunit "Connector Mock";
        EmailScenarioMock: Codeunit "Email Scenario Mock";
        // Email: Codeunit Email;
        EmailScenario: Codeunit "Email Scenario";
        EmailScenarioAttachImpl: Codeunit "Email Scenario Attach Impl.";
        PermissionsMock: Codeunit "Permissions Mock";

    [Test]
    [Scope('OnPrem')]
    procedure SetUpEmailScenarioWithNoAttachments()
    var
        EmailAccount: Record "Email Account";
        EmailAttachment: Record "Email Attachments";
        EmailScenarioAttachment: Record "Email Scenario Attachments";
        TempBLob: Codeunit "Temp Blob";
        AccountId: Guid;
        InStream: InStream;
    begin
        // [Scenario] Set up an email account with scenario without attachments. GetEmailAttachmentsByEmailScenarios will get nothing.
        PermissionsMock.Set('Email Admin');

        // [Given] A test email scenario has be assigned to the account.
        Initialize();
        TempBLob.CreateInStream(InStream);
        ConnectorMock.AddAccount(AccountId);

        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::"Test Email Scenario", AccountId, Enum::"Email Connector"::"Test Email Connector");

        // [When] calling GetEmailAccount
        // [Then] true is retuned and the email account is as expected
        Assert.IsTrue(EmailScenario.GetEmailAccount(Enum::"Email Scenario"::"Test Email Scenario", EmailAccount), 'There should be an email account');
        Assert.AreEqual(AccountId, EmailAccount."Account Id", 'Wrong account ID');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", EmailAccount.Connector, 'Wrong connector');

        // [Then] the Email Scenario Attachments table should be empty
        Assert.IsTrue(EmailScenarioAttachment.IsEmpty(), 'The Email Scenario Attachment should be empty');

        // [When] calling GetEmailAttachmentsByEmailScenario
        // [Then] Get the Attachment and the number of the email attachment should be 0
        EmailScenarioAttachImpl.GetEmailAttachmentsByEmailScenarios(EmailAttachment, Enum::"Email Scenario"::"Test Email Scenario".AsInteger());
        Assert.AreEqual(EmailAttachment.Count(), 0, 'Wrong Attachment Number');

    end;

    [Test]
    [Scope('OnPrem')]
    procedure SetTwoEmailAttachmentsWithOneDefault()
    var
        EmailAccount: Record "Email Account";
        EmailScenarioAttachments: Record "Email Scenario Attachments";
        EmailAttachments: Record "Email Attachments";
        Document: Codeunit "Temp Blob";
        AccountId: Guid;
        OutStream: OutStream;
        InStream: InStream;
    begin
        // [Scenario] Set the attachments to the scenario. GetEmailAttachmentsByEmailScenarios will returns the attachments realated to the scenario
        PermissionsMock.Set('Email Admin');

        // [Given] A test email scenario has be assigned to the account and add one email attachment to the scenario
        Initialize();
        Document.CreateOutStream(OutStream);
        OutStream.WriteText('Content');
        Document.CreateInStream(InStream);
        ConnectorMock.AddAccount(AccountId);

        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::"Test Email Scenario", AccountId, Enum::"Email Connector"::"Test Email Connector");
        AddAttachment('Attachment1', InStream, Enum::"Email Scenario"::"Test Email Scenario", true);
        AddAttachment('Attachment2', InStream, Enum::"Email Scenario"::"Test Email Scenario", false);

        // [When] calling GetEmailAccount
        // [Then] true is retuned and the email account is as expected
        Assert.IsTrue(EmailScenario.GetEmailAccount(Enum::"Email Scenario"::"Test Email Scenario", EmailAccount), 'There should be an email account');
        Assert.AreEqual(AccountId, EmailAccount."Account Id", 'Wrong account ID');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", EmailAccount.Connector, 'Wrong connector');

        // [Then] There should be two record in the EmailScenarioAttachments Table
        Assert.AreEqual(2, EmailScenarioAttachments.Count(), 'Wrong total attachment number');

        // [When] calling GetEmailAttachmentsByEmailScenario
        // [Then] Get the default attachment and the number of the email attachment should be 1 and 
        EmailScenarioAttachImpl.GetEmailAttachmentsByEmailScenarios(EmailAttachments, Enum::"Email Scenario"::"Test Email Scenario".AsInteger());
        Assert.AreEqual(2, EmailAttachments.Count(), 'Wrong current attachment number');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DefaultScenarioShowAllAttachments()
    var
        EmailScenarioAttachments: Record "Email Scenario Attachments";
        EmailAttachments: Record "Email Attachments";
        Document: Codeunit "Temp Blob";
        AccountId: Guid;
        DefaultAccountId: Guid;
        OutStream: OutStream;
        InStream: InStream;
    begin
        // [Scenario] Set the attachments to the scenario. GetEmailAttachmentsByEmailScenarios will returns the attachments realated to the scenario
        PermissionsMock.Set('Email Admin');

        // [Given] Two email account with different scenarios. Each of the scenarios has one attachment.
        Initialize();
        Document.CreateOutStream(OutStream);
        OutStream.WriteText('Content');
        Document.CreateInStream(InStream);
        ConnectorMock.AddAccount(AccountId);
        ConnectorMock.AddAccount(DefaultAccountId);

        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::"Test Email Scenario", AccountId, Enum::"Email Connector"::"Test Email Connector");
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::Default, DefaultAccountId, Enum::"Email Connector"::"Test Email Connector");
        AddAttachment('Attachment1', InStream, Enum::"Email Scenario"::"Test Email Scenario", false);

        // [Then] There should be two record in the EmailScenarioAttachments Table
        Assert.AreEqual(1, EmailScenarioAttachments.Count(), 'Wrong total attachment number');

        // [When] calling GetEmailAttachmentsByEmailScenario
        // [Then] Get the attachment and the number of the email attachment should be 1 and with right status
        EmailScenarioAttachImpl.GetEmailAttachmentsByEmailScenarios(EmailAttachments, Enum::"Email Scenario"::"Test Email Scenario".AsInteger());
        Assert.AreEqual(EmailAttachments.AttachmentDefaultStatus, false, 'The status of the attachment should be not default');
        Assert.AreEqual(1, EmailAttachments.Count(), 'Wrong current attachment number');

        // [When] The default account have only default scenario. Calling GetEmailAttachmentsByEmailScenario
        // [Then] For default scenario, return all the attachment for all scenarios
        EmailScenarioAttachImpl.GetEmailAttachmentsByEmailScenarios(EmailAttachments, Enum::"Email Scenario"::"Default".AsInteger());
        Assert.AreEqual(EmailAttachments.AttachmentDefaultStatus, false, 'The status of the attachment should be default');
        Assert.AreEqual(1, EmailAttachments.Count(), 'Wrong current attachment number');
    end;


    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SetTwoAttachmentsWithOneDefaultForScenarioMessage()
    var
        TempAccount: Record "Email Account" temporary;
        EmailMessage: Codeunit "Email Message";
        Document: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
        Result: Text;

    begin
        // [Scenario] Set the attachments to the scenario. GetEmailAttachmentsByEmailScenarios will returns the attachments realated to the scenario
        PermissionsMock.Set('Email Admin');
        Initialize();

        // [Given] An email account with test scenario. The scenario has  two attachments with only one default attachment.
        ConnectorMock.AddAccount(TempAccount);

        Document.CreateOutStream(OutStream);
        OutStream.WriteText('Content');
        Document.CreateInStream(InStream);

        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::"Test Email Scenario", TempAccount."Account Id", Enum::"Email Connector"::"Test Email Connector");
        AddAttachment('Attachment1', InStream, Enum::"Email Scenario"::"Test Email Scenario", true);
        AddAttachment('Attachment2', InStream, Enum::"Email Scenario"::"Test Email Scenario", false);

        // [Given] A email message under test scenario
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');
        EmailScenarioAttachImpl.AddAttachmentToMessage(EmailMessage, Enum::"Email Scenario"::"Test Email Scenario");

        // [Then] The email attachment should only has one default attachment. The attachment that is not default will not be added
        Assert.IsTrue(EmailMessage.Attachments_First(), 'There should be one default attachment');
        EmailMessage.Attachments_GetContent(InStream);
        InStream.ReadText(Result);
        Assert.AreEqual('Attachment1', EmailMessage.Attachments_GetName(), 'A different attachment name was expected');
        Assert.AreEqual('Content', Result, 'A different attachment content was expected');
        Assert.AreEqual(7, EmailMessage.Attachments_GetLength(), 'A different attachment length was expected');

        Assert.IsTrue(EmailMessage.Attachments_Next() = 0, 'The not default attachment should not be added to the message');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OpenEmailChooseScenarioAttachPageWithNoScenario()
    var
        EmailScenarioAttachments: Record "Email Scenario Attachments";
        Document: Codeunit "Temp Blob";
        EmailChooseScenarioAttachment: TestPage "Email Choose Scenario Attach";
        OutStream: OutStream;
        InStream: InStream;
        AccountId: Guid;
        DefaultAccountId: Guid;
    begin
        // [Scenario] Set the attachments to the scenario. GetEmailAttachmentsByEmailScenarios will returns the attachments realated to the scenario
        PermissionsMock.Set('Email Admin');

        // [Given] Two email account with different scenarios. Each of the scenarios has one not default attachment.
        Initialize();
        Document.CreateOutStream(OutStream);
        OutStream.WriteText('Content');
        Document.CreateInStream(InStream);
        ConnectorMock.AddAccount(AccountId);
        ConnectorMock.AddAccount(DefaultAccountId);

        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::"Test Email Scenario", AccountId, Enum::"Email Connector"::"Test Email Connector");
        AddAttachment('Attachment1', InStream, Enum::"Email Scenario"::"Test Email Scenario", false);
        AddAttachment('Attachment2', InStream, Enum::"Email Scenario"::"Test Email Scenario", true);
        AddAttachment('Attachment3', InStream, Enum::"Email Scenario"::Default, false);

        // [Then] There should be three record in the EmailScenarioAttachments Table
        Assert.AreEqual(3, EmailScenarioAttachments.Count(), 'Wrong total attachment number');

        // [When] Open the  Email Choose Scenario Attach page
        EmailChooseScenarioAttachment.Trap();
        EmailChooseScenarioAttachment.OpenView();

        // [Then] There are two records on the page for all the not default attachments for all scenarios.
        Assert.IsTrue(EmailChooseScenarioAttachment.First(), 'There should be data on the page');

        // Properties are expected
        Assert.AreEqual('Attachment3', EmailChooseScenarioAttachment.FileName.Value, 'A different attachment name was expected');
        Assert.AreEqual(Format(Enum::"Email Scenario"::"Default"), EmailChooseScenarioAttachment.Scenario.Value, 'A different attachment scenario was expected');

        EmailChooseScenarioAttachment.Expand(true);
        Assert.IsTrue(EmailChooseScenarioAttachment.Next(), 'There should be data on the page');

        // Properties are expected
        Assert.AreEqual('Attachment1', EmailChooseScenarioAttachment.FileName.Value, 'A different attachment name was expected');
        Assert.AreEqual(Format(Enum::"Email Scenario"::"Test Email Scenario"), EmailChooseScenarioAttachment.Scenario.Value, 'A different attachment scenario was expected');

        Assert.IsFalse(EmailChooseScenarioAttachment.Next(), 'There should not exist any data on the page');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure UploadFromScenarioToMessageEnaled()
    var
        TempAccount: Record "Email Account" temporary;
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Document: Codeunit "Temp Blob";
        EmailEditor: TestPage "Email Editor";
        OutStream: OutStream;
        InStream: InStream;

    begin
        // [Scenario] Set the attachments to the scenario. GetEmailAttachmentsByEmailScenarios will returns the attachments realated to the scenario
        PermissionsMock.Set('Email Admin');
        Initialize();

        // [Given] An email account with test scenario. The scenario has  two attachments with only one default attachment.
        ConnectorMock.AddAccount(TempAccount);

        Document.CreateOutStream(OutStream);
        OutStream.WriteText('Content');
        Document.CreateInStream(InStream);

        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::"Test Email Scenario", TempAccount."Account Id", Enum::"Email Connector"::"Test Email Connector");
        AddAttachment('Attachment1', InStream, Enum::"Email Scenario"::"Test Email Scenario", true);
        AddAttachment('Attachment2', InStream, Enum::"Email Scenario"::"Test Email Scenario", false);
        AddAttachment('Attachment3', InStream, Enum::"Email Scenario"::"Test Email Scenario", true);
        // [Given] A email message under test scenario
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');
        EmailScenarioAttachImpl.AddAttachmentToMessage(EmailMessage, Enum::"Email Scenario"::"Test Email Scenario");

        // [Then] Open the editor
        EmailEditor.Trap();
        Email.OpenInEditor(EmailMessage);
        Assert.IsTrue(EmailEditor.Attachments.First(), 'There should be one default attachment on the page');
        Assert.AreEqual('Attachment1', EmailEditor.Attachments.FileName.Value, 'A different attachment name was expected');

        Assert.IsTrue(EmailEditor.Attachments.Next(), 'There should be another default attachment on the page');
        Assert.AreEqual('Attachment3', EmailEditor.Attachments.FileName.Value, 'A different attachment name was expected');

        Assert.IsFalse(EmailEditor.Attachments.Next(), 'There should not be other attachment on the page');
        Assert.IsTrue(EmailEditor.Attachments.UploadFromScenario.Enabled(), 'UploadFromScenario Action enabled.');
    end;

    procedure AddAttachment(AttachmentName: Text[250]; AttachmentInStream: InStream; Scenario: Enum "Email Scenario"; Status: Boolean)
    var
        EmailScenarioAttachments: Record "Email Scenario Attachments";
    // EmailAttachment: Record "Email Attachments";
    begin
        EmailScenarioAttachments."Attachment Name" := AttachmentName;
        EmailScenarioAttachments."Email Attachment".ImportStream(AttachmentInStream, AttachmentName);
        EmailScenarioAttachments.Scenario := Scenario;
        EmailScenarioAttachments.AttachmentDefaultStatus := Status;
        EmailScenarioAttachments.Insert();
    end;

    local procedure CreateEmail(var EmailMessage: Codeunit "Email Message")
    var
        Any: Codeunit Any;
    begin
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
    end;

    local procedure Initialize()
    var
        EmailAttachments: Record "Email Attachments";
        EmailScenarioAttachments: Record "Email Scenario Attachments";
    begin
        EmailScenarioMock.DeleteAllMappings();
        EmailAttachments.DeleteAll();
        EmailScenarioAttachments.DeleteAll();
    end;
}
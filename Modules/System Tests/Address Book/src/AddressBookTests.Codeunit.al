// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134699 "Address Book Tests"
{
    SubType = Test;
    Permissions = tabledata "Email Outbox" = rd,
                  tabledata "Sent Email" = rd,
                  tabledata Address = rimd;
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";


    [Test]
    [HandlerFunctions('EmailRecipientLookupHandler')]
    procedure AddressBookTest()
    var
        TempAccount: Record "Email Account";
        SentEmail: Record "Sent Email";
        //Outbox: Record "Email Outbox";
        ConnectorMock: Codeunit "Connector Mock";
        Message: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailAccConnMock: Codeunit "Email Accounts Selection Mock";
        AddressBookMock: Codeunit "Address Book Mock";
        EditorPage: TestPage "Email Editor";
        Recipients: List of [Text];
        Recipient1, Recipient2 : Text;
    begin
        // [SCENARIO] Adding an extra ToRecipient and adding a CcRecipient with the addressbook

        // [GIVEN] A connector is installed and an account is added
        //Outbox.DeleteAll();
        //SentEmail.DeleteAll();
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        BindSubscription(EmailAccConnMock);
        BindSubscription(AddressBookMock);
        PermissionsMock.Set('Email Edit');

        // [GIVEN] An email message with a recipient, subject, body and related record
        Message.Create('test@test.com', 'Subject', 'Body');
        Email.AddRelation(Message, 0, CreateGuid(), Enum::"Email Relation Type"::"Primary Source");

        // [WHEN] Opening the email message in the email editor and performing a Lookup on ToRecipient field
        EditorPage.Trap();
        Email.OpenInEditor(Message, TempAccount);

        EditorPage.ToField.Lookup();

        // After the Lookup Modal is handled by EmailRecipientLookupHandler, an extra email address is added
        Assert.AreEqual('test@test.com;johndoe@test.com;', EditorPage.ToField.Value(), 'Email addresses in To field does not match');

        // [WHEN] Performing a lookup on CcRecipient Field
        EditorPage.CcField.Lookup();

        // After the Lookup Modal is handled by EmailRecipientLookupHandler, an email address is added to Ccfield
        Assert.AreEqual('johndoe@test.com;', EditorPage.CcField.Value(), 'Email address in CC field does not match');

        // [WHEN] Performing a lookup on BccRecipient Field
        EditorPage.BccField.Lookup();

        // After the Lookup Modal is handled by EmailRecipientLookupHandler, an email address is added to Bccfield
        Assert.AreEqual('johndoe@test.com;', EditorPage.BccField.Value(), 'Email address in Bcc field does not match');

        //EditorPage.ToField.SetValue('recipient@test.com');
        EditorPage.SubjectField.SetValue('Test Subject');
        EditorPage.BodyField.SetValue('Test body');

        // [WHEN] The send action is invoked, no error appears and the email is sent
        EditorPage.Send.Invoke();

        // [THEN] Verify the data
        Message.Get(ConnectorMock.GetEmailMessageID());
        SentEmail.SetRange("Message Id", Message.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A Sent Email record should have been inserted.');
        Assert.AreEqual('Test Subject', SentEmail.Description, 'The email subject should be "Subject"');
        Assert.AreEqual(TempAccount."Account Id", SentEmail."Account Id", 'A different account was expected');
        Assert.AreEqual(TempAccount."Email Address", SentEmail."Sent From", 'A different sent from was expected');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", SentEmail.Connector, 'A different connector was expected');

        Message.GetRecipients(Enum::"Email Recipient Type"::"To", Recipients);
        Assert.AreEqual(2, Recipients.Count(), '');

        Recipients.Get(1, Recipient1);
        Recipients.Get(2, Recipient2);
        Assert.AreEqual('johndoe@test.com', Recipient1, '');
        Assert.AreEqual('test@test.com', Recipient2, '');

        Message.GetRecipients(Enum::"Email Recipient Type"::"Cc", Recipients);
        Assert.AreEqual(1, Recipients.Count(), '');

        Recipients.Get(1, Recipient1);
        Assert.AreEqual('johndoe@test.com', Recipient1, '');

        Message.GetRecipients(Enum::"Email Recipient Type"::"Bcc", Recipients);
        Assert.AreEqual(1, Recipients.Count(), '');

        Recipients.Get(1, Recipient1);
        Assert.AreEqual('johndoe@test.com', Recipient1, '');
    end;

    [Test]
    [HandlerFunctions('EmailRecipientLookupCancelHandler')]
    procedure AddressBookCancelTest()
    var
        TempAccount: Record "Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        Message: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailAccConnMock: Codeunit "Email Accounts Selection Mock";
        AddressBookMock: Codeunit "Address Book Mock";
        EditorPage: TestPage "Email Editor";
    begin
        // [SCENARIO] Adding an extra ToRecipient and adding a CcRecipient with the addressbook

        // [GIVEN] A connector is installed and an account is added
        //Outbox.DeleteAll();
        //SentEmail.DeleteAll();
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        BindSubscription(EmailAccConnMock);
        BindSubscription(AddressBookMock);
        PermissionsMock.Set('Email Edit');

        // [GIVEN] An email message with a recipient, subject, body and related record
        Message.Create('test@test.com', 'Subject', 'Body');
        Email.AddRelation(Message, 0, CreateGuid(), Enum::"Email Relation Type"::"Primary Source");

        // [WHEN] Opening the email message in the email editor and performing a Lookup on ToRecipient field
        EditorPage.Trap();
        Email.OpenInEditor(Message, TempAccount);

        EditorPage.ToField.Lookup();

        // After the Lookup Modal is handled by EmailRecipientLookupHandler, an extra email address is added
        Assert.AreEqual('test@test.com', EditorPage.ToField.Value(), 'Email addresses in To field does not match');

        // [WHEN] Performing a lookup on CcRecipient Field
        EditorPage.CcField.Lookup();

        // After the Lookup Modal is handled by EmailRecipientLookupHandler, an email address is added to Ccfield
        Assert.AreEqual('', EditorPage.CcField.Value(), 'Email address in CC field does not match');
    end;

    [Test]
    [HandlerFunctions('EmailRecipientLookupEntitiesHandler,SaveAsDraftOnCloseHandler,EmailEntitiesHandler')]
    procedure AddressBookLookupFromEntitiesTest()
    var
        TempAccount: Record "Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        Message: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailAccConnMock: Codeunit "Email Accounts Selection Mock";
        AddressBookMock: Codeunit "Address Book Mock";
        EditorPage: TestPage "Email Editor";
    begin
        // [SCENARIO] Adding an extra ToRecipient and adding a CcRecipient with the addressbook

        // [GIVEN] A connector is installed and an account is added
        //Outbox.DeleteAll();
        //SentEmail.DeleteAll();
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        BindSubscription(EmailAccConnMock);
        BindSubscription(AddressBookMock);
        PermissionsMock.Set('Email Edit');

        // [GIVEN] An email message with a recipient, subject, body and related record
        Message.Create('test@test.com', 'Subject', 'Body');
        Email.AddRelation(Message, 0, CreateGuid(), Enum::"Email Relation Type"::"Primary Source");

        // [WHEN] Opening the email message in the email editor and performing a Lookup on ToRecipient field
        EditorPage.Trap();
        Email.OpenInEditor(Message, TempAccount);

        EditorPage.ToField.Lookup();

        // After the Lookup Modal is handled by EmailRecipientLookupHandler, an extra email address is added
        Assert.AreEqual('test@test.com', EditorPage.ToField.Value(), 'Email addresses in To field does not match');

        //EditorPage.ToField.SetValue('recipient@test.com');
        EditorPage.SubjectField.SetValue('Test Subject');
        EditorPage.BodyField.SetValue('Test body');
    end;


    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure EmailRecipientLookupHandler(var EmailAddress: TestPage "Email Address")
    begin
        EmailAddress.First();
        Assert.AreEqual('johndoe@test.com', EmailAddress."Email Address".Value(), 'Email address in addressbook does not match');
        Assert.AreEqual('John Doe', EmailAddress.Name.Value(), 'Name in addressbook does not match');
        Assert.AreEqual('Cronos', EmailAddress.Company.Value(), 'Company in addressbook does not match');
        Assert.AreEqual('Customer', EmailAddress.Source.Value(), 'Customer name in addressbook does not match');
        EmailAddress.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure EmailRecipientLookupCancelHandler(var EmailAddress: TestPage "Email Address")
    begin
        EmailAddress.Cancel().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure EmailRecipientLookupEntitiesHandler(var EmailAddress: TestPage "Email Address")
    begin
        EmailAddress.ManualLookup.Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure EmailAccountLookUpHandler(var EmailAccounts: TestPage "Email Accounts")
    begin
        EmailAccounts.First();
        EmailAccounts.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure EmailEntitiesHandler(var EmailAddressEntity: TestPage "Email Address Entity")
    begin
        EmailAddressEntity.First();
        Assert.AreEqual('Contact', EmailAddressEntity."Type".Value(), '');
        EmailAddressEntity.OK().Invoke();
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure SaveAsDraftOnCloseHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 1;
    end;
}
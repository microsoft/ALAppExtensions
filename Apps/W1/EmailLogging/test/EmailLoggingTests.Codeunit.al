// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139763 "Email Logging Tests"
{
    Subtype = Test;

    var
        EmailLoggingAPIHelper: Codeunit "Email Logging API Helper";
        EmailLoggingManagement: Codeunit "Email Logging Management";
        EmailLoggingInvoke: Codeunit "Email Logging Invoke";
        EmailLoggingAPIMock: Codeunit "Email Logging API Mock";
        EmailLoggingMockSubscribers: Codeunit "Email Logging Mock Subscribers";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibrarySales: Codeunit "Library - Sales";
        Assert: Codeunit Assert;
        Initialized: Boolean;
        Now: DateTime;

    [Test]
    [Scope('OnPrem')]
    procedure TestIsContact()
    var
        SegmentLine: Record "Segment Line";
        Contact: Record Contact;
    begin
        Contact.SetFilter("No.", '<>''''');
        Contact.SetFilter("Search E-Mail", '<>''''');
        Contact.FindFirst();
        Assert.IsTrue(EmailLoggingInvoke.IsContact(Contact."Search E-Mail", SegmentLine), 'Email does not belong to any of the contacts');
        Assert.AreEqual(Contact."No.", SegmentLine."Contact No.", 'Setting segment contact details failed');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestIsContactAlt()
    var
        SegmentLine: Record "Segment Line";
        ContactAltAddress: Record "Contact Alt. Address";
    begin
        ContactAltAddress.FindFirst();
        if ContactAltAddress."Search E-Mail" = '' then begin
            ContactAltAddress."Search E-Mail" := 'xxlalt@candoxy.net';
            ContactAltAddress.Modify();
        end;
        Assert.IsTrue(EmailLoggingInvoke.IsContact(ContactAltAddress."Search E-Mail", SegmentLine), 'Email does not belong to any of the alternative contacts.');
        Assert.AreEqual(ContactAltAddress."Contact No.", SegmentLine."Contact No.", 'Setting segment contact details failed.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestIsSalesperson()
    var
        SegmentLine: Record "Segment Line";
        SalesPersonPurchaser: Record "Salesperson/Purchaser";
    begin
        SalesPersonPurchaser.SetFilter(Code, '<>''''');
        SalesPersonPurchaser.SetFilter("Search E-Mail", '<>''''');
        SalesPersonPurchaser.FindFirst();
        Assert.IsTrue(EmailLoggingInvoke.IsSalesperson(SalesPersonPurchaser."Search E-Mail", SegmentLine), 'Email does not belong to any of the salespeople');
        Assert.AreEqual(SalesPersonPurchaser.Code, SegmentLine."Salesperson Code", 'Email does not belong to the expected sales person');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertInteractionLogEntry()
    var
        SegmentLine: Record "Segment Line";
        InteractionLogEntry: Record "Interaction Log Entry";
    begin
        Initialize();
        EmailLoggingInvoke.InsertInteractionLogEntry(SegmentLine, 99990);
        Assert.IsTrue(InteractionLogEntry.Get(99990), 'Inserting Interaction Log Entry failed');
        Assert.IsTrue(InteractionLogEntry."E-Mail Logged", 'Email not logged');
        InteractionLogEntry.Delete(true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdatingSegmentLine()
    var
        SegmentLine: Record "Segment Line";
        EmailLoggingMessage: Codeunit "Email Logging Message";
    begin
        Initialize();
        SegmentLine.SetFilter("Segment No.", '<>''''');
        SegmentLine.SetFilter("Line No.", '>0');
        SegmentLine.FindFirst();
        GetMessage(EmailLoggingMessage);
        EmailLoggingInvoke.UpdateSegmentLine(SegmentLine, 'GOLF', EmailLoggingMessage, 20);
        Assert.AreEqual(SegmentLine.Description, EmailLoggingMessage.GetSubject(), 'Error setting description');
        Assert.AreEqual(SegmentLine.Date, DT2Date(EmailLoggingMessage.GetSentDateTime()), 'Error date');
        Assert.AreEqual(SegmentLine."Attachment No.", 20, 'Error setting att. no.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSetupVerification()
    begin
        Initialize();
        InitializeSetup();
        EmailLoggingManagement.CheckEmailLoggingSetup();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestClearEmailLoggingSetup()
    var
        EmailLoggingSetup: Record "Email Logging Setup";
    begin
        Initialize();
        InitializeSetup();
        EmailLoggingSetup.Get();
        EmailLoggingSetup."Client Id" := 'some value';
        EmailLoggingSetup.SetClientSecret('some value');
        EmailLoggingSetup."Consent Given" := true;
        EmailLoggingSetup.Enabled := false;
        EmailLoggingSetup.Modify();

        Assert.IsTrue(EmailLoggingSetup."Email Address" <> '', 'Email address is not set');
        Assert.IsTrue(EmailLoggingSetup."Email Batch Size" > 0, 'Email batch size is not set');
        Assert.IsTrue(EmailLoggingSetup."Client Id" <> '', 'Client id is not set');
        Assert.IsTrue(EmailLoggingSetup.GetClientSecret() <> '', 'Client secret is not set');
        Assert.IsTrue(EmailLoggingSetup."Consent Given", 'Consent is not set');
        EmailLoggingManagement.ClearEmailLoggingSetup(EmailLoggingSetup);

        EmailLoggingSetup.Get();
        Assert.IsFalse(EmailLoggingSetup."Email Address" <> '', 'E-mail address is not cleared');
        Assert.AreEqual(EmailLoggingSetup.GetDefaultEmailBatchSize(), EmailLoggingSetup."Email Batch Size", 'Email batch size is not reset to default value');
        Assert.IsFalse(EmailLoggingSetup."Client Id" <> '', 'Client id is not cleared');
        Assert.IsFalse(EmailLoggingSetup.GetClientSecret() <> '', 'Client secret is not cleared');
        Assert.IsFalse(EmailLoggingSetup."Consent Given", 'Consent is not cleared');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateJob()
    var
        EmailLoggingSetup: Record "Email Logging Setup";
    begin
        Initialize();
        InitializeSetup();
        EmailLoggingSetup.Get();
        EmailLoggingSetup.Enabled := false;
        EmailLoggingSetup.Modify();

        Assert.IsFalse(EmailLoggingSetup.Enabled, 'Email Logging is not disabled');
        EmailLoggingManagement.CreateEmailLoggingJobQueueSetup();
        CheckJobQueueEntry(true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestMessageInitialized()
    var
        EmailLoggingMessage: Codeunit "Email Logging Message";
        MessageList: List of [JsonObject];
        MessageJsonObject: JsonObject;
        Id: Text;
        InternetMessageId: Text;
        WebLink: Text;
        IsDraft: Boolean;
        Subject: Text;
        SentDateTime: Text;
        ReceivedDateTime: Text;
        Sender: Text;
        ToRecipient: Text;
        CcRecipient: Text;
    begin
        Initialize();
        InitializeSetup();
        Id := 'id';
        InternetMessageId := 'internetMessageId';
        WebLink := 'https://link.com/' + InternetMessageId;
        IsDraft := false;
        SentDateTime := DatePart(Now) + 'T11:59:00Z';
        ReceivedDateTime := DatePart(Now) + 'T12:01:00Z';
        Subject := 'subject';
        Sender := 'sender@domain.com';
        ToRecipient := 'toRecipient@domain.com';
        CcRecipient := 'ccRecipient@domain.com';
        AddMessageToInbox(Id, InternetMessageId, WebLink, IsDraft, SentDateTime, ReceivedDateTime, Subject, Sender, ToRecipient, CcRecipient);
        EmailLoggingAPIHelper.GetMessages(MessageList);
        MessageList.Get(1, MessageJsonObject);
        EmailLoggingMessage.Initialize(MessageJsonObject);
        Assert.IsTrue(EmailLoggingMessage.IsInitialized(), 'Message is not initialized');
        Assert.AreEqual(Id, EmailLoggingMessage.GetId(), 'Unexpected id');
        Assert.AreEqual(InternetMessageId, EmailLoggingMessage.GetInternetMessageId(), 'Unexpected internetMessageId');
        Assert.AreEqual(WebLink, EmailLoggingMessage.GetWebLink(), 'Unexpected webLink');
        Assert.AreEqual(IsDraft, Format(EmailLoggingMessage.GetIsDraft()).ToLower() = 'yes', 'Unexpected isDraft');
        Assert.AreEqual(Subject, EmailLoggingMessage.GetSubject(), 'Unexpected subject');
        Assert.AreEqual(Sender, EmailLoggingMessage.GetSender(), 'Unexpected sender');
        Assert.AreEqual(DatePart(SentDateTime), DatePart(EmailLoggingMessage.GetSentDateTime()), 'Unexpected sentDateTime');
        Assert.AreEqual(DatePart(ReceivedDateTime), DatePart(EmailLoggingMessage.GetReceivedDateTime()), 'Unexpected receivedDateTime');
        Assert.AreEqual(1, EmailLoggingMessage.GetToRecipients().Count(), 'Unexpected toRecipients count');
        Assert.AreEqual(1, EmailLoggingMessage.GetCcRecipients().Count(), 'Unexpected ccRecipients count');
        Assert.AreEqual(2, EmailLoggingMessage.GetToAndCcRecipients().Count(), 'Unexpected toAndCcRecipients count');
        Assert.AreEqual(ToRecipient, EmailLoggingMessage.GetToRecipients().Get(1), 'Unexpected toRecipient');
        Assert.AreEqual(CcRecipient, EmailLoggingMessage.GetCcRecipients().Get(1), 'Unexpected ccRecipient');
        Assert.AreEqual(ToRecipient, EmailLoggingMessage.GetToAndCcRecipients().Get(1), 'Unexpected toAndCcRecipient #1');
        Assert.AreEqual(CcRecipient, EmailLoggingMessage.GetToAndCcRecipients().Get(2), 'Unexpected toAndCcRecipient #2');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestMessageLogged()
    var
        Contact: array[2] of Record Contact;
        Customer: array[2] of Record Customer;
        SalespersonPurchaser: array[2] of Record "Salesperson/Purchaser";
        InteractionLogEntry: Record "Interaction Log Entry";
        Attachment: Record Attachment;
        EmailLoggingMessage: Codeunit "Email Logging Message";
        LastLogEntryNo: Integer;
        LastAttachmentNo: Integer;
        AttachmentList: List of [Integer];
        I: Integer;
        J: Text;
    begin
        Initialize();
        InitializeSetup();
        if InteractionLogEntry.FindLast() then
            LastLogEntryNo := InteractionLogEntry."Entry No.";
        if Attachment.FindLast() then
            LastAttachmentNo := Attachment."No.";

        for I := 1 to 2 do begin
            J := Format(I);
            LibraryMarketing.CreateContactWithCustomer(Contact[I], Customer[I]);
            LibrarySales.CreateSalesperson(SalespersonPurchaser[I]);
            Contact[I].Validate("E-Mail", CopyStr('contact' + J + '@test.com', 1, MaxStrLen(Contact[I]."E-Mail")));
            Contact[I].Modify();
            SalespersonPurchaser[I].Validate("E-Mail", CopyStr('salesperson' + J + '@test.com', 1, MaxStrLen(SalespersonPurchaser[I]."E-Mail")));
            SalespersonPurchaser[I].Modify();
        end;
        AddMessageToInbox('id1', 'internetMessageId1', 'subject1', Contact[1]."E-Mail", SalespersonPurchaser[1]."E-Mail", SalespersonPurchaser[2]."E-Mail");
        AddMessageToInbox('id2', 'internetMessageId2', 'subject2', SalespersonPurchaser[1]."E-Mail", Contact[1]."E-Mail", Contact[2]."E-Mail");

        ProcessMessages();

        for I := 1 to 2 do begin
            J := Format(I);
            GetArchivedMessage('id' + J, EmailLoggingMessage);
            Assert.IsTrue(EmailLoggingInvoke.IsMessageAlreadyLogged(EmailLoggingMessage), 'Message is not logged');
        end;

        Attachment.SetFilter("No.", '>%1', LastAttachmentNo);
        Assert.IsTrue(Attachment.FindSet(), 'Attachment is not found');
        repeat
            AttachmentList.Add(Attachment."No.");
        until Attachment.Next() = 0;
        Assert.AreEqual(2, AttachmentList.Count(), 'Unexpected attachment count');

        InteractionLogEntry.SetFilter("Entry No.", '>%1', LastLogEntryNo);
        InteractionLogEntry.SetFilter("Contact No.", '%1|%2', Contact[1]."No.", Contact[2]."No.");
        InteractionLogEntry.SetFilter("Salesperson Code", '%1|%2', SalespersonPurchaser[1].Code, SalespersonPurchaser[2].Code);
        InteractionLogEntry.SetFilter("Attachment No.", '%1|%2', AttachmentList.Get(1), AttachmentList.Get(2));
        Assert.AreEqual(4, InteractionLogEntry.Count(), 'Unexpected interaction log entry count');

        for I := 1 to 2 do begin
            Customer[I].Delete();
            Contact[I].Delete();
            SalespersonPurchaser[I].Delete();
        end;
        InteractionLogEntry.SetFilter("Entry No.", '>%1', LastLogEntryNo);
        InteractionLogEntry.DeleteAll();
        Attachment.SetFilter("No.", '>%1', LastAttachmentNo);
        Attachment.Delete();
    end;

    [Test]
    procedure TestMessageNotLogged()
    var
        Contact: array[2] of Record Contact;
        Customer: array[2] of Record Customer;
        SalespersonPurchaser: array[2] of Record "Salesperson/Purchaser";
        InteractionLogEntry: Record "Interaction Log Entry";
        Attachment: Record Attachment;
        LogEntryCount: Integer;
        AttachmentCount: Integer;
        I: Integer;
        J: Text;
    begin
        Initialize();
        InitializeSetup();
        LogEntryCount := InteractionLogEntry.Count();
        AttachmentCount := Attachment.Count();
        for I := 1 to 2 do begin
            J := Format(I);
            LibraryMarketing.CreateContactWithCustomer(Contact[I], Customer[I]);
            LibrarySales.CreateSalesperson(SalespersonPurchaser[I]);
            Contact[I].Validate("E-Mail", CopyStr('contact' + J + '@test.com', 1, MaxStrLen(Contact[I]."E-Mail")));
            Contact[I].Modify();
            SalespersonPurchaser[I].Validate("E-Mail", CopyStr('salesperson' + J + '@test.com', 1, MaxStrLen(SalespersonPurchaser[I]."E-Mail")));
            SalespersonPurchaser[I].Modify();
        end;

        AddMessageToInbox('id1', 'internetMessageId1', 'subject1', Contact[1]."E-Mail", 'toMissing@salesperson.com', 'ccMissing@salesperson.com');
        AddMessageToInbox('id2', 'internetMessageId2', 'subject2', 'fromMissing@contact.com', SalespersonPurchaser[1]."E-Mail", 'ccMissing@salesperson.com');
        AddMessageToInbox('id3', 'internetMessageId3', 'subject3', 'fromMissing@salesperson.com', 'toMissing@contact.com', Contact[2]."E-Mail");
        AddMessageToInbox('id4', 'internetMessageId4', 'subject4', 'fromMissing@contact.com', SalespersonPurchaser[2]."E-Mail", 'ccMissing@salesperson.com');

        ProcessMessages();

        CheckMessageDeleted('id1');
        CheckMessageDeleted('id2');
        CheckMessageDeleted('id3');
        CheckMessageDeleted('id4');
        Assert.AreEqual(LogEntryCount, InteractionLogEntry.Count(), 'Interaction log entry is created');
        Assert.AreEqual(AttachmentCount, Attachment.Count(), 'Attachment is created');

        for I := 1 to 2 do begin
            Customer[I].Delete();
            Contact[I].Delete();
            SalespersonPurchaser[I].Delete();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDuplicatedMessageNotLogged()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        InteractionLogEntry: Record "Interaction Log Entry";
        Attachment: Record Attachment;
        LogEntryCount: Integer;
        AttachmentCount: Integer;
    begin
        Initialize();
        InitializeSetup();
        LogEntryCount := InteractionLogEntry.Count();
        AttachmentCount := Attachment.Count();
        LibraryMarketing.CreateContactWithCustomer(Contact, Customer);
        LibrarySales.CreateSalesperson(SalespersonPurchaser);
        Contact.Validate("E-Mail", CopyStr('contact@test.com', 1, MaxStrLen(Contact."E-Mail")));
        Contact.Modify();
        SalespersonPurchaser.Validate("E-Mail", CopyStr('salesperson@test.com', 1, MaxStrLen(SalespersonPurchaser."E-Mail")));
        SalespersonPurchaser.Modify();

        if Attachment.FindLast() then
            Attachment."No." := Attachment."No." + 1
        else
            Attachment."No." := 1;
        Attachment.Insert();
        Attachment.SetMessageID('id1');
        Attachment.SetInternetMessageID('internetMessageId');
        Attachment.SetEmailMessageUrl('https://link.com/1');
        Attachment.Modify();

        AddMessageToInbox('id2', Attachment.GetInternetMessageID());

        ProcessMessages();

        CheckMessageDeleted('id2');
        Assert.AreEqual(LogEntryCount, InteractionLogEntry.Count(), 'Interaction log entry is created');
        Assert.AreEqual(AttachmentCount + 1, Attachment.Count(), 'Attachment is created');

        Customer.Delete();
        Contact.Delete();
        SalespersonPurchaser.Delete();
        Attachment.FindLast();
        Attachment.Delete();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDraftMessageNotLogged()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        InteractionLogEntry: Record "Interaction Log Entry";
        Attachment: Record Attachment;
    begin
        Initialize();
        InitializeSetup();
        InteractionLogEntry.DeleteAll();
        Attachment.DeleteAll();

        LibraryMarketing.CreateContactWithCustomer(Contact, Customer);
        LibrarySales.CreateSalesperson(SalespersonPurchaser);
        Contact.Validate("E-Mail", CopyStr('contact@test.com', 1, MaxStrLen(Contact."E-Mail")));
        Contact.Modify();
        SalespersonPurchaser.Validate("E-Mail", CopyStr('salesperson@test.com', 1, MaxStrLen(SalespersonPurchaser."E-Mail")));
        SalespersonPurchaser.Modify();

        AddMessageToInbox('id1', 'internetMessageId1', true, Contact."E-Mail", SalespersonPurchaser."E-Mail");
        AddMessageToInbox('id2', 'internetMessageId2', true, SalespersonPurchaser."E-Mail", Contact."E-Mail");

        ProcessMessages();

        CheckMessageDeleted('id1');
        CheckMessageDeleted('id2');
        Assert.IsTrue(InteractionLogEntry.IsEmpty(), 'Interaction log entry is found');
        Assert.IsTrue(Attachment.IsEmpty(), 'Attachment is found');

        Customer.Delete();
        Contact.Delete();
        SalespersonPurchaser.Delete();
    end;

    local procedure Initialize()
    begin
        EmailLoggingAPIMock.ClearMailbox();
        if Initialized then
            exit;
        BindSubscription(EmailLoggingMockSubscribers);
        EmailLoggingAPIHelper.Initialize();
        Now := CurrentDateTime();
        Initialized := true;
    end;

    local procedure ProcessMessages()
    begin
        Codeunit.Run(Codeunit::"Email Logging Invoke");
    end;

    local procedure GetArchivedMessage(MessageId: Text; var EmailLoggingMessage: Codeunit "Email Logging Message")
    begin
        Assert.IsTrue(EmailLoggingAPIMock.GetArchivedMessage(MessageId, EmailLoggingMessage), 'Message has not been archived');
    end;

    local procedure CheckMessageDeleted(MessageId: Text)
    begin
        Assert.IsTrue(EmailLoggingAPIMock.IsMessageDeleted(MessageId), 'Message has not been deleted');
    end;

    local procedure AddMessageToInbox(Id: Text; InternetMessageId: Text)
    begin
        AddMessageToInbox(Id, InternetMessageId, false);
    end;

    local procedure AddMessageToInbox(Id: Text; InternetMessageId: Text; IsDraft: Boolean)
    var
        Sender: Text;
        ToRecipient: Text;
    begin
        Sender := 'sender@domain.com';
        ToRecipient := 'toRecipient@domain.com';
        AddMessageToInbox(Id, InternetMessageId, IsDraft, Sender, ToRecipient);
    end;

    local procedure AddMessageToInbox(Id: Text; InternetMessageId: Text; Subject: Text; Sender: Text; ToRecipient: Text; ccRecipient: Text)
    var
        WebLink: Text;
        SentDateTime: Text;
        ReceivedDateTime: Text;
    begin
        WebLink := 'https://link.com/' + Id;
        SentDateTime := DatePart(Now) + 'T11:59:00Z';
        ReceivedDateTime := DatePart(Now) + 'T12:01:00Z';
        AddMessageToInbox(Id, InternetMessageId, WebLink, false, SentDateTime, ReceivedDateTime, Subject, Sender, ToRecipient, CcRecipient);
    end;

    local procedure AddMessageToInbox(Id: Text; InternetMessageId: Text; IsDraft: Boolean; Sender: Text; ToRecipient: Text)
    var
        WebLink: Text;
        Subject: Text;
        SentDateTime: Text;
        ReceivedDateTime: Text;
        CcRecipient: Text;
    begin
        WebLink := 'https://link.com/' + Id;
        SentDateTime := DatePart(Now) + 'T11:59:00Z';
        ReceivedDateTime := DatePart(Now) + 'T12:01:00Z';
        Subject := 'subject';
        CcRecipient := 'ccRecipient@domain.com';
        AddMessageToInbox(Id, InternetMessageId, WebLink, IsDraft, SentDateTime, ReceivedDateTime, Subject, Sender, ToRecipient, CcRecipient);
    end;

    local procedure AddMessageToInbox(Id: Text; InternetMessageId: Text; WebLink: Text; IsDraft: Boolean; SentDateTime: Text; ReceivedDateTime: Text; Subject: Text; Sender: Text; ToRecipient: Text; CcRecipient: Text)
    begin
        EmailLoggingAPIMock.AddMessageToInbox(Id, InternetMessageId, WebLink, IsDraft, SentDateTime, ReceivedDateTime, Subject, Sender, ToRecipient, CcRecipient);
    end;

    local procedure GetMessage(var EmailLoggingMessage: Codeunit "Email Logging Message")
    var
        MessagesJsonObject: JsonObject;
    begin
        AddMessageToInbox('id', 'internetMessageId', false);
        EmailLoggingAPIMock.GetMessage('', '', 'id', MessagesJsonObject);
        EmailLoggingMessage.Initialize((MessagesJsonObject));
    end;

    local procedure InitializeSetup()
    var
        EmailLoggingSetup: Record "Email Logging Setup";
    begin
        if not EmailLoggingSetup.Get() then
            EmailLoggingSetup.Insert();
        EmailLoggingSetup."Email Address" := 'test@test.com';
        EmailLoggingSetup."Email Batch Size" := 2 * EmailLoggingSetup.GetDefaultEmailBatchSize();
        EmailLoggingSetup.Enabled := true;
        EmailLoggingSetup.Modify();
    end;

    local procedure CheckJobQueueEntry(ExpectedExists: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        ActualExists: Boolean;
    begin
        ActualExists := JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"Email Logging Job Runner");
        if ExpectedExists then
            Assert.IsTrue(ActualExists, 'Job is not created.')
        else
            Assert.IsFalse(ActualExists, 'Job is not deleted.')
    end;

    local procedure DatePart(Value: Text): Text
    begin
        exit(Value.Substring(1, 10));
    end;

    local procedure DatePart(Value: DateTime): Text
    begin
        exit(DatePart(DT2Date(Value)));
    end;

    local procedure DatePart(Value: Date): Text
    begin
        exit(Format(Value, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;
}

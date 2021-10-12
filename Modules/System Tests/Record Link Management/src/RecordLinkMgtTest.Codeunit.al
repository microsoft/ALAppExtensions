// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132508 "Record Link Mgt. Test"
{
    Subtype = Test;
    Permissions = tabledata "Record Link" = rmd;

    var
        RecordLinkManagement: Codeunit "Record Link Management";
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";

    trigger OnRun()
    begin
        // [MODULE] [Record Link Management]
    end;

    [Test]
    procedure TestWriteNote();
    var
        RecordLink: Record "Record Link";
        Any: Codeunit Any;
        Instream: InStream;
        LongText: Text;
        Text: Text;
        Byte: Byte;
    begin
        PermissionsMock.Set('Record Link View');
        // [WHEN] WriteNote is invoked with a text
        RecordLinkManagement.WriteNote(RecordLink, 'My note for the link');

        // [THEN] The Record Link variable has the text as a note
        // [THEN] The Note contains a single special byte before the actual message.
        RecordLink.Note.CreateInStream(Instream, TextEncoding::UTF8);
        Assert.AreEqual(1, Instream.Read(Byte), 'A special byte was expected.');
        Instream.ReadText(Text);
        Assert.AreEqual('My note for the link', Text, 'Mismatch in the text written.');

        // [WHEN] The text is bigger of 128 characters
        LongText := Any.AlphanumericText(128 + Any.IntegerInRange(512));
        RecordLinkManagement.WriteNote(RecordLink, LongText);

        // [THEN] The Note contains 2 special bytes before the actual message
        RecordLink.Note.CreateInStream(Instream, TextEncoding::UTF8);
        Assert.AreEqual(1, Instream.Read(Byte), 'A special byte was expected.');
        Assert.AreEqual(1, Instream.Read(Byte), 'A special byte was expected.');

        Instream.ReadText(Text);
        Assert.AreEqual(LongText, Text, 'Mismatch in the text written.');
    end;

    [Test]
    procedure TestReadNote();
    var
        RecordLink: Record "Record Link";
        Text: Text;
    begin
        PermissionsMock.Set('Record Link View');
        // [GIVEN] Some text is written to the record Link
        RecordLinkManagement.WriteNote(RecordLink, 'My note for the link');

        // [WHEN] The text is read back from the record link
        Text := RecordLinkManagement.ReadNote(RecordLink);

        // [THEN] The text matches what was put into the record link
        Assert.AreEqual('My note for the link', Text, 'Mismatch in the text read.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCopyLinks();
    var
        RecordLink: Record "Record Link";
        FromRecordLinkRecordTest: Record "Record Link Record Test";
        ToRecordLinkRecordTest: Record "Record Link Record Test";
        NewRecordLink: Record "Record Link";
        OnAfterCopyLinksMonitor: Codeunit "OnAfterCopyLinks Monitor";
        RecLinkCount: Integer;
    begin
        BindSubscription(OnAfterCopyLinksMonitor);
        PermissionsMock.Set('Record Link View');

        // [GIVEN] A new record is created to set record links on
        FromRecordLinkRecordTest.DeleteAll();
        FromRecordLinkRecordTest.Init();
        FromRecordLinkRecordTest.PK := 1;
        FromRecordLinkRecordTest.Field := 'Rec A';
        FromRecordLinkRecordTest.Insert();

        // [GIVEN] Some text is written to the record Link
        RecordLink.Type := RecordLink.Type::Note;
        // [GIVEN] Assign the record link to a record
        RecordLink."Record ID" := FromRecordLinkRecordTest.RecordId();
        RecordLinkManagement.WriteNote(RecordLink, 'My note for Rec A');

        // [GIVEN] The record link has Notify set to TRUE
        RecordLink.Validate(Notify, true);
        RecordLink.Validate(Created, CurrentDateTime());
        RecordLink.Validate("User ID", UserId());
        RecordLink.Validate(Company, CompanyName());
        PermissionsMock.Stop();
        RecordLink.Insert(true);
        PermissionsMock.Start();
        PermissionsMock.Set('Record Link View');

        // [GIVEN] A different instance of the table
        ToRecordLinkRecordTest.Init();
        ToRecordLinkRecordTest.PK := 2;
        ToRecordLinkRecordTest.Field := 'Rec B';
        ToRecordLinkRecordTest.Insert();

        // [WHEN] The record link is copied to the other instance
        RecLinkCount := NewRecordLink.Count();
        RecordLinkManagement.CopyLinks(FromRecordLinkRecordTest, ToRecordLinkRecordTest);
        Assert.IsTrue(OnAfterCopyLinksMonitor.IsEventRaised(), 'OnAfterCopyLinks event was not raised');

        // [THEN] A new record link has been created
        Assert.AreEqual(RecLinkCount + 1, NewRecordLink.Count(), 'No new record links created');
        Assert.AreNotEqual(NewRecordLink."Link ID", RecordLink."Link ID", 'New record link should be created with anew id.');

        // [THEN] The record link on the other instance has the same text
        NewRecordLink.SetRange("Record ID", ToRecordLinkRecordTest.RecordId());
        NewRecordLink.FindFirst();
        Assert.AreEqual('', RecordLinkManagement.ReadNote(NewRecordLink), 'Mismatch in the text read.');

        // [THEN] The record link on the other instance has Notify set to False
        Assert.IsFalse(NewRecordLink.Notify, 'Notify should have been unset.');
    end;

    [Test]
    [HandlerFunctions('HandleConfirm,HandleMessage')]
    procedure TestRemoveOrphanedLinks();
    var
        RecordLink: Record "Record Link";
        EmptyRecordId: RecordID;
    begin
        PermissionsMock.Set('Record Link View');
        // [GIVEN] Some text is written to the record Link
        RecordLink.DeleteAll();

        RecordLinkManagement.WriteNote(RecordLink, 'My note for the link');

        // [GIVEN] Insert the record link
        PermissionsMock.Stop();
        RecordLink.Insert(true);
        PermissionsMock.Start();
        PermissionsMock.Set('Record Link View');

        // [GIVEN] Ensure that Record link has no record id
        RecordLink.VALIDATE("Record ID", EmptyRecordId);
        RecordLink.Modify(true);

        // [WHEN] RemoveOrphanedLinks is called
        RecordLinkManagement.RemoveOrphanedLinks();

        // [THEN] No record link with that link id exists
        Assert.IsFalse(RecordLink.Get(RecordLink."Link ID"), 'As an orphan record link, this should have been removed.');
    end;

    [ConfirmHandler]
    procedure HandleConfirm(Question: Text[1024]; var Reply: Boolean);
    begin
        Assert.AreEqual('Do you want to remove links with no record reference?', Question, 'Wrong confirmation dialog');
        Reply := true;
    end;

    [MessageHandler]
    procedure HandleMessage(Message: Text[1024])
    begin
        Assert.AreEqual('1 orphaned links were removed.', Message, 'Wrong message');
    end;
}


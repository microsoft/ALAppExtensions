// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132508 "Record Link Mgt. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
      RecordLinkManagement : Codeunit "Record Link Management";
      LibraryAssert : Codeunit "Library Assert";

    trigger OnRun()
    begin
        // [MODULE] [Record Link Management]
    end;

    [Test]
    procedure TestWriteRecordLinkNote();
    var
      RecordLink : Record 2000000068;
      Instream : InStream;
      Text : Text;
    begin
      // [WHEN] WriteRecordLinkNote is invoked with a text
      RecordLinkManagement.WriteRecordLinkNote(RecordLink,'My note for the link');

      // [THEN] The Record Link variable has the text as a note
      RecordLink.Note.CREATEINSTREAM(Instream,TEXTENCODING::UTF8);
      LibraryAssert.IsTrue(Instream.READTEXT(Text) > 0,'There are characters to read.');
      LibraryAssert.IsTrue(STRPOS(Text,'My note for the link') > 0,'Mismatch in the text written.');
    end;

    [Test]
    procedure TestReadRecordLinkNote();
    var
      RecordLink : Record 2000000068;
      Text : Text;
    begin
      // [GIVEN] Some text is written to the record Link
      RecordLinkManagement.WriteRecordLinkNote(RecordLink,'My note for the link');

      // [WHEN] The text is read back from the record link
      Text := RecordLinkManagement.ReadRecordLinkNote(RecordLink);

      // [THEN] The text matches what was put into the record link
      LibraryAssert.AreEqual('My note for the link',Text,'Mismatch in the text read.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCopyLinks();
    var
      RecordLink : Record 2000000068;
      FromRecordLinkRecordTest : Record 132508;
      ToRecordLinkRecordTest : Record 132508;
      NewRecordLink : Record 2000000068;
      Text : Text;
    begin
      // [GIVEN] Some text is written to the record Link
      RecordLinkManagement.WriteRecordLinkNote(RecordLink,'My note for the link');

      // [GIVEN] The record link has Notify set to TRUE
      RecordLink.MODIFYALL(Notify,TRUE);

      // [GIVEN] Assign the record link to a record
      FromRecordLinkRecordTest.DELETEALL;
      FromRecordLinkRecordTest.INIT;
      FromRecordLinkRecordTest.PK := 1;
      FromRecordLinkRecordTest.Field := 'Rec A';
      FromRecordLinkRecordTest.INSERT;
      RecordLink."Record ID" := FromRecordLinkRecordTest.RECORDID;

      // [GIVEN] A different instance of the table
      ToRecordLinkRecordTest.INIT;
      ToRecordLinkRecordTest.PK := 2;
      ToRecordLinkRecordTest.Field := 'Rec B';
      ToRecordLinkRecordTest.INSERT;

      // [WHEN] The record link is copied to the other instance
      RecordLinkManagement.CopyLinks(FromRecordLinkRecordTest,ToRecordLinkRecordTest);

      // [THEN] The record link on the other instance has the same text
      NewRecordLink.SETRANGE("Record ID",ToRecordLinkRecordTest.RECORDID);
      NewRecordLink.FINDFIRST;
      Text := RecordLinkManagement.ReadRecordLinkNote(NewRecordLink);
      LibraryAssert.AreEqual('My note for the link',Text,'Mismatch in the text read.');

      // [THEN] The record link on the other instance has Notify set to False
      LibraryAssert.IsFalse(NewRecordLink.Notify,'Notify should have been unset.');
    end;
}


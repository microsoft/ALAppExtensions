// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Utilities;

using System.Environment.Configuration;
using System.Utilities;
using System.TestLibraries.Utilities;
using System.Environment;
using System.TestLibraries.Security.AccessControl;

codeunit 132508 "Record Link Mgt. Test"
{
    Subtype = Test;
    Permissions = tabledata "Record Link" = rmd;

    var
        RecordLinkManagement: Codeunit "Record Link Management";
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        PermissionsMock: Codeunit "Permissions Mock";
        WrongLinkTestErr: Label 'Mismatch in the text read.';

    trigger OnRun()
    begin
        // [MODULE] [Record Link Management]
    end;

    [Test]
    procedure TestWriteNote();
    var
        RecordLink: Record "Record Link";
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
        Assert.AreEqual('My note for the link', Text, WrongLinkTestErr);
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

        // [GIVEN] A new record 'Rec A' is created to set record links on
        FromRecordLinkRecordTest.DeleteAll();
        CreateRecordLinkRecTest(FromRecordLinkRecordTest);

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
        PermissionsMock.ClearAssignments();
        RecordLink.Insert(true);
        PermissionsMock.Set('Record Link View');

        // [GIVEN] A different record 'Rec B' in the same table
        CreateRecordLinkRecTest(ToRecordLinkRecordTest);

        // [WHEN] The record link is copied to the other instance
        RecLinkCount := NewRecordLink.Count();
        RecordLinkManagement.CopyLinks(FromRecordLinkRecordTest, ToRecordLinkRecordTest);
        Assert.IsTrue(OnAfterCopyLinksMonitor.IsEventRaised(), 'OnAfterCopyLinks event was not raised');

        // [THEN] A new record link has been created
        Assert.AreEqual(RecLinkCount + 1, NewRecordLink.Count(), 'No new record links created');
        Assert.AreNotEqual(NewRecordLink."Link ID", RecordLink."Link ID", 'New record link should be created with a new id.');

        // [THEN] The record link on the other instance has the same text
        NewRecordLink.SetRange("Record ID", ToRecordLinkRecordTest.RecordId());
        NewRecordLink.FindFirst();
        Assert.AreEqual('', RecordLinkManagement.ReadNote(NewRecordLink), WrongLinkTestErr);
    end;

    [Test]
    procedure CopyMultipleLinks()
    var
        FromRecordLinkRecordTest: Record "Record Link Record Test";
        ToRecordLinkRecordTest: Record "Record Link Record Test";
        FromRecordLink: Record "Record Link";
        ToRecordLink: Record "Record Link";
        NoteText: Text;
        I: Integer;
    begin
        // [SCENARIO] CopyLinks can copy multiple record links in one call

        // [GIVEN] A record 'RecordA' to assign links to
        CreateRecordLinkRecTest(FromRecordLinkRecordTest);

        // [GIVEN] Record links assigned the RecordA
        for I := 1 to Any.IntegerInRange(3, 6) do
            CreateRecordLink(FromRecordLinkRecordTest.RecordId);

        // [GIVEN] New record RecordB is created to receive the records
        CreateRecordLinkRecTest(ToRecordLinkRecordTest);

        // [WHEN] Copy links from RecordA to RecordB
        RecordLinkManagement.CopyLinks(FromRecordLinkRecordTest, ToRecordLinkRecordTest);

        // [THEN] Copies of all records from RecordA are created for RecordB
        FromRecordLink.SetRange("Record ID", FromRecordLinkRecordTest.RecordId);
        ToRecordLink.SetRange("Record ID", ToRecordLinkRecordTest.RecordId);
        Assert.RecordCount(ToRecordLink, FromRecordLink.Count());

        FromRecordLink.FindSet();
        ToRecordLink.FindSet();
        repeat
            NoteText := RecordLinkManagement.ReadNote(FromRecordLink);
            Assert.AreEqual(NoteText, RecordLinkManagement.ReadNote(ToRecordLink), WrongLinkTestErr);
        until (FromRecordLink.Next() = 0) or (ToRecordLink.Next() = 0);
    end;

    [Test]
    procedure CopyMultipleLinksInCrossCompanyRecord()
    var
        FromRecordLinkTestCrossCompany: Record "Record Link Test Cross Company";
        ToRecordLinkTestCrossCompany: Record "Record Link Test Cross Company";
        FromRecordLink: Record "Record Link";
        ToRecordLink: Record "Record Link";
        NoteText: Text;
        I: Integer;
    begin
        // [SCENARIO] CopyLinks can copy multiple record links in one call for cross company records

        // [GIVEN] A record 'RecordA' to assign links to
        CreateRecordLinkRecTest(FromRecordLinkTestCrossCompany);

        // [GIVEN] Record links assigned the RecordA
        for I := 1 to 5 do
            CreateRecordLink(FromRecordLinkTestCrossCompany.RecordId);
        VerifyRecordHasNotifyLinks(FromRecordLinkTestCrossCompany.RecordId, CompanyName(), 5);

        // [GIVEN] New record RecordB is created to receive the records
        CreateRecordLinkRecTest(ToRecordLinkTestCrossCompany);

        // [WHEN] Copy links from RecordA to RecordB
        RecordLinkManagement.CopyLinks(FromRecordLinkTestCrossCompany, ToRecordLinkTestCrossCompany);

        // [THEN] Copies of all records from RecordA are created for RecordB and set to not notify
        FromRecordLink.SetRange("Record ID", FromRecordLinkTestCrossCompany.RecordId);
        ToRecordLink.SetRange("Record ID", ToRecordLinkTestCrossCompany.RecordId);
        Assert.RecordCount(ToRecordLink, 5);

        FromRecordLink.FindSet();
        ToRecordLink.FindSet();
        repeat
            NoteText := RecordLinkManagement.ReadNote(FromRecordLink);
            Assert.AreEqual(NoteText, RecordLinkManagement.ReadNote(ToRecordLink), WrongLinkTestErr);
        until (FromRecordLink.Next() = 0) or (ToRecordLink.Next() = 0);
    end;

    [Test]
    procedure CopyMultipleLinksWithSimilarRecordIdInSeparateCompany()
    var
        FromRecordLinkRecordTest: Record "Record Link Record Test";
        ToRecordLinkRecordTest: Record "Record Link Record Test";
        RecordInOtherCompany: Record "Record Link Record Test";
        FromRecordLink: Record "Record Link";
        ToRecordLink: Record "Record Link";
        Company: Record Company;
        NoteText: Text;
        I: Integer;
    begin
        // [SCENARIO] CopyLinks can copy multiple record links in one call and sets notify to false without modifying links in other companies

        // [GIVEN] A record 'RecordA' to assign links to
        CreateRecordLinkRecTest(FromRecordLinkRecordTest);

        // [GIVEN] Record links assigned the RecordA
        for I := 1 to Any.IntegerInRange(3, 6) do
            CreateRecordLink(FromRecordLinkRecordTest.RecordId);

        // [GIVEN] New record RecordB is created to receive the records
        CreateRecordLinkRecTest(ToRecordLinkRecordTest);

        // [GIVEN] Another company
        Company.Name := 'Another Company';
        Company.Insert();

        // [GIVEN] A record similar to RecordB exist in the other company (same record id)
        RecordInOtherCompany.ChangeCompany(Company.Name);
        RecordInOtherCompany.TransferFields(ToRecordLinkRecordTest, true);
        RecordInOtherCompany.Insert();

        Assert.AreEqual(ToRecordLinkRecordTest.RecordId(), RecordInOtherCompany.RecordId(), 'Record ids are different');

        // [GIVEN] Record links assigned the the record in the other company and set to notify
        for I := 1 to 5 do
            CreateRecordLink(RecordInOtherCompany.RecordId, Company.Name);
        VerifyRecordHasNotifyLinks(RecordInOtherCompany.RecordId, Company.Name, 5);

        // [WHEN] Copy links from RecordA to RecordB
        RecordLinkManagement.CopyLinks(FromRecordLinkRecordTest, ToRecordLinkRecordTest);

        // [THEN] The links in the other company still has notify
        VerifyRecordHasNotifyLinks(RecordInOtherCompany.RecordId, Company.Name, 5);

        // [THEN] Copies of all records from RecordA are created for RecordB
        FromRecordLink.SetRange("Record ID", FromRecordLinkRecordTest.RecordId);
        FromRecordLink.SetRange(Company, CompanyName());
        ToRecordLink.SetRange("Record ID", ToRecordLinkRecordTest.RecordId);
        ToRecordLink.SetRange(Company, CompanyName());
        Assert.RecordCount(ToRecordLink, FromRecordLink.Count());

        FromRecordLink.FindSet();
        ToRecordLink.FindSet();
        repeat
            NoteText := RecordLinkManagement.ReadNote(FromRecordLink);
            Assert.AreEqual(NoteText, RecordLinkManagement.ReadNote(ToRecordLink), WrongLinkTestErr);
        until (FromRecordLink.Next() = 0) or (ToRecordLink.Next() = 0);
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
        PermissionsMock.ClearAssignments();
        RecordLink.Insert(true);
        PermissionsMock.Set('Record Link View');

        // [GIVEN] Ensure that Record link has no record id
        RecordLink.VALIDATE("Record ID", EmptyRecordId);
        RecordLink.Modify(true);

        // [WHEN] RemoveOrphanedLinks is called
        RecordLinkManagement.RemoveOrphanedLinks();

        // [THEN] No record link with that link id exists
        Assert.IsFalse(RecordLink.Get(RecordLink."Link ID"), 'As an orphan record link, this should have been removed.');
    end;

    [Test]
    procedure RemoveRecordLinksFromRecordSet()
    var
        RecordLinkRecTest: Record "Record Link Record Test";
        RecID: array[6] of Integer;
        I: Integer;
    begin
        // [SCENARIO] Delete all record links from a filtered recordset

        // [GIVEN] 6 records with record links
        for I := 1 to 6 do begin
            CreateRecordLinkRecTest(RecordLinkRecTest);
            RecordLinkRecTest.AddLink('');
            RecID[I] := RecordLinkRecTest.PK;
        end;

        // [WHEN] Filter the table to include records 1, 3, and 5, and call RemoveLinks
        RecordLinkRecTest.SetFilter(PK, '%1|%2|%3', RecID[1], RecID[3], RecID[5]);
        RecordLinkManagement.RemoveLinks(RecordLinkRecTest);

        // [THEN] Records 1, 3, 5 have no links
        RecordLinkRecTest.FindSet();
        repeat
            Assert.IsFalse(RecordLinkRecTest.HasLinks(), 'Record must not have links.');
        until RecordLinkRecTest.Next() = 0;

        // [THEN] Records 2, 4, 6 have links
        RecordLinkRecTest.SetFilter(PK, '%1|%2|%3', RecID[2], RecID[4], RecID[6]);
        RecordLinkRecTest.FindSet();
        repeat
            Assert.IsTrue(RecordLinkRecTest.HasLinks(), 'Record must have a record link.');
        until RecordLinkRecTest.Next() = 0;
    end;

    [Test]
    procedure RemoveRecordLinksErrorOnNotRecordArgument()
    var
        DummyText: Text;
        NotARecordErr: Label 'Internal server error. Please contact your system administrator.';
    begin
        // [SCENARIO] Error is thrown if the argument passed to the RemoveLinks procedure is not a Record

        asserterror RecordLinkManagement.RemoveLinks(DummyText);
        Assert.ExpectedError(NotARecordErr);
    end;

    local procedure CreateRecordLink(RecId: RecordId)
    begin
        CreateRecordLink(RecId, CompanyName());
    end;

    local procedure CreateRecordLink(RecId: RecordId; CompanyName: Text)
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink.Validate(Type, RecordLink.Type::Note);
        RecordLink.Validate("Record ID", RecId);
        RecordLinkManagement.WriteNote(RecordLink, Any.AlphanumericText(10));
        RecordLink.Validate(Created, CurrentDateTime());
        RecordLink.Validate("User ID", UserId());
        RecordLink.Validate(Company, CompanyName);
        RecordLink.Validate(Notify, true);
        RecordLink.Insert(true);
    end;

    local procedure CreateRecordLinkRecTest(var RecordLinkRecTest: Record "Record Link Record Test")
    begin
        Clear(RecordLinkRecTest);
        RecordLinkRecTest.Field := CopyStr(Any.AlphanumericText(10), 1, MaxStrLen(RecordLinkRecTest.Field));
        RecordLinkRecTest.Insert();
    end;

    local procedure CreateRecordLinkRecTest(var RecordLinkTestCrossCompany: Record "Record Link Test Cross Company")
    begin
        Clear(RecordLinkTestCrossCompany);
        RecordLinkTestCrossCompany.Field := CopyStr(Any.AlphanumericText(10), 1, MaxStrLen(RecordLinkTestCrossCompany.Field));
        RecordLinkTestCrossCompany.Insert();
    end;

    local procedure VerifyRecordHasNotifyLinks(RecordId: RecordID; CompanyName: Text; ExpectedCount: Integer)
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink.SetRange("Record ID", RecordId);
        RecordLink.SetRange(Company, CompanyName);
        Assert.RecordCount(RecordLink, ExpectedCount);
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


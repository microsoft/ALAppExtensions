// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Reflection;

using System.Reflection;
using System.TestLibraries.Reflection;
using System.TestLibraries.Utilities;
using System.TestLibraries.Security.AccessControl;

codeunit 135136 "Record Selection Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        TooManyRecordsErr: Label 'The selected table contains more than 2 records which is not supported.', Locked = true;
        NoRecordsErr: Label 'The selected table does not contain any records.', Locked = true;
        ExpectedTextTok: Label '3,C,The third', Locked = true;
        OnlyOneRecordMsg: Label 'The table contains only one record, which has been automatically selected.', Locked = true;
        SystemId: Guid;

    [Test]
    [HandlerFunctions('RecordLookupOKPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RecordSelectionTest()
    var
        RecordSelectionBuffer: Record "Record Selection Buffer";
        RecordSelection: Codeunit "Record Selection";
        RecordSelected: Boolean;
    begin
        // [SCENARIO] The record selection page is opened and a record is selected.
        // [GIVEN] Data in the test table
        Initialize();
        PermissionsMock.Set('Rec. Selection Read');

        // [WHEN] Open function is called and a record is selected.
        RecordSelected := RecordSelection.Open(Database::"Record Selection Test Table", 1000, RecordSelectionBuffer);

        // [THEN] The third record is picked
        Assert.IsTrue(RecordSelected, 'No record was selected.');
        Assert.AreEqual('3', RecordSelectionBuffer."Field 1", 'The third record should have been picked.');
        Assert.AreEqual('C', RecordSelectionBuffer."Field 2", 'The third record should have been picked.');
        Assert.AreEqual('The third', RecordSelectionBuffer."Field 3", 'The third record should have been picked.');
        Assert.AreEqual(SystemId, RecordSelectionBuffer."Record System Id", 'The third record should have been picked.');
    end;

    [Test]
    [HandlerFunctions('OneRecordMessageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RecordSelectionSingleRecordTest()
    var
        RecordSelectionBuffer: Record "Record Selection Buffer";
        RecordSelection: Codeunit "Record Selection";
        RecordSelected: Boolean;
    begin
        // [SCENARIO] The record selection page is opened and a record is auto selected because only one record exist in the table.
        // [GIVEN] Data in the test table
        InitializeRecordSelectionTestTable(1, 'A', 'The first', 'Other text');
        PermissionsMock.Set('Rec. Selection Read');

        // [WHEN] Open function is called and a record is auto selected.
        RecordSelected := RecordSelection.Open(Database::"Record Selection Test Table", 1000, RecordSelectionBuffer);

        // [THEN] The only record is picked
        Assert.IsTrue(RecordSelected, 'No record was selected.');
        Assert.AreEqual(SystemId, RecordSelectionBuffer."Record System Id", 'The first record should have been picked.');
    end;

    [Test]
    [HandlerFunctions('RecordLookupCancelPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RecordSelectionCancel()
    var
        RecordSelectionBuffer: Record "Record Selection Buffer";
        RecordSelection: Codeunit "Record Selection";
        RecordSelected: Boolean;
    begin
        // [SCENARIO] The record selection page is opened and then closed without making a selection.
        // [GIVEN] Data in the test table
        Initialize();
        PermissionsMock.Set('Rec. Selection Read');
        // [GIVEN] User selects Cancel
        // [THEN] Open function returns false
        RecordSelected := RecordSelection.Open(Database::"Record Selection Test Table", 1000, RecordSelectionBuffer);

        Assert.IsFalse(RecordSelected, 'The open function returned true');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RecordSelectionTooManyRecordsErrTest()
    var
        RecordSelectionBuffer: Record "Record Selection Buffer";
        RecordSelection: Codeunit "Record Selection";
    begin
        // [SCENARIO] The record selection page is opened but contains too many records so an error is thrown.
        // [GIVEN] Data in the test table
        Initialize();
        PermissionsMock.Set('Rec. Selection Read');

        // [WHEN] Open function is called and errors
        asserterror RecordSelection.Open(Database::"Record Selection Test Table", 2, RecordSelectionBuffer);

        // [THEN] An error is thrown that the table contains too many records
        Assert.ExpectedError(TooManyRecordsErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RecordSelectionNoRecordsErrTest()
    var
        RecordSelectionBuffer: Record "Record Selection Buffer";
        RecordSelection: Codeunit "Record Selection";
    begin
        // [SCENARIO] The record selection page is opened but contains no records so an error is thrown.
        // [GIVEN] Data in the test table
        PermissionsMock.Set('Rec. Selection Read');

        // [WHEN] Open function is called and errors
        asserterror RecordSelection.Open(Database::"Record Selection Test Table", 1000, RecordSelectionBuffer);

        // [THEN] An error is thrown that the table contains no records
        Assert.ExpectedError(NoRecordsErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RecordSelectionToTextTest()
    var
        RecordSelection: Codeunit "Record Selection";
    begin
        // [SCENARIO] To text is called for a record and the expected text is returned.
        Initialize();
        PermissionsMock.Set('Rec. Selection Read');
        // [GIVEN] ToText is called for a record
        // [THEN] the expected text is returned
        Assert.AreEqual(ExpectedTextTok, RecordSelection.ToText(Database::"Record Selection Test Table", SystemId), 'ToText did not return the expected text.');
    end;

    local procedure Initialize()
    begin
        InitializeRecordSelectionTestTable(1, 'A', 'The first', 'Other text');
        InitializeRecordSelectionTestTable(2, 'B', 'The second', 'Other text');
        InitializeRecordSelectionTestTable(3, 'C', 'The third', 'Other text');
    end;

    local procedure InitializeRecordSelectionTestTable(Integer: Integer; Code: Code[30]; Text: Text[250]; OtherText: Text[250])
    var
        RecordSelectionTestTable: Record "Record Selection Test Table";
    begin
        RecordSelectionTestTable.Init();
        RecordSelectionTestTable.SomeInteger := Integer;
        RecordSelectionTestTable.SomeCode := Code;
        RecordSelectionTestTable.SomeText := Text;
        RecordSelectionTestTable.SomeOtherText := OtherText;
        RecordSelectionTestTable.Insert();
        SystemId := RecordSelectionTestTable.SystemId;
    end;

    [ModalPageHandler]
    procedure RecordLookupOKPageHandler(var RecordLookup: TestPage "Record Lookup")
    begin
        RecordLookup.GoToKey(SystemId);
        RecordLookup.Ok().Invoke();
    end;

    [ModalPageHandler]
    procedure RecordLookupCancelPageHandler(var RecordLookup: TestPage "Record Lookup")
    begin
        RecordLookup.Cancel().Invoke();
    end;

    [MessageHandler]
    procedure OneRecordMessageHandler(Message: Text[1024])
    begin
        Assert.AreEqual(OnlyOneRecordMsg, Message, 'Wrong message when record is autoselected');
    end;
}
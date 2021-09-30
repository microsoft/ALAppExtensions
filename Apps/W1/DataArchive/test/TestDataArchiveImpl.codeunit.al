// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This codeunit tests archiving scenarios.
/// </summary>
codeunit 139504 "Test Data Archive Impl."
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCreateArchive()
    var
        DataArchive: Record "Data Archive"; // data archive app
        DataArchiveInterface: Codeunit "Data Archive";  // System App
        CurrCount: Integer;
        NewArchiveNo: Integer;
    begin
        CurrCount := DataArchive.Count();
        NewArchiveNo := DataArchiveInterface.Create('New Archive');

        Assert.AreNotEqual(0, NewArchiveNo, 'New archive returned 0');
        Assert.AreEqual(CurrCount + 1, DataArchive.Count(), 'Expected exactly one extra archive.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSaveRecord()
    var
        DataArchiveTable: Record "Data Archive Table"; // data archive app
        CurrCount: Integer;
        NewArchiveNo: Integer;
    begin
        CurrCount := DataArchiveTable.Count();
        NewArchiveNo := CreateCustomerArchive(true);
        Assert.AreNotEqual(0, NewArchiveNo, 'New archive returned 0');
        Assert.AreEqual(CurrCount + 1, DataArchiveTable.Count(), 'Expected exactly one extra archive.');
        DataArchiveTable.SetRange("Data Archive Entry No.", NewArchiveNo);
        DataArchiveTable.FindLast();
        Assert.AreEqual(1, DataArchiveTable."No. of Records", 'Wrong no. of records.');
        Assert.IsTrue(DataArchiveTable."Table Data (json)".HasValue(), 'The table data field is empty.');
        Assert.IsTrue(DataArchiveTable."Table Fields (json)".HasValue(), 'The table fields field is empty.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSaveRecords()
    var
        DataArchiveTable: Record "Data Archive Table"; // data archive app
        Customer: Record Customer;
        CurrCount: Integer;
        NewArchiveNo: Integer;
    begin
        CurrCount := DataArchiveTable.Count();
        NewArchiveNo := CreateCustomerArchive(false);
        Assert.AreNotEqual(0, NewArchiveNo, 'New archive returned 0');
        Assert.AreEqual(CurrCount + 1, DataArchiveTable.Count(), 'Expected exactly one extra archive.');
        DataArchiveTable.SetRange("Data Archive Entry No.", NewArchiveNo);
        DataArchiveTable.FindLast();
        Assert.AreEqual(Customer.Count(), DataArchiveTable."No. of Records", 'Wrong no. of records.');
        Assert.IsTrue(DataArchiveTable."Table Data (json)".HasValue(), 'The table data field is empty.');
        Assert.IsTrue(DataArchiveTable."Table Fields (json)".HasValue(), 'The table fields field is empty.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSaveSaveAsCSV()
    var
        DataArchiveList: TestPage "Data Archive List";
        NewArchiveNo: Integer;
    begin
        // Given: An archive exists
        NewArchiveNo := CreateCustomerArchive(false);
        Assert.AreNotEqual(0, NewArchiveNo, 'New archive returned 0');
        // Export to CSV gives no error
        DataArchiveList.OpenView();
        DataArchiveList.Last();
        DataArchiveList.SaveToCSV.Invoke();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSaveSaveAsExcel()
    var
        DataArchiveList: TestPage "Data Archive List";
        NewArchiveNo: Integer;
    begin
        // Given: An archive exists
        NewArchiveNo := CreateCustomerArchive(false);
        Assert.AreNotEqual(0, NewArchiveNo, 'New archive returned 0');

        // Export to Excel gives no error
        DataArchiveList.OpenView();
        DataArchiveList.Last();
        DataArchiveList.SaveAsExcel.Invoke();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestRecordDeletions()
    var
        DataArchiveTable: Record "Data Archive Table";
        Customer: Record Customer;
        DataArchiveNewArchive: TestPage "Data Archive - New Archive";
        CurrCount: Integer;
    begin
        // Given: A customer exists
        Customer."No." := CopyStr(Format(CreateGuid()), 1, MaxStrLen(Customer."No."));
        Customer.Insert();

        // When a recording of a customer deletion
        CurrCount := DataArchiveTable.Count();
        if DataArchiveTable.FindLast() then;
        DataArchiveNewArchive.OpenEdit();
        DataArchiveNewArchive.ArchiveName.SetValue('TEST');
        DataArchiveNewArchive.Start.Invoke();
        Customer.Delete();
        DataArchiveNewArchive.Stop.Invoke();
        DataArchiveNewArchive.Close();

        // Then a data archive entry/entries will be created, and at least one of them will be for Customer
        Assert.IsTrue(DataArchiveTable.Count() > CurrCount, 'New archive was expected.');
        DataArchiveTable.SetFilter("Data Archive Entry No.", '>%1', DataArchiveTable."Data Archive Entry No.");
        DataArchiveTable.SetRange("Table No.", Database::Customer);
        DataArchiveTable.FindLast();
        Assert.IsTrue(DataArchiveTable."Table Data (json)".HasValue(), 'The table data field is empty.');
        Assert.IsTrue(DataArchiveTable."Table Fields (json)".HasValue(), 'The table fields field is empty.');
    end;

    local procedure CreateCustomerArchive(OnlyFirstCustomer: Boolean): Integer
    var
        Customer: Record Customer;
        DataArchiveInterface: Codeunit "Data Archive";  // System App
        RecRef: RecordRef;
        NewArchiveNo: Integer;
    begin
        NewArchiveNo := DataArchiveInterface.Create('New Archive');
        if not Customer.FindFirst() then
            exit(0);
        RecRef.GetTable(Customer);
        if OnlyFirstCustomer then
            DataArchiveInterface.SaveRecord(Customer) // passed as Variant
        else
            DataArchiveInterface.SaveRecords(RecRef);
        DataArchiveInterface.Save();
        exit(NewArchiveNo);
    end;
}
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135031 "Persistent Blob Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateNewBlobTest()
    var
        PersistentBlob: Codeunit "Persistent Blob";
        "Key": BigInteger;
    begin
        // [SCENARIO] A new PersistentBlob can be created.

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Blob Storage Exec');

        Key := PersistentBlob.Create();
        Assert.IsTrue(PersistentBlob.Exists(Key), 'Blob should have been created.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteBlobTest()
    var
        PersistentBlob: Codeunit "Persistent Blob";
        "Key": BigInteger;
    begin
        // [SCENARIO] An existing PersistentBlob can be deleted.

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Blob Storage Exec');

        Key := PersistentBlob.Create();

        Assert.IsTrue(PersistentBlob.Delete(Key), 'Blob should have been deleted.');
        Assert.IsFalse(PersistentBlob.Exists(Key), 'Blob should not exist.');
        Assert.IsFalse(PersistentBlob.Delete(Key), 'Blob cannot be deleted.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ReadFromWriteToStreamTest()
    var
        TempBlob: Codeunit "Temp Blob";
        PersistentBlob: Codeunit "Persistent Blob";
        BlobOutStream: OutStream;
        BlobInStream: InStream;
        "Key": BigInteger;
        Content: Text;
        Result: Text;
    begin
        // [SCENARIO] Content from an InStream can be stored to PersistentBlob and PersistentBlob content can be written to an OutStream.

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Blob Storage Exec');

        // [GIVEN] Some Content is written to an InStream.
        Content := 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna';
        Content += 'aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ';
        Content += 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. ';
        Content += 'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
        TempBlob.CreateOutStream(BlobOutStream);
        BlobOutStream.WriteText(Content);
        TempBlob.CreateInStream(BlobInStream);

        // [GIVEN] An existing PersistentBlob.
        Key := PersistentBlob.Create();

        // [THEN] InStream's content can be stored to an existing BLOB.
        Assert.IsTrue(PersistentBlob.CopyFromInStream(Key, BlobInStream), 'It is possible to write to an existing Blob.');
        Assert.IsFalse(PersistentBlob.CopyFromInStream(Key + 1, BlobInStream),
          'It is not possible to write to a non existing Blob.');

        Clear(TempBlob);

        // [THEN] PersistentBlob's content can be written to an OutStream.
        TempBlob.CreateOutStream(BlobOutStream);
        Assert.IsTrue(PersistentBlob.CopyToOutStream(Key, BlobOutStream), 'It is possible to read from an existing Blob.');
        Assert.IsFalse(PersistentBlob.CopyToOutStream(Key + 1, BlobOutStream),
          'It is not possible to read from a non existing Blob.');

        // [THEN] Verify the content was not altered.
        TempBlob.CreateInStream(BlobInStream);
        BlobInStream.ReadText(Result);
        Assert.AreEqual(Content, Result, 'A different Blob content was expected.');
    end;

    [Test]
    procedure NoKeyReuseTest()
    var
        PersistentBlob: Codeunit "Persistent Blob";
        Key1: BigInteger;
        Key2: BigInteger;
    begin
        // [SCENARIO] A different key used every time a new PersistentBlob is created.

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Blob Storage Exec');

        Key1 := PersistentBlob.Create();
        PersistentBlob.Delete(Key1);
        Commit();
        Key2 := PersistentBlob.Create();
        Assert.AreNotEqual(Key1, Key2, 'Keys should not be reused.');
    end;
}


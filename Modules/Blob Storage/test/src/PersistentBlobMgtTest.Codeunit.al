// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135031 "Persistent Blob Mgt. Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateNewBlobTest()
    var
        PersistentBlobMgt: Codeunit "Persistent Blob Mgt.";
        "Key": BigInteger;
    begin
        // [SCENARIO] A new PersistentBlob can be created.
        Key := PersistentBlobMgt.Create();
        Assert.IsTrue(PersistentBlobMgt.Exists(Key), 'Blob should have been created.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteBlobTest()
    var
        PersistentBlobMgt: Codeunit "Persistent Blob Mgt.";
        "Key": BigInteger;
    begin
        // [SCENARIO] An existing PersistentBlob can be deleted.
        Key := PersistentBlobMgt.Create();

        Assert.IsTrue(PersistentBlobMgt.Delete(Key), 'Blob should have been deleted.');
        Assert.IsFalse(PersistentBlobMgt.Exists(Key), 'Blob should not exist.');
        Assert.IsFalse(PersistentBlobMgt.Delete(Key), 'Blob cannot be deleted.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ReadFromWriteToStreamTest()
    var
        TempBlob: Codeunit "Temp Blob";
        PersistentBlobMgt: Codeunit "Persistent Blob Mgt.";
        BlobOutStream: OutStream;
        BlobInStream: InStream;
        "Key": BigInteger;
        Content: Text;
        Result: Text;
    begin
        // [SCENARIO] Content from an InStream can be stored to PersistentBlob and PersistentBlob content can be written to an OutStream.

        // [GIVEN] Some Content is written to an InStream.
        Content := 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna';
        Content += 'aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ';
        Content += 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. ';
        Content += 'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
        TempBlob.CreateOutStream(BlobOutStream);
        BlobOutStream.WriteText(Content);
        TempBlob.CreateInStream(BlobInStream);

        // [GIVEN] An existing PersistentBlob.
        Key := PersistentBlobMgt.Create();

        // [THEN] InStream's content can be stored to an existing BLOB.
        Assert.IsTrue(PersistentBlobMgt.CopyFromInStream(Key, BlobInStream), 'It is possible to write to an existing Blob.');
        Assert.IsFalse(PersistentBlobMgt.CopyFromInStream(Key + 1, BlobInStream),
          'It is not possible to write to a non existing Blob.');

        Clear(TempBlob);

        // [THEN] PersistentBlob's content can be written to an OutStream.
        TempBlob.CreateOutStream(BlobOutStream);
        Assert.IsTrue(PersistentBlobMgt.CopyToOutStream(Key, BlobOutStream), 'It is possible to read from an existing Blob.');
        Assert.IsFalse(PersistentBlobMgt.CopyToOutStream(Key + 1, BlobOutStream),
          'It is not possible to read from a non existing Blob.');

        // [THEN] Verify the content was not altered.
        TempBlob.CreateInStream(BlobInStream);
        BlobInStream.ReadText(Result);
        Assert.AreEqual(Content, Result, 'A different Blob content was expected.');
    end;

    [Test]
    procedure NoKeyReuseTest()
    var
        PersistentBlobMgt: Codeunit "Persistent Blob Mgt.";
        Key1: BigInteger;
        Key2: BigInteger;
    begin
        // [SCENARIO] A different key used every time a new PersistentBlob is created.
        Key1 := PersistentBlobMgt.Create();
        PersistentBlobMgt.Delete(Key1);
        Commit();
        Key2 := PersistentBlobMgt.Create();
        Assert.AreNotEqual(Key1, Key2, 'Keys should not be reused.');
    end;
}


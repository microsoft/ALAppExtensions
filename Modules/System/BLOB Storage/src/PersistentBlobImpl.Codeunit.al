// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4108 "Persistent Blob Impl."
{
    Access = Internal;
    Permissions = TableData PersistentBlob = rimd;

    procedure Create() "Key": BigInteger
    var
        PersistentBlob: Record PersistentBlob;
    begin
        PersistentBlob.Insert();
        Key := PersistentBlob."Primary Key";
    end;

    procedure Exists("Key": BigInteger): Boolean
    var
        PersistentBlob: Record PersistentBlob;
    begin
        PersistentBlob.SetRange("Primary Key", Key);
        exit(not PersistentBlob.IsEmpty());
    end;

    procedure Delete("Key": BigInteger): Boolean
    var
        PersistentBlob: Record PersistentBlob;
    begin
        if PersistentBlob.Get(Key) then
            exit(PersistentBlob.Delete());
    end;

    procedure CopyFromInStream("Key": BigInteger; Source: InStream): Boolean
    var
        PersistentBlob: Record PersistentBlob;
        Destination: OutStream;
    begin
        if not PersistentBlob.Get(Key) then
            exit(false);

        PersistentBlob.Blob.CreateOutStream(Destination);
        if not CopyStream(Destination, Source) then
            exit(false);
        exit(PersistentBlob.Modify());
    end;

    procedure CopyToOutStream("Key": BigInteger; Destination: OutStream): Boolean
    var
        PersistentBlob: Record PersistentBlob;
        Source: InStream;
    begin
        if not PersistentBlob.Get(Key) then
            exit(false);

        PersistentBlob.CalcFields(Blob);
        PersistentBlob.Blob.CreateInStream(Source);
        exit(CopyStream(Destination, Source));
    end;
}


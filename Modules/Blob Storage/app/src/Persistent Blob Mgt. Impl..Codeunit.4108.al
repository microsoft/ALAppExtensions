// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4108 "Persistent Blob Mgt. Impl."
{
    Permissions = TableData PersistentBlob=rimd;

    trigger OnRun()
    begin
    end;

    [Scope('OnPrem')]
    procedure Create() "Key": BigInteger
    var
        PersistentBlob: Record PersistentBlob;
    begin
        PersistentBlob.Insert;
        Key := PersistentBlob."Primary Key";
    end;

    [Scope('OnPrem')]
    procedure Exists("Key": BigInteger): Boolean
    var
        PersistentBlob: Record PersistentBlob;
    begin
        exit(PersistentBlob.Get(Key));
    end;

    [Scope('OnPrem')]
    procedure Delete("Key": BigInteger): Boolean
    var
        PersistentBlob: Record PersistentBlob;
    begin
        if PersistentBlob.Get(Key) then
          exit(PersistentBlob.Delete);
    end;

    [Scope('OnPrem')]
    procedure CopyFromInStream("Key": BigInteger;Source: InStream): Boolean
    var
        PersistentBlob: Record PersistentBlob;
        Destination: OutStream;
    begin
        if not PersistentBlob.Get(Key) then
          exit(false);

        PersistentBlob.Blob.CreateOutStream(Destination);
        if not CopyStream(Destination,Source) then
          exit(false);
        exit(PersistentBlob.Modify);
    end;

    [Scope('OnPrem')]
    procedure CopyToOutStream("Key": BigInteger;Destination: OutStream): Boolean
    var
        PersistentBlob: Record PersistentBlob;
        Source: InStream;
    begin
        if not PersistentBlob.Get(Key) then
          exit(false);

        PersistentBlob.CalcFields(Blob);
        PersistentBlob.Blob.CreateInStream(Source);
        exit(CopyStream(Destination,Source));
    end;
}


// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4108 "Persistent Blob Impl."
{
    Access = Internal;
    Permissions = TableData "Persistent Blob" = rimd;

    procedure Create() "Key": BigInteger
    var
        PersistentBlob: Record "Persistent Blob";
    begin
        PersistentBlob.Insert();
        Key := PersistentBlob."Primary Key";
    end;

    procedure Exists("Key": BigInteger): Boolean
    var
        PersistentBlob: Record "Persistent Blob";
    begin
        PersistentBlob.SetRange("Primary Key", Key);
        exit(not PersistentBlob.IsEmpty());
    end;

    procedure Delete("Key": BigInteger): Boolean
    var
        PersistentBlob: Record "Persistent Blob";
    begin
        if PersistentBlob.Get(Key) then
            exit(PersistentBlob.Delete());
    end;

    procedure CopyFromInStream("Key": BigInteger; SourceInStream: InStream): Boolean
    var
        PersistentBlob: Record "Persistent Blob";
        DestinationOutStream: OutStream;
    begin
        if not PersistentBlob.Get(Key) then
            exit(false);

        PersistentBlob.Blob.CreateOutStream(DestinationOutStream);
        if not CopyStream(DestinationOutStream, SourceInStream) then
            exit(false);
        exit(PersistentBlob.Modify());
    end;

    procedure CopyToOutStream("Key": BigInteger; DestinationOutStream: OutStream): Boolean
    var
        PersistentBlob: Record "Persistent Blob";
        SourceInStream: InStream;
    begin
        if not PersistentBlob.Get(Key) then
            exit(false);

        PersistentBlob.CalcFields(Blob);
        PersistentBlob.Blob.CreateInStream(SourceInStream);
        exit(CopyStream(DestinationOutStream, SourceInStream));
    end;
}


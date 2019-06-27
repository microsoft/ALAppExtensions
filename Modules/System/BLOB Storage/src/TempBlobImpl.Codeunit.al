// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4107 "Temp Blob Impl."
{
    Access = Internal;

    var
        TempBlob: Record TempBlob temporary;

    [Scope('OnPrem')]
    procedure CreateInStream(var InStream: InStream)
    begin
        TempBlob.Blob.CreateInStream(InStream)
    end;

    [Scope('OnPrem')]
    procedure CreateInStreamWithEncoding(var InStream: InStream; Encoding: TextEncoding)
    begin
        TempBlob.Blob.CreateInStream(InStream, Encoding)
    end;

    [Scope('OnPrem')]
    procedure CreateOutStream(var OutStream: OutStream)
    begin
        TempBlob.Blob.CreateOutStream(OutStream)
    end;

    [Scope('OnPrem')]
    procedure CreateOutStreamWithEncoding(var OutStream: OutStream; Encoding: TextEncoding)
    begin
        TempBlob.Blob.CreateOutStream(OutStream, Encoding)
    end;

    [Scope('OnPrem')]
    procedure HasValue(): Boolean
    begin
        exit(TempBlob.Blob.HasValue())
    end;

    [Scope('OnPrem')]
    procedure Length(): Integer
    begin
        exit(TempBlob.Blob.Length())
    end;

    [Scope('OnPrem')]
    procedure FromRecord(RecordVariant: Variant; FieldNo: Integer)
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(RecordVariant);
        FromRecordRef(RecordRef, FieldNo)
    end;

    [Scope('OnPrem')]
    procedure FromRecordRef(RecordRef: RecordRef; FieldNo: Integer)
    var
        BlobFieldRef: FieldRef;
    begin
        BlobFieldRef := RecordRef.Field(FieldNo);
        TempBlob.Blob := BlobFieldRef.Value();
        if not HasValue() then begin
            BlobFieldRef.CalcField();
            TempBlob.Blob := BlobFieldRef.Value()
        end
    end;

    [Scope('OnPrem')]
    procedure ToRecordRef(var RecordRef: RecordRef; FieldNo: Integer)
    var
        BlobFieldRef: FieldRef;
    begin
        BlobFieldRef := RecordRef.Field(FieldNo);
        BlobFieldRef.Value := TempBlob.Blob
    end;
}


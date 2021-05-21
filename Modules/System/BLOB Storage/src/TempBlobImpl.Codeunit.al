// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4107 "Temp Blob Impl."
{
    Access = Internal;

    var
    #pragma warning disable AA0073
        TempBlob: Record "Temp Blob" temporary;
    #pragma warning restore AA0073

    procedure CreateInStream(var InStream: InStream)
    begin
        TempBlob.Blob.CreateInStream(InStream);
    end;

    procedure CreateInStream(var InStream: InStream; Encoding: TextEncoding)
    begin
        TempBlob.Blob.CreateInStream(InStream, Encoding);
    end;

    procedure CreateOutStream(var OutStream: OutStream)
    begin
        TempBlob.Blob.CreateOutStream(OutStream);
    end;

    procedure CreateOutStream(var OutStream: OutStream; Encoding: TextEncoding)
    begin
        TempBlob.Blob.CreateOutStream(OutStream, Encoding);
    end;

    procedure HasValue(): Boolean
    begin
        exit(TempBlob.Blob.HasValue());
    end;

    procedure Length(): Integer
    begin
        exit(TempBlob.Blob.Length());
    end;

    procedure FromRecord(RecordVariant: Variant; FieldNo: Integer)
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(RecordVariant);
        FromRecordRef(RecordRef, FieldNo);
    end;

    procedure FromRecordRef(RecordRef: RecordRef; FieldNo: Integer)
    var
        BlobFieldRef: FieldRef;
    begin
        BlobFieldRef := RecordRef.Field(FieldNo);
        FromFieldRef(BlobFieldRef);
    end;

    procedure ToRecordRef(var RecordRef: RecordRef; FieldNo: Integer)
    var
        BlobFieldRef: FieldRef;
    begin
        BlobFieldRef := RecordRef.Field(FieldNo);
        ToFieldRef(BlobFieldRef);
    end;

    procedure FromFieldRef(BlobFieldRef: FieldRef)
    begin
        TempBlob.Blob := BlobFieldRef.Value();
        if not HasValue() then begin
            BlobFieldRef.CalcField();
            TempBlob.Blob := BlobFieldRef.Value()
        end
    end;

    procedure ToFieldRef(var BlobFieldRef: FieldRef)
    begin
        BlobFieldRef.Value := TempBlob.Blob;
    end;
}


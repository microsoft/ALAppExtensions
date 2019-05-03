// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4100 "Temp Blob"
{

    trigger OnRun()
    begin
    end;

    var
        TempBlobImpl: Codeunit "Temp Blob Impl.";

    procedure CreateInStream(var InStream: InStream)
    begin
        // <summary>
        // Creates an InStream object with default encoding for the TempBlob. This enables you to read data from the TempBlob.
        // </summary
        // <param name="InStream">The InStream variable passed as a VAR to which the BLOB content will be attached.</param>
        TempBlobImpl.CreateInStream(InStream)
    end;

    procedure CreateInStreamWithEncoding(var InStream: InStream;Encoding: TextEncoding)
    begin
        // <summary>
        // Creates an InStream object with the specified encoding for the TempBlob. This enables you to read data from the TempBlob.
        // </summary>
        // <param name="InStream">The InStream variable passed as a VAR to which the BLOB content will be attached.</param>
        // <param name="Encoding">The text encoding to use.</param>
        TempBlobImpl.CreateInStreamWithEncoding(InStream,Encoding)
    end;

    procedure CreateOutStream(var OutStream: OutStream)
    begin
        // <summary>
        // Creates an OutStream object with default encoding for the TempBlob. This enables you to write data to the TempBlob.
        // </summary>
        // <param name="OutStream">The OutStream variable passed as a VAR to which the BLOB content will be attached.</param>
        TempBlobImpl.CreateOutStream(OutStream)
    end;

    procedure CreateOutStreamWithEncoding(var OutStream: OutStream;Encoding: TextEncoding)
    begin
        // <summary>
        // Creates an OutStream object with the specified encoding for the TempBlob. This enables you to write data to the TempBlob.
        // </summary>
        // <param name="OutStream">The OutStream variable passed as a VAR to which the BLOB content will be attached.</param>
        // <param name="Encoding">The text encoding to use.</param>
        TempBlobImpl.CreateOutStreamWithEncoding(OutStream,Encoding)
    end;

    procedure HasValue(): Boolean
    begin
        // <summary>
        // Determines whether the TempBlob has a value.
        // </summary>
        // <returns>True if the TempBlob has a value.</returns>
        exit(TempBlobImpl.HasValue)
    end;

    procedure Length(): Integer
    begin
        // <summary>
        // Determines the length of the data stored in the TempBlob.
        // </summary>
        // <returns>The number of bytes stored in the BLOB.</returns>
        exit(TempBlobImpl.Length)
    end;

    procedure FromRecord(RecordVariant: Variant;FieldNo: Integer)
    begin
        // <summary>
        // Copies the value of the BLOB field on the RecordVariant in the specified field to the TempBlob.
        // </summary>
        // <param name="RecordVariant">Any Record variable.</param>
        // <param name="FieldNo">The field number of the BLOB field to be read.</param>
        TempBlobImpl.FromRecord(RecordVariant,FieldNo);
    end;

    procedure FromRecordRef(RecordRef: RecordRef;FieldNo: Integer)
    begin
        // <summary>
        // Copies the value of the BLOB field on the RecordRef in the specified field to the TempBlob.
        // </summary>
        // <param name="RecordRef">A RecordRef variable attached to a Record.</param>
        // <param name="FieldNo">The field number of the BLOB field to be read.</param>
        TempBlobImpl.FromRecordRef(RecordRef,FieldNo)
    end;

    procedure ToRecordRef(var RecordRef: RecordRef;FieldNo: Integer)
    begin
        // <summary>
        // Copies the value of the TempBlob to the specified field on the RecordRef.
        // </summary>
        // <param name="RecordRef">A RecordRef variable attached to a Record.</param>
        // <param name="FieldNo">The field number of the Blob field to be written.</param>
        TempBlobImpl.ToRecordRef(RecordRef,FieldNo);
    end;
}


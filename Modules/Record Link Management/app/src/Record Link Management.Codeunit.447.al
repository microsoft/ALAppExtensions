// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 447 "Record Link Management"
{

    trigger OnRun()
    begin
    end;

    local procedure ResetNotifyOnLinks(RecVar: Variant)
    var
        RecordLink: Record "Record Link";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecVar);
        RecordLink.SetRange("Record ID",RecRef.RecordId);
        RecordLink.SetRange(Notify,true);
        if not RecordLink.IsEmpty then
          RecordLink.ModifyAll(Notify,false);
    end;

    procedure CopyLinks(FromRecord: Variant;ToRecord: Variant)
    var
        RecRefTo: RecordRef;
    begin
        // <summary>
        // Copies all the links from one record to the other and sets Notify to FALSE for them.
        // </summary>
        // <param name="FromRecord">The source record from which links are copied.</param>
        // <param name="ToRecord">The destination record to which links are copied.</param>

        RecRefTo.GetTable(ToRecord);
        RecRefTo.CopyLinks(FromRecord);
        ResetNotifyOnLinks(RecRefTo);
    end;

    procedure WriteRecordLinkNote(var RecordLink: Record "Record Link";Note: Text)
    var
        BinWriter: DotNet BinaryWriter;
        OStr: OutStream;
    begin
        // <summary>
        // Writes the Note BLOB into the format the client code expects.
        // </summary>
        // <param name="RecordLink">The record link passed as a VAR to which the note is added.</param>
        // <param name="Note">The note to be added.</param>
        RecordLink.Note.CreateOutStream(OStr,TEXTENCODING::UTF8);
        BinWriter := BinWriter.BinaryWriter(OStr);
        BinWriter.Write(Note);
    end;

    procedure ReadRecordLinkNote(RecordLink: Record "Record Link") Note: Text
    var
        BinReader: DotNet BinaryReader;
        IStr: InStream;
    begin
        // <summary>
        // Read the Note BLOB
        // </summary>
        // <param name="RecordLink">The record link from which the note is read.</param>
        // <returns>The note as a text.</returns>
        RecordLink.Note.CreateInStream(IStr,TEXTENCODING::UTF8);
        BinReader := BinReader.BinaryReader(IStr);
        // Peek if stream is empty
        if BinReader.BaseStream.Position = BinReader.BaseStream.Length then
          exit;
        Note := BinReader.ReadString;
    end;
}


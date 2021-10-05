// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exports the contents one or more "Data Archive Table" records and pack them into a zip file for download.
/// </summary>
codeunit 609 "Data Archive Export to CSV"
{
    Access = Internal;
    TableNo = "Data Archive Table";

    trigger OnRun()
    begin
        ExportToCSV(Rec);
    end;

    var
        CsvSeparator: Text[1];
        ArchiveEmptyErr: Label 'There are no archived records.';
        GeneratingFileMsg: Label 'Creating file @1@@@';
        DownloadLbl: Label 'Download';
        NotAllTablesExportedMsg: Label 'You do not have the Read permission for some of the selected tables. Only the tables you have the Read permission for have been exported.';
        NoFilesAddedMsg: Label 'No files were created.';


    local procedure ExportToCSV(var DataArchiveTable: Record "Data Archive Table")
    var
        DataArchive: Record "Data Archive";
        TempBlob: Codeunit "Temp Blob";
        DataCompression: Codeunit "Data Compression";
        Window: Dialog;
        InStr: InStream;
        OutStr: OutStream;
        FileName: Text;
        NoOfFilesAdded: Integer;
        NoOfDataRecords: Integer;
        NoOfTablesWithNoReadAccess: Integer;
        T0: Time;
    begin
        if DataArchiveTable.GetFilter("Data Archive Entry No.") = '' then
            DataArchiveTable.SetRange("Data Archive Entry No.", DataArchiveTable."Data Archive Entry No.");
        DataArchiveTable.SetFilter("No. of Records", '>0');
        DataArchiveTable.SetAutoCalcFields("Table Name");
        if not DataArchiveTable.FindSet() then
            Error(ArchiveEmptyErr);

        Window.Open(GeneratingFileMsg);
        T0 := Time;
        if StrPos(Format(1.1), ',') > 0 then
            CsvSeparator := ';'
        else
            CsvSeparator := ',';
            
        NoOfDataRecords := DataArchiveTable.Count();
        DataCompression.CreateZipArchive();
        repeat
            if DataArchiveTable.HasReadPermission() then begin
                if DataArchiveTable.Description = '' then
                    DataArchiveTable.Description := DataArchiveTable."Table Name";
                DataArchiveTable.Description := DelChr(DataArchiveTable.Description, '=', '/\');
                Clear(TempBlob);
                TempBlob.CreateOutStream(OutStr);
                WriteToCsvStream(DataArchiveTable, OutStr);
                TempBlob.CreateInStream(InStr);
                DataCompression.AddEntry(InStr, DataArchiveTable.Description + '.csv');
                NoOfFilesAdded += 1;
                if Time > T0 + 1000 then begin
                    Window.Update(1, NoOfFilesAdded * 100 div NoOfDataRecords);
                    T0 := Time;
                end;
            end else
                NoOfTablesWithNoReadAccess += 1;
        until DataArchiveTable.Next() = 0;
        Window.Close();
        if NoOfFilesAdded = 0 then begin
            Message(NoFilesAddedMsg);
            exit;
        end;
        TempBlob.CreateOutStream(OutStr);
        DataCompression.SaveZipArchive(OutStr);
        DataCompression.CloseZipArchive();
        TempBlob.CreateInStream(InStr);
        if NoOfFilesAdded > 1 then begin
            DataArchive.Get(DataArchiveTable."Data Archive Entry No.");
            FileName := DataArchive.Description + '.zip';
        end else
            FileName := DataArchiveTable.Description + '.zip';
        DownloadFromStream(InStr, DownloadLbl, '', '*.zip', FileName);
        if NoOfTablesWithNoReadAccess > 0 then
            Message(NotAllTablesExportedMsg);
    end;

    procedure WriteToCsvStream(var DataArchiveTable: Record "Data Archive Table"; var CsvOutStr: Outstream)
    var
        TempBlob: Codeunit "Temp Blob";
        SchemaJson: JsonArray;
        TableJson: JsonArray;
        RecordJson: JsonArray;
        FieldJson: JsonObject;
        JsonToken: JsonToken;
        InStr: InStream;
        OutStr: OutStream;
        QuoteChars: array[1000] of Boolean;
        QuoteTxt: Text[1];
        FieldTypeAsText: Text;
        RecordNo: Integer;
        FieldIndex: Integer;
        FieldNo: Integer;
        Line: TextBuilder;
        CR: Text[1];
    begin
        CR[1] := 10;
        // Schema - Headers in the sheet
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        DataArchiveTable."Table Fields (json)".ExportStream(OutStr);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        SchemaJson.ReadFrom(InStr);
        for FieldIndex := 0 to SchemaJson.Count() - 1 do begin
            SchemaJson.Get(FieldIndex, JsonToken);
            FieldJson := JsonToken.AsObject();
            FieldJson.Get('DataType', JsonToken);
            FieldTypeAsText := JsonToken.AsValue().AsText();
            if FieldIndex < ArrayLen(QuoteChars) then
                QuoteChars[FieldIndex + 1] := FieldTypeAsText in ['Text', 'Code'];
            FieldJson.Get('FieldName', JsonToken);
            If FieldIndex = 0 then
                Line.Append('"' + JsonToken.AsValue().AsText() + '"')
            else
                Line.Append(CsvSeparator + '"' + JsonToken.AsValue().AsText() + '"');
        end;
        CsvOutStr.WriteText(Line.ToText() + CR);
        // Data - Rows in the sheet
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        DataArchiveTable."Table Data (json)".ExportStream(OutStr);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        TableJson.ReadFrom(InStr);
        for RecordNo := 0 to TableJson.Count() - 1 do begin
            Clear(Line);
            TableJson.Get(RecordNo, JsonToken);
            RecordJson := JsonToken.AsArray();
            for FieldIndex := 0 to SchemaJson.Count() - 1 do begin
                SchemaJson.Get(FieldIndex, JsonToken);
                FieldJson := JsonToken.AsObject();
                FieldJson.Get('FieldNumber', JsonToken);
                FieldNo := JsonToken.AsValue().AsInteger();
                RecordJson.Get(FieldIndex, JsonToken);
                FieldJson := JsonToken.AsObject();
                FieldJson.Get(Format(FieldNo), JsonToken);
                if QuoteChars[FieldIndex + 1] then
                    QuoteTxt := '"'
                else
                    QuoteTxt := '';
                If FieldIndex = 0 then
                    Line.Append(QuoteTxt + JsonToken.AsValue().AsText() + QuoteTxt)
                else
                    Line.Append(CsvSeparator + QuoteTxt + JsonToken.AsValue().AsText() + QuoteTxt);
            end;
            CsvOutStr.WriteText(Line.ToText() + CR);
        end;
    end;
}
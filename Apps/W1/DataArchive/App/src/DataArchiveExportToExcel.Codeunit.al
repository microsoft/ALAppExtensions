// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exports the contents one or more "Data Archive Table" records into an Excel book with one sheet per table.
/// </summary>
codeunit 608 "Data Archive Export To Excel"
{
    Access = Internal;
    TableNo = "Data Archive Table";

    trigger OnRun()
    begin
        ExportToExcel(Rec);
    end;

    var
        ArchiveEmptyErr: Label 'There are no archived records.';
        GeneratingFileMsg: Label 'Creating file @1@@';
        NotAllTablesExportedMsg: Label 'You do not have the Read permission for some of the selected tables. Only the tables you have the Read permission for have been exported.';

    local procedure ExportToExcel(var DataArchiveTable: Record "Data Archive Table")
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        FileMgt: Codeunit "File Management";
        Window: Dialog;
        ServerFileName: Text;
        CurrentRecNo: Integer;
        NoOfTablesWithNoReadAccess: Integer;
        T0: Time;
    begin
        if DataArchiveTable.GetFilter("Data Archive Entry No.") = '' then
            DataArchiveTable.SetRange("Data Archive Entry No.", DataArchiveTable."Entry No.");
        DataArchiveTable.SetFilter("No. of Records", '>0');
        DataArchiveTable.SetAutoCalcFields("Table Name");
        if not DataArchiveTable.FindSet() then
            Error(ArchiveEmptyErr);

        Window.Open(GeneratingFileMsg);
        T0 := Time;
        ServerFileName := FileMgt.ServerTempFileName('xlsx');
        TempExcelBuffer.CreateBook(ServerFileName, DataArchiveTable."Table Name" + '-' + format(DataArchiveTable."Entry No."));
        Window.Update(1, 0);
        repeat
            if DataArchiveTable.HasReadPermission() then begin
                TempExcelBuffer.DeleteAll();
                FillExcelBuffer(TempExcelBuffer, DataArchiveTable, Window, T0, CurrentRecNo);
                TempExcelBuffer.SelectOrAddSheet(DataArchiveTable."Table Name" + '-' + format(DataArchiveTable."Entry No."));
                TempExcelBuffer.WriteAllToCurrentSheet(TempExcelBuffer);
            end else 
                NoOfTablesWithNoReadAccess += 1;
        until DataArchiveTable.Next() = 0;
        TempExcelBuffer.CloseBook();
        Window.Close();
        if NoOfTablesWithNoReadAccess > 0 then
            Message(NotAllTablesExportedMsg);
        TempExcelBuffer.OpenExcel();
    end;

    local procedure FillExcelBuffer(var TempExcelBuffer: Record "Excel Buffer" temporary; var DataArchiveTable: Record "Data Archive Table"; var Window: Dialog; T0: Time; var CurrentRecNo: integer)
    var
        DataArchiveMediaField: Record "Data Archive Media Field";
        TempBlob: Codeunit "Temp Blob";
        SchemaJson: JsonArray;
        TableJson: JsonArray;
        RecordJson: JsonArray;
        FieldJson: JsonObject;
        JsonToken: JsonToken;
        InStr: InStream;
        OutStr: OutStream;
        RecordNo: Integer;
        FieldIndex: Integer;
        FieldNo: Integer;
        FieldValueAsText: Text;
        FieldTypeAsText: Text;
        FieldValueAsDateTime: DateTime;
        FieldValueAsDate: Date;
        FieldValueAsInteger: Integer;
        FieldValueAsDecimal: Decimal;
        FieldValueAsTime: Time;
    begin
        // Schema - Headers in the sheet
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        DataArchiveTable."Table Fields (json)".ExportStream(OutStr);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        SchemaJson.ReadFrom(InStr);
        for FieldIndex := 0 to SchemaJson.Count() - 1 do begin
            SchemaJson.Get(FieldIndex, JsonToken);
            FieldJson := JsonToken.AsObject();
            FieldJson.Get('FieldName', JsonToken);
            FieldValueAsText := JsonToken.AsValue().AsText();
            TempExcelBuffer.Init();
            TempExcelBuffer.Validate("Column No.", FieldIndex + 1);
            TempExcelBuffer.Validate("Row No.", 1);
            TempExcelBuffer.Validate("Cell Type", TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer."Cell Value as Text" := copystr(FieldValueAsText, 1, MaxStrLen(TempExcelBuffer."Cell Value as Text"));
            TempExcelBuffer.Insert();
        end;

        // Data - Rows in the sheet
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        DataArchiveTable."Table Data (json)".ExportStream(OutStr);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        TableJson.ReadFrom(InStr);
        for RecordNo := 0 to TableJson.Count() - 1 do begin
            TableJson.Get(RecordNo, JsonToken);
            RecordJson := JsonToken.AsArray();
            for FieldIndex := 0 to SchemaJson.Count() - 1 do begin
                SchemaJson.Get(FieldIndex, JsonToken);
                FieldJson := JsonToken.AsObject();
                FieldJson.Get('FieldNumber', JsonToken);
                FieldNo := JsonToken.AsValue().AsInteger();
                FieldJson.Get('DataType', JsonToken);
                FieldTypeAsText := JsonToken.AsValue().AsText();
                RecordJson.Get(FieldIndex, JsonToken);
                FieldJson := JsonToken.AsObject();
                FieldJson.Get(Format(FieldNo), JsonToken);
                FieldValueAsText := JsonToken.AsValue().AsText();

                TempExcelBuffer.Init();
                TempExcelBuffer.Validate("Column No.", FieldIndex + 1);
                TempExcelBuffer.Validate("Row No.", RecordNo + 2);
                TempExcelBuffer.Validate("Cell Type", TempExcelBuffer."Cell Type"::Text);

                case FieldTypeAsText of
                    'Integer':
                        begin
                            if Evaluate(FieldValueAsInteger, FieldValueAsText, 9) then
                                FieldValueAsText := format(FieldValueAsInteger);
                            TempExcelBuffer.Validate("Cell Type", TempExcelBuffer."Cell Type"::Number);
                        end;
                    'Decimal':
                        begin
                            if Evaluate(FieldValueAsDecimal, FieldValueAsText, 9) then
                                FieldValueAsText := format(FieldValueAsDecimal);
                            TempExcelBuffer.Validate("Cell Type", TempExcelBuffer."Cell Type"::Number);
                        end;
                    'Date':
                        begin
                            if Evaluate(FieldValueAsDate, FieldValueAsText, 9) then
                                FieldValueAsText := format(FieldValueAsDate);
                            TempExcelBuffer.Validate("Cell Type", TempExcelBuffer."Cell Type"::Date);
                        end;
                    'DateTime':
                        begin
                            if Evaluate(FieldValueAsDateTime, FieldValueAsText, 9) then
                                FieldValueAsText := format(FieldValueAsDateTime);
                            TempExcelBuffer.Validate("Cell Type", TempExcelBuffer."Cell Type"::Date);
                        end;
                    'Time':
                        begin
                            if Evaluate(FieldValueAsTime, FieldValueAsText, 9) then
                                FieldValueAsText := format(FieldValueAsTime);
                            TempExcelBuffer.Validate("Cell Type", TempExcelBuffer."Cell Type"::Time);
                        end;
                    'Blob', 'Media':
                        if Evaluate(FieldValueAsInteger, FieldValueAsText, 9) then
                            if DataArchiveMediaField.Get(FieldValueAsInteger) then
                                FieldValueAsText := format(DataArchiveMediaField."Field Content");
                    else
                        TempExcelBuffer.Validate("Cell Type", TempExcelBuffer."Cell Type"::Text);
                end;

                TempExcelBuffer."Cell Value as Text" := copystr(FieldValueAsText, 1, MaxStrLen(TempExcelBuffer."Cell Value as Text"));
                TempExcelBuffer.Insert();
            end;
            CurrentRecNo += 1;
            if Time > T0 + 1000 then begin
                Window.Update(1, CurrentRecNo * 100 div DataArchiveTable."No. of Records");
                T0 := Time;
            end;
        end;
    end;

}

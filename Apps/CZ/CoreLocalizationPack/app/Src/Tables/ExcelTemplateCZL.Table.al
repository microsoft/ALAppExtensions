// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.IO;

using System.Utilities;

table 11750 "Excel Template CZL"
{
    Caption = 'Excel Template';
    DataClassification = CustomerContent;
    LookupPageId = "Excel Templates CZL";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; Template; Blob)
        {
            Caption = 'Template';
            DataClassification = CustomerContent;
        }
        field(25; Sheet; Text[250])
        {
            Caption = 'Sheet';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TempExcelBuffer: Record "Excel Buffer" temporary;
                Sheet2: Text[250];
                InStr: InStream;
            begin
                if not Template.HasValue() then
                    exit;
                CalcFields(Template);
                Template.CreateInStream(InStr);
                Sheet2 := TempExcelBuffer.SelectSheetsNameStream(InStr);
                if Sheet2 <> '' then
                    Sheet := Sheet2;
            end;
        }
        field(30; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        FileName: Text;
        DeleteQst: Label 'Do you want delete %1?', Comment = '%1 = File Name';
        ExcelExtensionTok: Label '.xlsx', Locked = true;

    procedure ExportToClientFile(var ExportToFile: Text): Boolean
    begin
        Rec.TestField(Code);
        if Template.HasValue() then begin
            CalcFields(Template);
            TempBlob.FromRecord(Rec, FieldNo(Template));
            if ExportToFile = '' then begin
                FileName := Rec.Code + ExcelExtensionTok;
                ExportToFile := FileManagement.BLOBExport(TempBlob, FileName, true);
            end else
                ExportToFile := FileManagement.BLOBExport(TempBlob, ExportToFile, false);
            exit(true);
        end;
    end;

    procedure ImportFromClientFile(): Boolean
    var
        RecordRef: RecordRef;
    begin
        Rec.TestField(Code);
        FileName := FileManagement.BLOBImport(TempBlob, ExcelExtensionTok);
        if FileName = '' then
            exit(false);

        RecordRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecordRef, FieldNo(Template));
        RecordRef.SetTable(Rec);
        if Modify(true) then;
        exit(true);
    end;

    procedure RemoveTemplate(Prompt: Boolean) DeleteOK: Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        DeleteYesNo: Boolean;
    begin
        Rec.TestField(Code);
        DeleteOK := false;
        DeleteYesNo := true;
        if Prompt then
            if not ConfirmManagement.GetResponse(StrSubstNo(DeleteQst, FieldCaption(Template)), false) then
                DeleteYesNo := false;

        if DeleteYesNo then begin
            Clear(Template);
            Clear(Sheet);
            if Modify(true) then;
            DeleteOK := true;
        end;
    end;
}

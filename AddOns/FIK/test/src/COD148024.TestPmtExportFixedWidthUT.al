// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148024 "Pmt Export Fixed-Width UT"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryTextFileValidation: Codeunit "Library - Text File Validation";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        FileLineCountIsWrongErr: Label 'Number of lines in file %1 is wrong.';
        FileLineValueIsWrongErr: Label 'Column number %1 has an unexpected value at line number %2.';
        ColumnsNotSequentialErr: Label 'The data to be exported is not structured correctly. The columns in the dataset must be sequential.';

    trigger OnRun();
    begin
        // [FEATURE] [FIK]
    end;

    [Test]
    procedure CreateSDCPmtFile();
    var
        FileName: Text[1024];
        DataExchEntryNo: Integer;
        SDCExport: Code[20];
    begin
        // Pre-Setup
        SDCExport := FindDataExchDefinition('*SDC*');

        // Setup
        DataExchEntryNo := CreateDataExch();
        CreateSDCDataExchFields(DataExchEntryNo, SDCExport, 'BTD');

        // Exercise
        ExportPmtDataToFixedWidthFile(FileName, DataExchEntryNo, XMLPORT::"Export Generic Fixed Width");

        // Verify
        VerifyPmtFileLineCount(FileName, 1, '3', 1, 1);
        VerifySDCPmtFileContent(DataExchEntryNo, FileName);
    end;

    [Test]
    procedure CreateBankDataPmtFile();
    var
        FileName: Text[1024];
        DataExchEntryNo: Integer;
        BankDataExport: Code[20];
    begin
        // Pre-Setup
        BankDataExport := FindDataExchDefinition('*BankData*');

        // Setup
        DataExchEntryNo := CreateDataExch();
        CreateBankDataDataExchFields(DataExchEntryNo, BankDataExport, 'BTD');

        // Exercise
        ExportPmtDataToFixedWidthFile(FileName, DataExchEntryNo, XMLPORT::"Export Generic Fixed Width");

        // Verify
        VerifyPmtFileLineCount(FileName, 1, 'IB030202000005', 1, 14);
        VerifyBankDataPmtFileContent(DataExchEntryNo, FileName);
    end;

    [Test]
    procedure CreateBankDataColumnsNotInSequence();
    var
        DataExchField: Record "Data Exch. Field";
        FileName: Text[1024];
        DataExchEntryNo: Integer;
        BankDataExport: Code[20];
    begin
        // Pre-Setup
        BankDataExport := FindDataExchDefinition('*BankData*');

        // Setup
        DataExchEntryNo := CreateDataExch();
        CreateBankDataDataExchFields(DataExchEntryNo, BankDataExport, 'BTD');
        DataExchField.GET(DataExchEntryNo, 1, 12);
        DataExchField.DELETE(TRUE);

        // Exercise
        ASSERTERROR ExportPmtDataToFixedWidthFile(FileName, DataExchEntryNo, XMLPORT::"Export Generic Fixed Width");

        // Verify
        Assert.ExpectedError(ColumnsNotSequentialErr);
    end;

    local procedure CheckColumnValue(DataExchNo: Integer; Line: Text[1024]; LineNo: Integer; ColumnNo: Integer; StartingPosition: Integer; Length: Integer);
    var
        Actual: Text;
        Expected: Text;
    begin
        Expected := PADSTR(GetFieldValue(DataExchNo, LineNo, ColumnNo), Length);
        Actual := ReadFieldValue(Line, StartingPosition, Length);
        Assert.AreEqual(Expected, Actual, STRSUBSTNO(FileLineValueIsWrongErr, ColumnNo, LineNo));
    end;

    local procedure CreateOutputTextFile(var OutputFile: File; var OutStream: OutStream; FileName: Text[1024]);
    begin
        OutputFile.WRITEMODE := TRUE;
        OutputFile.TEXTMODE := TRUE;
        OutputFile.CREATE(FileName);
        OutputFile.CREATEOUTSTREAM(OutStream);
    end;

    local procedure CreateDataExch() NewEntryNo: Integer;
    var
        DataExch: Record "Data Exch.";
    begin
        NewEntryNo := LastDataExchEntryNo() + 1;
        DataExch."Entry No." := NewEntryNo;
        DataExch.INSERT();
    end;

    local procedure CreateSDCDataExchFields(DataExchEntryNo: Integer; ExportCode: Code[20]; DataExchLineDefCode: Code[20]);
    var
        DataExchField: Record "Data Exch. Field";
    begin
        WITH DataExchField DO BEGIN
            InsertRec(DataExchEntryNo, 1, 1, '3', DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 2, STRSUBSTNO('%1%2', GetBranchNo(), GetAccountNo()), DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 3,
              FORMAT(LibraryUtility.GenerateRandomDate(TODAY(), WORKDATE()), 0, GetFormatStr(ExportCode, DataExchLineDefCode, 3)),
              DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 4,
              FORMAT(LibraryRandom.RandDec(10000, 2), 0, GetFormatStr(ExportCode, DataExchLineDefCode, 4)),
              DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 5, 'J', DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 6, PADSTR(LibraryUtility.GenerateGUID(), 20), DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 7, GetBranchNo(), DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 8, GetAccountNo(), DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 9, PADSTR('', 4), DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 10, PADSTR(LibraryUtility.GenerateGUID(), 20), DataExchLineDefCode);
        END;
    end;

    local procedure CreateBankDataDataExchFields(DataExchEntryNo: Integer; ExportCode: Code[20]; DataExchLineDefCode: Code[20]);
    var
        DataExchField: Record "Data Exch. Field";
        i: Integer;
    begin
        WITH DataExchField DO BEGIN
            InsertRec(DataExchEntryNo, 1, 1, 'IB030202000005', DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 2, '0001', DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 3,
              FORMAT(LibraryUtility.GenerateRandomDate(TODAY(), WORKDATE()), 0, GetFormatStr(ExportCode, DataExchLineDefCode, 3)),
              DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 4,
              FORMAT(100 * LibraryRandom.RandDec(10000, 2), 0, GetFormatStr(ExportCode, DataExchLineDefCode, 4)),
              DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 5, 'DKK', DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 6, '2', DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 7, '0' + GetBranchNo() + GetAccountNo(), DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 8, '2', DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 9, GetBranchNo(), DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 10, GetAccountNo(), DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 11, '0', DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 12, PADSTR(LibraryUtility.GenerateGUID(), 35), DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 13, PADSTR(LibraryUtility.GenerateGUID(), 32), DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 14, PADSTR(LibraryUtility.GenerateGUID(), 32), DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 15, PADSTR(LibraryUtility.GenerateGUID(), 32), DataExchLineDefCode);
            InsertRec(DataExchEntryNo, 1, 16, PADSTR(LibraryUtility.GenerateGUID(), 4), DataExchLineDefCode);
            FOR i := 17 TO 29 DO
                InsertRec(DataExchEntryNo, 1, i, '', DataExchLineDefCode);
        END;
    end;

    local procedure ExportPmtDataToFixedWidthFile(var FileName: Text[1024]; EntryNo: Integer; XMLPortNo: Integer);
    var
        DataExchField: Record "Data Exch. Field";
        FileManagement: Codeunit "File Management";
        ExportFile: File;
        OutStream: OutStream;
    begin
        FileName := COPYSTR(FileManagement.ServerTempFileName('txt'), 1, 1024);
        CreateOutputTextFile(ExportFile, OutStream, FileName);
        DataExchField.SETRANGE("Data Exch. No.", EntryNo);
        XMLPORT.EXPORT(XMLPortNo, OutStream, DataExchField);
        ExportFile.CLOSE();
    end;

    local procedure FindDataExchDefinition(DefCode: Text): Code[20];
    var
        DataExchDef: Record "Data Exch. Def";
    begin
        WITH DataExchDef DO BEGIN
            SETRANGE(Type, Type::"Payment Export");
            SETFILTER(Code, DefCode);
            FINDFIRST();
            EXIT(Code);
        END;
    end;

    local procedure GetAccountNo(): Text[10];
    begin
        EXIT(CopyStr(STRSUBSTNO('%1%2', LibraryRandom.RandIntInRange(11111, 99999), LibraryRandom.RandIntInRange(11111, 99999)), 1, 10));
    end;

    local procedure GetBranchNo(): Text[4];
    begin
        EXIT(FORMAT(LibraryRandom.RandIntInRange(1111, 9999)));
    end;

    local procedure GetFormatStr(DataExchDefCode: Code[20]; DataExchLineDefCode: Code[20]; ColumnNo: Integer): Text[100];
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
    begin
        DataExchColumnDef.GET(DataExchDefCode, DataExchLineDefCode, ColumnNo);
        EXIT(DataExchColumnDef."Data Format");
    end;

    local procedure GetFieldValue(DataExchNo: Integer; LineNo: Integer; ColumnNo: Integer): Text[250];
    var
        DataExchField: Record "Data Exch. Field";
    begin
        DataExchField.GET(DataExchNo, LineNo, ColumnNo);
        EXIT(DataExchField.Value);
    end;

    local procedure LastDataExchEntryNo(): Integer;
    var
        DataExch: Record "Data Exch.";
    begin
        IF DataExch.FINDLAST() THEN
            EXIT(DataExch."Entry No.");
        EXIT(0);
    end;

    local procedure ReadFieldValue(Line: Text[1024]; StartingPosition: Integer; Length: Integer): Text[1024];
    begin
        EXIT(CopyStr(LibraryTextFileValidation.ReadValue(Line, StartingPosition, Length), 1, 1024));
    end;

    local procedure VerifySDCPmtFileContent(DataExchNo: Integer; FileName: Text[1024]);
    var
        Actual: Text;
        Line: Text[1024];
        Expected: Text;
    begin
        Line := CopyStr(LibraryTextFileValidation.ReadLine(FileName, 1), 1, MaxStrLen(Line));
        CheckColumnValue(DataExchNo, Line, 1, 1, 1, 1);
        CheckColumnValue(DataExchNo, Line, 1, 2, 2, 14);
        CheckColumnValue(DataExchNo, Line, 1, 3, 16, 6);

        Expected := GetFieldValue(DataExchNo, 1, 4);
        Expected := PADSTR('', 15 - STRLEN(Expected)) + Expected;
        Actual := ReadFieldValue(Line, 22, 15);
        Assert.AreEqual(Expected, Actual, STRSUBSTNO(FileLineValueIsWrongErr, 4, 1));

        CheckColumnValue(DataExchNo, Line, 1, 5, 37, 1);
        CheckColumnValue(DataExchNo, Line, 1, 6, 38, 20);
        CheckColumnValue(DataExchNo, Line, 1, 7, 58, 4);
        CheckColumnValue(DataExchNo, Line, 1, 8, 62, 10);
        CheckColumnValue(DataExchNo, Line, 1, 9, 72, 4);
        CheckColumnValue(DataExchNo, Line, 1, 10, 76, 20);
    end;

    local procedure VerifyBankDataPmtFileContent(DataExchNo: Integer; FileName: Text[1024]);
    var
        Line: Text[1024];
        Actual: Text;
        Expected: Text;
    begin
        Line := CopyStr(LibraryTextFileValidation.ReadLine(FileName, 1), 1, MaxStrLen(Line));
        CheckColumnValue(DataExchNo, Line, 1, 1, 1, 14);
        CheckColumnValue(DataExchNo, Line, 1, 2, 15, 4);
        CheckColumnValue(DataExchNo, Line, 1, 3, 19, 8);

        Expected := CONVERTSTR(GetFieldValue(DataExchNo, 1, 4), ' ', '+');
        Expected := PADSTR('', 14 - STRLEN(Expected), '0') + Expected;
        Actual := ReadFieldValue(Line, 27, 14);
        Assert.AreEqual(Expected, Actual, STRSUBSTNO(FileLineValueIsWrongErr, 4, 1));

        CheckColumnValue(DataExchNo, Line, 1, 5, 41, 3);
        CheckColumnValue(DataExchNo, Line, 1, 6, 44, 1);
        CheckColumnValue(DataExchNo, Line, 1, 7, 45, 15);
        CheckColumnValue(DataExchNo, Line, 1, 8, 60, 1);
        CheckColumnValue(DataExchNo, Line, 1, 9, 61, 4);
        CheckColumnValue(DataExchNo, Line, 1, 10, 65, 10);
        CheckColumnValue(DataExchNo, Line, 1, 11, 75, 1);
        CheckColumnValue(DataExchNo, Line, 1, 12, 76, 35);
    end;

    local procedure VerifyPmtFileLineCount(FileName: Text[1024]; LineCount: Integer; KeyValue: Text; StartingPosition: Integer; FieldLength: Integer);
    var
        ActualLineCount: Integer;
    begin
        ActualLineCount := LibraryTextFileValidation.CountNoOfLinesWithValue(FileName, KeyValue, StartingPosition, FieldLength);
        Assert.AreEqual(LineCount, ActualLineCount, STRSUBSTNO(FileLineCountIsWrongErr, FileName));
    end;
}




// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.NoSeries;
using System.IO;
using System.Telemetry;
using System.Text;
using System.Utilities;

report 5314 "Import SIE"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Import SIE';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(JournalTemplateName; GenJournalLineGlobal."Journal Template Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Gen. Journal Template';
                        TableRelation = "Gen. Journal Template";
                        ToolTip = 'Specifies the name of the general journal to use during the import process.';

                        trigger OnValidate()
                        begin
                            GenJournalLineGlobal."Journal Batch Name" := '';
                        end;
                    }
                    field(JournalBatchName; GenJournalLineGlobal."Journal Batch Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Gen. Journal Batch';
                        Lookup = true;
                        ToolTip = 'Specifies the name of the general journal batch to use during the import process.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            GenJournalLineGlobal.TestField("Journal Template Name");
                            GenJournalTemplate.Get(GenJournalLineGlobal."Journal Template Name");
                            GenJournalBatch.SetRange("Journal Template Name", GenJournalLineGlobal."Journal Template Name");
                            GenJournalBatch."Journal Template Name" := GenJournalLineGlobal."Journal Template Name";
                            GenJournalBatch.Name := GenJournalLineGlobal."Journal Batch Name";
                            if Page.RunModal(0, GenJournalBatch) = Action::LookupOK then begin
                                GenJournalLineGlobal."Journal Batch Name" := GenJournalBatch.Name;
                                ValidateJnl(GenJournalLineGlobal);
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            if GenJournalLineGlobal."Journal Batch Name" <> '' then begin
                                GenJournalLineGlobal.TestField("Journal Template Name");
                                GenJournalBatch.Get(GenJournalLineGlobal."Journal Template Name", GenJournalLineGlobal."Journal Batch Name");
                            end;
                            ValidateJnl(GenJournalLineGlobal);
                        end;
                    }
                    field(ColumnDimField; ColumnDim)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Dimensions';
                        Editable = false;
                        ToolTip = 'Specifies the dimensions covered by the import process.';

                        trigger OnAssistEdit()
                        begin
                            Clear(DimensionsSiePage);
                            DimensionsSiePage.LookupMode(true);
                            DimensionsSiePage.Run();
                            ColumnDim := DimensionSie.GetDimSelectionText();
                        end;
                    }
                    field(InsertNewAccField; InsertNewAccount)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Insert G/L Account';
                        ToolTip = 'Specifies whether the general ledger account in the import file is missing in the chart of accounts, and must be set up during the import process.';
                    }
                    field(UseSeriesField; UseSeries)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Use Number Series for Doc. No.';
                        ToolTip = 'Specifies whether to use the number series functionality if document numbers are not provided in the import file.';
                    }
                }
            }
        }

        actions
        {
        }
#if CLEAN22
        trigger OnOpenPage()
        begin
            FeatureTelemetry.LogUptake('0000JPN', SieImportTok, Enum::"Feature Uptake Status"::Discovered);
            OnActivateForm();
        end;
#else
        trigger OnOpenPage()
        var
            SIEManagement: Codeunit "SIE Management";
        begin
            if not SIEManagement.IsFeatureEnabled() then begin
                Report.Run(Report::"SIE Import");
                Error('');
            end;

            FeatureTelemetry.LogUptake('0000JPN', SieImportTok, Enum::"Feature Uptake Status"::Discovered);
            OnActivateForm();
        end;
#endif
    }

    labels
    {
    }

    trigger OnPostReport()
    var
        GenJnlLine: Record "Gen. Journal Line";
        ConfirmMgt: Codeunit "Confirm Management";
        GenJnlMgt: Codeunit GenJnlManagement;
    begin
        FeatureTelemetry.LogUptake('0000JPO', SieImportTok, Enum::"Feature Uptake Status"::"Set up");

        if not GuiAllowed() then
            exit;
        GenJnlLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        if GenJnlLine.IsEmpty() then
            Message(ImportSuccessTxt)
        else
            if ConfirmMgt.GetResponseOrDefault(ImportSuccessTxt + OpenGenJournalQst, false) then
                GenJnlMgt.TemplateSelectionFromBatch(GenJournalBatch);
    end;

    trigger OnPreReport()
    var
        TempImportBufferSie: Record "Import Buffer SIE" temporary;
        FileName: Text;
        FileInStream: InStream;
    begin
        if TempBlobGlobal.HasValue() then
            TempBlobGlobal.CreateInStream(FileInStream)
        else begin
            if not UploadIntoStream(ImportFileTitleTxt, '', SieFileFilterTxt, FileName, FileInStream) then
                Error('');
            if FileName = '' then
                Error('');
        end;

        if GuiAllowed() then
            ProgressDialog.Open(ReadingFileTxt + CreateJournalTxt);

        ValidateJnl(GenJournalLineGlobal);
        DecimalSeparator := CopyStr(Format(1 / 2), 2, 1);
        ParseSieFileToImportBuffer(TempImportBufferSie, FileInStream);
        CreateDataFromImportBuffer(TempImportBufferSie);

        if GuiAllowed() then
            ProgressDialog.Close();
    end;

    var
        DimensionSie: Record "Dimension SIE";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLineGlobal: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TempBlobGlobal: Codeunit "Temp Blob";
        DimensionsSiePage: Page "Dimensions SIE";
        ProgressDialog: Dialog;
        ColumnDim: Text;
        InsertNewAccount: Boolean;
        UseSeries: Boolean;
        DD: Integer;
        MM: Integer;
        YYYY: Integer;
        DecimalSeparator: Text[1];
        SieFileFilterTxt: label 'SIE files(*.se)|*.se|All files|*.*';
        ImportFileTitleTxt: label 'Import SIE File';
        SieImportTok: label 'SIE Import Data', Locked = true;
        ReadingFileTxt: label 'Reading SIE file lines     #1##########\', Comment = '#1 - number of current line';
        CreateJournalTxt: label 'Create journal             @2@@@@@@@@@@\';
        ImportSuccessTxt: label 'The file was imported successfully. ';
        OpenGenJournalQst: label 'Do you want to open the General Journal window with the imported lines?';

    local procedure ParseSieFileToImportBuffer(var TempImportBufferSie: Record "Import Buffer SIE" temporary; var FileInStream: InStream)
    var
        DotNetStreamReader: Codeunit DotNet_StreamReader;
        DotNetEncoding: Codeunit DotNet_Encoding;
        BufferRecRef: RecordRef;
        BufferFieldRef: FieldRef;
        LineText: Text;
        CurrFieldValue: Text;
        EntryNo: Integer;
        BufferFieldNo: Integer;
        BufferMaxFieldLen: Integer;
    begin
        DotNetEncoding.Encoding(1252);      // Windows-1252
        DotNetStreamReader.StreamReader(FileInStream, DotNetEncoding);
        if DotNetStreamReader.EndOfStream() then
            exit;

        BufferMaxFieldLen := 100;
        BufferRecRef.GetTable(TempImportBufferSie);
        repeat
            LineText := DotNetStreamReader.ReadLine();
            EntryNo += 1;

            ProgressDialog.Update(1, EntryNo);

            LineText := ReplaceTabWithSpace(LineText);
            LineText := Ansi2Ascii(LineText);

            BufferFieldNo := 1;
            BufferRecRef.Init();
            BufferRecRef.Field(BufferFieldNo).Value := EntryNo;

            while (LineText <> '') and (BufferFieldNo <= 11) do begin   // total 10 fields in buffer
                BufferFieldNo += 1;
                CurrFieldValue := GetNextField(LineText);
                CurrFieldValue := RemoveHashAndBrackets(CurrFieldValue);

                BufferFieldRef := BufferRecRef.Field(BufferFieldNo);
                BufferFieldRef.Value := CopyStr(CurrFieldValue, 1, BufferMaxFieldLen);
            end;

            BufferRecRef.Insert();
        until DotNetStreamReader.EndOfStream();
    end;

    local procedure CreateDataFromImportBuffer(var TempImportBufferSie: Record "Import Buffer SIE" temporary)
    var
        GenJournalLine: Record "Gen. Journal Line";
        BufferRecCount: Integer;
        GLAccountNo: Code[20];
        DocumentNo: Code[20];
        PostingDate: Date;
        Description: Text[100];
        NextLineNo: Integer;
    begin
        if TempImportBufferSie.IsEmpty() then
            exit;

        BufferRecCount := TempImportBufferSie.Count();
        PostingDate := 0D;
        DocumentNo := '';
        Description := '';
        NextLineNo := GenJournalLine.GetNewLineNo(GenJournalBatch."Journal Template Name", GenJournalBatch.Name);

        TempImportBufferSie.FindSet();
        repeat
            if GuiAllowed() then
                ProgressDialog.Update(2, Round(TempImportBufferSie."Entry No." / BufferRecCount * 10000, 1.0));

            case TempImportBufferSie."Import Field 1" of
                'FLAGGA':
                    TempImportBufferSie.TestField("Import Field 2", '0');
                'TRANS':
                    CreateGenJnlLine(TempImportBufferSie, DocumentNo, PostingDate, Description, NextLineNo);
                'KONTO':
                    if InsertNewAccount then begin
                        GLAccountNo := CopyStr(DelChr(TempImportBufferSie."Import Field 2", '=', ' '), 1, MaxStrLen(GLAccount."No."));
                        if GLAccountNo <> '' then begin
                            GLAccount.Init();
                            GLAccount.Validate("No.", GLAccountNo);
                            GLAccount.Validate(Name, CopyStr(DelChr(TempImportBufferSie."Import Field 3", '=', '"'), 1, 30));
                            if (CopyStr(GLAccount."No.", 1, 1) = '1') or (CopyStr(GLAccount."No.", 1, 1) = '2') then
                                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Balance Sheet"
                            else
                                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Income Statement";
                            GLAccount."Direct Posting" := true;
                            if GLAccount.Insert() then;
                        end;
                    end;
                'VER':
                    begin
                        if UseSeries then
                            DocumentNo := CopyStr(DelChr(TempImportBufferSie."Import Field 2", '=', '"') + DelChr(TempImportBufferSie."Import Field 3", '=', '"'), 1, MaxStrLen(DocumentNo))
                        else
                            DocumentNo := CopyStr(DelChr(TempImportBufferSie."Import Field 3", '=', '"'), 1, MaxStrLen(DocumentNo));
                        if StrLen(DocumentNo) = 0 then
                            DocumentNo := NoSeriesMgt.GetNextNo(GenJournalBatch."No. Series", WorkDate(), false);

                        TempImportBufferSie."Import Field 4" := DelChr(TempImportBufferSie."Import Field 4", '=<>', DelChr(TempImportBufferSie."Import Field 4", '=<>', '0123456789'));
                        // File format YYYYMMDD according to swedish standard
                        Evaluate(DD, CopyStr(TempImportBufferSie."Import Field 4", 7, 2));
                        Evaluate(MM, CopyStr(TempImportBufferSie."Import Field 4", 5, 2));
                        Evaluate(YYYY, CopyStr(TempImportBufferSie."Import Field 4", 1, 4));
                        PostingDate := DMY2Date(DD, MM, YYYY);
                        Description := TempImportBufferSie."Import Field 5";
                    end;
            end;
        until TempImportBufferSie.Next() = 0;
    end;

    local procedure ValidateJnl(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
    end;

    local procedure Ansi2Ascii(AnsiText: Text): Text
    var
        AsciiStr: Text[30];
        AnsiStr: Text[30];
        AE: Char;
        UE: Char;
        Lilla: Char;
        Stora: Char;
    begin
        AsciiStr := 'åäöüÅÄÖÜéêèâàç';
        AE := 196;
        UE := 220;
        Lilla := 229;
        Stora := 197;
        AnsiStr := Format(Lilla) + 'õ÷³' + Format(Stora) + Format(AE) + 'Í' + Format(UE) + 'ÚÛÞÔÓþ';

        exit(ConvertStr(AnsiText, AnsiStr, AsciiStr));
    end;

    local procedure RemoveHashAndBrackets(String: Text): Text
    begin
        String := DelChr(String, '=', '#{}');
        exit(String);
    end;

    local procedure GetNextField(var String: Text) FieldValue: Text
    var
        CurrChar: Char;
        lo: Integer;
        hi: Integer;
    begin
        for lo := 1 to StrLen(String) do begin
            CurrChar := String[lo];
            if CurrChar <> ' ' then
                case CurrChar of
                    '"':
                        for hi := lo + 1 to StrLen(String) do
                            if String[hi] = '"' then begin
                                FieldValue := CopyStr(String, lo, hi - lo + 1);
                                String := DelChr(CopyStr(String, hi + 1), '<', ' ');
                                exit;
                            end;
                    '{':
                        for hi := lo + 1 to StrLen(String) do
                            if String[hi] = '}' then begin
                                FieldValue := CopyStr(String, lo, hi - lo + 1);
                                String := DelChr(CopyStr(String, hi + 1), '<', ' ');
                                exit;
                            end;
                    else
                        for hi := lo + 1 to StrLen(String) do begin
                            if String[hi] = ' ' then begin
                                FieldValue := CopyStr(String, lo, hi - lo);
                                String := DelChr(CopyStr(String, hi), '<', ' ');
                                exit;
                            end;
                            if String[hi] = '{' then begin
                                FieldValue := CopyStr(String, lo, hi - lo);
                                String := CopyStr(String, hi);
                                exit;
                            end;
                        end;
                end;
        end;

        FieldValue := DelChr(String, '<', ' ');
        String := ''
    end;

    local procedure CreateGenJnlLine(var TempImportBufferSie: Record "Import Buffer SIE" temporary; DocumentNo: Code[20]; PostingDate: Date; DescriptionValue: Text[100]; var NextLineNo: Integer)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if DocumentNo = '' then
            DocumentNo := NoSeriesMgt.GetNextNo(GenJournalBatch."No. Series", WorkDate(), false);
        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := GenJournalBatch."Journal Template Name";
        GenJournalLine."Journal Batch Name" := GenJournalBatch.Name;
        GenJournalLine."Line No." := NextLineNo;
        GenJournalLine.Insert();
        GenJournalLine.SetUpNewLine(GenJournalLine, GenJournalLine."Balance (LCY)", true);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"G/L Account");
        GenJournalLine."Posting Date" := PostingDate;
        GenJournalLine."Document Date" := PostingDate;
        GenJournalLine."VAT Reporting Date" := PostingDate;
        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine."Posting No. Series" := GenJournalBatch."Posting No. Series";
        GenJournalLine.Description := DescriptionValue;
        GenJournalLine.Validate("Account No.", TempImportBufferSie."Import Field 2");
        Evaluate(GenJournalLine.Amount, ConvertStr(TempImportBufferSie."Import Field 4", '.', DecimalSeparator));
        GenJournalLine.Validate(Amount);

        if StrLen(TempImportBufferSie."Import Field 3") > 2 then
            GetDimValue(GenJournalLine, TempImportBufferSie."Import Field 3");

        GenJournalLine.Modify();
        NextLineNo += 10000;
    end;

    local procedure GetDimValue(var GenJournalLine: Record "Gen. Journal Line"; DimensionString: Text[100])
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionValue: Record "Dimension Value";
        DimensionManagement: Codeunit DimensionManagement;
        Dim1: Code[20];
        Dim2: Code[20];
        SieNumber: Integer;
    begin
        while DimensionString <> '' do begin
            Dim1 := GetNextDimField(DimensionString);
            if Dim1 <> '' then
                Evaluate(SieNumber, Dim1)
            else
                exit;

            Dim2 := GetNextDimField(DimensionString);
            DimensionSie.SetRange(Selected, true);
            DimensionSie.SetRange("SIE Dimension", SieNumber);
            if DimensionSie.FindFirst() then
                case DimensionSie.ShortCutDimNo of
                    1:
                        GenJournalLine.Validate("Shortcut Dimension 1 Code", Dim2);
                    2:
                        GenJournalLine.Validate("Shortcut Dimension 2 Code", Dim2);
                    3:
                        GenJournalLine.ValidateShortcutDimCode(3, Dim2);
                    4:
                        GenJournalLine.ValidateShortcutDimCode(4, Dim2);
                    5:
                        GenJournalLine.ValidateShortcutDimCode(5, Dim2);
                    6:
                        GenJournalLine.ValidateShortcutDimCode(6, Dim2);
                    7:
                        GenJournalLine.ValidateShortcutDimCode(7, Dim2);
                    8:
                        GenJournalLine.ValidateShortcutDimCode(8, Dim2)
                    else begin
                        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, GenJournalLine."Dimension Set ID");
                        TempDimensionSetEntry.Init();
                        TempDimensionSetEntry."Dimension Code" := DimensionSie."Dimension Code";
                        TempDimensionSetEntry."Dimension Value Code" := Dim2;
                        DimensionValue.Get(DimensionSie."Dimension Code", Dim2);
                        TempDimensionSetEntry."Dimension Value ID" := DimensionValue."Dimension Value ID";
                        TempDimensionSetEntry.Insert();
                        GenJournalLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                    end;
                end;
        end;
    end;

    local procedure GetNextDimField(var String: Text[100]) FieldValue: Text[20]
    var
        lo: Integer;
        hi: Integer;
        CurrChar: Char;
    begin
        for lo := 1 to StrLen(String) do begin
            CurrChar := String[lo];
            if CurrChar <> ' ' then
                case CurrChar of
                    '"':
                        for hi := lo + 1 to StrLen(String) do
                            if String[hi] = '"' then begin
                                FieldValue := CopyStr(CopyStr(String, lo + 1, hi - lo - 1), 1, MaxStrLen(FieldValue));
                                String := DelChr(CopyStr(String, hi + 1), '<', ' ');
                                exit;
                            end;
                    else begin
                        for hi := lo to StrLen(String) do
                            if (String[hi] = ' ') or
                               (String[hi] = '"')
                            then begin
                                FieldValue := CopyStr(CopyStr(String, lo, hi - lo), 1, MaxStrLen(FieldValue));
                                String := DelChr(CopyStr(String, hi), '<', ' ');
                                exit;
                            end;
                        FieldValue := CopyStr(CopyStr(String, lo, hi - lo + 1), 1, MaxStrLen(FieldValue));
                        String := '';
                    end;
                end;
        end;
        FieldValue := '';
        String := '';
    end;

    local procedure OnActivateForm()
    begin
        ColumnDim := DimensionSie.GetDimSelectionText();
    end;

    local procedure ReplaceTabWithSpace(LineText: Text): Text
    var
        TabChar: Char;
    begin
        TabChar := 9;
        exit(ConvertStr(LineText, Format(TabChar), ' '));
    end;

    procedure InitializeRequest(var TempBlob: Codeunit "Temp Blob")
    var
        BlobInStream: InStream;
        BlobOutStream: OutStream;
    begin
        TempBlob.CreateInStream(BlobInStream);
        TempBlobGlobal.CreateOutStream(BlobOutStream);
        CopyStream(BlobOutStream, BlobInStream);
    end;
}

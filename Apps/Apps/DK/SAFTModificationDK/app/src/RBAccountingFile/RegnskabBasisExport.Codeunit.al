// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.Enums;
using System.Reflection;
using System.Telemetry;
using System.Utilities;

codeunit 13698 "Regnskab Basis Export"
{
    trigger OnRun()
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        if GenerateFileToBlob(TempBlob) then
            WriteBlobToFileAndDownload(TempBlob)
        else
            Message(NoEntriesFoundTxt);
    end;

    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        AmountCalculationMethod: array[2] of Enum "Analysis Amount Type";
        StartingDate: Date;
        EndingDate: Date;
        Initialized: Boolean;
        CSVSeparator: Char;
        DownloadLbl: Label 'Download';
        FileNameTxt: Label 'Regnskab Basies Export for %1 to %2.csv', Comment = '%1, %2 - starting and ending dates';
        ProcessWindowTxt: Label 'Processing lines:\#1 of #2', Comment = '#1 - current line, #2 - total lines';
        NoEntriesFoundTxt: Label 'No G/L balance changes were found for the selected date range and mapping.';
        NotInitializedErr: Label 'Initialize codeunit with Initialize() before calling its methods.';
        Header1Txt: Label 'KONTONUMMER', Locked = true;
        Header2Txt: Label 'KONTONAVN', Locked = true;
        Header3Txt: Label 'VAERDI', Locked = true;


    /// <summary>
    /// Initializes the codeunit with the starting and ending dates, the G/L Account Mapping Header and the CSV separator.
    /// </summary>
    /// <param name="NewStartingDate"></param>
    /// <param name="NewEndingDate"></param>
    /// <param name="NewGLAccountMappingHeader"></param>
    /// <param name="NewCSVSeparator"></param>
    procedure Initialize(NewStartingDate: Date; NewEndingDate: Date; NewGLAccountMappingHeader: Record "G/L Account Mapping Header"; NewCSVSeparator: Char; AmtCalcMethodIncomeStatement: Enum "Analysis Amount Type"; AmtCalcMethodBalanceSheet: Enum "Analysis Amount Type")
    begin
        StartingDate := NewStartingDate;
        EndingDate := NewEndingDate;
        GLAccountMappingHeader := NewGLAccountMappingHeader;
        CSVSeparator := NewCSVSeparator;
        AmountCalculationMethod[1] := AmtCalcMethodIncomeStatement;
        AmountCalculationMethod[2] := AmtCalcMethodBalanceSheet;
        Initialized := true;
    end;

    /// <summary>
    /// Simpler initialization method that uses the default CSV separator, default dates and default amount calculation methods.
    /// </summary>
    /// <param name="NewGLAccountMappingHeader"></param>
    procedure InitializeDefault(NewGLAccountMappingHeader: Record "G/L Account Mapping Header")
    begin
        StartingDate := NewGLAccountMappingHeader."Starting Date";
        EndingDate := NewGLAccountMappingHeader."Ending Date";
        GLAccountMappingHeader := NewGLAccountMappingHeader;
        CSVSeparator := ';';
        AmountCalculationMethod[1] := AmountCalculationMethod[1] ::"Net Change";
        AmountCalculationMethod[2] := AmountCalculationMethod[2] ::"Balance at Date";
        Initialized := true;
    end;

    /// <summary>
    /// Generates the Regnskab Basis Accounting file to a blob.
    /// </summary>
    /// <param name="TempBlob"></param>
    /// <returns>True if the file was written to Blob; False if there were errors or file is empty.</returns>
    procedure GenerateFileToBlob(var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        TotalAmounts: Dictionary of [Code[20], Decimal];
    begin
        if not Initialized then
            Error(NotInitializedErr);

        GenerateTotalAmounts(TotalAmounts);
        if TotalAmounts.Count() > 0 then begin
            WriteAccountingFileToBlob(TotalAmounts, TempBlob);
            exit(true);
        end;
    end;

    local procedure GenerateTotalAmounts(var TotalAmounts: Dictionary of [Code[20], Decimal])
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        GLAccount: Record "G/L Account";
        AuditMappingHelper: Codeunit "Audit Mapping Helper";
        StandardGLAccountNo: Code[20];
        ProgressWindow: Dialog;
        GLAccountAmount: Decimal;
        Counter: Integer;
        Total: Integer;
    begin
        AuditMappingHelper.VerifyMappingIsDone(GLAccountMappingHeader.Code);
        GLAccountMappingLine.SetRange("G/L Account Mapping Code", GLAccountMappingHeader.Code);
        Counter := 0;
        Total := GLAccountMappingLine.Count();
        if GuiAllowed() then
            ProgressWindow.Open(ProcessWindowTxt, Total, Counter);
        if GLAccountMappingLine.FindSet() then
            repeat
                Counter := Counter + 1;
                if GuiAllowed() then
                    ProgressWindow.Update();
                StandardGLAccountNo := GLAccountMappingLine."Standard Account No.";
                GLAccount.Get(GLAccountMappingLine."G/L Account No.");
                GLAccountAmount := GetAmountForDateRange(GLAccount, StartingDate, EndingDate);
                if GLAccountAmount <> 0 then
                    if TotalAmounts.ContainsKey(StandardGLAccountNo) then
                        TotalAmounts.Set(StandardGLAccountNo, TotalAmounts.Get(StandardGLAccountNo) + GLAccountAmount)
                    else
                        TotalAmounts.Add(StandardGLAccountNo, GLAccountAmount);
            until GLAccountMappingLine.Next() = 0;
        if GuiAllowed() then
            ProgressWindow.Close();
    end;

    local procedure GetAmountForDateRange(var GLAccount: Record "G/L Account"; FromDate: Date; ToDate: Date) Result: Decimal
    var
        CalcMethod: Enum "Analysis Amount Type";
    begin
        GLAccount.SetRange("Date Filter", FromDate, ToDate);
        if GLAccount."Income/Balance" = GLAccount."Income/Balance"::"Income Statement" then
            CalcMethod := AmountCalculationMethod[1]
        else
            CalcMethod := AmountCalculationMethod[2];
        case CalcMethod of
            CalcMethod::"Net Change":
                begin
                    GLAccount.CalcFields("Net Change");
                    exit(GLAccount."Net Change");
                end;
            CalcMethod::"Balance at Date":
                begin
                    GLAccount.CalcFields("Balance at Date");
                    exit(GLAccount."Balance at Date");
                end;
            else
                OnGetAmountForDateRangeOnCaseElse(GLAccount, FromDate, ToDate, CalcMethod, Result);
        end;
    end;

    local procedure WriteAccountingFileToBlob(TotalAmounts: Dictionary of [Code[20], Decimal]; var TempBlob: Codeunit "Temp Blob")
    var
        CSVOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(CSVOutStream, TextEncoding::UTF8);
        WriteHeaderToStream(CSVOutStream);
        WriteTotalAmountsToStream(CSVOutStream, TotalAmounts);
    end;

    local procedure WriteBlobToFileAndDownload(var TempBlob: Codeunit "Temp Blob")
    var
        CSVInStream: InStream;
        FileName: Text;
    begin
        TempBlob.CreateInStream(CSVInStream, TextEncoding::UTF8);
        FileName := GenerateFileName();
        DownloadFromStream(CSVInStream, DownloadLbl, '', '*.csv', FileName);
        FeatureTelemetry.LogUsage('0000KTA', 'Regnskab Basis Export', 'Generated file successfully.');
    end;

    local procedure WriteHeaderToStream(var CSVOutStream: OutStream)
    var
        ElementsList: List of [Text];
    begin
        ElementsList.Add(Header1Txt);
        ElementsList.Add(Header2Txt);
        ElementsList.Add(Header3Txt);
        WriteListAsLineToStream(CSVOutStream, ElementsList);
    end;

    local procedure WriteTotalAmountsToStream(var CSVOutStream: OutStream; TotalAmounts: Dictionary of [Code[20], Decimal])
    var
        ElementsList: List of [Text];
        GLAccountCode: Code[20];
    begin
        foreach GLAccountCode in TotalAmounts.Keys do begin
            Clear(ElementsList);
            ElementsList.Add(Format(GLAccountCode));
            ElementsList.Add(GetDescriptionOfStandardGLAccount(GLAccountCode));
            ElementsList.Add(Format(Round(TotalAmounts.Get(GLAccountCode), 1), 0, 9));
            WriteListAsLineToStream(CSVOutStream, ElementsList);
        end;
    end;

    local procedure WriteListAsLineToStream(var CSVOutStream: OutStream; ListOfText: List of [Text])
    var
        Line: TextBuilder;
    begin
        ComposeLine(Line, ListOfText);
        CSVOutStream.WriteText(Line.ToText());
    end;

    local procedure ComposeLine(var Line: TextBuilder; ListOfText: List of [Text])
    var
        TypeHelper: Codeunit "Type Helper";
        Element: Text;
    begin
        foreach Element in ListOfText do begin
            Line.Append(CSVSeparator);
            Line.Append(Element);
        end;
        Line.Remove(1, 1);
        Line.Append(TypeHelper.CRLFSeparator());
    end;

    local procedure GetDescriptionOfStandardGLAccount(GLAccountCode: Code[20]) Description: Text
    var
        StandardAccount: Record "Standard Account";
    begin
        StandardAccount.SetRange(Type, GLAccountMappingHeader."Standard Account Type");
        StandardAccount.SetRange("No.", GLAccountCode);
        StandardAccount.FindFirst();
        Description := StandardAccount.Description;
    end;

    local procedure GenerateFileName(): Text
    begin
        exit(StrSubstNo(FileNameTxt, Format(StartingDate), Format(EndingDate)));
    end;

    [IntegrationEvent(true, false)]
    local procedure OnGetAmountForDateRangeOnCaseElse(var GLAccount: Record "G/L Account"; FromDate: Date; ToDate: Date; CalcMethod: Enum "Analysis Amount Type"; var Result: Decimal)
    begin
    end;
}

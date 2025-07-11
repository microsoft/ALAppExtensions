// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.GeneralLedger.Ledger;
using System.Reflection;
using System.Utilities;

codeunit 5281 "Audit Data Handling SAF-T" implements "Audit File Export Data Handling"
{
    Access = Public;

    var
        MasterDataTxt: label 'Master Data';
        GLEntriesTxt: label 'General Ledger Entries from %1 to %2', Comment = '%1, %2 - starting and ending date';
        SourceDocumentsTxt: label 'Source Documents';

    procedure LoadStandardAccounts(StandardAccountType: Enum "Standard Account Type") Result: Boolean
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        CreateStandardDataSAFT: Interface CreateStandardDataSAFT;
    begin
        if not AuditFileExportSetup.Get() then
            exit(false);
        CreateStandardDataSAFT := AuditFileExportSetup."SAF-T Modification";
        exit(CreateStandardDataSAFT.LoadStandardAccounts(StandardAccountType));
    end;

    internal procedure CreateAuditFileExportLines(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportLine: Record "Audit File Export Line";
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
        LineNo: Integer;
    begin
        AuditFileExportLine.SetRange(ID, AuditFileExportHeader.ID);
        AuditFileExportLine.DeleteAll(true);

        // Master data
        if IsDataClassEnabled(Enum::"Audit File Export Data Class"::MasterData) then
            AuditFileExportMgt.InsertAuditFileExportLine(
                AuditFileExportLine, LineNo, AuditFileExportHeader.ID, Enum::"Audit File Export Data Class"::MasterData,
                MasterDataTxt, AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");

        // General ledger entries
        if IsDataClassEnabled(Enum::"Audit File Export Data Class"::GeneralLedgerEntries) then
            InsertExportLineForGLEntries(AuditFileExportHeader, LineNo);

        // Source documents
        if IsDataClassEnabled(Enum::"Audit File Export Data Class"::SourceDocuments) then
            AuditFileExportMgt.InsertAuditFileExportLine(
                AuditFileExportLine, LineNo, AuditFileExportHeader.ID, Enum::"Audit File Export Data Class"::SourceDocuments,
                SourceDocumentsTxt, AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
    end;

    internal procedure GenerateFileContentForAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line"; var TempBlob: Codeunit "Temp Blob")
    var
        GenerateXMLFileSAFT: Codeunit "Generate File SAF-T";
    begin
        GenerateXMLFileSAFT.GenerateFileContent(AuditFileExportLine, TempBlob);
    end;

    internal procedure GetFileNameForAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line") FileName: Text[1024]
    var
        AuditExportLineCopy: Record "Audit File Export Line";
        SAFTDataMgt: Codeunit "SAF-T Data Mgt.";
        TypeHelper: Codeunit "Type Helper";
        TotalNumberOfFiles: Integer;
        CreatedDateTime: DateTime;
    begin
        AuditExportLineCopy.SetRange(ID, AuditFileExportLine.ID);
        TotalNumberOfFiles := AuditExportLineCopy.Count();

        CreatedDateTime := TypeHelper.GetCurrentDateTimeInUserTimeZone();
        FileName := SAFTDataMgt.GetXmlFileName(CreatedDateTime, AuditFileExportLine."Line No.", TotalNumberOfFiles);
    end;

    internal procedure InitAuditExportDataTypeSetup()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        LoadStandardDataSAFT: Interface CreateStandardDataSAFT;
    begin
        if not AuditFileExportSetup.Get() then
            exit;
        LoadStandardDataSAFT := AuditFileExportSetup."SAF-T Modification";
        LoadStandardDataSAFT.InitAuditExportDataTypeSetup();
    end;

    local procedure InsertExportLineForGLEntries(var AuditFileExportHeader: Record "Audit File Export Header"; var LineNo: Integer)
    var
        AuditFileExportLine: Record "Audit File Export Line";
        GLEntry: Record "G/L Entry";
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
        ShiftDateFormula: DateFormula;
        StartingDate: Date;
        EndingDate: Date;
        StopExportEntriesByPeriod: Boolean;
    begin
        if (not AuditFileExportHeader."Split By Month") and (not AuditFileExportHeader."Split By Date") then begin
            AuditFileExportMgt.InsertAuditFileExportLine(
                AuditFileExportLine, LineNo, AuditFileExportHeader.ID, Enum::"Audit File Export Data Class"::GeneralLedgerEntries,
                StrSubstNo(GLEntriesTxt, AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date"),
                AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
            exit;
        end;

        StartingDate := AuditFileExportHeader."Starting Date";
        if AuditFileExportHeader."Split By Month" then
            Evaluate(ShiftDateFormula, '<CM>')
        else
            Evaluate(ShiftDateFormula, '<0D>');
        EndingDate := CalcDate(ShiftDateFormula, AuditFileExportHeader."Starting Date");
        repeat
            StopExportEntriesByPeriod := EndingDate >= AuditFileExportHeader."Ending Date";
            if CalcDate(ShiftDateFormula, EndingDate) >= AuditFileExportHeader."Ending Date" then
                EndingDate := ClosingDate(EndingDate);

            GLEntry.SetRange("Posting Date", StartingDate, EndingDate);
            if not GLEntry.IsEmpty() then
                AuditFileExportMgt.InsertAuditFileExportLine(
                    AuditFileExportLine, LineNo, AuditFileExportHeader.ID, Enum::"Audit File Export Data Class"::GeneralLedgerEntries,
                    StrSubstNo(GLEntriesTxt, StartingDate, EndingDate), StartingDate, EndingDate);
            StartingDate := NormalDate(EndingDate) + 1;
            EndingDate := CalcDate(ShiftDateFormula, StartingDate);
        until StopExportEntriesByPeriod;
    end;

    local procedure IsDataClassEnabled(AuditFileExportDataClass: enum "Audit File Export Data Class"): Boolean
    var
        AuditExportDataTypeSetup: Record "Audit Export Data Type Setup";
    begin
        AuditExportDataTypeSetup.SetRange("Export Enabled", true);
        AuditExportDataTypeSetup.SetRange("Export Data Class", AuditFileExportDataClass);
        exit(not AuditExportDataTypeSetup.IsEmpty());
    end;

    local procedure CalculateGLEntryTotals(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        GLEntry: Record "G/L Entry";
        GLEntryByTransSAFT: Query "G/L Entry By Trans. SAF-T";
    begin
        GLEntry.SetCurrentKey("Transaction No.");
        GLEntry.SetRange("Posting Date", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        GLEntry.CalcSums("Debit Amount", "Credit Amount");
        AuditFileExportHeader."Total G/L Entry Debit" := GLEntry."Debit Amount";
        AuditFileExportHeader."Total G/L Entry Credit" := GLEntry."Credit Amount";
        AuditFileExportHeader."Number of G/L Entries" := 0;

        GLEntryByTransSAFT.SetRange(Posting_Date, AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        if GLEntryByTransSAFT.Open() then begin
            while GLEntryByTransSAFT.Read() do
                AuditFileExportHeader."Number of G/L Entries" += 1;
            GLEntryByTransSAFT.Close();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Audit File Export Mgt.", 'OnBeforeModifyAuditFileExportHeaderToStartExport', '', false, false)]
    local procedure OnBeforeModifyAuditFileExportHeaderToStartExport(var AuditFileExportHeader: Record "Audit File Export Header")
    begin
        CalculateGLEntryTotals(AuditFileExportHeader);
    end;
}

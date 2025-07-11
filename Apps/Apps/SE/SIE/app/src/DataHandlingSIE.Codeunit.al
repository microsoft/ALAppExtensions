// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.IO;
using System.Utilities;

codeunit 5315 "Data Handling SIE" implements "Audit File Export Data Handling"
{
    var
        MasterDataTxt: label 'Master Data';
        CustomDataTxt: label 'Master Data and G/L Entries';

    procedure LoadStandardAccounts(StandardAccountType: Enum "Standard Account Type") Result: Boolean;
    var
        TempCSVBuffer: Record "CSV Buffer" temporary;
        SIEManagement: Codeunit "SIE Management";
        ImportAuditDataMgt: Codeunit "Import Audit Data Mgt.";
        CSVDocContent: Text;
        CSVFieldSeparator: Text[1];
    begin
        CSVFieldSeparator := ';';
        CSVDocContent := SIEManagement.GetStandardAccountsCSVDocSIE(StandardAccountType);
        if CSVDocContent = '' then
            exit(false);
        ImportAuditDataMgt.LoadStandardAccountsFromCSVTextToCSVBuffer(TempCSVBuffer, CSVDocContent, CSVFieldSeparator);

        if TempCSVBuffer.IsEmpty() then
            exit(false);
        ImportAuditDataMgt.ImportStandardAccountsFromCSVBuffer(TempCSVBuffer, StandardAccountType);

        exit(true);
    end;

    procedure CreateAuditFileExportLines(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportLine: Record "Audit File Export Line";
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
        LineNo: Integer;
        LineDescription: Text;
    begin
        AuditFileExportLine.SetRange(ID, AuditFileExportHeader.ID);
        AuditFileExportLine.DeleteAll(true);

        if AuditFileExportHeader."File Type" = "File Type SIE"::"4. Transactions" then
            LineDescription := CustomDataTxt
        else
            LineDescription := MasterDataTxt;

        // all data in one line
        AuditFileExportMgt.InsertAuditFileExportLine(
            AuditFileExportLine, LineNo, AuditFileExportHeader.ID, Enum::"Audit File Export Data Class"::Custom,
            LineDescription, AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
    end;

    procedure GenerateFileContentForAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line"; var TempBlob: codeunit "Temp Blob")
    var
        GenerateFileSIE: Codeunit "Generate File SIE";
    begin
        GenerateFileSIE.GenerateFileContent(AuditFileExportLine, TempBlob);
    end;

    procedure GetFileNameForAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line") FileName: Text[1024]
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        SIEManagement: Codeunit "SIE Management";
    begin
        // For SIE file name is taken from header, while file name for header is taken from Format Setup
        if AuditFileExportHeader.Get(AuditFileExportLine.ID) then
            if AuditFileExportHeader."Audit File Name" <> '' then
                exit(AuditFileExportHeader."Audit File Name");

        exit(SIEManagement.GetAuditFileName());
    end;

    procedure InitAuditExportDataTypeSetup()
    begin
    end;
}

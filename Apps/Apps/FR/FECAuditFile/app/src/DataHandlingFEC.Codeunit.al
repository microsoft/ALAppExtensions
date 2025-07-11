// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Foundation.Company;
using System.Utilities;

codeunit 10827 "Data Handling FEC" implements "Audit File Export Data Handling"
{
    Access = Internal;

    var
        CustomDataTxt: label 'Master Data and G/L Entries';
        InvalidWindowsChrStringTxt: label '""#%&*:<>?\/{|}~', Locked = true;
        FileNameTemplateTxt: label '%1FEC%2.txt', Locked = true, Comment = '%1 - Company Registration No., %2 - period ending date';

    procedure LoadStandardAccounts(StandardAccountType: Enum "Standard Account Type") Result: Boolean;
    begin
    end;

    procedure CreateAuditFileExportLines(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportLine: Record "Audit File Export Line";
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
        LineNo: Integer;
    begin
        AuditFileExportLine.SetRange(ID, AuditFileExportHeader.ID);
        AuditFileExportLine.DeleteAll(true);

        // all data in one line
        AuditFileExportMgt.InsertAuditFileExportLine(
            AuditFileExportLine, LineNo, AuditFileExportHeader.ID, "Audit File Export Data Class"::Custom,
            CustomDataTxt, AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
    end;

    procedure GenerateFileContentForAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line"; var TempBlob: codeunit "Temp Blob")
    var
        GenerateFileTaxAuditFEC: Codeunit "Generate File FEC";
    begin
        GenerateFileTaxAuditFEC.GenerateFileContent(AuditFileExportLine, TempBlob);
    end;

    procedure GetFileNameForAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line") FileName: Text[1024]
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        CompanyInformation: Record "Company Information";
    begin
        if not AuditFileExportHeader.Get(AuditFileExportLine.ID) then
            exit('');

        CompanyInformation.Get();
        CompanyInformation.TestField("Registration No.");
        FileName :=
            StrSubstNo(FileNameTemplateTxt, Format(CompanyInformation.GetSIREN()), GetFormattedDate(AuditFileExportHeader."Ending Date"));
        FileName := DelChr(FileName, '=', InvalidWindowsChrStringTxt);
    end;

    procedure InitAuditExportDataTypeSetup()
    begin
    end;

    procedure GetFormattedDate(DateValue: Date): Text[8]
    begin
        if DateValue = 0D then
            exit('');
        exit(Format(DateValue, 8, '<Year4><Month,2><Day,2>'));
    end;
}

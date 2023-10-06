// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Utilities;

codeunit 5266 "Audit File Data Handling" implements "Audit File Export Data Handling"
{
    Access = Internal;

    procedure LoadStandardAccounts(StandardAccountType: enum "Standard Account Type") Result: Boolean
    begin
    end;

    procedure CreateAuditFileExportLines(var AuditFileExportHeader: Record "Audit File Export Header")
    begin
    end;

    procedure GenerateFileContentForAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line"; var TempBlob: Codeunit "Temp Blob")
    begin
    end;

    procedure GetFileNameForAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line") FileName: Text[1024]
    begin
    end;

    procedure InitAuditExportDataTypeSetup()
    begin
    end;
}

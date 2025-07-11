// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Utilities;

codeunit 5265 "Audit Line Export Runner"
{
    TableNo = "Audit File Export Line";

    var
        NoFileContentErr: label 'No file content was generated for the audit file export line.';
        NoFileNameErr: label 'No file name was specified for the audit file export line.';

    trigger OnRun()
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text[1024];
        IAuditFileExportDataHandling: Interface "Audit File Export Data Handling";
        FileContentInStream: InStream;
    begin
        Rec.LockTable();
        Rec.Validate("Server Instance ID", ServiceInstanceId());
        Rec.Validate("Session ID", SessionId());
        Rec.Validate("Created Date/Time", 0DT);
        Rec.Validate("No. Of Attempts", 3);
        Rec.Modify();
        Commit();

        AuditFileExportHeader.Get(Rec.ID);
        IAuditFileExportDataHandling := AuditFileExportHeader."Audit File Export Format";
        IAuditFileExportDataHandling.GenerateFileContentForAuditFileExportLine(Rec, TempBlob);
        if not TempBlob.HasValue() then
            Error(NoFileContentErr);

        FileName := IAuditFileExportDataHandling.GetFileNameForAuditFileExportLine(Rec);
        if FileName = '' then
            Error(NoFileNameErr);

        TempBlob.CreateInStream(FileContentInStream);
        AuditFileExportMgt.CompleteAuditFileExportLine(Rec, FileContentInStream, FileName);
    end;

}

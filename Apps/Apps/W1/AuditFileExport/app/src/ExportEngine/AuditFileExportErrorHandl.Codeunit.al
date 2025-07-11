// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

codeunit 5263 "Audit File Export Error Handl."
{
    TableNo = "Audit File Export Line";
    trigger OnRun()
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
    begin
        AuditFileExportMgt.LogError(Rec);
        Rec.LockTable();
        Rec.Status := Rec.Status::Failed;
        Rec.Progress := 100;
        if Rec."No. Of Attempts" > 0 then
            Rec."No. Of Attempts" -= 1;
        Rec.Modify(true);
        AuditFileExportHeader.Get(Rec.ID);
        AuditFileExportMgt.UpdateExportStatus(AuditFileExportHeader);
        AuditFileExportMgt.SendTraceTagOfExport(AuditFileExportTxt, GetCancelTraceTagMessage(Rec));
        AuditFileExportMgt.StartExportLinesNotStartedYet(AuditFileExportHeader);
    end;

    var
        FailedExportTxt: label 'Failed to export data for the line with ID: %1, Task ID: %2', Comment = '%1 - integer; %2 - GUID';
        AuditFileExportTxt: label 'Audit file export';

    local procedure GetCancelTraceTagMessage(AuditFileExportLine: Record "Audit File Export Line"): Text
    begin
        exit(StrSubstNo(FailedExportTxt, AuditFileExportLine.ID, AuditFileExportLine."Task ID"));
    end;
}

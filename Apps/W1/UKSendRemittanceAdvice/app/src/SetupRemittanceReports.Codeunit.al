// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4031 SetupRemittanceReports
{
    Subtype = Install;
    trigger OnInstallAppPerCompany()
    var
    begin
        SetupReportSelections();
    end;

    local procedure SetupReportSelections()
    var
        ReportSelections: Record "Report Selections";
    begin
        InsertReportSelections(ReportSelections.Usage::"V.Remittance", '1', Report::"Remittance Advice - Journal");
        InsertReportSelections(ReportSelections.Usage::"P.V.Remit.", '1', Report::"Remittance Advice - Entries");
    end;

    local procedure InsertReportSelections(ReportUsage: Enum "Report Selection Usage"; ReportSequence: Code[10]; ReportId: Integer)
    var
        ReportSelections: Record "Report Selections";
    begin
        if not ReportSelections.Get(ReportUsage, ReportSequence) then begin
            ReportSelections.Init();
            ReportSelections.Usage := ReportUsage;
            ReportSelections.Sequence := ReportSequence;
            ReportSelections."Report ID" := ReportId;
            ReportSelections."Use for Email Attachment" := true;
            ReportSelections."Use for Email Body" := false;
            if ReportSelections.Insert() then;
        end;
    end;
}
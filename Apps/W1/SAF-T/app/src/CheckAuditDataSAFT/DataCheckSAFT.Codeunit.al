codeunit 5287 "Data Check SAF-T" implements DataCheckSAFT
{
    procedure CheckDataToExport(var AuditFileExportHeader: Record "Audit File Export Header") DataCheckStatus: enum "Audit Data Check status"
    begin
        DataCheckStatus := "Audit Data Check Status"::" ";
    end;

    procedure CheckAuditDocReadyToExport(var AuditFileExportHeader: Record "Audit File Export Header") DataCheckStatus: enum "Audit Data Check Status"
    begin
        DataCheckStatus := "Audit Data Check Status"::" ";
    end;
}
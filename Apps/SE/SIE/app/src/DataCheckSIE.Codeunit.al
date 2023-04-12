codeunit 5317 "Data Check SIE" implements "Audit File Export Data Check"
{
    procedure CheckDataToExport(var AuditFileExportHeader: Record "Audit File Export Header"): enum "Audit Data Check Status"
    begin
    end;

    procedure CheckAuditDocReadyToExport(var AuditFileExportHeader: Record "Audit File Export Header"): enum "Audit Data Check Status"
    begin
        AuditFileExportHeader.TestField("File Type");
        exit("Audit Data Check Status"::Passed);
    end;
}
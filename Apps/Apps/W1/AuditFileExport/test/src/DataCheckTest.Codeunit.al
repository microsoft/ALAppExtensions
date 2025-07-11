codeunit 148038 "Data Check Test" implements "Audit File Export Data Check"
{
    procedure CheckDataToExport(var AuditFileExportHeader: Record "Audit File Export Header"): enum "Audit Data Check Status"
    var
        Contact: Record Contact;
    begin
        Contact.Get(AuditFileExportHeader.Contact);
        Contact.TestField(Address);
    end;

    procedure CheckAuditDocReadyToExport(var AuditFileExportHeader: Record "Audit File Export Header"): enum "Audit Data Check Status"
    begin
        AuditFileExportHeader.TestField("Header Comment");
    end;
}
codeunit 10829 "Install FEC"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        AuditFileExportFormatSetup: Record "Audit File Export Format Setup";
        AuditFileExportFormat: Enum "Audit File Export Format";
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if (AppInfo.DataVersion() <> Version.Create('0.0.0.0')) then
            exit;

        AuditFileExportSetup.InitSetup(AuditFileExportFormat::FEC);
        AuditFileExportFormatSetup.InitSetup(AuditFileExportFormat::FEC, '', false);
    end;
}
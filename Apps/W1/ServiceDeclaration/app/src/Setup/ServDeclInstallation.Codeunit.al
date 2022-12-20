codeunit 5015 "Serv. Decl. Installation"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        ServDeclMgt: Codeunit "Service Declaration Mgt.";
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if (AppInfo.DataVersion() <> Version.Create('0.0.0.0')) then
            exit;

        ServDeclMgt.InstallServDecl();
    end;


}
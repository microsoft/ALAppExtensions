codeunit 10017 "IRS 1096 Installation"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if (AppInfo.DataVersion() <> Version.Create('0.0.0.0')) then
            exit;

        IRS1096FormMgt.InstallFeature();
    end;


}
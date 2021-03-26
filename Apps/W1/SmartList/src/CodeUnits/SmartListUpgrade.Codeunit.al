codeunit 2481 "SmartList Upgrade"
{
    Subtype = Upgrade;

    var

    trigger OnUpgradePerDatabase();
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        // Any logic needed here?
    end;

    trigger OnUpgradePerCompany();
    var
        //SmartListInstall: Codeunit "SmartList Install";
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        // Any logic needed here?

        //SmartListInstall.CreateDefaultSmartListRecords();
    end;
}
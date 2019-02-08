codeunit 9093 "Postcode GetAddress.io Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase();
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        // Restoring data from V1 extension tables. This upgrade will only run for version 1
        if AppInfo.DataVersion().Major() = 1 then
            NAVAPP.LOADPACKAGEDATA(DATABASE::"Postcode GetAddress.io Config");
    end;

    trigger OnUpgradePerCompany();
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        // Restoring data from V1 extension tables. This upgrade will only run for version 1
        if AppInfo.DataVersion().Major() = 1 then
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Postcode GetAddress.io Config");
    end;

}


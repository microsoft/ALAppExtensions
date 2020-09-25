codeunit 1361 "MS - WorldPay Standard Upgrade"
{
    Subtype = Upgrade;


    trigger OnUpgradePerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        // Restoring data from V1 extension tables. This upgrade will only run for version 1
        if AppInfo.DataVersion().Major() = 1 then begin
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"MS - WorldPay Std. Template");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"MS - WorldPay Standard Account");
            NavApp.RESTOREARCHIVEDATA(Database::"MS - WorldPay Transaction");
        end;
    end;

}


codeunit 1071 "MS - PayPal Standard Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany();
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        // Only run when going from V1 to V2 extension.  This code could be removed after PROD has V2 extension.
        if AppInfo.DataVersion().Major() = 1 then begin
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"MS - PayPal Standard Template");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"MS - PayPal Standard Account");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"MS - PayPal Transaction");
        end;
    end;
}


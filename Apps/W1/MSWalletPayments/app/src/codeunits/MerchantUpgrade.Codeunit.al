#if not CLEAN20
codeunit 1081 "MS - Wallet Merchant Upgrade"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';
    Subtype = Upgrade;

    trigger OnUpgradePerCompany();
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        // Only run when going from V1 to V2 extension.  This code could be removed after PROD has V2 extension.
        if AppInfo.DataVersion().Major() = 1 then begin
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"MS - Wallet Merchant Template");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"MS - Wallet Merchant Account");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"MS - Wallet Payment");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"MS - Wallet Charge");
        end;
    end;
}
#endif

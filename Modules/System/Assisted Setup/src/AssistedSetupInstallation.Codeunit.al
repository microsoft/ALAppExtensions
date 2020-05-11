codeunit 1809 "Assisted Setup Installation"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        EnvironmentInfo: Codeunit "Environment Information";
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if EnvironmentInfo.VersionInstalled(AppInfo.Id()) = 0 then
            SetAllUpgradeTags();
    end;

    local procedure SetAllUpgradeTags()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        AssistedSetupUpgradeTag: Codeunit "Assisted Setup Upgrade Tag";
    begin
        UpgradeTag.SetUpgradeTag(AssistedSetupUpgradeTag.GetDeleteAssistedSetupTag());
    end;
}
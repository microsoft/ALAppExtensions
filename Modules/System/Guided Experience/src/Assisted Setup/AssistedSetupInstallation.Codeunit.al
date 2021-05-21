// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AA0235
codeunit 1809 "Assisted Setup Installation"
#pragma warning restore AA0235
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
        if not UpgradeTag.HasUpgradeTag(AssistedSetupUpgradeTag.GetDeleteAssistedSetupTag()) then
            UpgradeTag.SetUpgradeTag(AssistedSetupUpgradeTag.GetDeleteAssistedSetupTag());
    end;
}

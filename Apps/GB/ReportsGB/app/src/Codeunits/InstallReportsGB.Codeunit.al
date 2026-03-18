#if CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using System.Upgrade;

codeunit 10593 "Install Reports GB"
{
    Access = Internal;
    Subtype = Install;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagReportsGB: Codeunit "Upg. Tag Reports GB";

    trigger OnInstallAppPerCompany()
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        if CurrentModuleInfo.AppVersion().Major() < 30 then
            exit;

        InstallReportsGB();
    end;

    local procedure InstallReportsGB()
    var
        ReportsGBHelperProcedures: Codeunit "Reports GB Helper Procedures";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagReportsGB.GetReportsGBUpgradeTag()) then
            exit;
        ReportsGBHelperProcedures.SetDefaultReportLayouts();
        UpgradeTag.SetUpgradeTag(UpgTagReportsGB.GetReportsGBUpgradeTag());
    end;
}
#endif
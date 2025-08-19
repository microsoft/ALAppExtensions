#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using System.Upgrade;

codeunit 10582 "Upgrade Reports GB"
{
    ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagReportsGB: Codeunit "Upg. Tag Reports GB";

    trigger OnUpgradePerCompany()
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        if CurrentModuleInfo.AppVersion().Major() < 30 then
            exit;

        UpgradeReportsGB();
    end;

    local procedure UpgradeReportsGB()
    var
        FeatureReportsGB: Codeunit "Feature - Reports GB";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagReportsGB.GetReportsGBUpgradeTag()) then
            exit;
        FeatureReportsGB.SetDefaultReportLayouts();
        UpgradeTag.SetUpgradeTag(UpgTagReportsGB.GetReportsGBUpgradeTag());
    end;
}
#endif
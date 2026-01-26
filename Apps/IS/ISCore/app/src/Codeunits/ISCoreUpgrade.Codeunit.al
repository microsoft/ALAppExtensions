// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using System.Upgrade;

codeunit 14602 "IS Core Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
    begin
        TransferISCpecificData();
        UpdateDocumentRetentionPeriod();
    end;

    local procedure TransferISCpecificData()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        EnableISCoreApp: Codeunit "Enable IS Core App";
    begin
        if UpgradeTag.HasUpgradeTag(EnableISCoreApp.GetISCoreAppUpdateTag()) then
            exit;
            
        EnableISCoreApp.TransferData();

        UpgradeTag.SetUpgradeTag(EnableISCoreApp.GetISCoreAppUpdateTag());
    end;

    local procedure UpdateDocumentRetentionPeriod()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        ISCoreInstall: Codeunit "IS Core Install";
        EnableISCoreApp: Codeunit "Enable IS Core App";
    begin
        if UpgradeTag.HasUpgradeTag(EnableISCoreApp.GetISDocRetentionPeriodTag()) then
            exit;
        ISCoreInstall.UpdateGeneralLedgserSetup();
        UpgradeTag.SetUpgradeTag(EnableISCoreApp.GetISDocRetentionPeriodTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    var
        EnableISCoreApp: Codeunit "Enable IS Core App";
    begin
        PerCompanyUpgradeTags.Add(EnableISCoreApp.GetISCoreAppUpdateTag());
        PerCompanyUpgradeTags.Add(EnableISCoreApp.GetISDocRetentionPeriodTag());
    end;
}
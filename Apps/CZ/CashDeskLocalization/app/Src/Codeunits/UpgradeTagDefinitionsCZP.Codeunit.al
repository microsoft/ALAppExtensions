// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using System.Upgrade;

codeunit 31106 "Upgrade Tag Definitions CZP"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetDataVersion173PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion174PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion180PerDatabaseUpgradeTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetDataVersion173PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion174PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion180PerCompanyUpgradeTag());
    end;

    procedure GetDataVersion173PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZP-UpgradeCashDeskLocalizationForCzech-PerDatabase-17.3');
    end;

    procedure GetDataVersion174PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZP-UpgradeCashDeskLocalizationForCzech-PerDatabase-17.4');
    end;

    procedure GetDataVersion180PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZP-UpgradeCashDeskLocalizationForCzech-PerDatabase-18.0');
    end;

    procedure GetDataVersion173PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZP-UpgradeCashDeskLocalizationForCzech-PerCompany-17.3');
    end;

    procedure GetDataVersion174PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZP-UpgradeCashDeskLocalizationForCzech-PerCompany-17.4');
    end;

    procedure GetDataVersion180PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZP-UpgradeCashDeskLocalizationForCzech-PerCompany-18.0');
    end;
}

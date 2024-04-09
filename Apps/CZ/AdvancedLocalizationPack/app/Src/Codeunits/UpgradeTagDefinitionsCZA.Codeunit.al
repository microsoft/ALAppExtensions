// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Upgrade;

codeunit 31261 "Upgrade Tag Definitions CZA"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetDataVersion180PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion182PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion183PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion200PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion210PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion220PerDatabaseUpgradeTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetDataVersion180PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion182PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion183PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion200PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion210PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion220PerCompanyUpgradeTag());
    end;

    procedure GetDataVersion180PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerDatabase-18.0');
    end;

    procedure GetDataVersion182PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerDatabase-18.2');
    end;

    procedure GetDataVersion183PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerDatabase-18.3');
    end;

    procedure GetDataVersion200PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerDatabase-20.0');
    end;

    procedure GetDataVersion210PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerDatabase-21.0');
    end;

    procedure GetDataVersion220PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerDatabase-22.0');
    end;

    procedure GetDataVersion180PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerCompany-18.0');
    end;

    procedure GetDataVersion182PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerCompany-18.2');
    end;

    procedure GetDataVersion183PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerCompany-18.3');
    end;

    procedure GetDataVersion200PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerCompany-20.0');
    end;

    procedure GetDataVersion210PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerCompany-21.0');
    end;

    procedure GetDataVersion220PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerCompany-22.0');
    end;
}

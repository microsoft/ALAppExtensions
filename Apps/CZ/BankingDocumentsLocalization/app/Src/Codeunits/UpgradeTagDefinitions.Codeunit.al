// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using System.Upgrade;

codeunit 31333 "Upgrade Tag Definitions CZB"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetDataVersion190PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion221PerDatabaseUpgradeTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetDataVersion190PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion221PerCompanyUpgradeTag());
    end;

    procedure GetDataVersion190PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZB-UpgradeBankingDocumentsLocalizationForCzech-PerDatabase-19.0');
    end;

    procedure GetDataVersion190PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZB-UpgradeBankingDocumentsLocalizationForCzech-PerCompany-19.0');
    end;

    procedure GetDataVersion221PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZB-UpgradeBankingDocumentsLocalizationForCzech-PerDatabase-22.1');
    end;

    procedure GetDataVersion221PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZB-UpgradeBankingDocumentsLocalizationForCzech-PerCompany-22.1');
    end;
}

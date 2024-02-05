// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using System.Upgrade;

codeunit 31089 "Upgrade Tag Definitions CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetDataVersion190PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion200PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion210PerDatabaseUpgradeTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetDataVersion190PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion200PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion210PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetSalesAdvLetterEntryCustomerNoUpgradeTag());
        PerCompanyUpgradeTags.Add(GetAdvanceLetterApplicationAmountLCYUpgradeTag());
        PerCompanyUpgradeTags.Add(GetPostVATDocForReverseChargeUpgradeTag());
    end;

    procedure GetDataVersion190PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZZ-UpgradeAdvancePaymentsLocalizationForCzech-PerDatabase-19.0');
    end;

    procedure GetDataVersion200PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZZ-UpgradeAdvancePaymentsLocalizationForCzech-PerDatabase-20.0');
    end;

    procedure GetDataVersion210PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZZ-UpgradeAdvancePaymentsLocalizationForCzech-PerDatabase-21.0');
    end;

    procedure GetDataVersion190PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZZ-UpgradeAdvancePaymentsLocalizationForCzech-PerCompany-19.0');
    end;

    procedure GetDataVersion200PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZZ-UpgradeAdvancePaymentsLocalizationForCzech-PerCompany-20.0');
    end;

    procedure GetDataVersion210PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZZ-UpgradeAdvancePaymentsLocalizationForCzech-PerCompany-21.0');
    end;

    procedure GetSalesAdvLetterEntryCustomerNoUpgradeTag(): Code[250]
    begin
        exit('CZZ-470101-SalesAdvLetterEntryCustomerNoUpgradeTag-20230420');
    end;

    procedure GetAdvanceLetterApplicationAmountLCYUpgradeTag(): Code[250]
    begin
        exit('CZZ-478403-AdvanceLetterApplicationAmountLCYUpgradeTag-20230717');
    end;

    procedure GetPostVATDocForReverseChargeUpgradeTag(): Code[250]
    begin
        exit('CZZ-494279-PostVATDocForReverseChargeUpgradeTag-20240111');
    end;
}

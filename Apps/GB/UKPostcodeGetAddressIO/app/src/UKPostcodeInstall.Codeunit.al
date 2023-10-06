﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using Microsoft.Foundation.Company;
using System.Environment;
using System.Privacy;
using System.Upgrade;

codeunit 9094 "UK Postcode Install"
{
    Subtype = install;

    trigger OnInstallAppPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        if AppInfo.DataVersion().Major() = 0 then
            SetAllUpgradeTags();

        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Postcode GetAddress.io Config");
    end;

    local procedure SetAllUpgradeTags()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        PostCodeGetAddressUpgrade: Codeunit "Postcode GetAddress.io Upgrade";
    begin
        if not UpgradeTag.HasUpgradeTag(PostCodeGetAddressUpgrade.GetUKPostcodeSecretsToISUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(PostCodeGetAddressUpgrade.GetUKPostcodeSecretsToISUpgradeTag());

        if not UpgradeTag.HasUpgradeTag(PostCodeGetAddressUpgrade.GetUKPostcodeSecretsToISValidationTag()) then
            UpgradeTag.SetUpgradeTag(PostCodeGetAddressUpgrade.GetUKPostcodeSecretsToISValidationTag());
    end;
}

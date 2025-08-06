// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Upgrade;

codeunit 27033 "Upgrade DIOT"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase()
    begin
    end;

    trigger OnUpgradePerCompany()
    begin
        UpdateDIOTConcepts();
        UpdateDIOTCountryData();
    end;

    local procedure UpdateDIOTConcepts()
    var
        DIOTConcept: Record "DIOT Concept";
        DIOTConceptLink: Record "DIOT Concept Link";
        DIOTDataMgt: Codeunit "DIOT Data Management";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetDIOTConceptsUpgradeTag()) then
            exit;

        DIOTConceptLink.DeleteAll();
        DIOTConcept.DeleteAll();
        DIOTDataMgt.InsertDefaultDIOTConcepts();

        UpgradeTag.SetUpgradeTag(GetDIOTConceptsUpgradeTag());
    end;

    local procedure UpdateDIOTCountryData()
    var
        DIOTCountryData: Record "DIOT Country/Region Data";
        DIOTInitialize: Codeunit "DIOT - Initialize";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetDIOTCountryUpgradeTag()) then
            exit;

        DIOTCountryData.DeleteAll();
        DIOTInitialize.InsertDefaultDIOTCountryData();

        UpgradeTag.SetUpgradeTag(GetDIOTCountryUpgradeTag());
    end;

    local procedure GetDIOTConceptsUpgradeTag(): Code[250]
    begin
        exit('MS-566061-DIOTConceptsUpgradeTag-20250528');
    end;

    local procedure GetDIOTCountryUpgradeTag(): Code[250]
    begin
        exit('MS-566061-DIOTCountryUpgradeTag-20250528');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetDIOTConceptsUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDIOTCountryUpgradeTag());
    end;
}
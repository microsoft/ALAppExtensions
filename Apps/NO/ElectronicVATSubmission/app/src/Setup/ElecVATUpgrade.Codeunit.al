// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Upgrade;

codeunit 10691 "Elec. VAT Upgrade"
{
    Subtype = Upgrade;

    var
        LoginURLTxt: Label 'https://login.idporten.no', Locked = true;
        AuthenticationURLTxt: Label 'https://idporten.no', Locked = true;

    trigger OnUpgradePerCompany()
    begin
        UpgradeReportVATNoteInVATReportSetup();
        UpgradeElecVATSetupWith2024Endpoints();
    end;

    local procedure UpgradeReportVATNoteInVATReportSetup()
    var
        VATReportSetup: Record "VAT Report Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetReportVATNoteInVATReportSetupTag()) then
            exit;

        if not VATReportSetup.Get() then
            exit;

        VATReportSetup.Validate("Report VAT Note", true);
        VATReportSetup.Modify(true);

        UpgradeTag.SetUpgradeTag(GetReportVATNoteInVATReportSetupTag());
    end;

    local procedure UpgradeElecVATSetupWith2024Endpoints()
    var
        ElecVATSetup: Record "Elec. VAT Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetUpgradeElecVATSetupWith2024EndpointsSetupTag()) then
            exit;

        if not ElecVATSetup.Get() then
            exit;

        ElecVATSetup.Validate("Authentication URL", AuthenticationURLTxt);
        ElecVATSetup.Validate("Login URL", LoginURLTxt);
        if ElecVATSetup.Modify(true) then;

        UpgradeTag.SetUpgradeTag(GetUpgradeElecVATSetupWith2024EndpointsSetupTag());
    end;

    local procedure GetReportVATNoteInVATReportSetupTag(): Code[250];
    begin
        exit('MS-433237-ReportVATNoteInVATReportSetupTag-20220418');
    end;

    local procedure GetUpgradeElecVATSetupWith2024EndpointsSetupTag(): Code[250];
    begin
        exit('MS-498271-ElecVATSetupWith2024EndpointsSetupTag-20240219');
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetReportVATNoteInVATReportSetupTag());
        PerCompanyUpgradeTags.Add(GetUpgradeElecVATSetupWith2024EndpointsSetupTag());
    end;

}

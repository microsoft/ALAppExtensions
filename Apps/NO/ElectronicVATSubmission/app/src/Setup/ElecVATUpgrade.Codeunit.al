// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Upgrade;

codeunit 10691 "Elec. VAT Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeReportVATNoteInVATReportSetup();
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

    local procedure GetReportVATNoteInVATReportSetupTag(): Code[250];
    begin
        exit('MS-433237-ReportVATNoteInVATReportSetupTag-20220418');
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetReportVATNoteInVATReportSetupTag());
    end;

}

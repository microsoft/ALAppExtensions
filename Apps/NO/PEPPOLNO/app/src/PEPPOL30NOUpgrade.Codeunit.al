// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol;

using System.Upgrade;

codeunit 37353 "PEPPOL30 NO Upgrade"
{
    Subtype = Upgrade;
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    trigger OnUpgradePerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        PEPPOL30NOInstall: Codeunit "PEPPOL30 NO Install";
    begin
        if not UpgradeTag.HasUpgradeTag(InitialUpgradeTag()) then begin
            PEPPOL30NOInstall.CreateElectronicDocumentFormats();
            UpgradeTag.SetUpgradeTag(InitialUpgradeTag());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerCompanyUpgradeTags, '', false, false)]
    local procedure OnGetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(InitialUpgradeTag());
    end;

    local procedure InitialUpgradeTag(): Text[250]
    begin
        exit('MS-260217-PEPPOLNO-APP-INSTALL');
    end;

}

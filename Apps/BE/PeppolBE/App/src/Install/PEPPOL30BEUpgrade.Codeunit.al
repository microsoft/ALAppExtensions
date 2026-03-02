// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol.BE;

using System.Upgrade;

codeunit 37313 "PEPPOL30 BE Upgrade"
{
    Subtype = Upgrade;
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    trigger OnUpgradePerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        PEPPOL30BEInitialize: Codeunit "PEPPOL30 BE Initialize";
    begin
        if UpgradeTag.HasUpgradeTag(InitialUpgradeTag()) then
            exit;

        PEPPOL30BEInitialize.CreateElectronicDocumentFormats();
        UpgradeTag.SetUpgradeTag(InitialUpgradeTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerCompanyUpgradeTags, '', false, false)]
    local procedure OnGetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(InitialUpgradeTag());
    end;

    local procedure InitialUpgradeTag(): Text[250]
    begin
        exit('MS-260126-PEPPOLBE-APP-INSTALL');
    end;
}

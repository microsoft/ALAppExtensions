// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

using System.Upgrade;

#pragma warning disable AS0130
#pragma warning disable PTE0025
codeunit 6435 "Logiq Upgrade"
#pragma warning restore AS0130
#pragma warning restore PTE0025
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var

    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(UpgradeServiceIntegrationTag());
    end;

    local procedure UpgradeServiceIntegrationTag(): Code[250]
    begin
        exit('MS-499158-UpdateServiceIntegrationLogiq-20250129');
    end;


}
#if CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using System.Upgrade;

codeunit 10555 "UK Postcode Upg Tag"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetUKPostcodeUpgradeTag());
    end;

    internal procedure GetUKPostcodeUpgradeTag(): Code[250]
    begin
        exit('MS-604125-UKPostcodeGetAddressIOUpgradeTag-20251008');
    end;
}
#endif
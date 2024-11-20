// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using System.Upgrade;

codeunit 9093 "Postcode GetAddress.io Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany();
    begin
        UpdateApiEndPoint();
    end;

    local procedure UpdateApiEndPoint()
    var
        PostcodeConfig: Record "Postcode GetAddress.io Config";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeEndPointTxt: Label 'https://api.getAddress.io/find/', Locked = True;
        OldEndPointTxt: Label 'https://api.getaddress.io/v2/uk/', Locked = true;
    begin
        if UpgradeTag.HasUpgradeTag(GetUKPostcodeNewEndPointTag()) then
            exit;

        if PostcodeConfig.Get() then
            if PostcodeConfig.EndpointURL = OldEndPointTxt then begin
                PostcodeConfig.EndpointURL := UpgradeEndPointTxt;
                PostcodeConfig.Modify();
            end;
        UpgradeTag.SetUpgradeTag(GetUKPostcodeNewEndPointTag());
    end;

    internal procedure GetUKPostcodeNewEndPointTag(): Code[250]
    begin
        exit('MS-435041-UKPostCodeNewAPIEndPoint-202200505');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetUKPostcodeNewEndPointTag());
    end;
}


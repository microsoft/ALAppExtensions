// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using System.Upgrade;

codeunit 9093 "Postcode GetAddress.io Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase();
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        // Restoring data from V1 extension tables. This upgrade will only run for version 1
        if AppInfo.DataVersion().Major() = 1 then
            NAVAPP.LOADPACKAGEDATA(DATABASE::"Postcode GetAddress.io Config");
    end;

    trigger OnUpgradePerCompany();
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        // Restoring data from V1 extension tables. This upgrade will only run for version 1
        if AppInfo.DataVersion().Major() = 1 then
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Postcode GetAddress.io Config");
        UpgradeSecretsToIsolatedStorage();
        UpdateApiEndPoint();
    end;

    trigger OnValidateUpgradePerCompany()
    begin
        VerifySecretsUpgradeToIsolatedStorage();
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

    local procedure UpgradeSecretsToIsolatedStorage()
    var
        ServicePassword: Record "Service Password";
        PostcodeSetup: Record "Postcode GetAddress.io Config";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetUKPostcodeSecretsToISUpgradeTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(GetUKPostcodeSecretsToISUpgradeTag()) then
            exit;

        if PostcodeSetup.Get() then
            if ServicePassword.Get(PostcodeSetup.APIKey) then
                if EncryptionEnabled() then
                    IsolatedStorage.SetEncrypted(PostcodeSetup.APIKey, ServicePassword.GetPassword(), DataScope::Company)
                else
                    IsolatedStorage.Set(PostcodeSetup.APIKey, ServicePassword.GetPassword(), DataScope::Company);

        UpgradeTag.SetUpgradeTag(GetUKPostcodeSecretsToISUpgradeTag());
    end;

    local procedure VerifySecretsUpgradeToIsolatedStorage()
    var
        ServicePassword: Record "Service Password";
        PostcodeSetup: Record "Postcode GetAddress.io Config";
        UpgradeTag: Codeunit "Upgrade Tag";
        IsolatedStorageValue: Text;
        ServicePasswordValue: Text;
    begin
        if UpgradeTag.HasUpgradeTag(GetUKPostcodeSecretsToISValidationTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(GetUKPostcodeSecretsToISValidationTag()) then
            exit;

        if PostcodeSetup.Get() then
            if ServicePassword.Get(PostcodeSetup.APIKey) then begin
                if not IsolatedStorage.Get(PostcodeSetup.APIKey, DataScope::Company, IsolatedStorageValue) then
                    Error('Could not retrieve the secret from isolated storage after the Upgrade for key "%1"', PostcodeSetup.APIKey);
                ServicePasswordValue := ServicePassword.GetPassword();
                if IsolatedStorageValue <> ServicePasswordValue then
                    Error('The secret value for key "%1" in isolated storage does not match the one in service password.', PostcodeSetup.APIKey);
            end;

        UpgradeTag.SetUpgradeTag(GetUKPostcodeSecretsToISValidationTag());
    end;

    internal procedure GetUKPostcodeSecretsToISUpgradeTag(): Code[250]
    begin
        exit('MS-328257-UKPostcodeSecretsToIS-20190925');
    end;

    internal procedure GetUKPostcodeSecretsToISValidationTag(): Code[250]
    begin
        exit('MS-328257-UKPostcodeSecretsToIS-Validate-20190925');
    end;

    internal procedure GetUKPostcodeNewEndPointTag(): Code[250]
    begin
        exit('MS-435041-UKPostCodeNewAPIEndPoint-202200505');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetUKPostcodeSecretsToISUpgradeTag());
        PerCompanyUpgradeTags.Add(GetUKPostcodeSecretsToISValidationTag());
        PerCompanyUpgradeTags.Add(GetUKPostcodeNewEndPointTag());
    end;
}


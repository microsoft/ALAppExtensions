// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
        if (AppInfo.DataVersion().Major() < 2) or ((AppInfo.DataVersion().Major() = 2) and (AppInfo.DataVersion().Minor() = 0)) then
            UpgradeSecretsToIsolatedStorage();
    end;

    trigger OnValidateUpgradePerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if (AppInfo.DataVersion().Major() < 2) or ((AppInfo.DataVersion().Major() = 2) and (AppInfo.DataVersion().Minor() = 0)) then
            VerifySecretsUpgradeToIsolatedStorage();
    end;

    local procedure UpgradeSecretsToIsolatedStorage()
    var
        ServicePassword: Record "Service Password";
        PostcodeSetup: Record "Postcode GetAddress.io Config";
    begin
        if PostcodeSetup.Get() then
            if ServicePassword.Get(PostcodeSetup.APIKey) then
                if EncryptionEnabled() then
                    IsolatedStorage.SetEncrypted(PostcodeSetup.APIKey, ServicePassword.GetPassword(), DataScope::Company)
                else
                    IsolatedStorage.Set(PostcodeSetup.APIKey, ServicePassword.GetPassword(), DataScope::Company);
    end;

    local procedure VerifySecretsUpgradeToIsolatedStorage()
    var
        ServicePassword: Record "Service Password";
        PostcodeSetup: Record "Postcode GetAddress.io Config";
        IsolatedStorageValue: Text;
        ServicePasswordValue: Text;
    begin
        if PostcodeSetup.Get() then
            if ServicePassword.Get(PostcodeSetup.APIKey) then begin
                if not IsolatedStorage.Get(PostcodeSetup.APIKey, IsolatedStorageValue) then
                    Error('Could not retrieve the secret from isolated storage after the Upgrade for key "%1"', PostcodeSetup.APIKey);
                ServicePasswordValue := ServicePassword.GetPassword();
                if IsolatedStorageValue <> ServicePasswordValue then
                    Error('The secret value for key "%1" in isolated storage does not match the one in service password.', PostcodeSetup.APIKey);
            end;
    end;
}


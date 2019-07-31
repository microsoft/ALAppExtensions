// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1851 "Sales Forecast Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        ModuleInfo: ModuleInfo;
    begin
        if NavApp.GetCurrentModuleInfo(ModuleInfo) then begin
            if ModuleInfo.DataVersion().Major() = 1 then begin
                // we are upgrading from version 1.?.?.? to version 2.?.?.?
                NavApp.RestoreArchiveData(Database::"MS - Sales Forecast");
                NavApp.RestoreArchiveData(Database::"MS - Sales Forecast Parameter");
                NavApp.RestoreArchiveData(Database::"MS - Sales Forecast Setup");
                // The "Has Sales Forecast" field on the item table is populated through triggers on request and does never persist any data.
                NavApp.DeleteArchiveData(Database::Item);
            end;
            if (ModuleInfo.DataVersion().Major() < 2) or ((ModuleInfo.DataVersion().Major() = 2) and (ModuleInfo.DataVersion().Minor() = 0)) then
                UpgradeSecretsToIsolatedStorage();
        end;

        DeleteCachedAPIKeysAndURIValues();
    end;

    trigger OnValidateUpgradePerCompany()
    var
        ModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        if (ModuleInfo.DataVersion().Major() < 2) or ((ModuleInfo.DataVersion().Major() = 2) and (ModuleInfo.DataVersion().Minor() = 0)) then
            VerifySecretsUpgradeToIsolatedStorage();
    end;

    local procedure DeleteCachedAPIKeysAndURIValues();
    var
        ServicePassword: Record "Service Password";
        SalesForecastSetup: Record "MS - Sales Forecast Setup";
        NullGuid: Guid;
    begin
        SalesForecastSetup.GetSingleInstance();
        if not IsNullGuid(SalesForecastSetup."Service Pass API Key ID") then
            if ServicePassword.Get(SalesForecastSetup."Service Pass API Key ID") then begin
                ServicePassword.Delete();
                SalesForecastSetup."Service Pass API Key ID" := NullGuid;
                SalesForecastSetup.Modify();
            end;

        if not IsNullGuid(SalesForecastSetup."Service Pass API Uri ID") then
            if ServicePassword.Get(SalesForecastSetup."Service Pass API Uri ID") then begin
                ServicePassword.Delete();
                SalesForecastSetup."Service Pass API Uri ID" := NullGuid;
                SalesForecastSetup.Modify();
            end;
    end;

    local procedure UpgradeSecretsToIsolatedStorage()
    var
        ServicePassword: Record "Service Password";
        SalesForecastSetup: Record "MS - Sales Forecast Setup";
    begin
        if SalesForecastSetup.Get() then
            if ServicePassword.Get(SalesForecastSetup."API Key ID") then
                if EncryptionEnabled() then
                    IsolatedStorage.SetEncrypted(SalesForecastSetup."API Key ID", ServicePassword.GetPassword(), DataScope::Company)
                else
                    IsolatedStorage.Set(SalesForecastSetup."API Key ID", ServicePassword.GetPassword(), DataScope::Company);
    end;

    local procedure VerifySecretsUpgradeToIsolatedStorage()
    var
        ServicePassword: Record "Service Password";
        SalesForecastSetup: Record "MS - Sales Forecast Setup";
        IsolatedStorageValue: Text;
        ServicePasswordValue: Text;
    begin
        if SalesForecastSetup.Get() then
            if ServicePassword.Get(SalesForecastSetup."API Key ID") then begin
                if not IsolatedStorage.Get(SalesForecastSetup."API Key ID", IsolatedStorageValue) then
                    Error('Could not retrieve the secret from isolated storage after the Upgrade for key "%1"', SalesForecastSetup."API Key ID");
                ServicePasswordValue := ServicePassword.GetPassword();
                if IsolatedStorageValue <> ServicePasswordValue then
                    Error('The secret value for key "%1" in isolated storage does not match the one in service password.', SalesForecastSetup."API Key ID");
            end;
    end;
}


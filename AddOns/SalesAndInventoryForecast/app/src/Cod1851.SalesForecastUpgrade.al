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
            UpgradeSecretsToIsolatedStorage();
        end;

    end;

    trigger OnValidateUpgradePerCompany()
    begin
        VerifySecretsUpgradeToIsolatedStorage();
    end;

    local procedure UpgradeSecretsToIsolatedStorage()
    var
        ServicePassword: Record "Service Password";
        SalesForecastSetup: Record "MS - Sales Forecast Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetSalesForecastSecretsToISUpgradeTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(GetSalesForecastSecretsToISUpgradeTag()) then
            exit;

        if SalesForecastSetup.Get() then
            if ServicePassword.Get(SalesForecastSetup."API Key ID") then
                if EncryptionEnabled() then
                    IsolatedStorage.SetEncrypted(SalesForecastSetup."API Key ID", ServicePassword.GetPassword(), DataScope::Company)
                else
                    IsolatedStorage.Set(SalesForecastSetup."API Key ID", ServicePassword.GetPassword(), DataScope::Company);

        UpgradeTag.SetUpgradeTag(GetSalesForecastSecretsToISUpgradeTag());
    end;

    local procedure VerifySecretsUpgradeToIsolatedStorage()
    var
        ServicePassword: Record "Service Password";
        SalesForecastSetup: Record "MS - Sales Forecast Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        IsolatedStorageValue: Text;
        ServicePasswordValue: Text;
    begin
        if UpgradeTag.HasUpgradeTag(GetSalesForecastSecretsToISValidationTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(GetSalesForecastSecretsToISValidationTag()) then
            exit;

        if SalesForecastSetup.Get() then
            if ServicePassword.Get(SalesForecastSetup."API Key ID") then begin
                if not IsolatedStorage.Get(SalesForecastSetup."API Key ID", DataScope::Company, IsolatedStorageValue) then
                    Error('Could not retrieve the secret from isolated storage after the Upgrade for key "%1"', SalesForecastSetup."API Key ID");
                ServicePasswordValue := ServicePassword.GetPassword();
                if IsolatedStorageValue <> ServicePasswordValue then
                    Error('The secret value for key "%1" in isolated storage does not match the one in service password.', SalesForecastSetup."API Key ID");
            end;

        UpgradeTag.SetUpgradeTag(GetSalesForecastSecretsToISValidationTag());
    end;

    internal procedure GetSalesForecastSecretsToISUpgradeTag(): Code[250]
    begin
        exit('MS-328257-SalesForecastSecretsToIS-20190925');
    end;

    internal procedure GetSalesForecastSecretsToISValidationTag(): Code[250]
    begin
        exit('MS-328257-SalesForecastSecretsToIS-Validate-20190925');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetSalesForecastSecretsToISUpgradeTag());
        PerCompanyUpgradeTags.Add(GetSalesForecastSecretsToISValidationTag());
    end;
}


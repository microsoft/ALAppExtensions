codeunit 2430 "Xs Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeSecretsToIsolatedStorage();
    end;

    trigger OnValidateUpgradePerCompany()
    begin
        VerifySecretsUpgradeToIsolatedStorage();
    end;

    local procedure UpgradeSecretsToIsolatedStorage()
    var
        SyncSetup: Record "Sync Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetXSSecretsToISUpgradeTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(GetXSSecretsToISUpgradeTag()) then
            exit;

        if not SyncSetup.Get() then
            exit;
        if SyncSetup."XS Xero Access Key" = '' then
            exit;
        if SyncSetup."XS Xero Access Secret" = '' then
            exit;

        if EncryptionEnabled() then begin
            IsolatedStorage.SetEncrypted('XS Xero Access Key', SyncSetup."XS Xero Access Key", DataScope::Company);
            IsolatedStorage.SetEncrypted('XS Xero Access Secret', SyncSetup."XS Xero Access Secret", DataScope::Company);
        end else begin
            IsolatedStorage.Set('XS Xero Access Key', SyncSetup."XS Xero Access Key", DataScope::Company);
            IsolatedStorage.Set('XS Xero Access Secret', SyncSetup."XS Xero Access Secret", DataScope::Company);
        end;

        UpgradeTag.SetUpgradeTag(GetXSSecretsToISUpgradeTag());
    end;

    local procedure VerifySecretsUpgradeToIsolatedStorage()
    var
        SyncSetup: Record "Sync Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        IsolatedStorageKeyValue: Text;
        IsolatedStorageSecretValue: Text;
    begin
        if UpgradeTag.HasUpgradeTag(GetXSSecretsToISValidationTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(GetXSSecretsToISValidationTag()) then
            exit;

        if not SyncSetup.Get() then
            exit;
        if SyncSetup."XS Xero Access Key" = '' then
            exit;
        if SyncSetup."XS Xero Access Secret" = '' then
            exit;
        if not IsolatedStorage.Get('XS Xero Access Key', DataScope::Company, IsolatedStorageKeyValue) then
            Error('Could not retrieve the secret from isolated storage after the Upgrade for key "%1"', 'XS Xero Access Key');
        if not IsolatedStorage.Get('XS Xero Access Secret', DataScope::Company, IsolatedStorageSecretValue) then
            Error('Could not retrieve the secret from isolated storage after the Upgrade for key "%1"', 'XS Xero Access Secret');

        if IsolatedStorageKeyValue <> SyncSetup."XS Xero Access Key" then
            Error('The secret value for key "%1" in isolated storage does not match the one in the Xs Sync Setup.', 'XS Xero Access Key');
        if IsolatedStorageSecretValue <> SyncSetup."XS Xero Access Secret" then
            Error('The secret value for key "%1" in isolated storage does not match the one in the Xs Sync Setup.', 'XS Xero Access Secret');

        UpgradeTag.SetUpgradeTag(GetXSSecretsToISValidationTag());
    end;

    internal procedure GetXSSecretsToISUpgradeTag(): Code[250]
    begin
        exit('MS-328257-XSSecretsToIS-20190925');
    end;

    internal procedure GetXSSecretsToISValidationTag(): Code[250]
    begin
        exit('MS-328257-XSSecretsToIS-Validate-20190925');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetXSSecretsToISUpgradeTag());
        PerCompanyUpgradeTags.Add(GetXSSecretsToISValidationTag());
    end;
}
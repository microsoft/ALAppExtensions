codeunit 1452 "MS - Yodlee Service Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase();
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        IF AppInfo.DataVersion().Major() = 1 THEN
            NAVAPP.LOADPACKAGEDATA(DATABASE::"MS - Yodlee Data Exchange Def");
    end;

    trigger OnUpgradePerCompany();
    var
        MSYodleeBankSessionRecordRef: RecordRef;
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        IF AppInfo.DataVersion().Major() = 1 THEN BEGIN
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"MS - Yodlee Bank Service Setup");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"MS - Yodlee Bank Acc. Link");
            IF NAVAPP.GETARCHIVERECORDREF(DATABASE::"MS - Yodlee Bank Session", MSYodleeBankSessionRecordRef) THEN
                NAVAPP.RESTOREARCHIVEDATA(DATABASE::"MS - Yodlee Bank Session")
            ELSE
                NAVAPP.LOADPACKAGEDATA(DATABASE::"MS - Yodlee Bank Session");
        END;
        CleanupYodleeBankAccountLink();
        UpdateDataExchangeDefinition();
        UpdateYodleeBankSession();

        UpgradeSecretsToIsolatedStorage();
    end;

    trigger OnValidateUpgradePerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        VerifySecretsUpgradeToIsolatedStorage();
    end;

    procedure UpdateDataExchangeDefinition();
    var
        MSYodleeDataExchangeDef: Record 1452;
        MSYodleeBankServiceSetup: Record 1450;
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetYodleeUpdateDataExchangeDefinitionTag()) then
            exit;

        MSYodleeDataExchangeDef.ResetDataExchToDefault();

        IF MSYodleeBankServiceSetup.GET() THEN
            IF MSYodleeBankServiceSetup."Bank Feed Import Format" = '' THEN
                MSYodleeDataExchangeDef.UpdateMSYodleeBankServiceSetupBankStmtImportFormat();

        UpgradeTag.SetUpgradeTag(GetYodleeUpdateDataExchangeDefinitionTag());
    end;

    local procedure CleanupYodleeBankAccountLink();
    var
        MSYodleeBankAccLink: Record 1451;
        BankAccount: Record 270;
    begin
        IF MSYodleeBankAccLink.FIND('-') THEN
            REPEAT
                IF NOT BankAccount.GET(MSYodleeBankAccLink."No.") THEN
                    MSYodleeBankAccLink.DELETE()
                ELSE
                    IF (BankAccount."Currency Code" <> '') AND (MSYodleeBankAccLink."Currency Code" <> '') AND (BankAccount."Currency Code" <> MSYodleeBankAccLink."Currency Code") THEN
                        MSYodleeBankAccLink.DELETE();
            UNTIL MSYodleeBankAccLink.NEXT() = 0;
    end;

    procedure UpdateYodleeBankSession();
    var
        MSYodleeBankServiceSetup: Record 1450;
        MSYodleeBankSession: Record 1453;
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetYodleeUpdateBankSessionTableTag()) then
            exit;

        IF MSYodleeBankSession.GET() THEN
            EXIT;

        IF NOT MSYodleeBankServiceSetup.GET() THEN
            EXIT;

        MSYodleeBankSession.INIT();
        MSYodleeBankSession.TRANSFERFIELDS(MSYodleeBankServiceSetup);
        MSYodleeBankSession.INSERT();

        UpgradeTag.SetUpgradeTag(GetYodleeUpdateBankSessionTableTag());
    end;

    local procedure UpgradeSecretsToIsolatedStorage()
    var
        YodleeServiceSetup: Record "MS - Yodlee Bank Service Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetYodleeSecretsToISUpgradeTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(GetYodleeSecretsToISUpgradeTag()) then
            exit;

        if YodleeServiceSetup.Get() then begin
            MoveSPSecretToIsolatedStorage(YodleeServiceSetup."Consumer Password");
            MoveSPSecretToIsolatedStorage(YodleeServiceSetup."Cobrand Name");
            MoveSPSecretToIsolatedStorage(YodleeServiceSetup."Cobrand Password");
            MoveENKVSecretToIsolatedStorage('YODLEE_SERVICEURL');
            MoveENKVSecretToIsolatedStorage('YODLEE_FASTLINKURL');
            MoveENKVSecretToIsolatedStorage('YODLEE_USERNAME');
            MoveENKVSecretToIsolatedStorage('YODLEE_PASSWORD');
        end;

        UpgradeTag.SetUpgradeTag(GetYodleeSecretsToISUpgradeTag());
    end;

    local procedure VerifySecretsUpgradeToIsolatedStorage()
    var
        YodleeServiceSetup: Record "MS - Yodlee Bank Service Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetYodleeSecretsToISValidationTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(GetYodleeSecretsToISValidationTag()) then
            exit;

        if YodleeServiceSetup.Get() then begin
            VerifySPSecret(YodleeServiceSetup."Consumer Password");
            VerifySPSecret(YodleeServiceSetup."Cobrand Name");
            VerifySPSecret(YodleeServiceSetup."Cobrand Password");
            VerifyENKSecret('YODLEE_SERVICEURL');
            VerifyENKSecret('YODLEE_FASTLINKURL');
            VerifyENKSecret('YODLEE_USERNAME');
            VerifyENKSecret('YODLEE_PASSWORD');
        end;

        UpgradeTag.SetUpgradeTag(GetYodleeSecretsToISValidationTag());
    end;

    local procedure MoveSPSecretToIsolatedStorage(ServicePasswordKey: Text[200])
    var
        ServicePassword: Record "Service Password";
    begin
        if ServicePassword.Get(ServicePasswordKey) then
            if EncryptionEnabled() then
                IsolatedStorage.SetEncrypted(ServicePasswordKey, ServicePassword.GetPassword(), DataScope::Company)
            else
                IsolatedStorage.Set(ServicePasswordKey, ServicePassword.GetPassword(), DataScope::Company);
    end;

    local procedure MoveENKVSecretToIsolatedStorage(EncryptedKeyValueKey: Text[200])
    var
        EncryptedKeyValue: Record "Encrypted Key/Value";
    begin
        if EncryptedKeyValue.Get(EncryptedKeyValueKey) then
            if EncryptionEnabled() then
                IsolatedStorage.SetEncrypted(EncryptedKeyValueKey, EncryptedKeyValue.GetValue(), DataScope::Company)
            else
                IsolatedStorage.Set(EncryptedKeyValueKey, EncryptedKeyValue.GetValue(), DataScope::Company);
    end;

    local procedure VerifySPSecret(ServicePasswordKey: Text[200])
    var
        ServicePassword: Record "Service Password";
        IsolatedStorageValue: Text;
        ServicePasswordValue: Text;
    begin
        if ServicePassword.Get(ServicePasswordKey) then begin
            if not IsolatedStorage.Get(ServicePasswordKey, DataScope::Company, IsolatedStorageValue) then
                Error('Could not retrieve the secret from isolated storage after the Upgrade for key "%1"', ServicePasswordKey);
            ServicePasswordValue := ServicePassword.GetPassword();
            if IsolatedStorageValue <> ServicePasswordValue then
                Error('The secret value for key "%1" in isolated storage does not match the one in service password.', ServicePasswordKey);
        end;
    end;

    local procedure VerifyENKSecret(EncryptedKeyValueKey: Text[200])
    var
        EncryptedKeyValue: Record "Encrypted Key/Value";
        IsolatedStorageValue: Text;
        EncryptedValue: Text;
    begin
        if EncryptedKeyValue.Get(EncryptedKeyValueKey) then begin
            if not IsolatedStorage.Get(EncryptedKeyValueKey, DataScope::Company, IsolatedStorageValue) then
                Error('Could not retrieve the secret from isolated storage after the Upgrade for key "%1"', EncryptedKeyValueKey);
            EncryptedValue := EncryptedKeyValue.GetValue();
            if IsolatedStorageValue <> EncryptedValue then
                Error('The secret value for key "%1" in isolated storage does not match the one in encrypted key value.', EncryptedKeyValueKey);
        end;
    end;

    internal procedure GetYodleeSecretsToISUpgradeTag(): Code[250]
    begin
        exit('MS-328257-YodleeSecretsToIS-20190925');
    end;

    internal procedure GetYodleeSecretsToISValidationTag(): Code[250]
    begin
        exit('MS-328257-YodleeSecretsToIS-Validate-20190925');
    end;

    internal procedure GetYodleeUpdateBankSessionTableTag(): Code[250]
    begin
        exit('YodleeUpdateBankSession-20200221');
    end;

    internal procedure GetYodleeUpdateDataExchangeDefinitionTag(): Code[250]
    begin
        exit('YodleeUpdateDataExchangeDefinition-20200221');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyags(var PerCompanyUpgradeTags: List of [Code[250]])
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(GetYodleeSecretsToISUpgradeTag()) then
            PerCompanyUpgradeTags.Add(GetYodleeSecretsToISUpgradeTag());

        if not UpgradeTag.HasUpgradeTag(GetYodleeSecretsToISValidationTag()) then
            PerCompanyUpgradeTags.Add(GetYodleeSecretsToISValidationTag());

        if not UpgradeTag.HasUpgradeTag(GetYodleeUpdateBankSessionTableTag()) then
            PerCompanyUpgradeTags.Add(GetYodleeUpdateBankSessionTableTag());

        if not UpgradeTag.HasUpgradeTag(GetYodleeUpdateDataExchangeDefinitionTag()) then
            PerCompanyUpgradeTags.Add(GetYodleeUpdateDataExchangeDefinitionTag());
    end;
}

